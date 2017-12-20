//
//  Theme.m
//  sobottaprototype
//
//  Created by Herbert Poul on 8/11/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "Theme.h"
#import "DefaultTheme.h"
#import "SobottaBlueTheme.h"


@implementation SOThemeManager

+ (SobottaBlueTheme*)sharedTheme
{
    static SobottaBlueTheme *sharedTheme = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Create and return the theme:
        //        sharedTheme = [[SSDefaultTheme alloc] init];
        //        sharedTheme = [[SSTintedTheme alloc] init];
        //sharedTheme = [[SSMetalTheme alloc] init];
        sharedTheme = [[SobottaBlueTheme alloc] init];
    });
    
    return sharedTheme;
}



+ (void)customizeAppAppearance
{
    id <SOTheme> theme = [self sharedTheme];
    
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
//    [navigationBarAppearance setBackgroundImage:[theme navigationBackgroundForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
//    [navigationBarAppearance setBackgroundImage:[theme navigationBackgroundForBarMetrics:UIBarMetricsLandscapePhone] forBarMetrics:UIBarMetricsLandscapePhone];



    UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];

    
    UISegmentedControl *segmentedAppearance = [UISegmentedControl appearance];
    UITabBar *tabBarAppearance = [UITabBar appearance];
    UIToolbar *toolbarAppearance = [UIToolbar appearance];
    UISearchBar *searchBarAppearance = [UISearchBar appearance];
    UISlider *sliderAppearance = [UISlider appearance];
    UIProgressView *progressAppearance = [UIProgressView appearance];
    UISwitch *switchAppearance = [UISwitch appearance];
    UIStepper *stepperAppearance = [UIStepper appearance];



    
    
    NSMutableDictionary *titleTextAttributes = [[NSMutableDictionary alloc] init];
    UIColor *mainColor = [theme mainColor];
    if (mainColor) {
        [titleTextAttributes setObject:mainColor forKey:NSForegroundColorAttributeName];
    }
    UIColor *shadowColor = [theme shadowColor];
    if (shadowColor) {
        [titleTextAttributes setObject:shadowColor forKey:UITextAttributeTextShadowColor];
        CGSize shadowOffset = [theme shadowOffset];
        [titleTextAttributes setObject:[NSValue valueWithCGSize:shadowOffset] forKey:UITextAttributeTextShadowOffset];
    }
    [navigationBarAppearance setTitleTextAttributes:titleTextAttributes];
    [barButtonItemAppearance setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [barButtonItemAppearance setTitleTextAttributes:titleTextAttributes forState:UIControlStateHighlighted];
    //[segmentedAppearance setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    [searchBarAppearance setScopeBarButtonTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
//    [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor blackColor]}];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UINavigationBar appearance] setBarTintColor:[theme barTintColor]];
    [[UINavigationBar appearance] setTintColor:mainColor];
    [[UISwitch appearance] setOnTintColor:[theme barTintColor]];
    
    
    //UILabel *headerLabelAppearance = [UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil];




    UIColor *accentTintColor = [theme accentTintColor];
    if (accentTintColor) {
        [sliderAppearance setMaximumTrackTintColor:accentTintColor];
        [progressAppearance setTrackTintColor:accentTintColor];
        UIBarButtonItem *toolbarBarButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil];
        [toolbarBarButtonItemAppearance setTintColor:accentTintColor];
//        [tabBarAppearance setSelectedImageTintColor:accentTintColor];
    }
    UIColor *baseTintColor = [theme baseTintColor];
    if (baseTintColor) {
//        [navigationBarAppearance setTintColor:baseTintColor];
        [barButtonItemAppearance setTintColor:baseTintColor];
//        [segmentedAppearance setTintColor:baseTintColor];
//        [tabBarAppearance setTintColor:baseTintColor];
        [toolbarAppearance setTintColor:baseTintColor];
        [searchBarAppearance setTintColor:baseTintColor];
        [sliderAppearance setThumbTintColor:baseTintColor];
        [sliderAppearance setMinimumTrackTintColor:baseTintColor];
        [progressAppearance setProgressTintColor:baseTintColor];
        //[stepperAppearance setTintColor:baseTintColor];
        //[headerLabelAppearance setTextColor:baseTintColor];
    } else if (mainColor) {
        //[headerLabelAppearance setTextColor:mainColor];
    }
//    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"toolbarbg"] forBarMetrics:UIBarMetricsDefault];
//    [navigationBarAppearance setBackgroundImage:[UIImage imageNamed:@"toolbarbg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
//    [toolbarAppearance setBackgroundImage:[UIImage imageNamed:@"toolbarbg"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];

}


@end
