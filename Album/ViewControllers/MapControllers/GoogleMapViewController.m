//
//  GoogleMapViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/6/22.
//

#import "GoogleMapViewController.h"
#import "ColorConvertHelper.h"
#import "LocationGenerator.h"
#import "ComposeViewController.h"
#import "DetailsViewCOntroller.h"
#import "Friendship.h"
#import "ParseAPIHelper.h"
#import "InfoPOIView.h"
#import "InfoMarkerView.h"
#import "AlbumConstants.h"
#import "Image.h"
#import "Parse/Parse.h"
#import <Parse/PFImageView.h>
#import "Pin.h"
@import GooglePlaces;

@interface GoogleMapViewController ()<GMSMapViewDelegate, GMSIndoorDisplayDelegate, CLLocationManagerDelegate,
ComposeViewControllerDelegate, GMSAutocompleteViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *markerArr;
@property (nonatomic, strong) NSMutableDictionary *placeToPins;
@property (nonatomic, strong) NSMutableDictionary *pinImages;
@property (nonatomic, strong) NSMutableDictionary *pinIdToUsername;
@property (nonatomic, strong) ParseAPIHelper *apiHelper;
@property (nonatomic, strong) NSMutableSet *friendsIdSet; // User IDs of current user's friends
@property (nonatomic, weak) PFUser *currentUser;
@property (nonatomic, strong) ColorConvertHelper *colorHelper;
@property (nonatomic, strong) GMSAutocompleteFilter *filter;
@property (nonatomic) int radius;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation GoogleMapViewController

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    [self setLocationManager];
    // Set the intiial map view position
    CLLocation *curPos = self.locationManager.location;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:curPos.coordinate.latitude
                                                            longitude:curPos.coordinate.longitude
                                                                 zoom:12];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = self.mapView;
    self.mapView.myLocationEnabled = true;
    self.mapView.delegate = self;
}

- (void)setLocationManager {
    // Initialize the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
    // Ask for location permission
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.radius = 5000;
    self.colorHelper = [[ColorConvertHelper alloc] init];
    
    // Set user
    self.currentUser = [PFUser currentUser];
    // Initialize data structures to cache retrieved data
    self.placeToPins = [[NSMutableDictionary alloc] init];
    self.pinImages = [[NSMutableDictionary alloc] init];
    self.friendsIdSet = [[NSMutableSet alloc] init];
    self.pinIdToUsername = [[NSMutableDictionary alloc] init];
    
    // Add animation when change segmentedControl
    [self.segmentedControl addTarget:self action:@selector(animate) forControlEvents:UIControlEventValueChanged];
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(_mapView.camera.target.latitude,
                                                                  _mapView.camera.target.longitude);
    self.coordinate = self.locationManager.location.coordinate;
    [self setButton];
    [self setMarkerCircle:mapCenter];
    [self fetchMarkers];
} /* viewDidLoad */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setButton];
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(_mapView.camera.target.latitude,
                                                                  _mapView.camera.target.longitude);
    [self setMarkerCircle:mapCenter];
    [self fetchMarkers];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        GMSCameraUpdate *locationCam = [GMSCameraUpdate setTarget:manager.location.coordinate zoom:12];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.coordinate = manager.location.coordinate;
            [self.mapView animateWithCameraUpdate:locationCam];
            [self.mapView clear];
            [self setMarkerCircle:manager.location.coordinate];
            [self fetchMarkers];
        });
    }
}


#pragma mark - UIView

- (void)setMarkerCircle:(CLLocationCoordinate2D)mapCenter {
    GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
    marker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:self.currentUser[@"colorHexString"]]];
    marker.map = self.mapView;
    self.circ = [GMSCircle circleWithPosition:marker.position radius:self.radius];
    self.circ.fillColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:0.5];
    self.circ.map = self.mapView;
}
- (void)setButton {
    // Set button: 3 radius limiting options
    NSArray *radiusOptions =
    [NSArray arrayWithObjects:[self createRadiusAction:1000], [self createRadiusAction:5000], [self createRadiusAction:10000], nil];
    UIMenu *menu = [UIMenu menuWithTitle:@"Options" children:radiusOptions];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" menu:menu];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage systemImageNamed:@"mappin.and.ellipse"]];
} /* setButton */

