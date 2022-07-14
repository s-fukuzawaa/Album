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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NULL;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
