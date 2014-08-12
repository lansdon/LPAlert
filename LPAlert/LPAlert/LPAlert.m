//
//  LPAlert.m
//  LPAlert
//
//  Created by Lansdon Page on 8/11/14.
//  Copyright (c) 2014 Lansdon Page. All rights reserved.
//

#import "LPAlert.h"
#import "../ACPButton/ACPButton.h"

// IPAD alerts automatically adjust font sizes.
#define IS_IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#pragma mark - DEFAULTS
// DEFAULTS
const int DEF_TITLE_FONT_SIZE = 24;
const int DEF_SUBTITLE_FONT_SIZE = 22;
const int DEF_BODY_FONT_SIZE = 18;
const int DEF_BTN_FONT_SIZE = 20;
const float IPAD_FSIZE_MULT = 2.0;	// ipad multiplies font sizes with this
const NSString* DEF_FONT_NAME = @"Helvetica";
UIColor* DEF_BG_COLOR;




#pragma mark - Button Object
///////////////////////////////////////
// Button Obj
// Used to store button settings which buttons are generated from.
/////////////////////////////////////////
@interface ButtonObj : NSObject
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, strong) ButtonCallbackBlock actionBlock;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, weak) NSNumber * horizontalButtons;

- (id) initWithKey: (NSString*)key text:(NSString*)text actionBlock:(ButtonCallbackBlock)callBackBlock;
- (id) initWithKey: (NSString*)key text:(NSString*)text color:(UIColor*)color horizontalButtons:(NSNumber*)horizontalButtons actionBlock:(ButtonCallbackBlock)callBackBlock;

@end

@implementation ButtonObj

- (id) initWithKey: (NSString*)key text:(NSString*)text actionBlock:(ButtonCallbackBlock)actionBlock {
	self = [super init];
	if(self) {
		_key = key;
		_text = text;
		_actionBlock = actionBlock;
	}
	return self;
}

- (id) initWithKey: (NSString*)key text:(NSString*)text color:(UIColor*)color horizontalButtons:(NSNumber*)horizontalButtons actionBlock:(ButtonCallbackBlock)callBackBlock {
	self = [super init];
	if(self) {
		_key = key;
		_text = text;
		_actionBlock = callBackBlock;
        _color = color;
        _horizontalButtons = horizontalButtons;
	}
	return self;
}
@end
////////////////////////////// END BUTTON OBJ //////////////////////////////////////////



#pragma mark - LPAlert
// >>>>>>>>>>>>>>>>>>> LPAlert <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// Custom alert class for displaying arbitrary collections of
// labels and buttons
// The alert includes a Title and Subtitle field.
// Also has the ability to assign a background image..
// ////////////////////////////////////////////////////////////
static LPAlert* __singletonAlert = nil;
@interface LPAlert() {
	bool restoreScreenSaver;
	NSMutableArray* buttons;
	NSMutableArray* bodyLabels;
	float titleHeight;
	float subTitleHeight;
	float buttonHeight;
	
	// STYLE
	AlertStyles		alertStyleType;
	// SIZE
	AlertSizes		alertSizeType;
	CGRect			alertFrame;
	
	
}


// FONTS - See setFontType
@property (nonatomic, strong) NSNumber*			titleFontSize;
@property (nonatomic, strong) NSNumber*			subtitleFontSize;
@property (nonatomic, strong) NSNumber*			bodyFontSize;
@property (nonatomic, strong) NSNumber*			btnFontSize;
@property (nonatomic, strong) NSString*			titleFontName;
@property (nonatomic, strong) NSString*			subtitleFontName;
@property (nonatomic, strong) NSString*			bodyFontName;
@property (nonatomic, strong) NSString*			buttonFontName;

// Section Heights Based on percentage of window size.(they must add to 1.0
@property (nonatomic, strong) NSDecimalNumber*	headerHeightPerc;
@property (nonatomic, strong) NSDecimalNumber*	bodyHeightPerc;
@property (nonatomic, strong) NSDecimalNumber*	buttonsHeightPerc;

@end


@implementation LPAlert

#pragma mark Alert CREATION
// Alert Creation - Use these to make a new alert!
+ (LPAlert*) newAlert {
	return [self newAlertWithStyle:ALERT_STYLE_NONE sizeType:ALERT_SIZE_AUTO];
}

+ (LPAlert*) newAlertWithStyle:(AlertStyles)alertStyle {
	return [self newAlertWithStyle:alertStyle sizeType:ALERT_SIZE_AUTO];
}