- (UIAction *)createRadiusAction:(int)radius {
    return [UIAction actionWithTitle:[NSString stringWithFormat:@"%d m",
                                      radius] image:nil identifier:nil handler:^(__kindof UIAction *_Nonnull action) {
        dispatch_async(
                       dispatch_get_main_queue(), ^{
                           [self recenterView:radius];
                       });
    }];
}

// Recenter the view with a fixed radius
- (void)recenterView:(int)radius {
    self.radius = radius;
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(self.mapView.camera.target.latitude,
                                                                  self.mapView.camera.target.longitude);
    self.coordinate = mapCenter;
    [self.mapView clear];
    [self setMarkerCircle:mapCenter];
    [self fetchMarkers];
}
- (void)loadMarkers {
    // Place markers on initial map view
    for (Pin *pin in self.markerArr) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(pin.latitude, pin.longitude);
        PFUser *author = pin.author;
        PFUser *friend = [self fetchUser:author.objectId][0];
        marker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:friend[@"colorHexString"]]];
        marker.title = pin.placeName;
        marker.snippet = pin.placeID;
        marker.map = self.mapView;
    }
}

// Used for switch control animation
- (void)animate {
    [UIView animateWithDuration:2 animations:^{ self.view.alpha = 0.0; self.mapView.alpha = 0.0; }];
    [UIView animateWithDuration:2 animations:^{ self.view.alpha = 1; self.mapView.alpha = 1; }];
}

#pragma mark - IBAction

- (IBAction)switchControl:(id)sender {
    [self.mapView clear];
    [self recenterView:self.radius];
}

- (IBAction)searchPlaceButton:(id)sender {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    
    // Specify the place data types to return.
    GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldPlaceID | GMSPlaceFieldCoordinate);
    acController.placeFields = fields;
    
    // Specify a filter.
    self.filter = [[GMSAutocompleteFilter alloc] init];
    self.filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
    acController.autocompleteFilter = _filter;
    
    // Display the autocomplete view controller.
    [self presentViewController:acController animated:YES completion:nil];
}

#pragma mark - Parse API

- (void)fetchMarkers {
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    // Fetch current user's pins
    [self fetchPersonal];
    if (index == 1) {
        // Fetch friends pins
        [self fetchFriends];
    } else if (index == 2) {
        // Fetches pins of all public users
        [self fetchFriends];
        [self fetchGlobal];
    }
}

