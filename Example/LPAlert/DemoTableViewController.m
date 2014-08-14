//
//  DemoTableViewController.m
//  LPAlertDemo
//
//  Created by Lansdon Page on 8/12/14.
//  Copyright (c) 2014 Lansdon Page. All rights reserved.
//

#import "DemoTableViewController.h"
#import "LabelConfigTableViewCell.h"
#import <LPAlert.h>


typedef NS_ENUM(NSUInteger, TableSections) {
    TITLE_SECTION,
    SUBTITLE_SECTION,
    LABELS_SECTION,
	BUTTONS_SECTION
};

#pragma mark - LabelConfig Object
// These objects are used to hold label configurations that are set in LabelConfigTableViewCell
@interface LabelConfig : NSObject <LabelConfigCellDelegate>
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSNumber *fontSize;
@property (strong, nonatomic) NSNumber *fontColor;
@property (strong, nonatomic) NSNumber *bgColor;
-(id)init;
-(void)importFromCell:(LabelConfigTableViewCell*)cell;
-(void)exportToCell:(LabelConfigTableViewCell*)cell;
@end

@implementation LabelConfig
-(id) init {
	self = [super init];
	if(self) {
		_text = @"";
		_fontSize = @(20);
		_fontColor = @(2);
		_bgColor = @(0);
	}
	return self;
}
#pragma LabelConfigCell Delegate
-(void)cellDidChange:(LabelConfigTableViewCell *)cell {
	[self importFromCell:cell];
}

#pragma mark import/export
-(void)importFromCell:(LabelConfigTableViewCell*)cell {
	_text = cell.textTF.text;
	_fontSize = @((int)cell.fontStep.value);
	_fontColor = @((int)cell.fontColorStep.value);
	_bgColor = @((int)cell.backColorStep.value);
}

-(void)exportToCell:(LabelConfigTableViewCell*)cell {
	cell.textTF.text = _text;
	cell.fontStep.value = [_fontSize intValue];
	cell.fontColorStep.value = [_fontColor intValue];
	cell.backColorStep.value = [_bgColor intValue];
	cell.delegate = self;
	[cell update];	// update the labels
}

@end

#pragma mark - DemoTableViewController

@interface DemoTableViewController ()
@property (strong, nonatomic) LabelConfig* titleConfig;
@property (strong, nonatomic) LabelConfig* subtitleConfig;
@end

@implementation DemoTableViewController {
	NSMutableArray *labelConfigs;
	NSMutableArray *buttonConfigs;
}

#pragma mark View Controller
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	buttonConfigs = [[NSMutableArray alloc] init];
	labelConfigs = [[NSMutableArray alloc] init];
	
	_titleConfig = [[LabelConfig alloc] init];
	_titleConfig.text = @"Chill Man";
	_subtitleConfig = [[LabelConfig alloc] init];
	LabelConfig* btnConfig = [[LabelConfig alloc] init];
	btnConfig.text = @"Okie Dokey";
	[buttonConfigs addObject:btnConfig];
	
	[self styleChanged:nil];
	[self sizeChanged:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case TITLE_SECTION: return 1; break;
		case SUBTITLE_SECTION: return 1; break;
		case LABELS_SECTION: return [labelConfigs count]; break;
		case BUTTONS_SECTION: return [buttonConfigs count]; break;
		default: return 0; break;
	}
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case TITLE_SECTION: return @"Title (optional)"; break;
		case SUBTITLE_SECTION: return @"Subtitle (optional)"; break;
		case LABELS_SECTION: return @"Labels (optional)"; break;
		case BUTTONS_SECTION: return @"Buttons (need 1!)"; break;
		default: return 0; break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LabelConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelConfigCell" forIndexPath:indexPath];
    LabelConfig* config = nil;	// This is the data member that corresponds to the cell
	switch (indexPath.section) {
		case TITLE_SECTION:  config = _titleConfig; break;
		case SUBTITLE_SECTION: config = _subtitleConfig; break;
		case LABELS_SECTION: config = [labelConfigs objectAtIndex:indexPath.row]; break;
		case BUTTONS_SECTION: config = [buttonConfigs objectAtIndex:indexPath.row]; break;
		default: assert(false); break;
	}
	
	// Associate the cell with it's data member and setup delegate
	[config exportToCell:cell];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark SHOW

