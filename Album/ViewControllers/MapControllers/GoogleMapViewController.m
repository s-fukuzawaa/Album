//
//  GoogleMapViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/6/22.
//

#import "GoogleMapViewController.h"
#import "LocationGenerator.h"
#import "ComposeViewController.h"
#import "InfoPOIView.h"
#import "Parse/Parse.h"
#import "Pin.h"

@interface GoogleMapViewController ()<GMSMapViewDelegate,GMSIndoorDisplayDelegate, CLLocationManagerDelegate, InfoPOIViewDelegate, ComposeViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *markerArr;
@property (nonatommic, strong) NSArray *fetchedPins;
@end

@implementation GoogleMapViewController

- (void)loadView {
    [super loadView];
    //Set the inital map view position
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy =
    kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
    
    CLLocation *curPos = self.locationManager.location;
    //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:curPos.coordinate.latitude longitude:curPos.coordinate.longitude zoom:12];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    [self fetchMarkers];
    self.view = self.mapView;
    self.mapView.myLocationEnabled = true;
    self.mapView.delegate = self;
    
}

- (void) loadMarkers {
    int i=0;
    while(i<self.markerArr.count) {
        Pin *pin=self.markerArr[i];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(pin.latitude, pin.longitude);
        marker.title = pin.placeName;
        marker.snippet = pin.placeID;
        marker.map = self.mapView;
        i++;
    }
    self.view = self.mapView;
    self.mapView.myLocationEnabled = true;
    self.mapView.delegate = self;
}

- (void) fetchMarkers {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    // fetch data asynchronously
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

- (void) fetchPins: (CLLocationCoordinate2D) coordinate {
    // Fetch pins with specific coordinate
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query whereKey:@"latitude" equalTo:@(coordinate.latitude)];
    [query whereKey:@"longitude" equalTo:@(coordinate.longitude)];
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        if (pins != nil) {
            // Store the posts, update count
            NSLog(@"Successfully fetched markers!");
            self.fetchedPins = pins;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(_mapView.camera.target.latitude,
                                                                  _mapView.camera.target.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
    marker.map = self.mapView;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    self.circ.map = nil;
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
        [self.mapView animateToZoom:self.mapView.camera.zoom +1];
        return YES;
    }
    self.circ = [GMSCircle circleWithPosition:marker.position radius:800];
    self.circ.fillColor = [UIColor colorWithRed: 0.67 green: 0.67 blue: 0.67 alpha: 0.5];
    self.circ.map = self.mapView;
    
    return NO;
}



- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.map = self.mapView;
}

- (void)mapView:(GMSMapView *)mapView
    didTapPOIWithPlaceID:(NSString *)placeID
                    name:(NSString *)name
                location:(CLLocationCoordinate2D)location {
  self.infoMarker = [GMSMarker markerWithPosition:location];
  self.infoMarker.snippet = placeID;
  self.infoMarker.title = name;
  self.infoMarker.opacity = 0;
  CGPoint pos = self.infoMarker.infoWindowAnchor;
  pos.y = 1;
  self.infoMarker.infoWindowAnchor = pos;
  self.infoMarker.map = mapView;
  mapView.selectedMarker = self.infoMarker;
}

- (UIView*) mapView:(GMSMapView *)mapView markerInfoWindow:(nonnull GMSMarker *)marker {
    InfoPOIView *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    infoWindow.placeName.text = marker.title;
    return infoWindow;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    [self performSegueWithIdentifier:@"composeSegue" sender:self];
}

- (void)didPost {
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(self.infoMarker.position.latitude, self.infoMarker.position.longitude);
    marker.title = self.infoMarker.title;
    marker.snippet = self.infoMarker.snippet;
    marker.map = self.mapView;
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"composeSegue"]){
        ComposeViewController *composeVC = [segue destinationViewController];
        composeVC.placeName = self.infoMarker.title;
        composeVC.coordinate = self.infoMarker.position;
        composeVC.placeID = self.infoMarker.snippet;
        composeVC.delegate = self;
    }
}
@end

