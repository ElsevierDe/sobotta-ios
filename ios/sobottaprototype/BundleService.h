//
//  BundleService.h
//  sobottaprototype
//
//  Created by Herbert Poul on 02/01/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#define EVENT_BUNDLE_PRICE_UPDATED @"com.austrianapps.ios.elsevier.bundlepriceupdated"

#import <Foundation/Foundation.h>

@interface Bundle : NSObject

/**
 * internal id of the bundle, we use to persist which ones the user has purchased.
 */
@property (readonly) NSString *bundleId;
@property (readonly) NSString *label;
@property NSString *productId;
/**
 * product ids used for vouchers, etc. to identify this bundle.
 */
@property NSArray<NSString *> *secondaryProductIds;
@property NSArray<NSNumber *> *chapterIds;
@property int figureCount;
@property (readonly) NSString *formattedPrice;
@property (readonly) NSDecimalNumber *price;

- (instancetype)initWithBundleId:(NSString *)bundleId productId:(NSString *)productId secondaryProductIds:(NSArray<NSString *> *)secondaryProductIds chapterIds:(NSArray<NSNumber *> *)chapterIds figureCount:(int)figureCount;

@end

/**
 * Responsible for managing bundles. (ie. purchase of single chapters)
 */
@interface BundleService : NSObject

@property NSArray<Bundle *> *bundles;

+ (BundleService *)instance;

- (Bundle *)bundleById:(NSString *)bundleId;

- (Bundle *)bundleForProductId:(NSString *)productId;

- (Bundle *)bundleForChapterId:(NSNumber *)chapterId;

@end