- (IBAction)showAlertPressed:(id)sender {
//	[self synchConfigsWithTable];
	
	
	LPAlert* alert = [LPAlert newAlertWithStyle:(AlertStyles)(int)_styleStepper.value sizeType:(AlertSizes)(int)_sizeStep.value];
	[alert setTitle:_titleConfig.text];
	alert.titleBackgroundColor = [self colorForNumber:_titleConfig.bgColor];
	[alert setFontType:TITLE_FONT name:nil size:[_titleConfig.fontSize intValue] color:[self colorForNumber:_titleConfig.fontColor]];
	[alert setSubTitle:_subtitleConfig.text];
	alert.subTitleBackgroundColor = [self colorForNumber:_subtitleConfig.bgColor];
	[alert setFontType:SUBTITLE_FONT name:nil size:[_subtitleConfig.fontSize intValue] color:[self colorForNumber:_subtitleConfig.fontColor]];
	
	for (LabelConfig* config in labelConfigs) {
		if(config.text.length) {
			UILabel* label = [alert addLabel:config.text fontSize:[config.fontSize intValue] color:[self colorForNumber:config.fontColor]];
			label.backgroundColor = [self colorForNumber:config.bgColor];
		}
	}
	
	for (LabelConfig* config in buttonConfigs) {
		if(config.text.length) {
			[alert addButton:config.text text:config.text color:[self colorForNumber:config.bgColor] horizontalButton:_btnLayoutSwitch.on actionBlock:nil];
			alert.buttonTextColor = [self colorForNumber:config.fontColor];
		}
	}
	if(_showImageSwitch.on)
		[alert setBackgroundImageWithFile:@"AppleLogo"];
	[alert show];
}


#pragma mark Color Conversions
- (UIColor*)colorForType:(ColorList)type {
	switch (type) {
		case CLEAR_COLOR: return [UIColor clearColor]; break;
		case BLACK_COLOR: return [UIColor blackColor]; break;
		case BLUE_COLOR: return [UIColor blueColor]; break;
		case RED_COLOR: return [UIColor redColor]; break;
		case GREEN_COLOR: return [UIColor greenColor]; break;
		case ORANGE_COLOR: return [UIColor orangeColor]; break;
		case YELLOW_COLOR: return [UIColor yellowColor]; break;
		default: return [UIColor clearColor]; break;
	}
}

// For use with ColorList enum
-(UIColor*)colorForNumber:(NSNumber*)type {
	return [self colorForType:(ColorList)[type intValue]];
}

#pragma mark Add Labels
- (IBAction)addLabelPressed:(id)sender {
	[labelConfigs addObject:[[LabelConfig alloc] init]];
	[self.tableView reloadData];
}
#pragma mark Add Buttons

- (IBAction)addButtonPressed:(id)sender {
	[buttonConfigs addObject:[[LabelConfig alloc] init]];
	[self.tableView reloadData];
}

#pragma Change Style
- (IBAction)styleChanged:(id)sender {
	NSString* style = nil;
	switch((AlertStyles)(int)_styleStepper.value)
	{
		case ALERT_STYLE_ERROR: style = @"Error"; break;
		case ALERT_STYLE_LP: style = @"LP Special"; break;
		case ALERT_STYLE_NONE: style = @"None"; break;
		case ALERT_STYLE_WARNING: style = @"Warning"; break;
		default: style = @"oops";
	}
	[_styleLabel setText:[NSString stringWithFormat:@"Style: %@", style]];
}

#pragma Change Size
- (IBAction)sizeChanged:(id)sender {
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

@end
