//
//  BundleService.m
//  sobottaprototype
//
//  Created by Herbert Poul on 02/01/16.
//  Copyright © 2016 Stephan Kitzler-Walli. All rights reserved.
//

#import "BundleService.h"

#import <StoreKit/StoreKit.h>

#import "DatabaseController.h"


@interface Bundle ()

@property (nonatomic) SKProduct *skProduct;

@end


@implementation Bundle

- (instancetype)initWithBundleId:(NSString *)bundleId productId:(NSString *)productId secondaryProductIds:(NSArray<NSString *> *)secondaryProductIds chapterIds:(NSArray<NSNumber *> *)chapterIds figureCount:(int)figureCount {
    if (self = [super init]) {
        _bundleId = bundleId;
        _productId = productId;
        _chapterIds = chapterIds;
        _secondaryProductIds = secondaryProductIds;
        _figureCount = figureCount;
    }
    return self;
}

- (NSString *)label {
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:self.chapterIds.count];
    for (NSNumber *chapterId in self.chapterIds) {
        [names addObject:[NSString stringWithFormat:@"%d %@", chapterId.intValue, [[DatabaseController Current] chapterNameById:chapterId.intValue]]];
    }
    return [names componentsJoinedByString:@", "];
}

- (void)setSkProduct:(SKProduct *)product {
    _skProduct = product;
    
    // TODO I guess we could reuse this NSNumberFormatter?!
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    
    _formattedPrice = formattedPrice;
}

- (NSDecimalNumber *)price {
    return self.skProduct.price;
}

@end


@interface BundleService () <SKProductsRequestDelegate>

@property SKProductsRequest *request;

@end


@implementation BundleService

static BundleService *instance;

+ (BundleService *)instance {
    if(!instance){
        instance = [[BundleService alloc] init];
    }
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *(^productId)(int c) = ^NSString *(int c) {
            return [NSString stringWithFormat:@"sobotta2free.chapter%02d", c];
        };
        NSArray<NSString *> *(^productIds)(int c) = ^NSArray<NSString *>*(int c) {
            return @[[NSString stringWithFormat:@"sobotta2free.chapter%02d.free", c]];
        };
        /*
         calculating figures per chapter:
         sqlite> select o.level1_id, count(f.id) from figure f inner join outline o on o.chapter_id = f.chapter_id group by o.level1_id;
         1|63
         2|154
         3|193
         4|223
         5|114
         6|142
         7|125
         8|166
         9|75
         10|66
         11|89
         12|196
*/
        _bundles = @[
                     [[Bundle alloc] initWithBundleId:@"chapter1" productId:productId(1) secondaryProductIds:productIds(1) chapterIds:@[@1] figureCount:63],
                     [[Bundle alloc] initWithBundleId:@"chapter2" productId:productId(2) secondaryProductIds:productIds(2) chapterIds:@[@2] figureCount:154],
                     [[Bundle alloc] initWithBundleId:@"chapter3" productId:productId(3) secondaryProductIds:productIds(3) chapterIds:@[@3] figureCount:193],
                     [[Bundle alloc] initWithBundleId:@"chapter4" productId:productId(4) secondaryProductIds:productIds(4) chapterIds:@[@4] figureCount:223],
                     [[Bundle alloc] initWithBundleId:@"chapter5" productId:productId(5) secondaryProductIds:productIds(5) chapterIds:@[@5] figureCount:114],
                     [[Bundle alloc] initWithBundleId:@"chapter6" productId:productId(6) secondaryProductIds:productIds(6) chapterIds:@[@6] figureCount:142],
                     [[Bundle alloc] initWithBundleId:@"chapter7" productId:productId(7) secondaryProductIds:productIds(7) chapterIds:@[@7] figureCount:125],
                     [[Bundle alloc] initWithBundleId:@"chapter8,9,10" productId:productId(8) secondaryProductIds:productIds(8) chapterIds:@[@8, @9, @10] figureCount:307],
                     [[Bundle alloc] initWithBundleId:@"chapter11" productId:productId(11) secondaryProductIds:productIds(9) chapterIds:@[@11] figureCount:89],
                     [[Bundle alloc] initWithBundleId:@"chapter12" productId:productId(12) secondaryProductIds:productIds(10) chapterIds:@[@12] figureCount:196],
                     ];
        
//#ifdef SOB_DEBUG
//        [_bundles bk_each:^(Bundle *obj) {
//            obj.productId = @"com.elsevier.emeal.sobotta2.9783437189012";
//        }];
//#endif
        
        NSArray<NSString *> *purchaseableProductIds = [_bundles bk_map:^id(Bundle *obj) {
            return obj.productId;
        }];
        
        _request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:purchaseableProductIds]];
        _request.delegate = self;
        [_request start];
    }
    return self;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"received product response. invalid: %@ valid: %@", response.invalidProductIdentifiers, response.products);
    [response.products enumerateObjectsUsingBlock:^(SKProduct * _Nonnull product, NSUInteger idx, BOOL * _Nonnull stop) {
        [self bundleForProductId:product.productIdentifier].skProduct = product;
    }];
    if (response.invalidProductIdentifiers.count > 0) {
        NSLog(@"Invalid product identifiers: %@", response.invalidProductIdentifiers);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_BUNDLE_PRICE_UPDATED object:self];
}

- (Bundle *)bundleById:(NSString *)bundleId {
    return [self.bundles bk_match:^BOOL(Bundle *obj) {
        return [obj.bundleId isEqualToString:bundleId];
    }];
}

- (Bundle *)bundleForProductId:(NSString *)productId {
    return [self.bundles bk_match:^BOOL(Bundle *obj) {
        return [obj.productId isEqualToString:productId] || [obj.secondaryProductIds containsObject:productId];
    }];
}

- (Bundle *)bundleForChapterId:(NSNumber *)chapterId {
    return [self.bundles bk_match:^BOOL(Bundle *obj) {
        return [obj.chapterIds containsObject:chapterId];
    }];
}

@end
