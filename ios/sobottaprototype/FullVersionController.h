//
//  FullVersionController.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/18/13.
//  Copyright (c) 2013 Stephan Kitzler-Walli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "HasVoucherController.h"
#import "ASIHTTPRequest.h"
#import "DatabaseController.h"

@class FigureProxy;
@class FigureInfo;
@class SectionInfo;

//#define CHECKPINURL @"http://www.elsevier.de/restapi/v1/checkPin"
//#define CHECKPINURL @"http://tools.sphene.net:8888/sobotta/elsevier-sobotta/www/api/checkpin.php"
#define CHECKPINURL @"http://inapp.elsevier-verlag.de/sobotta-data/api/checkpin.php"
#define FIGUREURL_BARE @"http://inapp.elsevier-verlag.de/sobotta-data/all/figures/bare"
#define FIGUREURL_LINES @"http://inapp.elsevier-verlag.de/sobotta-data/all/figures/lines"

#define PRODUCT_FULL @"com.elsevier.emeal.sobotta2.9783437189074"
#define PRODUCT_FREE @"com.elsevier.emeal.sobotta2.9783437189005"

#define PREF_HASFULLVERSION @"hasfull"
#define PREF_PURCHASED_BUNDLE_IDS @"purchasedBundleIds"
#define PREF_ALLOW_DOWNLOAD @"allowdownloadnew"
#define PREF_CACHE_VALIDVOUCHER @"validvouchercache"
#define PREF_CACHE_VALIDVOUCHER_RESPONSE @"validvouchercacheresponse"

#define SOBDOWNLOADSTATUSCHANGED @"com.elsevier.apps.sobotta.downloadstatuschanged"
#define SOBPRIORITIZEDDOWNLOAD @"com.elsevier.apps.sobotta.downloadedpriority"



typedef enum {
    // not yet initialized ..
    DownloadStatusInit,
    // user is still free, so nothing to do..
    DownloadStatusFree,
    // we are currently syncing
    DownloadStatusSync,
    // download in progress
    DownloadStatusInProgress,
    // download was paused
    DownloadStatusPaused,
    // everything in sync. all images downloaded.
    DownloadStatusDone,
} DownloadStatus;

@interface FullVersionController : NSObject<UIAlertViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSManagedObjectContext *_managedObjectContext;
    UIBackgroundTaskIdentifier *_bgTaskId;
    // internal cache if user has full version (0: undefined, 1: YES, -1: NO)
    int _hasFullVersion;
    
    FigureProxy *_prioritizeFigure;
    DatabaseController *_dbController;
}

+ (FullVersionController *) instance;


@property DownloadStatus status;

@property (readonly) long downloadTotalSize;
@property (readonly) long downloadTotalCount;
@property (readonly) long downloadProgress;
@property (readonly) long downloadProgressCount;


- (NSArray<NSString *> *)purchasedBundleIds;
- (NSArray<NSNumber *> *)purchasedChapterIds;
- (BOOL)hasPurchasedChapterId:(NSNumber *)chapterId;
- (void)purchasedBundles:(NSArray<Bundle *> *)bundles;

- (NSString*) formatSizeAsMB:(long) size withPrecision:(int)prec;

- (void) askForVoucherOnBuyClick:(UIViewController *)parentViewController chapterId:(NSNumber *)chapterId;
- (void) askForVoucher;
- (void) startFullInAppPurchase;
- (void) startInAppPurchaseWithActivityView:(NSString *)productId;

/**
 * @return true if the user has either purchased at least one bundle, or has upgraded to full version.
 */
- (BOOL)hasPurchased;
- (BOOL) hasFullVersion;
- (void) setHasFullVersion:(BOOL)hasFullVersion;
- (FigureProxy *) loadFigureProxyForFigureId:(NSNumber *)figureId;
- (void) askToStartDownload;
- (void) transformToFullVersion;
- (BOOL)allowShowFigure:(FigureInfo *)figure;
- (BOOL)allowShowSection:(SectionInfo *)sectionInfo;

- (BOOL) hasDownloadedAllFigures;

- (void) resumeDownload;
- (void) pauseDownload;

- (NSString*) figureBarePath;
- (NSString *) figureLinesPath;
- (void) prioritizeFigure:(FigureProxy*) prioritizeFigure;
- (void) updateCustomDimension;

@end
