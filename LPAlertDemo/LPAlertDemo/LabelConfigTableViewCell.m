//
//  LabelConfigTableViewCell.m
//  LPAlertDemo
//
//  Created by Lansdon Page on 8/12/14.
//  Copyright (c) 2014 Lansdon Page. All rights reserved.
//

#import "LabelConfigTableViewCell.h"
#import "DemoTableViewController.h"

const int MIN_FONT = 12;
const int MAX_FONT = 48;

const int MIN_STYLE = 0;
const int MAX_STYLE = 3;

const int MIN_SIZE = 0;
const int MAX_SIZE = 4;

const int MIN_COLOR = 0;
const int MAX_COLOR = COLOR_TOTAL - 1;




@implementation LabelConfigTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		_fontColorStep.minimumValue = 0;
		_backColorStep.minimumValue = 0;
		_fontStep.minimumValue = MIN_FONT;
		_fontStep.maximumValue = MAX_FONT;
		[_fontStep setValue:MIN_FONT];
		
		[self fontColorChanged:nil];
		[self bgColorChanged:nil];
		[self fontSizeChanged:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
	_fontColorStep.minimumValue = 0;
	_backColorStep.minimumValue = 0;
	_fontStep.minimumValue = MIN_FONT;
	_fontStep.maximumValue = MAX_FONT;
	[_fontStep setValue:MIN_FONT];
	
	[self fontColorChanged:nil];
	[self bgColorChanged:nil];
	[self fontSizeChanged:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) update {	// Can be used externally to update labels
	[self fontColorChanged:nil];
	[self bgColorChanged:nil];
	[self fontSizeChanged:nil];
}

- (IBAction)textChanged:(id)sender {
	[self cellChanged];
}

- (IBAction)fontSizeChanged:(id)sender {
	[_fontSizeLabel setText:[NSString stringWithFormat:@"Font Size: %d", (int)_fontStep.value]];
	[self cellChanged];
}
- (IBAction)bgColorChanged:(id)sender {
	NSLog(@"bg color = %f", _backColorStep.value);
	ColorList type = [self colorTypeFromValue:_backColorStep.value];
	[_backColorLabel setText:[NSString stringWithFormat:@"BG Color: %@", [self stringForColorType:type]]];
	[self cellChanged];
}

- (IBAction)fontColorChanged:(id)sender {
	ColorList type = [self colorTypeFromValue:_fontColorStep.value];
	[_colorLabel setText:[NSString stringWithFormat:@"Font Color: %@", [self stringForColorType:type]]];
	[self cellChanged];
}

-(void)cellChanged {
	if(_delegate)
		[_delegate cellDidChange:self];
}

-(ColorList)colorTypeFromValue:(float)value {
	return (ColorList)((int)value % COLOR_TOTAL);
}

- (UIColor*)colorForType:(ColorList)type {
	switch (type) {
		case CLEAR_COLOR: return [UIColor clearColor]; break;
		case BLACK_COLOR: return [UIColor blackColor]; break;
		case BLUE_COLOR: return [UIColor blueColor]; break;
		case RED_COLOR: return [UIColor redColor]; break;
		case GREEN_COLOR: return [UIColor greenColor]; break;
		case ORANGE_COLOR: return [UIColor orangeColor]; break;
		case YELLOW_COLOR: return [UIColor yellowColor]; break;
		default: return [UIColor blackColor]; break;
	}
}

- (NSString*)stringForColorType:(ColorList)type {
	switch (type) {
		case CLEAR_COLOR: return @"Clear"; break;
		case BLACK_COLOR: return @"Black"; break;
		case BLUE_COLOR: return @"Blue"; break;
		case RED_COLOR: return @"Red"; break;
		case GREEN_COLOR: return @"Green"; break;
		case ORANGE_COLOR: return @"Orange"; break;
		case YELLOW_COLOR: return @"Yellow"; break;
		default: return @"Black"; break;
	}
}
@end
