//
//  GoogleMapViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/6/22.
//

#import "GoogleMapViewController.h"
#import "LocationGenerator.h"
#import "ComposeViewController.h"
#import "DetailsViewCOntroller.h"
#import "InfoPOIView.h"
#import "InfoMarkerView.h"
#import "Parse/Parse.h"
#import <Parse/PFImageView.h>
#import "Pin.h"

@interface GoogleMapViewController ()<GMSMapViewDelegate,GMSIndoorDisplayDelegate, CLLocationManagerDelegate, InfoPOIViewDelegate, ComposeViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *markerArr;
@property (nonatomic, strong) NSMutableDictionary *placeToPins;
@property (nonatomic, strong) NSMutableDictionary *pinImages;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation GoogleMapViewController

- (void)loadView {
    [super loadView];
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
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:curPos.coordinate.latitude longitude:curPos.coordinate.longitude zoom:12];
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
    
}

- (void) loadMarkers {
    // Place markers on initial map view
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
}

- (void) fetchMarkers {
    // Query to find markers that belong to current user
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query includeKey: @"objectId"];
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

- (NSArray *) fetchPinsFromCoord: (CLLocationCoordinate2D) coordinate {
    // Fetch pins with specific coordinate
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query whereKey:@"latitude" equalTo:@(coordinate.latitude)];
    [query whereKey:@"longitude" equalTo:@(coordinate.longitude)];
    [query includeKey: @"objectId"];
    [query orderByDescending:(@"traveledOn")];
    return [query findObjects];
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
    // Fetch if there's existing posts related to this coordinate
    CLLocationCoordinate2D coordinate = marker.position;
    // If cached data exists (if this coordinate has existing pins)
    if(self.placeToPins[marker.title]) {
        InfoMarkerView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoExistWindow" owner:self options:nil] objectAtIndex:0];
        PFObject *firstPin = [self.placeToPins[marker.title] lastObject];
        // Set Image
        NSArray* imagesFromPin = self.pinImages[firstPin.objectId];
        if(imagesFromPin && imagesFromPin.count > 0) {
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
    // Array of pins from the specific coordinate
    NSArray *pinsFromCoord = [self fetchPinsFromCoord:coordinate];
    // Check if exisitng pins exist from this coordinate
    if(pinsFromCoord && pinsFromCoord.count > 0) {
        PFObject *firstPin = pinsFromCoord[0];
        int i=0;
        while(i<pinsFromCoord.count) {
            PFObject *pin = pinsFromCoord[i];
            // Save pins into cache data structure
            if(!self.placeToPins[pin[@"placeName"]]){
                [self.placeToPins setObject:[[NSMutableArray alloc]init] forKey:pin[@"placeName"]];
            }
            [self.placeToPins[pin[@"placeName"]] addObject:pin];
            // Save images of the specific pin to the cache data structure
            NSArray* imagesFromPin = [self imagesFromPin:pin.objectId];
            [self.pinImages setObject:imagesFromPin forKey:pin.objectId];
            i++;
        }
        InfoMarkerView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"InfoExistWindow" owner:self options:nil] objectAtIndex:0];
        // Set image of the info window to first in the array
        NSArray* imagesFromPin = self.pinImages[firstPin.objectId];
        if(imagesFromPin && imagesFromPin.count > 0) {
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
}

- (NSArray*) imagesFromPin: (NSString*) pinId {
    // Fetch images related to specific pin
    PFQuery *query = [PFQuery queryWithClassName:@"Image"];
    [query whereKey:@"pinId" equalTo:pinId];
    return [query findObjects];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    // If there are pins exist at this coordinate, lead to details otherwise compose view
    if(self.placeToPins[marker.title]){
        [self performSegueWithIdentifier:@"detailsSegue" sender:marker];
    }else{
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
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"composeSegue"]){
        ComposeViewController *composeVC = [segue destinationViewController];
        composeVC.placeName = self.infoMarker.title;
        composeVC.coordinate = self.infoMarker.position;
        composeVC.placeID = self.infoMarker.snippet;
        composeVC.delegate = self;
    }else if([segue.identifier isEqual:@"detailsSegue"]){
        DetailsViewController *detailsVC = [segue destinationViewController];
        GMSMarker *marker=sender;
        PFObject *firstPin = [self.placeToPins[marker.title] lastObject];
        // Set Image
        NSArray* imagesFromPin = self.pinImages[firstPin.objectId];
        if(imagesFromPin && imagesFromPin.count > 0) {
            PFFileObject *imageFile = imagesFromPin[0][@"imageFile"];
            detailsVC.pinImage = imageFile;
        }
        // Set place name
        detailsVC.placeName = firstPin[@"placeName"];
        // Set date
        NSString *date = [self.formatter stringFromDate:firstPin[@"traveledOn"]];
        detailsVC.date = date;
        // Set caption
        detailsVC.caption = [@"Caption: " stringByAppendingString:firstPin[@"captionText"]];
    }
}
@end

