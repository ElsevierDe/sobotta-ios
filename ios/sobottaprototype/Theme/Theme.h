//
//  Theme.h
//  sobottaprototype
//
//  Created by Herbert Poul on 8/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SobottaBlueTheme.h"


#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define cLogVerbosity 4

#define KWLogError(format ...) if (cLogVerbosity >= 1 ) NSLog(format)
#define KWLogWarning(format ...) if (cLogVerbosity >= 2 ) NSLog(format)
#define KWLogInfo(format ...) if (cLogVerbosity >= 3 ) NSLog(format)
#define KWLogDebug(format ...) if (cLogVerbosity >= 4 ) NSLog(format)

#define cViewTypePin 0
#define cViewTypeLabel 1
#define cViewTypeImageOnly 2
#define cViewTypeTrainingPin 30
#define cViewTypeTrainingLabel 40
#define cViewTypeRepetitionTrainingPin 50

#define cMaxZoomFactor 2.85
#define cMinZoomFactor 0.75

#define cImageViewDoubleTapZoomScale 1.3
#define cImageViewDoubleTapAnimation NO

#define cCaptionRoundedCornerWidth 5.0
#define cCaptionRoundedCornerHeight 3.0
//#define cCaptionSpacingBottom 9.0
#define cCaptionSpacingBottom 9.0

#define cCaptionDisplayHeight 225.0
//#define cCaptionHideHeight 65.0
#define cCaptionHideHeight 70.0
#define cCaptionClipHeight 25.0

#define cLabelViewFont_Size 16
#define cLabelViewFont_Width 1000

#define cPinAnnotationGreen @"pin_green.png"
#define cPinAnnotationLightGreen @"pin_lightgreen.png"
#define cPinAnnotationRed @"pin_red.png"
#define cPinAnnotationLightRed @"pin_lightred.png"
#define cPinAnnotationBlue @"pin_blue.png"

#define cLabelStateNone 0
#define cLabelStateSolvedCorrect 1
#define cLabelStateSolvedWrong 2
#define cLabelStateSkipped 3
#define cLabelStateResolve 4
#define cLabelStateWrong 5 //used when the user just clicked on the wrong lagel
#define cLabelStateDuplicate 6

#define cNoteColorBlue [UIColor colorWithRed:0 green:175.0/255.0 blue:236.0/255.0 alpha:1.0] //#00afec
#define cNoteColorGreen [UIColor colorWithRed:170.0/255.0 green:211.0/255.0 blue:118.0/255.0 alpha:1.0] //#aad376
#define cNoteColorViolet [UIColor colorWithRed:101.0/255.0 green:49.0/255.0 blue:143.0/255.0 alpha:1.0] //#65318f
#define cNoteColorPink [UIColor colorWithRed:235.0/255.0 green:29.0/255.0 blue:93.0/255.0 alpha:1.0] //#eb1d5d
#define cNoteColorRed [UIColor colorWithRed:235.0/255.0 green:33.0/255.0 blue:46.0/255.0 alpha:1.0] //#eb212e

#define cNotePositionLeft 0
#define cNotePositionRight 1

#define cNoteViewRightPadding 20
#define cNoteViewTopPadding 40
#define cNoteViewLeftPadding 20

#define cNoteIndicatorImageWidth 10
#define cNoteIndicatorImageHeight 11
#define cNoteIndicatorImagePadding 5

#define cTrainingAlertCorrect 100
#define cTrainingAlertWrongFirstTry 110
#define cTrainingAlertWrongSecondTry 120
#define cTrainingAlertNextFigure 130
#define cTrainingAlertEndTraining 140
#define cTrainingAlert100PercentCorrect 150

#define cTrainingViewModeTraining 0
#define cTrainingViewModePageResult 1
#define cTrainingViewModeIntermediateResult 2
#define cTrainingViewModeEndResult 3

@protocol SOTheme <NSObject>


- (UIColor *)mainColor;
- (UIColor *)highlightColor;
- (UIColor *)shadowColor;
- (UIColor *)backgroundColor;

- (UIColor *)baseTintColor;
- (UIColor *)accentTintColor;
- (UIColor *)barTintColor;


- (CGSize)shadowOffset;

- (UIImage *)topShadow;
- (UIImage *)bottomShadow;



- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics;


- (UIImage *)contentButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)barButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)barBackButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
// left/right padding
- (UIFont *) barButtonFont;
- (float) barButtonHorizontalPadding;
// spacing between label and icon
- (float) barButtonImageSpacing;
- (UIColor*) barButtonColor;

- (void) barButtonPrepareLabel:(UILabel *)label;
- (void) contentButtonPrepareLabel:(UILabel *)label;


- (UIColor *) cellBorderColor;
- (float) cellBorderRadius;


- (void) prepareNavigationBarTitle:(UILabel *)label;


////////////////////////////
// image grid view
- (UIFont *) imageGridHeaderFont;
- (UIColor *) imageGridBottomBorderColor;
- (float) imageGridHeaderPadding;

@end



@interface SOThemeManager : NSObject

+ (SobottaBlueTheme *)sharedTheme;

+ (void)customizeAppAppearance;
//+ (void)customizeTableView:(UITableView *)tableView;
//+ (void)customizeTabBarItem:(UITabBarItem *)item forTab:(SSThemeTab)tab;
//+ (void)customizeDoorButton:(UIButton *)button;

@end
