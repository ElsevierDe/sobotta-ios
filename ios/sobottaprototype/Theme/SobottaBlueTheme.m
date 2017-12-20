
//
//  SobottaBlueTheme.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SobottaBlueTheme.h"

@implementation SobottaBlueTheme


#define kFontSizeHeader 18.f
#define kFontSizeLabels 12.f


- (UIColor *)baseTintColor
{
    //return [UIColor colorWithRed:0 green:87 blue:134 alpha:1.0];
    //return [UIColor colorWithHue:.55833 saturation:1 brightness:.53 alpha:1.0];
    //return [UIColor colorWithRed:246./256 green:129./256 blue:33./256 alpha:1.0];
    return [UIColor whiteColor];
}

- (UIColor *)barTintColor {
    return [self orange];
}

- (UIColor *)orange {
    return [UIColor colorWithRed:246./256 green:129./256 blue:33./256 alpha:1.0];
}

- (UIColor *)mainColor {
    return [UIColor whiteColor];
}


- (UIFont *) imageGridHeaderFont {
    return [UIFont boldSystemFontOfSize:(kFontSizeHeader)];
}
- (UIColor *) imageGridBottomBorderColor {
    return UIColorFromRGB(0x3D2918);
//    return     UIColorFromRGB(0x897463);
//    // DARK BLUE
//    return [UIColor colorWithRed:55/255. green:106/255. blue:137/255. alpha:0.5f];
}
- (float) imageGridHeaderPadding {
    return 5.f;
}
- (UIColor *) cellBorderColor {
    return UIColorFromRGB(0xC9BFB6);
//    // light blue
//    return [UIColor colorWithRed:182/255. green:195/255. blue:201/255. alpha:1];
}
- (float) cellBorderRadius {
    return 5.f;
}


- (UIFont *) barButtonFont {
    if (IS_PHONE) {
        return [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.f];
    } else {
        return [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.f];
    }
    //    return [UIFont boldSystemFontOfSize:12];
}


- (void) barButtonPrepareLabel:(UILabel *)label {
    label.shadowOffset = CGSizeMake(0, 2);
    [label setTextColor:[self barButtonColor]];
}
- (void) contentButtonPrepareLabel:(UILabel *)label {
    label.shadowOffset = CGSizeMake(0, 2);
    label.shadowColor = [UIColor whiteColor];
    [label setTextColor:[UIColor darkGrayColor]];
}

- (float) barButtonImageSpacing {
    return 16.;
}
- (float) barButtonHorizontalPadding {
    return 14;
}


- (UIImage *)barButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    if (state == UIControlStateNormal) {
        return [[UIImage imageNamed:@"header-button-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4., 0, 4.)];
    } else if (state == UIControlStateSelected) {
        return [[UIImage imageNamed:@"header-button-pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4., 0, 4.)];
    } else if (state == UIControlStateDisabled) {
        return [[UIImage imageNamed:@"header-button-default-disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4., 0, 4.)];
    }
    return nil;
}

- (UIImage *)barBackButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    if (state == UIControlStateNormal) {
        return [[UIImage imageNamed:@"header-button-back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16., 0, 5.)];
    } else if (state == UIControlStateSelected) {
        return [[UIImage imageNamed:@"header-button-back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16., 0, 5.)];
    }
    return nil;
}


- (UIImage *)contentButtonBackgroundForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    if (state == UIControlStateNormal) {
        return [[UIImage imageNamed:@"button-gray-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(4., 4., 4., 4.) resizingMode:UIImageResizingModeStretch];
    } else if (state == UIControlStateSelected) {
        return [[UIImage imageNamed:@"button-gray-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(4., 4., 4., 4.) resizingMode:UIImageResizingModeStretch];
    }
    return nil;
}
/*
- (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics {
    return [[UIImage imageNamed:@"toolbarbgnew"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}
 */


- (UIColor *) barButtonColor {
    return [UIColor whiteColor];
}

- (void) prepareNavigationBarTitle:(UILabel *)label {
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.f];
//    [UIFont bol]
    label.textColor = [UIColor whiteColor];
}

- (void)applyButtonTheme:(UIButton *)button {
    button.backgroundColor = self.orange;
//    button.titleLabel.textColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 2;
    button.contentEdgeInsets = UIEdgeInsetsMake(8, 32, 8, 32);
}


@end
