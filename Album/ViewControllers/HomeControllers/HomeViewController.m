//
//  HomeViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "HomeViewController.h"
#import "GoogleMapViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) GoogleMapViewController *prevVC;
@end

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Initial view with map
    GoogleMapViewController *googleMapVC = [[GoogleMapViewController alloc] init];
    googleMapVC.switchStatus = 0;
    self.prevVC = googleMapVC;
    [self addChildViewController:self.prevVC];
    [self.mapViewContainer addSubview:self.prevVC.view];
}
- (void)viewDidLoad {
	[super viewDidLoad];
}
- (IBAction)viewSwitchControl:(UISegmentedControl*)sender {
	// Map View case
    [self.prevVC.view removeFromSuperview];
    [self.prevVC removeFromParentViewController];
    [self performSegueWithIdentifier:@"mapSegue" sender:sender];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GoogleMapViewController *googleMapVC = [segue destinationViewController];
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        googleMapVC.switchStatus = ((UISegmentedControl *)sender).selectedSegmentIndex;
    }else{
        googleMapVC.switchStatus = 0;
    }
}
@end