- (void)fetchPersonal {
    // Query to find markers that belong to current user
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    [query orderByDescending:(@"traveledOn")];
    [query whereKey:@"author" equalTo:self.currentUser];
    double earthR = 6378137;
    double dLat = (double)(self.radius) / earthR;
    double dLon = (double)(self.radius) / (earthR * cos(M_PI * self.coordinate.latitude / 180));
    [query whereKey:@"latitude" lessThanOrEqualTo:@(self.coordinate.latitude + dLat * 180 / M_PI)];
    [query whereKey:@"latitude" greaterThanOrEqualTo:@(self.coordinate.latitude - dLat * 180 / M_PI)];
    [query whereKey:@"longitude" lessThanOrEqualTo:@(self.coordinate.longitude + dLon * 180 / M_PI)];
    [query whereKey:@"longitude" greaterThanOrEqualTo:@(self.coordinate.longitude - dLon * 180 / M_PI)];
    [query includeKey:@"objectId"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        if (pins != nil) {
            // Store the posts, update count
            NSLog(@"Successfully fetched markers!");
            self.markerArr = (NSMutableArray *)pins;
            [self loadMarkers];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (NSArray *)fetchUser:(NSString *)userId {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:userId];
    return [userQuery findObjects];
}
- (void)fetchFriends {
    // Query to find markers that belong to current user and current user's friend
    PFQuery *friendQuery = [PFQuery queryWithClassName:classNameFriendship];
    [friendQuery whereKey:@"requesterId" equalTo:self.currentUser.objectId];
    [friendQuery whereKey:@"hasFriended" equalTo:@(2)];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
        if (friendships != nil) {
            // For each friend, find their pins
            for (Friendship *friendship in friendships) {
                NSString *friendId = friendship[@"recipientId"];
                PFUser *friend = [self fetchUser:friendId][0];
                [self.friendsIdSet addObject:friendId];
                PFQuery *query = [PFQuery queryWithClassName:classNamePin];
                [query whereKey:@"author"
                       equalTo:friend];
                [query orderByDescending:(@"traveledOn")];
                [query includeKey:@"objectId"];
                // [self.apiHelper constructQuery:query radius:self.radius coordinate:self.coordinate];
                [query findObjectsInBackgroundWithBlock :^(NSArray *pins, NSError *error) {
                    if (pins != nil) {
                        // Store the pins, update count
                        NSLog(
                              @"Successfully fetched pins!");
                        // Add pins to the marker array
                        for (PFObject *pin in pins) {
                            Pin *tempPin = (Pin *)pin;
                            if (!tempPin.isCloseFriendPin || friendship.isClose) {
                                [self.markerArr addObject:pin];
                                [self.pinIdToUsername setObject:friend.username forKey:pin.objectId];
                            }
                        }
                        // Reload markers
                        [self loadMarkers];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            }
        } else {
            NSLog(@"%@",
                  error.localizedDescription);
        }
    }];
} /* fetchFriends */


// Used to find all markers in database
- (void)fetchGlobal {
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    [query orderByDescending:(@"traveledOn")];
    [query includeKey:@"objectId"];
    double earthR = 6378137;
    double dLat = (double)(self.radius) / earthR;
    double dLon = (double)(self.radius) / (earthR * cos(M_PI * self.coordinate.latitude / 180));
    [query whereKey:@"latitude" lessThanOrEqualTo:@(self.coordinate.latitude + dLat * 180 / M_PI)];
    [query whereKey:@"latitude" greaterThanOrEqualTo:@(self.coordinate.latitude - dLat * 180 / M_PI)];
    [query whereKey:@"longitude" lessThanOrEqualTo:@(self.coordinate.longitude + dLon * 180 / M_PI)];
    [query whereKey:@"longitude" greaterThanOrEqualTo:@(self.coordinate.longitude - dLon * 180 / M_PI)];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        if (pins != nil) {
            // Store the posts, update count
            NSLog(@"Successfully fetched markers!");
            self.markerArr = [[NSMutableArray alloc] init];
            for (PFObject *pin in pins) {
                PFUser *author = pin[@"author"];
                PFUser *user = [self fetchUser:author.objectId][0];
                if (([user[@"isPublic"] isEqual:@(YES)] || [user isEqual:self.currentUser]) &&
                    ![self.friendsIdSet containsObject:author.objectId])
                {
                    [self.markerArr addObject:pin];
                    [self.pinIdToUsername setObject:user.username forKey:pin.objectId];
                }
            }
            [self loadMarkers];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSMutableArray *)fetchPinsFromCoord:(CLLocationCoordinate2D)coordinate {// Fetch pins with specific coordinate
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    NSInteger segmentControlIndex = self.segmentedControl.selectedSegmentIndex;
    if (segmentControlIndex == 0) {
        [query whereKey:@"author" equalTo:self.currentUser];
    }
    [query whereKey:@"latitude" equalTo:@(coordinate.latitude)];
    [query whereKey:@"longitude" equalTo:@(coordinate.longitude)];
    [query includeKey:@"objectId"];
    [query orderByDescending:(@"traveledOn")];
    NSMutableArray *pins = (NSMutableArray *)[query findObjects];
    if (segmentControlIndex == 1) {
        for(Pin *pin in pins) {
            if ([self.friendsIdSet containsObject:pin.author.objectId] == NO &&
                [pin.author.objectId isEqual:self.currentUser.objectId] == NO)
            {
                [pins removeObject:pin];
            }
        }
    }
    return pins;
}


- (void)imagesFromPin:(NSString *)pinId withBlock:(PFQueryArrayResultBlock)block {
    // Fetch images related to specific pin
    PFQuery *query = [PFQuery queryWithClassName:classNameImage];
    [query whereKey:@"pinId" equalTo:pinId];
    [query orderByAscending:(@"traveledOn")];

    [query findObjectsInBackgroundWithBlock:^(NSArray *_Nullable imageObjs, NSError *_Nullable error) {
        NSMutableArray *images = [[NSMutableArray alloc] init];
        if (imageObjs != nil) {
            for (Image *imageObject in imageObjs) {
                [imageObject[@"imageFile"] getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:imageData];
                        [images addObject:image];
                    }
                }];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        block(images, error);
    }];
}

#pragma mark - GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
        [self.mapView animateToZoom:self.mapView.camera.zoom + 1];
        return YES;
    }
    return NO;
}
- (void)         mapView:(GMSMapView *)mapView
    didTapPOIWithPlaceID:(NSString *)placeID
                    name:(NSString *)name
                location:(CLLocationCoordinate2D)location {
    self.infoMarker = [GMSMarker markerWithPosition:location];
    self.infoMarker.snippet = placeID;
    self.infoMarker.title = name;
    self.infoMarker.opacity = 0;
    self.infoMarker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:self.currentUser[@"colorHexString"]]];
    CGPoint pos = self.infoMarker.infoWindowAnchor;
    pos.y = 1;
    self.infoMarker.infoWindowAnchor = pos;
    self.infoMarker.map = mapView;
    mapView.selectedMarker = self.infoMarker;
}

