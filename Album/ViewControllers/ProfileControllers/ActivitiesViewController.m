//
//  ActivitiesViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/7/22.
//

#import "ActivitiesViewController.h"

@interface ActivitiesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ActivitiesViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Assign tableview data source and delegate
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}
- (IBAction)backButton:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return NULL;
}
@end
