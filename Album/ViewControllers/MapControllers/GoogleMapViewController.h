//
//  GoogleMapViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/6/22.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;
@import GoogleMapsUtils;
NS_ASSUME_NONNULL_BEGIN

@interface GoogleMapViewController : UIViewController
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMUClusterManager *clusterManager;
@property (nonatomic, strong) GMSCircle *circ;
@property (nonatomic, strong) GMSMarker *infoMarker;
@end

NS_ASSUME_NONNULL_END