+ (LPAlert*) newAlertWithSizeType:(AlertSizes)sizeType {
	return [self newAlertWithStyle:ALERT_STYLE_NONE sizeType:sizeType];
}

+ (LPAlert*) newAlertWithStyle:(AlertStyles)alertStyle sizeType:(AlertSizes)sizeType {
	return [self newNestedAlertWithStyle:alertStyle sizeType:sizeType parentView:nil];
}

// Nested alerts will appear inside the parent and it's frame will not exceed the parent size.
+ (LPAlert*) newNestedAlertWithStyle:(AlertStyles)alertStyle sizeType:(AlertSizes)sizeType parentView:(UIView*)parentView {
	
	// Warning!! Order is important!
	LPAlert* alert = [self singletonAlertUsingParent:parentView];
	
	
	// Update parent - This is an optional container view (use to restrict the alert to an area)
	if(parentView)
		alert.parent = parentView;
	
	[alert setAlertStyle:alertStyle];	// This must be setup before [alert setup] !
	[alert setAlertSize:sizeType];		// This must be setup before [alert setup] !
	
	[alert setup];						// This function uses previously defined variables.
	
	return alert;
}

+ (LPAlert*) shared {
	return [self singletonAlertUsingParent:nil];
}

// This is a weird singleton that resets it's object everytime it's called.
+ (LPAlert*) singletonAlertUsingParent:(UIView*)parentView {
	// Reset the object if it exists.
	if(__singletonAlert) {
		[__singletonAlert hide];
		[__singletonAlert removeFromSuperview];
		__singletonAlert = nil;
	}
    
	__singletonAlert = [[LPAlert alloc] initWithParent:parentView];
    return __singletonAlert;
}

#pragma mark Public Controls
- (void) show {
	if(_parent) {
		[self hide];
	}
	
	[self update];
	
	if(!_parent) {
		_parent = [[[UIApplication sharedApplication] windows] firstObject];
		[_parent addSubview:self];
	}
	
	// Try to dismiss the keyboard if it's open
	[_parent endEditing:YES];
	
}

- (void) hide {
	if(_parent) {
		[self removeFromSuperview];
		_parent = nil;
	}
}

+ (void) hide {
	if(__singletonAlert) {
		[__singletonAlert hide];
	}
}

- (void) reset {
	[self hide];
	_backgroundImageView = nil;
	[buttons removeAllObjects];
	[bodyLabels removeAllObjects];
	_buttonTextColor = nil;
	_buttonColor = nil;
	(void)[self init];
}

+ (bool) isVisible {
	if(__singletonAlert)
		return ![__singletonAlert isHidden];
	else return false;
}

#pragma mark Internal Initialization


// Default size is similar to UIAlertView
- (id) initWithParent:(UIView*)parentView {
	// This will determine the area the entire view covers (including transparent outter view.
	if(parentView) self = [super initWithFrame:parentView.bounds];
	else self = [super initWithFrame:[self frameFromPercentageOfScreenWidth:1.0 percentageOfScreenHeight:1.0]];
	
	self = [super init];
	if(self) {
		// Set defaults <<<<<<<<<<<<
		_titleFontName = _subtitleFontName = _bodyFontName = _buttonFontName = (NSString*)DEF_FONT_NAME;
		_titleFontSize = @(DEF_TITLE_FONT_SIZE);
		_subtitleFontSize = @(DEF_SUBTITLE_FONT_SIZE);
		_bodyFontSize = @(DEF_BODY_FONT_SIZE);
		DEF_BG_COLOR = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.75];
		
		_buttonColor = [UIColor lightGrayColor];
		_buttonTextColor = [UIColor blackColor];
		
		_parent = nil;
		
		[self setMultipleTouchEnabled:YES];
		
		buttons = [[NSMutableArray alloc] init];
		bodyLabels = [[NSMutableArray alloc] init];
		
		// Configure transparent Outside view
		[self setBackgroundColor:(UIColor*)DEF_BG_COLOR];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		_title					= @"";
		_subTitle				= @"";
		
		_backgroundColor		= self.backgroundColor;
		_subTitleTextColor		= [UIColor redColor];
		_textColor				= [UIColor darkTextColor];
		_borderColor			= [UIColor blackColor];
		
		_bodyLabelTextAlignment = NSTextAlignmentCenter;
		_bodyLineCount			= [NSNumber numberWithInt:0];
		
		_padding				= [NSNumber numberWithInt:10];
		
		_buttonsHeightPerc		= [[NSDecimalNumber alloc] initWithFloat:0.2];
		
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
								 UIViewAutoresizingFlexibleHeight |
								 UIViewAutoresizingFlexibleLeftMargin |
								 UIViewAutoresizingFlexibleTopMargin);
		
		[self setAlertStyle:ALERT_STYLE_NONE];
		[self setAlertSize:ALERT_SIZE_AUTO];
		
	}
	return self;
}

