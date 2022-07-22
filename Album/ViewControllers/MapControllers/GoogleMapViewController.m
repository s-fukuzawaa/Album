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
#import "InfoPOIView.h"
#import "InfoMarkerView.h"
#import "AlbumConstants.h"
#import "Parse/Parse.h"
#import <Parse/PFImageView.h>
#import "Pin.h"

@interface GoogleMapViewController ()<GMSMapViewDelegate, GMSIndoorDisplayDelegate, CLLocationManagerDelegate,
ComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *markerArr;
@property (nonatomic, strong) NSMutableDictionary *placeToPins;
@property (nonatomic, strong) NSMutableDictionary *pinImages;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSMutableSet *friendsIdSet; // User IDs of current user's friends
@property (nonatomic, weak) PFUser *currentUser;
@property (nonatomic, strong) ColorConvertHelper *colorHelper;
@end

@implementation GoogleMapViewController
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIView animateWithDuration:1 animations:^{self.view.alpha = 0.0; self.mapView.alpha = 0.0;}];
    [UIView animateWithDuration:1 animations:^{self.view.alpha = 1; self.mapView.alpha = 1;}];
}
- (void)loadView {
    [super loadView];
    [UIView animateWithDuration:1 animations:^{self.view.alpha = 0.0; self.mapView.alpha = 0.0;}];
    [UIView animateWithDuration:1 animations:^{self.view.alpha = 1; self.mapView.alpha = 1;}];
    self.colorHelper = [[ColorConvertHelper alloc] init];
    // Set user
    self.currentUser = [PFUser currentUser];
    // Initialize the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy =
    kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
    // Ask for authentication
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    // Set the intiial map view position
    CLLocation *curPos = self.locationManager.location;
    GMSCameraPosition *camera =
    [GMSCameraPosition cameraWithLatitude:curPos.coordinate.latitude longitude:curPos.coordinate.longitude zoom:12];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    [self fetchMarkers];
    self.view = self.mapView;
    self.mapView.myLocationEnabled = true;
    self.mapView.delegate = self;
    // Set the date formatter
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"MMM dd, YYYY"];
    [self.formatter setDateStyle:NSDateFormatterMediumStyle];
    // Initialize data structures to cache retrieved data
    self.placeToPins = [[NSMutableDictionary alloc] init];
    self.pinImages = [[NSMutableDictionary alloc] init];
    self.friendsIdSet = [[NSMutableSet alloc] init];
    [self.segmentedControl addTarget:self action:@selector(animate) forControlEvents:UIControlEventValueChanged];
} /* loadView */

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
- (void)fetchMarkers {
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    if (index == 0) {
        // Fetch current user's pins
        [self fetchPersonal];
    } else if (index == 1) {
        // Fetch current user's pins
        [self fetchPersonal];
        // Fetch friends pins
        [self fetchFriends];
    } else {
        // Fetches pins of all users
        [self fetchGlobal];
    }
}

