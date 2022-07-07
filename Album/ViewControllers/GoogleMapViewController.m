//
//  GoogleMapViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/6/22.
//

#import "GoogleMapViewController.h"
#import "LocationGenerator.h"
@import GoogleMaps;
@import GoogleMapsUtils;

@interface GoogleMapViewController ()<GMSMapViewDelegate>
@end

@implementation GoogleMapViewController {
    GMSMapView *_mapView;
    GMUClusterManager *_clusterManager;
    GMSCircle *_circ;
}

- (void)loadView {
    [super loadView];
    //Set the inital map view position
    // TODO: Need to set to current GPS location
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:35.6762 longitude:139.6503 zoom:12];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = _mapView;
    _mapView.myLocationEnabled = true;
    _mapView.delegate = self;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(_mapView.camera.target.latitude,
                                                                  _mapView.camera.target.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
    marker.icon = [UIImage imageNamed:@"custom_pin.png"];
    marker.map = _mapView;
    //      NSArray<GMSMarker *> *markerArray = [LocationGenerator generateMarkersNear:mapCenter count:100];
    //
    //      id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
    //      id<GMUClusterIconGenerator> clusterIconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
    //      id<GMUClusterRenderer> renderer = [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView clusterIconGenerator:clusterIconGenerator];
    //      _clusterManager = [[GMUClusterManager alloc] initWithMap:_mapView algorithm:algorithm renderer:renderer];
    //
    //      [_clusterManager addItems:markerArray];
    //      [_clusterManager cluster];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    _circ.map = nil;
    if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
        [_mapView animateToZoom:_mapView.camera.zoom +1];
        return YES;
    }
    _circ = [GMSCircle circleWithPosition:marker.position radius:800];
    _circ.fillColor = [UIColor colorWithRed: 0.67 green: 0.67 blue: 0.67 alpha: 0.5];
    _circ.map = _mapView;
    return NO;
}
@end