// Setup requires local settings to be set before running. Otherwise there may be issues.
// Particularly the style and size functions should have been called already.
-(void) setup {
	// Container View is the frame you see around the alert.
	// Container View has background colors etc
	if(_alertView)
		[_alertView removeFromSuperview];
	_alertView = [[UIView alloc] init];
	_alertView.frame = [self centeredFrameFromSourceFrame:alertFrame];
	[_alertView setBackgroundColor:[UIColor lightGrayColor]];
	_alertView.opaque = true;
	[self addSubview:_alertView];
	
	[self update];
}


#pragma mark Frame Helpers
- (CGRect) frameFromPercentageOfScreenWidth:(CGFloat)percentOfScreenWidth percentageOfScreenHeight:(CGFloat)percentageOfHeight {
	NSInteger statsBarHeight = 20;
	CGRect screenRect	= [[UIScreen mainScreen] bounds];
	NSInteger initY = 0;	// Y value for top of frame. in ios7 we want to account for status bar.
	CGFloat viewWidth	= screenRect.size.width * percentOfScreenWidth;
	//	if(!IOS7) {
	screenRect.size.height -= statsBarHeight;
	initY += statsBarHeight;
	//	}
	CGFloat viewHeight	= screenRect.size.height * percentageOfHeight;
	return CGRectMake(0, initY, viewWidth, viewHeight);
}

- (CGRect) centeredFrameFromSourceFrame:(CGRect) frame {
	return CGRectMake(
					  self.bounds.size.width/2 - frame.size.width/2,
					  self.bounds.size.height/2 - frame.size.height/2,
					  frame.size.width,
					  frame.size.height
					  );
}

#pragma mark Layout Operations


