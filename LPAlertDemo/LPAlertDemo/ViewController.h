//
//  ViewController.h
//  LPAlertDemo
//
//  Created by Lansdon Page on 8/11/14.
//  Copyright (c) 2014 Lansdon Page. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *titleTF;
@property (strong, nonatomic) IBOutlet UITextField *subtitleTF;
@property (strong, nonatomic) IBOutlet UITextField *body1TF;
@property (strong, nonatomic) IBOutlet UITextField *body2TF;
@property (strong, nonatomic) IBOutlet UITextField *body3TF;
@property (strong, nonatomic) IBOutlet UITextField *button1TF;
@property (strong, nonatomic) IBOutlet UITextField *button2TF;

@property (strong, nonatomic) IBOutlet UIStepper *titleFontStep;
@property (strong, nonatomic) IBOutlet UILabel *titleFontLabel;

@property (strong, nonatomic) IBOutlet UIStepper *subtitleFontStep;
@property (strong, nonatomic) IBOutlet UILabel *subtitleFontLabel;

@property (strong, nonatomic) IBOutlet UIStepper *body1FontStep;
@property (strong, nonatomic) IBOutlet UILabel *body1FontLabel;

@property (strong, nonatomic) IBOutlet UIStepper *body2FontStep;
@property (strong, nonatomic) IBOutlet UILabel *body2FontLabel;

@property (strong, nonatomic) IBOutlet UIStepper *body3FontStep;
@property (strong, nonatomic) IBOutlet UILabel *body3FontLabel;

@property (strong, nonatomic) IBOutlet UIStepper *styleStep;
@property (strong, nonatomic) IBOutlet UILabel *styleLabel;
@property (strong, nonatomic) IBOutlet UIStepper *sizeStep;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;

@property (strong, nonatomic) IBOutlet UISwitch *btnOrderSwitch;

@property (strong, nonatomic) IBOutlet UIButton *showBtn;

- (IBAction)show:(id)sender;

- (IBAction)adjTitleFontSize:(id)sender;
- (IBAction)adjSubtitleFontSize:(id)sender;
- (IBAction)adjLabel1FontSize:(id)sender;
- (IBAction)adjLabel2FontSize:(id)sender;
- (IBAction)adjLabel3FontSize:(id)sender;
- (IBAction)adjStyle:(id)sender;
- (IBAction)adjSize:(id)sender;
- (IBAction)adjBtnOrder:(id)sender;

@end
