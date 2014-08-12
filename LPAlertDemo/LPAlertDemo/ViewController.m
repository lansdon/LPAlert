//
//  ViewController.m
//  LPAlertDemo
//
//  Created by Lansdon Page on 8/11/14.
//  Copyright (c) 2014 Lansdon Page. All rights reserved.
//

#import "ViewController.h"
#import "LPAlert/LPAlert.h"

const int MIN_FONT = 12;
const int MAX_FONT = 48;

const int MIN_STYLE = 0;
const int MAX_STYLE = 3;

const int MIN_SIZE = 0;
const int MAX_SIZE = 4;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Font switches and labels
	_titleFontStep.minimumValue = MIN_FONT;
	_titleFontStep.maximumValue = MAX_FONT;
	[_titleFontStep setValue:28];
	[self adjTitleFontSize:nil];
	
	_subtitleFontStep.minimumValue = MIN_FONT;
	_subtitleFontStep.maximumValue = MAX_FONT;
	[_subtitleFontStep setValue:22];
	[self adjSubtitleFontSize:nil];
	
	_body1FontStep.minimumValue = MIN_FONT;
	_body1FontStep.maximumValue = MAX_FONT;
	[_body1FontStep setValue:18];
	[self adjLabel1FontSize:nil];
	
	_body2FontStep.minimumValue = MIN_FONT;
	_body2FontStep.maximumValue = MAX_FONT;
	[_body2FontStep setValue:12];
	[self adjLabel2FontSize:nil];
	
	_body3FontStep.minimumValue = MIN_FONT;
	_body3FontStep.maximumValue = MAX_FONT;
	[_body3FontStep setValue:16];
	[self adjLabel3FontSize:nil];

	_styleStep.minimumValue = MIN_STYLE;
	_styleStep.maximumValue = MAX_STYLE;
	[_styleStep setValue:MIN_STYLE];
	[self adjStyle:nil];
	
	_sizeStep.minimumValue = MIN_SIZE;
	_sizeStep.maximumValue = MAX_SIZE;
	[_sizeStep setValue:MIN_SIZE];
	[self adjSize:nil];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SHOW
- (IBAction)show:(id)sender {
	LPAlert* alert = [LPAlert newAlertWithStyle:(AlertStyles)(int)_styleStep.value sizeType:(AlertSizes)(int)_sizeStep.value];
	[alert setTitle:_titleTF.text];
	[alert setFontType:TITLE_FONT name:nil size:(int)_titleFontStep.value];
	[alert setSubTitle:_subtitleTF.text];
	[alert setFontType:SUBTITLE_FONT name:nil size:(int)_subtitleFontStep.value];
	if(_body1TF.text.length)
		[alert addLabel:_body1TF.text fontSize:(int)_body1FontStep.value color:nil];
	if(_body2TF.text.length)
		[alert addLabel:_body2TF.text fontSize:(int)_body2FontStep.value color:nil];
	if(_body3TF.text.length)
		[alert addLabel:_body3TF.text fontSize:(int)_body3FontStep.value color:nil];
	if(_button1TF.text.length)
		[alert addButton:_button1TF.text text:_button1TF.text color:nil horizontalButton:!_btnOrderSwitch.on actionBlock:nil];
	if(_button2TF.text.length)
		[alert addButton:_button2TF.text text:_button2TF.text color:nil horizontalButton:!_btnOrderSwitch.on actionBlock:nil];
	[alert show];
}


#pragma mark View Input
- (IBAction)adjTitleFontSize:(id)sender {
	[_titleFontLabel setText:[NSString stringWithFormat:@"%d", (int)_titleFontStep.value]];
}
- (IBAction)adjSubtitleFontSize:(id)sender {
	[_subtitleFontLabel setText:[NSString stringWithFormat:@"%d", (int)_subtitleFontStep.value]];
}
- (IBAction)adjLabel1FontSize:(id)sender {
	[_body1FontLabel setText:[NSString stringWithFormat:@"%d", (int)_body1FontStep.value]];
}
- (IBAction)adjLabel2FontSize:(id)sender {
	[_body2FontLabel setText:[NSString stringWithFormat:@"%d", (int)_body2FontStep.value]];
}
- (IBAction)adjLabel3FontSize:(id)sender {
	[_body3FontLabel setText:[NSString stringWithFormat:@"%d", (int)_body3FontStep.value]];
}
- (IBAction)adjStyle:(id)sender {
	NSString* style = nil;
	switch((AlertStyles)(int)_styleStep.value)
	{
		case ALERT_STYLE_ERROR: style = @"Error"; break;
		case ALERT_STYLE_LP: style = @"LP Special"; break;
		case ALERT_STYLE_NONE: style = @"None"; break;
		case ALERT_STYLE_WARNING: style = @"Warning"; break;
		default: style = @"oops";
	}
	
	[_styleLabel setText:[NSString stringWithFormat:@"Style: %@", style]];
}
- (IBAction)adjSize:(id)sender {
	NSString* size = nil;
	switch((AlertSizes)(int)_sizeStep.value)
	{
		case ALERT_SIZE_AUTO: size = @"Auto"; break;
		case ALERT_SIZE_FULL_SCREEN: size = @"Full Screen"; break;
		case ALERT_SIZE_LARGE: size = @"Large"; break;
		case ALERT_SIZE_MED: size = @"Medium"; break;
		case ALERT_SIZE_SMALL: size = @"Small"; break;
		default: size = @"oops";
	}
	
	[_sizeLabel setText:[NSString stringWithFormat:@"Size: %@", size]];
}

- (IBAction)adjBtnOrder:(id)sender {
}

@end
