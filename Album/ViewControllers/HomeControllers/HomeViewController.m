//
//  HomeViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.mapViewContainer.alpha = 0.0;
	self.albumViewContainer.alpha = 1.0;
	// Do any additional setup after loading the view.
}
- (IBAction)viewSwitchControl:(UISegmentedControl*)sender {
	// Map View case
	if(sender.selectedSegmentIndex == 0) {
		[UIView animateWithDuration:0.5 animations:^{
		         self.mapViewContainer.alpha = 0.0;
		         self.albumViewContainer.alpha = 1.0;
		 }];
	} else { // Album View case
		[UIView animateWithDuration:0.5 animations:^{
		         self.mapViewContainer.alpha = 1.0;
		         self.albumViewContainer.alpha = 0.0;
		 }];
	}
}


@end