- (void)fetchPersonal {
    // Query to find markers that belong to current user
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    [query whereKey:@"author" equalTo:self.currentUser];
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

- (void)fetchFriends {
    // Query to find markers that belong to current user and current user's friend
    PFQuery *friendQuery = [PFQuery queryWithClassName:classNameFriendship];
    [friendQuery whereKey:@"requesterId" equalTo:self.currentUser.objectId];
    [friendQuery whereKey:@"hasFriended" equalTo:@(2)];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *friendships, NSError *error) {
        if (friendships != nil) {
            NSLog(@"Successfully fetched friendships!");
            // For each friend, find their pins
            for (Friendship *friendship in friendships) {
                NSString *friendId = friendship[@"recipientId"];
                PFUser *friend = [self fetchUser:friendId][0];
                [self.friendsIdSet addObject:friendId];
                PFQuery *query = [PFQuery queryWithClassName:classNamePin];
                [query whereKey:@"author" equalTo:friend];
                [query includeKey:@"objectId"];
                [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
                    if (pins != nil) {
                        // Store the pins, update count
                        NSLog(@"Successfully fetched pins!");
                        // Add pins to the marker array
                        for (PFObject *pin in pins) {
                            [self.markerArr addObject:pin];
                        }
                        // Reload markers
                        [self loadMarkers];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
} /* fetchFriends */

// Used to find specfic user
- (NSArray *)fetchUser:(NSString *)userId {
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:userId];
    return [userQuery findObjects];
}

- (void)fetchGlobal {
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
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

- (NSMutableArray *)fetchPinsFromCoord:(CLLocationCoordinate2D)coordinate {
    // Fetch pins with specific coordinate
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    if (index == 0) {
        [query whereKey:@"author" equalTo:self.currentUser];
    }
    
    [query whereKey:@"latitude" equalTo:@(coordinate.latitude)];
    [query whereKey:@"longitude" equalTo:@(coordinate.longitude)];
    [query includeKey:@"objectId"];
    [query orderByDescending:(@"traveledOn")];
    NSMutableArray *pins = (NSMutableArray *)[query findObjects];
    if (index == 1) {
        int i = 0;
        while (i < pins.count) {
            Pin *pin = pins[i];
            if ([self.friendsIdSet containsObject:pin.author.objectId] == NO &&
                [pin.author.objectId isEqual:self.currentUser.objectId] == NO)
            {
                [pins removeObject:pin];
            }
            i++;
        }
    }
    return pins;
} /* fetchPinsFromCoord */

- (void)viewDidLoad {
    [super viewDidLoad];
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(_mapView.camera.target.latitude,
                                                                  _mapView.camera.target.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
    marker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:self.currentUser[@"colorHexString"]]];
    marker.map = self.mapView;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    self.circ.map = nil;
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
        [self.mapView animateToZoom:self.mapView.camera.zoom + 1];
        return YES;
    }
    self.circ = [GMSCircle circleWithPosition:marker.position radius:800];
    self.circ.fillColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:0.5];
    self.circ.map = self.mapView;
    return NO;
}
- (void) animate{
    [UIView animateWithDuration:1 animations:^{self.view.alpha = 0.0; self.mapView.alpha = 0.0;}];
    [UIView animateWithDuration:1 animations:^{self.view.alpha = 1; self.mapView.alpha = 1;}];
}
- (IBAction)switchControl:(id)sender {
    [self.mapView clear];
//    [UIView animateWithDuration:1 animations:^{self.mapView.alpha = 0;}];
//    [UIView animateWithDuration:1 animations:^{self.mapView.alpha = 1;}];

    [self loadView];
}


- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.map = self.mapView;
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

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(nonnull GMSMarker *)marker {
    // Fetch if there's existing posts related to this coordinate
    CLLocationCoordinate2D coordinate = marker.position;
    // If cached data exists (if this coordinate has existing pins)
    if (self.placeToPins[marker.title]) {
        InfoMarkerView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoExistWindow" owner:self options:nil] objectAtIndex:0];
        PFObject *firstPin = [self.placeToPins[marker.title] lastObject];
        // Set Image
        NSArray *imagesFromPin = self.pinImages[firstPin.objectId];
        PFFileObject *imageFile = imagesFromPin[0][@"imageFile"];
        [markerView.pinImageView setFile:imageFile];
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [markerView.pinImageView setImage:image];
            }
        }];
        // Set place name
        [markerView.placeNameLabel setText:firstPin[@"placeName"]];
        // Set date
        NSString *date = [self.formatter stringFromDate:firstPin[@"traveledOn"]];
        [markerView.dateLabel setText:date];
        return markerView;
    }
    // Array of pins from the specific coordinate
    NSArray *pinsFromCoord = [self fetchPinsFromCoord:coordinate];
    // Check if exisitng pins exist from this coordinate
    if (pinsFromCoord && pinsFromCoord.count > 0) {
        PFObject *firstPin = pinsFromCoord[0];
        for (PFObject *pin in pinsFromCoord) {
            // Save pins into cache data structure
            if (!self.placeToPins[pin[@"placeName"]]) {
                [self.placeToPins setObject:[[NSMutableArray alloc]init] forKey:pin[@"placeName"]];
            }
            [self.placeToPins[pin[@"placeName"]] addObject:pin];
            // Save images of the specific pin to the cache data structure
            NSArray *imagesFromPin = [self imagesFromPin:pin.objectId];
            [self.pinImages setObject:imagesFromPin forKey:pin.objectId];
        }
        InfoMarkerView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoExistWindow" owner:self options:nil] objectAtIndex:0];
        // Set image of the info window to first in the array
        NSArray *imagesFromPin = self.pinImages[firstPin.objectId];
        if (imagesFromPin && imagesFromPin.count > 0) {
            PFFileObject *imageFile = imagesFromPin[0][@"imageFile"];
            [markerView.pinImageView setFile:imageFile];
            [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [markerView.pinImageView setImage:image];
                }
            }];
        }
        // Set place name
        [markerView.placeNameLabel setText:firstPin[@"placeName"]];
        // Set date
        NSString *date = [self.formatter stringFromDate:firstPin[@"traveledOn"]];
        [markerView.dateLabel setText:date];
        return markerView;
    }
    // If there are no pins existing at this coordinate, present info window that leads to compose view
    InfoPOIView *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    infoWindow.placeName.text = marker.title;
    return infoWindow;
} /* mapView */

- (NSArray *)imagesFromPin:(NSString *)pinId {
    // Fetch images related to specific pin
    PFQuery *query = [PFQuery queryWithClassName:classNameImage];
    [query whereKey:@"pinId" equalTo:pinId];
    return [query findObjects];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    // If there are pins exist at this coordinate, lead to details otherwise compose view
    if (self.placeToPins[marker.title]) {
        [self performSegueWithIdentifier:@"detailsSegue" sender:marker];
    } else {
        [self performSegueWithIdentifier:@"composeSegue" sender:self];
    }
}

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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"composeSegue"]) {
        ComposeViewController *composeVC = [segue destinationViewController];
        composeVC.placeName = self.infoMarker.title;
        composeVC.coordinate = self.infoMarker.position;
        composeVC.placeID = self.infoMarker.snippet;
        composeVC.delegate = self;
    } else if ([segue.identifier isEqual:@"detailsSegue"]) {
        DetailsViewController *detailsVC = [segue destinationViewController];
        GMSMarker *marker = sender;
        PFObject *firstPin = [self.placeToPins[marker.title] lastObject];
        // Set Images array
        NSArray *imageObjs = self.pinImages[firstPin.objectId];
        NSMutableArray *pinImages = [[NSMutableArray alloc] init];
        // For each image object, get the image file and convert to UIImage
        for (PFObject *imageObj in imageObjs) {
            PFFileObject *file = imageObj[@"imageFile"];
            [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [pinImages addObject:image];
                }
            }];
        }
        // Save pin
        detailsVC.pin = (Pin *)firstPin;
        detailsVC.imagesFromPin = pinImages;
    }
} /* prepareForSegue */
@end

