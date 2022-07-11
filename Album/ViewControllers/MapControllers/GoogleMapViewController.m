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

@interface GoogleMapViewController ()<GMSMapViewDelegate,GMSIndoorDisplayDelegate, CLLocationManagerDelegate>
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
    self.view = self.mapView;
    self.mapView.myLocationEnabled = true;
    self.mapView.delegate = self;
    
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
    [self performSegueWithIdentifier:@"toCompose" sender:self];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"toCompose"]){
        ComposeViewController *composeVC = [segue destinationViewController];
    }
}
@end

