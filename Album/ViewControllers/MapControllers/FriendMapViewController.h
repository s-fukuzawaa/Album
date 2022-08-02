//
//  FriendMapViewController.h
//  Album
//
//  Created by Airei Fukuzawa on 7/18/22.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Pin.h"
#import <Parse/Parse.h>
@import GoogleMaps;
@import GoogleMapsUtils;

NS_ASSUME_NONNULL_BEGIN
@protocol FriendMapViewControllerDelegate

- (void)didTapWindow: (Pin*) pin imagesFromPin:(NSArray*) images;

@end
@interface FriendMapViewController : UIViewController
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMUClusterManager *clusterManager;
@property (nonatomic, strong) GMSCircle *circ;
@property (nonatomic, strong) GMSMarker *infoMarker;
@property (nonatomic, weak) id<FriendMapViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
