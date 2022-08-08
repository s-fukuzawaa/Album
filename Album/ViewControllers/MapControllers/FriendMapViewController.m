//
//  FriendMapViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/18/22.
//

#import "FriendMapViewController.h"
#import "LocationGenerator.h"
#import "ColorConvertHelper.h"
#import "InfoPOIView.h"
#import "InfoMarkerView.h"
#import "ParseAPIHelper.h"
#import "Image.h"
#import "AlbumConstants.h"
#import "Parse/Parse.h"
#import <Parse/PFImageView.h>
#import "Pin.h"

@interface FriendMapViewController () <GMSMapViewDelegate, GMSIndoorDisplayDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) NSMutableArray *markerArr;
@property (nonatomic, strong) NSMutableDictionary *placeToPins;
@property (nonatomic, strong) NSMutableDictionary *pinImages;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) Pin *pinToDetail;
@end

@implementation FriendMapViewController

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    [self setLocationManager];
    // Set the intiial map view position
    CLLocation *curPos = self.locationManager.location;
    GMSCameraPosition *camera =
    [GMSCameraPosition cameraWithLatitude:curPos.coordinate.latitude longitude:curPos.coordinate.longitude zoom:6];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = self.mapView;
    self.mapView.myLocationEnabled = true;
    self.mapView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize data structures to cache retrieved data
    self.placeToPins = [[NSMutableDictionary alloc] init];
    self.pinImages = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Add loading screen
        [self animateLoadingScreen];
        // Clear map
        [self.mapView clear];
        // Fetch pins from database, add to markers
        [self fetchMarkers];
    });
}

// Used for switch control animation
- (void)animateLoadingScreen {
    // Add loading screen
    self.overlayView =
    [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    self.overlayView.backgroundColor = [UIColor whiteColor];
    self.overlayView.alpha = 1;
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] init];
    activityView.center = self.view.center;
    [self.overlayView addSubview:activityView];
    [activityView startAnimating];
    [self.view addSubview:self.overlayView];
    [self.view bringSubviewToFront:self.overlayView];
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

#pragma mark - CLLocationManagerDelegate
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    if (manager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        GMSCameraUpdate *locationCam = [GMSCameraUpdate setTarget:manager.location.coordinate zoom:6];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.coordinate = manager.location.coordinate;
            [self.mapView animateWithCameraUpdate:locationCam];
            [self.mapView clear];
            [self fetchMarkers];
        });
    }
}

#pragma mark - UILoad

- (void)loadMarkers {
    // Place markers on initial map view
    for (Pin *pin in self.markerArr) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(pin.latitude, pin.longitude);
        marker.title = pin.placeName;
        marker.icon = [GMSMarker markerImageWithColor:[ColorConvertHelper colorFromHexString:self.user[@"colorHexString"]]];
        marker.snippet = pin.placeID;
        marker.map = self.mapView;
    }
    // Fade out the loading screen
    [UIView transitionWithView:self.view duration:2 options:UIViewAnimationOptionTransitionNone animations:^(void) { self.overlayView.alpha
        = 0.0f;
    } completion:^(BOOL finished) { [self.
                                     overlayView  removeFromSuperview]; }];
}

#pragma mark - Parse API

- (void)fetchMarkers {
    // Query to find markers that belong to specific user
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    [query whereKey:@"author" equalTo:self.user];
    [query includeKey:@"objectId"];
    [query orderByDescending:(@"traveledOn")];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        if (pins != nil) {
            // Store the posts, update count
            NSLog(@"Successfully fetched markers!");
            self.markerArr = (NSMutableArray *)pins;
            for (PFObject *pin in pins) {
                [self.placeToPins setObject:pin forKey:pin[@"placeName"]];
                // Save images of the specific pin to the cache data structure
                [ParseAPIHelper imagesFromPin:pin.objectId withBlock:^(NSArray *_Nullable images, NSError *_Nullable error) {
                    if (images != nil) {
                        // Set image of the info window to first in the array
                        [self.pinImages setObject:images forKey:pin.objectId];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            }
            [self loadMarkers];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
} /* fetchMarkers */

- (NSArray *)fetchPinsFromCoord:(CLLocationCoordinate2D)coordinate {
    // Fetch pins with specific coordinate
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    query.limit = 1;
    [query whereKey:@"author" equalTo:self.user];
    [query whereKey:@"latitude" equalTo:@(coordinate.latitude)];
    [query whereKey:@"longitude" equalTo:@(coordinate.longitude)];
    [query includeKey:@"objectId"];
    [query orderByDescending:(@"traveledOn")];
    NSMutableArray *pins = (NSMutableArray *)[query findObjects];
    for (Pin *pin in pins) {
        [ParseAPIHelper imagesFromPin:pin.objectId withBlock:^(NSArray *_Nullable images, NSError *_Nullable error) {
            if (images != nil) {
                // Set image of the info window to first in the array
                [self.pinImages setObject:images forKey:pin.objectId];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    return pins;
} /* fetchPinsFromCoord */

#pragma mark - GMSMapViewDelegate
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    // Reset to be detailed pin
    self.pinToDetail = nil;
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
    self.infoMarker.icon = [GMSMarker markerImageWithColor:[ColorConvertHelper colorFromHexString:self.user[@"colorHexString"]]];
    CGPoint pos = self.infoMarker.infoWindowAnchor;
    pos.y = 1;
    self.infoMarker.infoWindowAnchor = pos;
    self.infoMarker.map = mapView;
    mapView.selectedMarker = self.infoMarker;
}

// Return an info window from a pin
- (InfoMarkerView *)coordMarkerView:(Pin *)pin {
    // Set the detail Pin
    self.pinToDetail = pin;
    InfoMarkerView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoExistWindow" owner:self options:nil] objectAtIndex:0];
    // Set Image
    NSArray *imagesFromPin = self.pinImages[pin.objectId];
    if (imagesFromPin.count != 0) {
        [markerView.pinImageView setImage:imagesFromPin[0]];
    }
    // Set place name
    [markerView.placeNameLabel setText:pin[@"placeName"]];
    // Set username
    [markerView.usernameLabel setText:[@"@" stringByAppendingString:self.user.username]];
    // Set date
    NSString *date = [[ParseAPIHelper dateFormatter] stringFromDate:pin[@"traveledOn"]];
    [markerView.dateLabel setText:date];
    return markerView;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(nonnull GMSMarker *)marker {
    // Fetch if there's existing posts related to this coordinate
    CLLocationCoordinate2D coordinate = marker.position;
    // If cached data exists (if this coordinate has existing pins)
    if (self.placeToPins[marker.title]) {
        return [self coordMarkerView:self.placeToPins[marker.title]];
    }
    // Array of pins from the specific coordinate
    NSArray *pinsFromCoord = [self fetchPinsFromCoord:coordinate];
    // Check if exisitng pins exist from this coordinate
    if (pinsFromCoord && pinsFromCoord.count > 0) {
        return [self coordMarkerView:pinsFromCoord[0]];
    }
    // If there are no pins existing at this coordinate, present info window that leads to compose view
    InfoPOIView *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    infoWindow.placeName.text = marker.title;
    return infoWindow;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    // If there are pins exist at this coordinate, lead to details otherwise compose view
    Pin *pin = self.placeToPins[marker.title];
    if (pin != nil) {
        [self.delegate didTapWindow:pin imagesFromPin:self.pinImages[pin.objectId]];
    }
}
@end