// This is the primary drawing function. This will add all the labels/text/buttons to the view prior to displaying
- (void) update {
	
	[self calculateHeights];
	
	CGFloat viewHeight			= _alertView.frame.size.height;
	CGFloat viewWidth			= _alertView.frame.size.width;
	CGFloat subViewWidth		= viewWidth; // - 2.0 * [_padding floatValue];
	
	///////////////////////// Build View with subviews /////////////////////
	UIView *view = _alertView;
	[view clipsToBounds];
	view.backgroundColor = _backgroundColor;
	view.layer.cornerRadius = 5.f;
	view.layer.borderColor = _borderColor.CGColor;
	view.layer.borderWidth = 3.f;
	
	// Adding extra background to ensure space is filled.
	if(_backgroundView) {
		[_backgroundView removeFromSuperview];
	}
	_backgroundView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
	[_backgroundView clipsToBounds];
	_backgroundView.layer.masksToBounds = YES;
	_backgroundView.layer.cornerRadius = 5.0f;
	_backgroundView.backgroundColor = _backgroundColor;
	[view addSubview:_backgroundView];
	
	// Background Image First
	[self setupBackgroundImage];
	
	if(_titleLabel)
		[_titleLabel removeFromSuperview];
	if(![_title length]) { titleHeight = 25; }
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, subViewWidth, titleHeight + [_padding integerValue])];
	[_titleLabel setBackgroundColor:_titleBackgroundColor ? _titleBackgroundColor : [UIColor clearColor]];
	[_titleLabel setText:_title];
	[_titleLabel setTextColor:_titletextColor];
	_titleLabel.textAlignment = NSTextAlignmentCenter;
	[_titleLabel setFont:[self titleFont]];
	_titleLabel.layer.cornerRadius = 5.0f;
	_titleLabel.adjustsFontSizeToFitWidth = YES;
	[view addSubview:_titleLabel];
	
	if(![_subTitle length]) { subTitleHeight = 0; }
	_subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _titleLabel.frame.origin.y+_titleLabel.frame.size.height, subViewWidth, subTitleHeight)];
	[_subTitleLabel setBackgroundColor:_subTitleBackgroundColor ? _subTitleBackgroundColor : [UIColor clearColor]];
	[_subTitleLabel setText:_subTitle];
	[_subTitleLabel setTextColor:_subTitleTextColor];
	_subTitleLabel.textAlignment = NSTextAlignmentCenter;
	[_subTitleLabel setFont:[self subtitleFont]];
	[view addSubview:_subTitleLabel];
	
	////////////////////// LABELS ///////////////////////
	NSInteger currentLabelY = _subTitleLabel.frame.origin.y+subTitleHeight; // buttons start here;
	
	// Place each label sequentially
	for (UILabel* label in bodyLabels) {
		if(label) {
			int labelHeight = [label bounds].size.height;
			[label setFrame:CGRectMake([_padding integerValue], currentLabelY, subViewWidth-2*[_padding integerValue], labelHeight)];
			currentLabelY += labelHeight;
			//			[label setFont:[self bodyFont]];
			[view addSubview:label];
		}
	}
	
	////////////////////// BUTTONS ///////////////////////
	// Place each button sequentially
	// Start at the calculated location for the button area
	//	int currentButtonY = currentLabelY;
	int currentButtonY = ((int)(viewHeight - (viewHeight * [_buttonsHeightPerc floatValue])));
    
    CGFloat currentButtonX = 4; //starts at 4 to make room for button border
    CGFloat marginOffsetX = 4; //offset needed for button border to show
    CGFloat marginOffsetY = 4; //offset needed for button border to show
    NSUInteger TotalButtonCount = [buttons count]; //used for spacing of horizontal buttons
	NSInteger buttonCount = 0, btnIndex = 0;
	for (ButtonObj* btnObj in buttons) {
		if(( btnObj && [[btnObj key] length] && [[btnObj text] length])) {
			NSString* title = [NSString stringWithFormat:@"%@", [btnObj text]];
			NSLog(@"%@", title);
            
            //Check for horizontal vs vertical buttons
            if([btnObj.horizontalButtons intValue] == 0)
            {
                //buttons are vertical
                //2*margin offset x is to move the button off the right border
                ACPButton* curBtn = [[ACPButton alloc] initWithFrame:CGRectMake(currentButtonX, currentButtonY - marginOffsetY, (subViewWidth -(2*marginOffsetX)), buttonHeight)];
                currentButtonY += buttonHeight + 2;
				if(_buttonColor)
					[curBtn setStyle:_buttonColor  andBottomColor:_buttonColor];
                if(_buttonTextColor)
                    [curBtn setLabelTextColor:_buttonTextColor highlightedColor:[UIColor lightGrayColor] disableColor:nil];
                [curBtn setCornerRadius:8.0f];
                if(btnObj.color) //this is a color property that can be set when creating the button
                {
                    [curBtn setStyle:btnObj.color  andBottomColor:btnObj.color];
                }
                [curBtn setTag:btnIndex];			// Use this in action function
                [curBtn setTitle:title forState:UIControlStateNormal];
                curBtn.titleLabel.numberOfLines = 1;
                curBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
				[curBtn.titleLabel setFont:[self buttonlFont]];
                [curBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
				
                [view addSubview:curBtn];
                ++buttonCount;
            }
            else
            {
                //This is for horizontal buttons
                ACPButton* curBtn = [[ACPButton alloc] initWithFrame:CGRectMake(currentButtonX, (viewHeight - buttonHeight) - marginOffsetY, (subViewWidth/TotalButtonCount) - marginOffsetX, buttonHeight)];
                currentButtonX += (subViewWidth/TotalButtonCount) - marginOffsetX;
                if(_buttonColor)
                    [curBtn setStyle:_buttonColor  andBottomColor:_buttonColor];
                if(_buttonTextColor)
                    [curBtn setLabelTextColor:_buttonTextColor highlightedColor:[UIColor lightGrayColor] disableColor:nil];
                [curBtn setCornerRadius:8.0f];
                if(btnObj.color) //this is a color property that can be set when creating the button
                {
                    [curBtn setStyle:btnObj.color  andBottomColor:btnObj.color];
                }
                [curBtn setTag:btnIndex];			// Use this in action function
                [curBtn setTitle:title forState:UIControlStateNormal];
                curBtn.titleLabel.numberOfLines = 1;
                curBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
 				[curBtn.titleLabel setFont:[self buttonlFont]];
				[curBtn addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:curBtn];
                ++buttonCount;
            }
		}
		++btnIndex;
	}
	
	// Center window in parent view (if it exists)
	//	if([self superview]) {
	//		CGRect parent = [self superview].bounds;
	//		CGRect bounds = self.bounds;
	//		CGRect newFrame = CGRectMake(
	//									 parent.size.width/2 - bounds.size.width/2,
	//									 parent.size.height/2 - bounds.size.height/2,
	//									 bounds.size.width,
	//									 bounds.size.height);
	//		self.frame = newFrame;
	//	}
	
}


