#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BonMot.h"
#import "BONChain.h"
#import "BONCompatibility.h"
#import "BONSpecial.h"
#import "BONTag.h"
#import "BONText.h"
#import "BONTextable.h"
#import "NSAttributedString+BonMotUtilities.h"
#import "UIImage+BonMotUtilities.h"

FOUNDATION_EXPORT double BonMotVersionNumber;
FOUNDATION_EXPORT const unsigned char BonMotVersionString[];

