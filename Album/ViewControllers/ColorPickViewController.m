//
//  ColorPickViewController.m
//  Album
//
//  Created by Airei Fukuzawa on 7/19/22.
//

#import "ColorPickViewController.h"
#import "FCColorPickerViewController.h"

@interface ColorPickViewController () <FCColorPickerViewControllerDelegate>
@property (nonatomic, strong) UIColor *color;
@end

@implementation ColorPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)chooseColor:(id)sender {
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPicker];
    colorPicker.color = self.color;
    colorPicker.delegate = self;

    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:colorPicker animated:YES completion:nil];
}

#pragma mark - FCColorPickerViewControllerDelegate Methods

- (void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
    self.color = color;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 *
 * // In a storyboard-based application, you will often want to do a little preparation before navigation
 * - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 * // Get the new view controller using [segue destinationViewController].
 * // Pass the selected object to the new view controller.
 * }
 */

@end