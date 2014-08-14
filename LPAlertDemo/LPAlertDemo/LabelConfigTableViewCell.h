//
//  LabelConfigTableViewCell.h
//  LPAlertDemo
//
//  Created by Lansdon Page on 8/12/14.
//  Copyright (c) 2014 Lansdon Page. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ColorList) {
	CLEAR_COLOR,
    BLACK_COLOR,
    BLUE_COLOR,
    RED_COLOR,
	GREEN_COLOR,
	ORANGE_COLOR,
	YELLOW_COLOR,
	COLOR_TOTAL
};

@class LabelConfigTableViewCell;

@protocol LabelConfigCellDelegate <NSObject>

-(void) cellDidChange:(LabelConfigTableViewCell*)cell;

@end

@interface LabelConfigTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextField *textTF;
@property (strong, nonatomic) IBOutlet UIStepper *fontStep;
@property (strong, nonatomic) IBOutlet UILabel *fontSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *colorLabel;
@property (strong, nonatomic) IBOutlet UILabel *backColorLabel;
@property (strong, nonatomic) IBOutlet UIStepper *fontColorStep;
@property (strong, nonatomic) IBOutlet UIStepper *backColorStep;

@property (nonatomic) id delegate;

- (void) update;	// Can be used externally to update labels
- (IBAction)textChanged:(id)sender;
- (IBAction)fontSizeChanged:(id)sender;
- (IBAction)bgColorChanged:(id)sender;
- (IBAction)fontColorChanged:(id)sender;
@end