- (InfoMarkerView *) loadingMarkerView:(UIActivityIndicatorView *) indicator{
    InfoMarkerView * loadingMarkerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoExistWindow" owner:self options:nil] objectAtIndex:0];
    indicator.hidesWhenStopped = YES;
    indicator.frame = CGRectMake(35, 15, 30, 30);
    indicator.center = loadingMarkerView.center;
    [indicator startAnimating];
    [loadingMarkerView addSubview:indicator];
    [loadingMarkerView.pinImageView setHidden:YES];
    [loadingMarkerView.usernameLabel setHidden:YES];
    [loadingMarkerView.placeNameLabel setText:@"Loading..."];
    [loadingMarkerView.dateLabel setHidden:YES];
    return loadingMarkerView;
}

- (InfoMarkerView *) cachedMarkerView: (NSString*) title{
    InfoMarkerView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoExistWindow" owner:self options:nil] objectAtIndex:0];
    Pin *firstPin = [self.placeToPins[title] lastObject];
    // Set Image
    NSArray *imagesFromPin = self.pinImages[firstPin.objectId];
    if (imagesFromPin.count != 0) {
        [markerView.pinImageView setImage:imagesFromPin[0]];
    }
    // Set place name
    [markerView.placeNameLabel setText:firstPin[@"placeName"]];
    // Set username
    NSString *username = ([firstPin.author.objectId isEqualToString:self.currentUser.objectId])? self.currentUser.username : self.pinIdToUsername[firstPin.objectId];
    [markerView.usernameLabel setText:[@"@" stringByAppendingString:username]];
    // Set date
    NSString *date = [[self.apiHelper dateFormatter] stringFromDate:firstPin[@"traveledOn"]];
    [markerView.dateLabel setText:date];
    return markerView;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(nonnull GMSMarker *)marker {
    // Fetch if there's existing posts related to this coordinate
    CLLocationCoordinate2D coordinate = marker.position;
    // If cached data exists (if this coordinate has existing pins)
    if (self.placeToPins[marker.title]) {
        return [self cachedMarkerView:marker.title];
    }
    // Array of pins from the specific coordinate
    NSArray *pinsFromCoord = [self fetchPinsFromCoord:coordinate];
    // Check if exisitng pins exist from this coordinate
    if (pinsFromCoord && pinsFromCoord.count > 0) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        InfoMarkerView *markerView = [self loadingMarkerView:indicator];
        PFObject *firstPin = pinsFromCoord[0];
        if (!self.placeToPins[firstPin[@"placeName"]]) {
            [self.placeToPins setObject:[[NSMutableArray alloc]init] forKey:firstPin[@"placeName"]];
        }
        [self.placeToPins[firstPin[@"placeName"]] addObject:firstPin];
        // Save images of the specific pin to the cache data structure
        [self imagesFromPin:firstPin.objectId withBlock:^(NSArray *_Nullable images, NSError *_Nullable error) {
            if (images != nil) {
                [self.pinImages setObject:images forKey:firstPin.objectId];
                // Set image of the info window to first in the array
                NSArray *imagesFromPin = self.pinImages[firstPin.objectId];
                if (imagesFromPin && imagesFromPin.count > 0) {
                    PFFileObject *file = imagesFromPin[0][@"imageFile"];
                    [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                        if (!error) {
                            UIImage *image = [UIImage imageWithData:imageData];
                            [markerView.pinImageView setImage:image];
                        }
                    }];
                }
                // Set place name
                [markerView.placeNameLabel setText:firstPin[@"placeName"]];
                // Set date
                NSString *date = [[self.apiHelper dateFormatter] stringFromDate:firstPin[@"traveledOn"]];

                [markerView.dateLabel setText:date];
                [indicator stopAnimating];
                [markerView.pinImageView setHidden:NO];
                [markerView.placeNameLabel setHidden:NO];
                [markerView.dateLabel setHidden:NO];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        return markerView;
    }
    // If there are no pins existing at this coordinate, present info window that leads to compose view
    InfoPOIView *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    infoWindow.placeName.text = marker.title;
    return infoWindow;
} /* mapView */

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    // If there are pins exist at this coordinate, lead to details otherwise compose view
    if (self.placeToPins[marker.title]) {
        [self performSegueWithIdentifier:segueDetails sender:marker];
    } else {
        [self performSegueWithIdentifier:segueCompose sender:self];
    }
}

#pragma mark - ComposeViewControllerDelegate

- (void)didPost {
    // Place marker after composing pin at the location
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(self.infoMarker.position.latitude, self.infoMarker.position.longitude);
    marker.title = self.infoMarker.title;
    marker.snippet = self.infoMarker.snippet;
    marker.map = self.mapView;
    marker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:self.currentUser[@"colorHexString"]]];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GMSAutocompleteViewControllerDelegate

