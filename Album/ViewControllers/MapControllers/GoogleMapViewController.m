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
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) ParseAPIHelper *apiHelper;
@property (nonatomic, strong) NSMutableSet *friendsIdSet; // User IDs of current user's friends
@property (nonatomic, weak) PFUser *currentUser;
@property (nonatomic, strong) ColorConvertHelper *colorHelper;
@property (nonatomic, strong) GMSAutocompleteFilter *filter;
@property (nonatomic) int radius;
@end

@implementation GoogleMapViewController

- (void)loadView {
    [super loadView];
    [UIView animateWithDuration:1 animations:^{ self.view.alpha = 0.0; self.mapView.alpha = 0.0; }];
    [UIView animateWithDuration:1 animations:^{ self.view.alpha = 1; self.mapView.alpha = 1; }];
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
    // Add animation when change segmentedControl
    [self.segmentedControl addTarget:self action:@selector(animate) forControlEvents:UIControlEventValueChanged];
    // Set button
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(_mapView.camera.target.latitude,
                                                                  _mapView.camera.target.longitude);
    UIAction *radius1 = [UIAction actionWithTitle:@"1000m" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.radius = 1000;
        [self.mapView clear];
        [self loadView];
        GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
        marker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:self.currentUser[@"colorHexString"]]];
        marker.map = self.mapView;
        self.circ = [GMSCircle circleWithPosition:marker.position radius:self.radius];
        self.circ.fillColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:0.5];
        self.circ.map = self.mapView;
    }];
    UIAction *radius2 = [UIAction actionWithTitle:@"5000m" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        self.radius = 1000;
        [self.mapView clear];
        [self loadView];
        GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
        marker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:self.currentUser[@"colorHexString"]]];
        marker.map = self.mapView;
        self.circ = [GMSCircle circleWithPosition:marker.position radius:self.radius];
        self.circ.fillColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:0.5];
        self.circ.map = self.mapView;
    }];
    NSArray* radiusOptions = [NSArray arrayWithObjects:radius1, radius2, nil];
    UIMenu *menu = [UIMenu menuWithTitle:@"Options" children:radiusOptions];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" menu:menu];
    [self.navigationItem.leftBarButtonItem setImage:[UIImage systemImageNamed:@"mappin.and.ellipse"]];
    
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
    CLLocationCoordinate2D coordinate = self.locationManager.location.coordinate;
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    [query whereKey:@"author" equalTo:self.currentUser];
    [query whereKey:@"latitude" lessThanOrEqualTo:@(coordinate.latitude + self.radius)];
    [query whereKey:@"latitude" greaterThanOrEqualTo:@(coordinate.latitude - self.radius)];
    [query whereKey:@"longitude" lessThanOrEqualTo:@(coordinate.longitude + self.radius)];
    [query whereKey:@"longitude" greaterThanOrEqualTo:@(coordinate.longitude - self.radius)];
    [query includeKey:@"objectId"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
               if (pins != nil) {
               // Store the posts, update count
               NSLog(@"Successfully fetched markers!");
                   NSLog(@"Count %lu",pins.count);
               self.markerArr = (NSMutableArray *)pins;
               [self loadMarkers];
               } else {
               NSLog(@"%@", error.localizedDescription);
               }
           }];
}

- (void)fetchFriends {
    // Query to find markers that belong to current user and current user's friend
    CLLocationCoordinate2D coordinate = self.locationManager.location.coordinate;
    [self.apiHelper fetchFriends:self.currentUser.objectId coordinate:coordinate radius:self.radius withBlock:^(NSArray *friendArr, NSError *error) {
                                                               if (friendArr != nil) {
                                                               // For each friend, find their pins
                                                               for (Friendship *friendship in friendArr) {
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
- (NSArray *) fetchUser: (NSString *)userId {
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
    self.radius = 1000;
    self.circ = [GMSCircle circleWithPosition:marker.position radius:self.radius];
    self.circ.fillColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:0.5];
    self.circ.map = self.mapView;
    
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
        [self.mapView animateToZoom:self.mapView.camera.zoom + 1];
        return YES;
    }
    return NO;
}
- (void)animate {
    [UIView animateWithDuration:1 animations:^{ self.view.alpha = 0.0; self.mapView.alpha = 0.0; }];
    [UIView animateWithDuration:1 animations:^{ self.view.alpha = 1; self.mapView.alpha = 1; }];
}
- (IBAction)switchControl:(id)sender {
    [self.mapView clear];
    [self loadView];
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
        if(imagesFromPin.count!=0) {
            [markerView.pinImageView setImage:imagesFromPin[0]];
        }
        
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
            [self.pinImages setObject:[self imagesFromPin:pin.objectId] forKey:pin.objectId];
        }
        InfoMarkerView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoExistWindow" owner:self options:nil] objectAtIndex:0];
        // Set image of the info window to first in the array
        NSArray *imagesFromPin = self.pinImages[firstPin.objectId];
        if (imagesFromPin && imagesFromPin.count > 0) {
            [markerView.pinImageView setImage:imagesFromPin[0]];
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
    NSArray *imageObjs = [query findObjects];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for(Image *imageObject in imageObjs) {
        [imageObject[@"imageFile"] getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                       if (!error) {
                       UIImage *image = [UIImage imageWithData:imageData];
                           [images addObject:image];
                       }
                   }];
    }
    return (NSArray*) images;
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
- (IBAction)radiusOptions:(id)sender {
    
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

- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    CLLocationCoordinate2D location = place.coordinate;
    GMSCameraUpdate *locationCam = [GMSCameraUpdate setTarget:location zoom:12];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView animateWithCameraUpdate:locationCam];
        GMSMarker *marker = [GMSMarker markerWithPosition:location];
        marker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:self.currentUser[@"colorHexString"]]];
        self.circ = [GMSCircle circleWithPosition:marker.position radius:self.radius];
        self.circ.fillColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:0.5];
        self.circ.map = self.mapView;
        marker.map = self.mapView;
    });
    
      // Do something with the selected place.
      NSLog(@"Place name %@", place.name);
      NSLog(@"Place ID %@", place.placeID);
      NSLog(@"Place attributions %@", place.attributions.string);
}


- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        NSMutableArray *pinImages = self.pinImages[firstPin.objectId];
        // Save pin
        detailsVC.pin = (Pin *)firstPin;
        detailsVC.imagesFromPin = pinImages;
    }
} /* prepareForSegue */
@end