// This will analyze what views/labels have been added and calculate dimensions for each section (title, subtitle, body, buttons)
-(void)calculateHeights {
	CGFloat viewWidth			= _alertView.frame.size.width;
	CGFloat viewHeight			= _alertView.frame.size.height -7;
	int calculatedViewHeight	= 0;
	// Calculate how many items we have of each type.
	int buttonCount = (int)[buttons count];
	int labelCount = (int)[bodyLabels count];
	if(!buttonCount && !labelCount) return;
	
	////////////////////////////  HEADER /////////////////////////////////
	float headerHeightPerc = 0.2;
	_headerHeightPerc =  _headerHeightPerc ? _headerHeightPerc : [[NSDecimalNumber alloc] initWithFloat:headerHeightPerc];
	titleHeight		= (int)(viewHeight * [_headerHeightPerc floatValue] * 0.6);
	subTitleHeight	= (int)(viewHeight * [_headerHeightPerc floatValue] * 0.4); // ints get rid of artifacts
	calculatedViewHeight += (titleHeight + subTitleHeight);
	
	////////////////////////////// BUTTONS //////////////////////////////
	// We calculate buttons before body in order to not allocate too much room for buttons
	// when they don't need it.
	/////////////////////////////////////////////////////////////////////
	float btnHeightPercTemp = [_buttonsHeightPerc floatValue] > 0.05 ? [_buttonsHeightPerc floatValue] : 0.2;
	float defaultButtonAreaHeight = viewHeight * btnHeightPercTemp;	// Default percent of the REMAINING height for buttons.
	
	// Limit the min/max height of a button
	int buttonMaxH = 75; //viewHeight * 0.25;			// Button can't be taller than 10% of the view
	int buttonMinH = 50;			// Button can't be taller than 10% of the view
	
	float buttonCalculatedHeight = 0;
	int buttonRows = 1;
	for (ButtonObj* btnObj in buttons) {
		if(![btnObj.horizontalButtons boolValue] && btnObj != buttons.firstObject) {
			buttonRows++;
		}
	}
	buttonCalculatedHeight = defaultButtonAreaHeight / buttonRows;
	
	// Min/Max restrictions
	buttonCalculatedHeight = buttonCalculatedHeight < buttonMinH ? buttonMinH : buttonCalculatedHeight;
	buttonCalculatedHeight = buttonCalculatedHeight > buttonMaxH ? buttonMaxH : buttonCalculatedHeight;
	buttonHeight = (int)buttonCalculatedHeight; // update class variable
	
	// This is the size of the entire button area using the min/max heights
	float buttonAreaCalculatedHeight = buttonCalculatedHeight * buttonRows;
	calculatedViewHeight += buttonAreaCalculatedHeight;
	
	// Do we need more space than the default gives us?
	if(buttonAreaCalculatedHeight > defaultButtonAreaHeight) {
		NSLog(@"LPAlert - Button area wants more. %f of %f requested", buttonAreaCalculatedHeight, viewHeight);
	}
	
	_buttonsHeightPerc = [[NSDecimalNumber alloc] initWithFloat:buttonAreaCalculatedHeight/viewHeight];
	NSLog(@"LPAlert - Button area height perc:%@", _buttonsHeightPerc);
	
	
	////////////////////////////// Labels //////////////////////////////
	// We calculate buttons before body in order to not allocate too much room for buttons
	// when they don't need it.
	/////////////////////////////////////////////////////////////////////
	float defaultLabelAreaHeight = viewHeight - (viewHeight*([_buttonsHeightPerc floatValue]+headerHeightPerc));	// Default percent of the REMAINING height for labels.
	
	// Limit the min/max height of a button
	int labelMaxH = 200;
	float labelAreaCalculatedHeight = 0;
	CGSize maximumLabelSize = CGSizeMake(viewWidth-2*[_padding integerValue],labelMaxH);
	
	//Calculate the expected size based on the font and linebreak mode of the labels
	for(UILabel* label in bodyLabels) {
		
		CGRect newFrame = [label.attributedText
						   boundingRectWithSize:maximumLabelSize
						   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
						   context:nil];
		
		newFrame.size.height = newFrame.size.height > labelMaxH ? labelMaxH : newFrame.size.height;
		label.frame = newFrame;
		labelAreaCalculatedHeight += newFrame.size.height;
	}
	
	// Now we've calculated how much space the labels will take up based on their text.
	// Now adjust their sizes to fill up the text area evenly (if needed).
	if(labelAreaCalculatedHeight > 0 && labelAreaCalculatedHeight < defaultLabelAreaHeight) {
		float ratio = defaultLabelAreaHeight / labelAreaCalculatedHeight;
		for(UILabel* label in bodyLabels) {
			CGRect adjustedFrame = label.frame;
			
			adjustedFrame.size.height = label.frame.size.height * ratio;
			label.frame = adjustedFrame;
		}
	}
	calculatedViewHeight += defaultLabelAreaHeight;
	
	// Do we need more space than the default gives us?
	if(labelAreaCalculatedHeight > defaultLabelAreaHeight) {
		NSLog(@"LPAlert - Label area wants more. %f of %f requested", labelAreaCalculatedHeight, viewHeight);
	}
	
	_bodyHeightPerc = [[NSDecimalNumber alloc] initWithFloat:labelAreaCalculatedHeight/viewHeight];
	NSLog(@"LPAlert - Label area height perc:%@", _bodyHeightPerc);
	
}