- (void)      viewController:(GMSAutocompleteViewController *)viewController
    didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    CLLocationCoordinate2D location = place.coordinate;
    GMSCameraUpdate *locationCam = [GMSCameraUpdate setTarget:location zoom:12];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.coordinate = location;
        [self.mapView animateWithCameraUpdate:locationCam];
        [self.mapView clear];
        [self setMarkerCircle:location];
        [self fetchMarkers];
    });
}


- (void)          viewController:(GMSAutocompleteViewController *)viewController
    didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:segueCompose]) {
        ComposeViewController *composeVC = [segue destinationViewController];
        composeVC.placeName = self.infoMarker.title;
        composeVC.coordinate = self.infoMarker.position;
        composeVC.placeID = self.infoMarker.snippet;
        composeVC.delegate = self;
    } else if ([segue.identifier isEqual:segueDetails]) {
        DetailsViewController *detailsVC = [segue destinationViewController];
        GMSMarker *marker = sender;
        PFObject *firstPin = [self.placeToPins[marker.title] lastObject];
        // Set Images array
        NSMutableArray *pinImages = self.pinImages[firstPin.objectId];
        // Save pin
        detailsVC.pin = (Pin *)firstPin;
        detailsVC.imagesFromPin = pinImages;
        // Save username
        detailsVC.username = [self fetchUser:detailsVC.pin.author.objectId][0][@"username"];
    }
}
@end
