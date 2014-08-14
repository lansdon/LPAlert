//
//  DemoTableViewController.h
//  LPAlertDemo
//
//  Created by Lansdon Page on 8/12/14.
//  Copyright (c) 2014 Lansdon Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UISwitch *btnLayoutSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *showImageSwitch;
@property (strong, nonatomic) IBOutlet UIButton *addButtonBtn;
@property (strong, nonatomic) IBOutlet UIButton *addLabelBtn;
@property (strong, nonatomic) IBOutlet UIStepper *styleStepper;
@property (strong, nonatomic) IBOutlet UILabel *styleLabel;
@property (strong, nonatomic) IBOutlet UIStepper *sizeStep;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;

@property (strong, nonatomic) IBOutlet UIButton *showAlertBtn;
- (IBAction)showAlertPressed:(id)sender;
- (IBAction)addLabelPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;
- (IBAction)styleChanged:(id)sender;
- (IBAction)sizeChanged:(id)sender;
@end