#pragma mark Background Images

// internal
-(void)setupBackgroundImage {
	if(!_backgroundImageView) return;
	[_backgroundImageView removeFromSuperview];
	[_backgroundImageView clipsToBounds];
	[_backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
	[_backgroundImageView setAlpha:0.3];
	_backgroundImageView.layer.cornerRadius = 5.0f;
	
	[_alertView addSubview:_backgroundImageView];
}

- (void) setBackgroundImage:(UIImage*)image {
	if(image) {
		_backgroundImageView = [[UIImageView alloc] initWithFrame:_alertView.bounds];
		if(_backgroundImageView) {
			[_backgroundImageView setImage:image];
			[self setupBackgroundImage];
		}
	}
}

-(void) setBackgroundImageWithFile:(NSString*)filename {
	UIImage* backgroundImage = [UIImage imageNamed:filename];
	[self setBackgroundImage: backgroundImage];
}



#pragma mark Buttons
- (void) addButton:(NSString*)key text:(NSString*)text actionBlock:(ButtonCallbackBlock)callbackBlock {
	[self addButton:key text:text color:_buttonColor horizontalButton:NO actionBlock:callbackBlock];
}

- (void) addButton:(NSString*)key text:(NSString*)text color:(UIColor *)color actionBlock:(ButtonCallbackBlock)callbackBlock {
	[self addButton:key text:text color:color horizontalButton:NO actionBlock:callbackBlock];
}

- (void) addButton:(NSString*)key text:(NSString*)text color:(UIColor *)color
  horizontalButton:(BOOL)horizontalButton actionBlock:(ButtonCallbackBlock)callbackBlock {
	ButtonObj* btn = [[ButtonObj alloc] initWithKey:key text:text color:color ? color : _buttonColor horizontalButtons:@(horizontalButton) actionBlock:callbackBlock];
	[buttons addObject:btn];
}

-(void)buttonPress:(id)sender {
	NSNumber* buttonIndex = [NSNumber numberWithInteger:[sender tag]];
	ButtonObj* btnObj = [buttons objectAtIndex:[buttonIndex integerValue]];
	NSLog(@"Button selected: index(%ld), key(%@)", (long)[sender tag], btnObj.key);
		
	[self hide];
	
	// Call the block assigned to the button (if it exists)
	if(btnObj.actionBlock)
		btnObj.actionBlock(btnObj.key);
	
}



#pragma mark Labels
// The primary method to add a label. Everything else leads here.
- (UILabel*) addLabel:(NSString*)text font:(UIFont*)font color:(UIColor*)color {
	UILabel* label = [[UILabel alloc] init];
	[label setText:text];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setOpaque:false];
	[label setTextColor:color ? color : _textColor];
	label.lineBreakMode = NSLineBreakByWordWrapping;
	label.numberOfLines = [_bodyLineCount integerValue];
	label.textAlignment = _bodyLabelTextAlignment;
	
	// Adjust font size for IPAD to be larger
	if(IS_IPAD)
		font = [font fontWithSize: font.pointSize * IPAD_FSIZE_MULT];
	[label setFont:font];
	
	[bodyLabels addObject:label];
	
	return label;
}

- (UILabel*) addLabel:(NSString*)text {
	return [self addLabel:text font:[self bodyFont] color:nil];
}

