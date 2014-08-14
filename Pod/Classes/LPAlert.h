//
//  LPAlert.h
//  LPAlert
//
//  Created by Lansdon Page on 8/11/14.
//  Copyright (c) 2014 Lansdon Page. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AlertFontTypes) {
    TITLE_FONT,
    SUBTITLE_FONT,
    BODY_FONT,
	BUTTON_FONT
};

typedef NS_ENUM(NSUInteger, AlertStyles) {
	ALERT_STYLE_NONE,		// No colors - similar to std alert
	ALERT_STYLE_WARNING,	// Orange header / buttons colored
	ALERT_STYLE_ERROR,		// Red header	/ buttons colored
	ALERT_STYLE_LP
};

typedef NS_ENUM(NSUInteger, AlertSizes) {
	ALERT_SIZE_SMALL,			// Fills approx 1/4 of screen
	ALERT_SIZE_MED,				// Fills approx 1/2 of screen
	ALERT_SIZE_LARGE,			// Fills approx 3/4 of screen
	ALERT_SIZE_FULL_SCREEN,		// Full screen
	ALERT_SIZE_AUTO				// Adjust to content
};


typedef void ((^ButtonCallbackBlock)(NSString* key));

@interface LPAlert : UIView

@property (nonatomic, strong) UIView*			parent;
@property (nonatomic, strong) UIView*			alertView;

@property (nonatomic, strong) NSString*			title;
@property (nonatomic, strong) NSString*			subTitle;

@property (nonatomic, assign) BOOL				useSandyHeader;	// Default SC header

// COLORS
@property (nonatomic, strong) UIColor*			backgroundColor;

@property (nonatomic, strong) UIColor*			titletextColor;
@property (nonatomic, strong) UIColor*			titleBackgroundColor;
@property (nonatomic, strong) UIColor*			subTitleTextColor;
@property (nonatomic, strong) UIColor*			subTitleBackgroundColor;
@property (nonatomic, strong) UIColor*			textColor;
@property (nonatomic, strong) UIColor*			borderColor;
@property (nonatomic, strong) UIColor*			buttonColor;
@property (nonatomic, strong) UIColor*			buttonTextColor;

@property (nonatomic, strong) UILabel*			titleLabel;
@property (nonatomic, strong) UILabel*			subTitleLabel;

@property (nonatomic, strong) NSNumber*			bodyLineCount;
@property (nonatomic) NSTextAlignment			bodyLabelTextAlignment;

@property (nonatomic) NSNumber*					padding;

@property (nonatomic, strong) UIImageView*		backgroundImageView;
@property (nonatomic, strong) UILabel*			backgroundView;

//////////////////////////////////////////////////
// Alert Creation - Use these to make a new alert!
//////////////////////////////////////////////////
+ (LPAlert*) newAlert;
+ (LPAlert*) newAlertWithStyle:(AlertStyles)alertStyle;
+ (LPAlert*) newAlertWithSizeType:(AlertSizes)sizeType;
+ (LPAlert*) newAlertWithStyle:(AlertStyles)alertStyle sizeType:(AlertSizes)sizeType;
// Nested alerts will appear inside the parent and it's frame will not exceed the parent size.
+ (LPAlert*) newNestedAlertWithStyle:(AlertStyles)alertStyle sizeType:(AlertSizes)sizeType parentView:(UIView*)parentView;

//////////////////////////////////////////////////
// Basic Controls
//////////////////////////////////////////////////
- (void) show;
- (void) hide;
+ (void) hide;
- (void) reset;
+ (bool) isVisible;

//////////////////////////////////////////////////
// Add Buttons
//////////////////////////////////////////////////
- (void) addButton:(NSString*)key text:(NSString*)text actionBlock:(ButtonCallbackBlock)callbackBlock;
- (void) addButton:(NSString*)key text:(NSString*)text color:(UIColor *)color actionBlock:(ButtonCallbackBlock)callbackBlock;
- (void) addButton:(NSString*)key text:(NSString*)text color:(UIColor *)color
  horizontalButton:(BOOL)horizontalButton actionBlock:(ButtonCallbackBlock)callbackBlock;

//////////////////////////////////////////////////
// Add Text (goes after the title and subtitle from top to bottom)
//////////////////////////////////////////////////
- (UILabel*) addLabel:(NSString*)text font:(UIFont*)font color:(UIColor*)color;
- (UILabel*) addLabel:(NSString*)text;
- (UILabel*) addLabel:(NSString*)text fontSize:(NSInteger)fontSize color:(UIColor*)color;
- (UILabel*) addLabel:(NSString*)text fontType:(AlertFontTypes)fontType;
- (UILabel*) addLabel:(NSString*)text fontType:(AlertFontTypes)fontType color:(UIColor*)color;
- (UILabel*) addLabel:(NSString*)text fontSize:(NSInteger)fontSize fontName:(NSString*)fontName color:(UIColor*)color;

//////////////////////////////////////////////////
// Add a single background image that is centered in the view with transparency
//////////////////////////////////////////////////
- (void) setBackgroundImageWithFile:(NSString*)filename;
- (void) setBackgroundImage:(UIImage*)image;

////////////////////////////////////////////////////////////
// Set Font Type - Font helper PUBLIC function
// USE THIS TO CONFIGURE FONTS!
// pass null to name to use existing name. If no name exists a default is used.
// pass 0 to size to use existing size. If no size exists, the default is used.
/////////////////////////////////////////////////////////////
-(void) setFontType:(AlertFontTypes)fontType name:(NSString*)name size:(int)size color:(UIColor*)color;
-(void) setFontType:(AlertFontTypes)fontType name:(NSString*)name size:(int)size;
-(void) setFontType:(AlertFontTypes)fontType font:(UIFont*)font color:(UIColor*)color;
-(void) setFontType:(AlertFontTypes)fontType font:(UIFont*)font;

////////////////////////////////////////////////////////////
// ALERT STYLES
// Set the look of the alert. This effects colors, and appearance.
/////////////////////////////////////////////////////////////
-(void) setAlertStyle:(AlertStyles)style;

////////////////////////////////////////////////////////////
// ALERT SIZES
// Set the alert size
/////////////////////////////////////////////////////////////
-(void) setAlertSize:(AlertSizes)sizeType;
-(void) setAlertSizeWithFrame:(CGRect)frame;
-(void) setAlertSizeWithPercentOfScreenWidth:(CGFloat)percOfWidth percentOfScreenHeight:(CGFloat)percOfHeight;

@end
