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
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) ColorConvertHelper *colorHelper;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) ParseAPIHelper *apiHelper;
@end

@implementation FriendMapViewController

#pragma mark - UIViewController

- (void)loadView {
    [super loadView];
    // Initialize color converting helper class
    self.colorHelper = [[ColorConvertHelper alloc] init];
    // Initalize api helper
    self.apiHelper = [[ParseAPIHelper alloc] init];
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
    [GMSCameraPosition cameraWithLatitude:curPos.coordinate.latitude longitude:curPos.coordinate.longitude zoom:6];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    [self fetchMarkers];
    self.view = self.mapView;
    self.mapView.myLocationEnabled = true;
    self.mapView.delegate = self;
    // Initialize data structures to cache retrieved data
    self.placeToPins = [[NSMutableDictionary alloc] init];
    self.pinImages = [[NSMutableDictionary alloc] init];
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
    int i = 0;
    while (i < self.markerArr.count) {
        Pin *pin = self.markerArr[i];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(pin.latitude, pin.longitude);
        marker.title = pin.placeName;
        marker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:self.user[@"colorHexString"]]];
        marker.snippet = pin.placeID;
        marker.map = self.mapView;
        i++;
    }
}

#pragma mark - Parse API

- (void)fetchMarkers {
    // Query to find markers that belong to specific user
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    [query whereKey:@"author" equalTo:self.user];
    [query includeKey:@"objectId"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        if (pins != nil) {
            // Store the posts, update count
            NSLog(@"Successfully fetched markers!");
            self.markerArr = (NSMutableArray *)pins;
            for (PFObject *pin in pins) {
                if (!self.placeToPins[pin[@"placeName"]]) {
                    [self.placeToPins setObject:[[NSMutableArray alloc]init] forKey:pin[@"placeName"]];
                }
                [self.placeToPins[pin[@"placeName"]] addObject:pin];
                // Save images of the specific pin to the cache data structure
                [self imagesFromPin:pin.objectId withBlock:^(NSArray *_Nullable images, NSError *_Nullable error) {
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
}

- (NSArray *)fetchPinsFromCoord:(CLLocationCoordinate2D)coordinate {
    // Fetch pins with specific coordinate
    PFQuery *query = [PFQuery queryWithClassName:classNamePin];
    [query whereKey:@"author" equalTo:self.user];
    [query whereKey:@"latitude" equalTo:@(coordinate.latitude)];
    [query whereKey:@"longitude" equalTo:@(coordinate.longitude)];
    [query includeKey:@"objectId"];
    [query orderByDescending:(@"traveledOn")];
    NSMutableArray *pins = (NSMutableArray *)[query findObjects];
    for(Pin *pin in pins) {
        [self imagesFromPin:pin.objectId withBlock:^(NSArray *_Nullable images, NSError *_Nullable error) {
                if (images != nil) {
                    // Set image of the info window to first in the array
                    [self.pinImages setObject:images forKey:pin.objectId];
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
    }
    return pins;
}

#pragma mark - GMSMapViewDelegate
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

- (void)         mapView:(GMSMapView *)mapView
    didTapPOIWithPlaceID:(NSString *)placeID
                    name:(NSString *)name
                location:(CLLocationCoordinate2D)location {
    self.infoMarker = [GMSMarker markerWithPosition:location];
    self.infoMarker.snippet = placeID;
    self.infoMarker.title = name;
    self.infoMarker.opacity = 0;
    self.infoMarker.icon = [GMSMarker markerImageWithColor:[self.colorHelper colorFromHexString:self.user[@"colorHexString"]]];
    CGPoint pos = self.infoMarker.infoWindowAnchor;
    pos.y = 1;
    self.infoMarker.infoWindowAnchor = pos;
    self.infoMarker.map = mapView;
    mapView.selectedMarker = self.infoMarker;
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
    [markerView.usernameLabel setText:[@"@" stringByAppendingString:self.user.username]];
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
        return [self cachedMarkerView:marker.title];
    }
    // If there are no pins existing at this coordinate, present info window that leads to compose view
    InfoPOIView *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    infoWindow.placeName.text = marker.title;
    return infoWindow;
}

- (NSArray *)imagesFromPin:(NSString *)pinId {
    // Fetch images related to specific pin
    PFQuery *query = [PFQuery queryWithClassName:classNameImage];
    [query whereKey:@"pinId" equalTo:pinId];
    NSArray *imageObjs = [query findObjects];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (Image *imageObject in imageObjs) {
        [imageObject[@"imageFile"] getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [images addObject:image];
            }
        }];
    }
    return (NSArray *)images;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    // If there are pins exist at this coordinate, lead to details otherwise compose view
    if (self.placeToPins[marker.title]) {
        PFObject *firstPin = [self.placeToPins[marker.title] lastObject];
        [self.delegate didTapWindow:(Pin *)firstPin imagesFromPin:self.pinImages[firstPin.objectId]];
    }
}
@end