- (UILabel*) addLabel:(NSString*)text fontSize:(NSInteger)fontSize color:(UIColor*)color {
	return [self addLabel:text font:[UIFont fontWithName:_bodyFontName size:fontSize] color:color];
}

- (UILabel*) addLabel:(NSString*)text fontType:(AlertFontTypes)fontType {
	return [self addLabel:text font:[self fontForType:fontType] color:nil];
}

- (UILabel*) addLabel:(NSString*)text fontType:(AlertFontTypes)fontType color:(UIColor*)color {
	return [self addLabel:text font:[self fontForType:fontType] color:color];
}

- (UILabel*) addLabel:(NSString*)text fontSize:(NSInteger)fontSize fontName:(NSString*)fontName color:(UIColor*)color {
	return [self addLabel:text font:[UIFont fontWithName:fontName size:fontSize] color:color];
}



#pragma mark FONTS

////////////////////////////////////////////////////////////
// Set Font Type - Font helper PUBLIC function
// pass null to name to use existing name. If no name exists a default is used.
// pass 0 to size to use existing size. If no size exists, the default is used.
/////////////////////////////////////////////////////////////
-(void) setFontType:(AlertFontTypes)fontType name:(NSString*)name size:(int)size color:(UIColor*)color {
	switch (fontType)
	{
		case TITLE_FONT:
			_titleFontName = name ? name : _titleFontName ? _titleFontName : DEF_FONT_NAME;
			_titleFontSize = size > 0 ? @(size) : @([self calcTitleFontSize]);
			if(color) _titletextColor = color;
			break;
		case SUBTITLE_FONT:
			_subtitleFontName = name ? name : _subtitleFontName ? _subtitleFontName : DEF_FONT_NAME;
			_subtitleFontSize = size > 0 ? @(size) : @([self calcSubtitleFontSize]);
			if(color) _subTitleTextColor = color;
			break;
		case BODY_FONT:
			_bodyFontName = name ? name : _bodyFontName ? _bodyFontName : DEF_FONT_NAME;
			_bodyFontSize = size > 0 ? @(size) : @([self calcBodyFontSize]);
			if(color) _textColor = color;
			break;
		case BUTTON_FONT:
			_buttonFontName = name ? name : _buttonFontName ? _buttonFontName : DEF_FONT_NAME;
			_bodyFontSize = size > 0 ? @(size) : @([self calcButtonFontSize]);
			if(color) _textColor = color;
			break;
	}
}

-(void) setFontType:(AlertFontTypes)fontType name:(NSString*)name size:(int)size {
	[self setFontType:fontType name:name size:size color:nil];
}


-(void) setFontType:(AlertFontTypes)fontType font:(UIFont*)font color:(UIColor*)color {
	[self setFontType:fontType name:[font fontName] size:[font pointSize] color:color];
}

-(void) setFontType:(AlertFontTypes)fontType font:(UIFont*)font {
	[self setFontType:fontType font:font color:nil];
}

-(UIFont*)titleFont {
	return [UIFont fontWithName:_titleFontName size:[self calcTitleFontSize]];
}

-(UIFont*)subtitleFont {
	return [UIFont fontWithName:_subtitleFontName size:[self calcSubtitleFontSize]];
}

-(UIFont*)bodyFont {
	return [UIFont fontWithName:_bodyFontName size:[self calcBodyFontSize]];
}

-(UIFont*)buttonlFont {
	return [UIFont fontWithName:_buttonFontName size:[self calcButtonFontSize]];
}

-(int)calcTitleFontSize {
	int size = (_titleFontSize && [_titleFontSize intValue] > 0) ? [_titleFontSize intValue] : DEF_TITLE_FONT_SIZE;
	if ( IS_IPAD ) size *= IPAD_FSIZE_MULT;
	return (int)size;
}

-(int)calcSubtitleFontSize {
	int size = (_subtitleFontSize && [_subtitleFontSize intValue] > 0) ? [_subtitleFontSize intValue] : DEF_SUBTITLE_FONT_SIZE;
	if ( IS_IPAD ) size *= IPAD_FSIZE_MULT;
	return (int)size;
}

-(int)calcBodyFontSize {
	int size = (_bodyFontSize && [_bodyFontSize intValue] > 0) ? [_bodyFontSize intValue] : DEF_BODY_FONT_SIZE;
	if ( IS_IPAD ) size *= IPAD_FSIZE_MULT;
	return (int)size;
}

-(int)calcButtonFontSize {
	int size = (_btnFontSize && [_btnFontSize intValue] > 0) ? [_btnFontSize intValue] : DEF_BTN_FONT_SIZE;
	if ( IS_IPAD ) size *= IPAD_FSIZE_MULT;
	return (int)size;
}

-(UIFont*) fontForType:(AlertFontTypes)fontType {
	switch (fontType) {
		case TITLE_FONT: return [self titleFont]; break;
		case SUBTITLE_FONT: return [self subtitleFont]; break;
		case BODY_FONT: return [self bodyFont]; break;
		case BUTTON_FONT:
		default: return [self buttonlFont]; break;
	}
}


#pragma mark STYLES
////////////////////////////////////////////////////////////
// ALERT STYLES
// Set the look of the alert. This effects colors, and appearance.
/////////////////////////////////////////////////////////////
-(void) setAlertStyle:(AlertStyles)style {
	alertStyleType = style;
	switch (style) {
		case ALERT_STYLE_ERROR:
			_titletextColor = [UIColor darkTextColor];
			_titleBackgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:27.0 / 255.0 blue:27.0 / 255.0 alpha:1.0];
			_textColor = [UIColor colorWithRed:82.0 / 255.0 green:32.0 / 255.0 blue:1.0 / 255.0 alpha:1.0];
			_buttonColor = [UIColor colorWithRed:100.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0];
			_buttonTextColor = [UIColor whiteColor];
			[self setBackgroundColor:DEF_BG_COLOR];
			break;
			
		case ALERT_STYLE_WARNING:
			_titletextColor = [UIColor darkTextColor];
			_titleBackgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:166.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
			_textColor = [UIColor darkGrayColor];
			_buttonColor = [UIColor colorWithRed:100.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0];
			_buttonTextColor = [UIColor whiteColor];
			[self setBackgroundColor:DEF_BG_COLOR];
			break;
			
		case ALERT_STYLE_LP:
			_titletextColor = [UIColor redColor];
			_titleBackgroundColor = [UIColor blackColor];
			_textColor = [UIColor darkTextColor];
			_buttonColor = [UIColor darkGrayColor];
			_buttonTextColor = [UIColor lightTextColor];
			[self setBackgroundColor:[UIColor lightGrayColor]];
			break;
			
		case ALERT_STYLE_NONE:
		default:
			alertStyleType = ALERT_STYLE_NONE;	// Catch invalid args and use default
			_titletextColor = [UIColor darkTextColor];
			_titleBackgroundColor = [UIColor clearColor];
			_subTitleBackgroundColor = [UIColor clearColor];
			_subTitleTextColor = [UIColor darkTextColor];
			_textColor = [UIColor darkTextColor];
			_buttonColor = [UIColor colorWithRed:99.0 / 255.0 green:99.0 / 255.0 blue:99.0 / 255.0 alpha:0.5];
			_buttonTextColor = [UIColor whiteColor];
			[self setBackgroundColor:DEF_BG_COLOR];
			break;
	}
}

////////////////////////////////////////////////////////////
// ALERT SIZES
// Set the alert size
/////////////////////////////////////////////////////////////
-(void) setAlertSize:(AlertSizes)sizeType {
	alertSizeType = sizeType;
	switch (sizeType) {
		case ALERT_SIZE_FULL_SCREEN:
			alertFrame = [self frameFromPercentageOfScreenWidth:1.0 percentageOfScreenHeight:1.0];
			break;
		case ALERT_SIZE_LARGE:
			alertFrame = [self frameFromPercentageOfScreenWidth:0.9 percentageOfScreenHeight:0.8];
			break;
		case ALERT_SIZE_MED:
			alertFrame = [self frameFromPercentageOfScreenWidth:0.85 percentageOfScreenHeight:0.6];
			break;
		case ALERT_SIZE_SMALL:
			alertFrame = [self frameFromPercentageOfScreenWidth:0.75 percentageOfScreenHeight:0.4];
			break;
		case ALERT_SIZE_AUTO:
		default:
			alertFrame = [self frameFromPercentageOfScreenWidth:0.8 percentageOfScreenHeight:0.4];
			break;
	}
}

-(void) setAlertSizeWithFrame:(CGRect)frame {
	alertFrame = frame;
}

-(void) setAlertSizeWithPercentOfScreenWidth:(CGFloat)percOfWidth percentOfScreenHeight:(CGFloat)percOfHeight {
	alertFrame = [self frameFromPercentageOfScreenWidth:percOfWidth percentageOfScreenHeight:percOfHeight];
}


@end





