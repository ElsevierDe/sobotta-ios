//
//  FullVersionController.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/18/13.
//  Copyright (c) 2013 Stephan Kitzler-Walli. All rights reserved.
//

#import "FullVersionController.h"

#import "AppDelegate.h"
#import "FigureProxy.h"
#import "DejalActivityView.h"
#import "iOSDocumentMigrator.h"
#import "GAI.h"
#import "SignInSync.h"
#import <ACTReporter.h>
#import <AdSupport/ASIdentifierManager.h>
#import "FigureDatasource.h"
#import "HasVoucherController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>


#define TAG_VOUCHER_INPUT 3
#define TAG_DOWNLOAD_SHOULDSTART 4


@interface FullVersionController() {
    NSArray<NSString *> *_cachedPurchasedBundleIds;
}


@property(nonatomic, strong) SKProduct *tmpProduct;

@property (readonly) NSArray<NSString *> *purchasedBundleIds;


@end

@implementation FullVersionController



static FullVersionController *current;

+ (FullVersionController *)instance {
	if(!current){
		current = [[FullVersionController alloc] init];
	}
	
	return current;
}


- (id)init {
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSPersistentStoreCoordinator *coordinator = [delegate persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
//        _managedObjectContext = delegate.managedObjectContext;
        _status = DownloadStatusInit;
        _hasFullVersion = 0;
        _downloadProgress = 0;
        _cachedPurchasedBundleIds = nil;
        _dbController = [DatabaseController Current];
        // hide download status during startup, for full users
        if ([self hasFullVersion]) {
            [self updateStatus:DownloadStatusDone];
        }
        [self syncStatus];
    }
    return self;
}

- (void)updateCustomDimension {
    if ([[FullVersionController instance] hasFullVersion]) {
        if ([[FullVersionController instance] hasDownloadedAllFigures]) {
            [[DatabaseController Current] trackPurchaseStatus:@"paid-downloaded"];
        } else {
            [[DatabaseController Current] trackPurchaseStatus:@"paid"];
        }
    } else {
        [[DatabaseController Current] trackPurchaseStatus:@"free"];
    }
}


#pragma mark - handle update stuff
- (void) syncStatus {
    if (![self hasEnabledDownloading] && [self hasPurchased]) {
        if (![DejalActivityView currentActivityView]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Showing DejalActivityViewForView.");
                [DejalBezelActivityView activityViewForView:self.baseView];
            });
        }
    } else {
        [DejalActivityView removeView];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,
                                             (unsigned long)NULL), ^(void) {
        if (![self hasPurchased]) {
            [self updateStatus:DownloadStatusFree];
            NSLog(@"User only as free status. not syncing data.");
            return;
        }
        
        long edate = [self latestLocalFigureEdate];
        NSLog(@"Starting sync into local database.");
        FMDatabaseQueue *queue = [[DatabaseController Current] contentDatabaseQueue];
        [queue inDatabase:^(FMDatabase *db) {
            [_managedObjectContext lock];
            int i = 0;
            FMResultSet* resultSet = [db executeQuery:@"SELECT f.id,f.filename,f.filesize,f.sortorder,f.edate,f.chapter_id,o.level1_id FROM figure f INNER JOIN outline o ON o.chapter_id = f.chapter_id WHERE f.edate > ?" withArgumentsInArray:@[[NSNumber numberWithLong:edate]]];
            while ([resultSet next]) {
                NSDictionary *r = [resultSet resultDictionary];
                FigureProxy *figureProxy = [self figureProxyForFigureId:[r objectForKey:@"id"] withContentDbResult:r];
                figureProxy.downloaded = [NSNumber numberWithBool:NO];
                i++;
            }
            if ([db hadError]) {
                NSLog(@"Error selecting figures %@", [db lastErrorMessage]);
            }
            NSLog(@"Synced %d figures.", i);
            // only show sync status bar, when files are still to be donwloaded
            if (i > 0) {
                [self updateStatus:DownloadStatusSync];
            }
            NSError *error;
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Error while saving managed context! %@", error);
            }
            [_managedObjectContext unlock];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [DejalActivityView removeView];
        });
        NSLog(@"Finished sync. downloading.");
        [self downloadFullVersionAsync];
    });
    
}


- (FigureProxy *) loadFigureProxyForFigureId:(NSNumber *)figureId {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FigureProxy"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"figure_id = %@", figureId];
    NSArray *ret = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if ([ret count] < 1) {
        return nil;
    }
    return [ret objectAtIndex:0];
}

/**
 * returns a FigureProxy, either an existing or a new one.
 */
- (FigureProxy *) figureProxyForFigureId:(NSNumber *)figureId withContentDbResult:(NSDictionary *)contentDbResult {
    FigureProxy *figureProxy = [self loadFigureProxyForFigureId:figureId];
    if (figureProxy == nil) {
//        NSLog(@"Creating new FigureProxy.");
        figureProxy = [NSEntityDescription insertNewObjectForEntityForName:@"FigureProxy" inManagedObjectContext:_managedObjectContext];
        figureProxy.figure_id = figureId;
    }
    figureProxy.order = [contentDbResult objectForKey:@"sortorder"];
    figureProxy.filename = [contentDbResult objectForKey:@"filename"];
    figureProxy.totalfilesizebyte = [contentDbResult objectForKey:@"filesize"];
    figureProxy.syncedate = [contentDbResult objectForKey:@"edate"];
    figureProxy.chapter_id = [contentDbResult objectForKey:@"chapter_id"];
    figureProxy.level1_id = [contentDbResult objectForKey:@"level1_id"];
    return figureProxy;
}

- (NSInteger) latestLocalFigureEdate {
    [_managedObjectContext lock];
    
    NSInteger edate = 0;
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"FigureProxy" inManagedObjectContext:_managedObjectContext];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"syncedate" ascending:NO];
    [req setSortDescriptors:@[sort]];
    // if chapter_id is not yet synced ignore syncedate from that data set.
    [req setPredicate:[NSPredicate predicateWithFormat:@"level1_id > 0"]];
    [req setFetchLimit:1];
    NSError *error;
    NSArray *result = [_managedObjectContext executeFetchRequest:req error:&error];
    if (result && [result count] > 0) {
        FigureProxy *f = [result objectAtIndex:0];
        edate = [f.syncedate longValue];
    }
        
    
    if (edate == 0) {
        edate = -1;
    }
    NSLog(@"latestLocalFigureEdate: %ld // result count: %ld", edate, [result count]);
    [_managedObjectContext unlock];
    return edate;
}

- (NSString*) formatSizeAsMB:(long) size withPrecision:(int)prec {
    // we start with byte
    double mb = size / 1024. / 1024.;
    NSString *stringFormat = [NSString stringWithFormat:@"%%.%df", prec];
    if (prec == 0) {
        // always round up.
        mb += 0.5;
    }
    return [NSString stringWithFormat:stringFormat, mb];
}

- (void)increaseDownloadProgressBy:(long) filesize {
    static NSTimeInterval timeStamp = 0;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    _downloadProgress += filesize;
    
    if (now - timeStamp > 1) {
        timeStamp = now;
        // only sent notifications every two seconds at most.
        if (_status == DownloadStatusInProgress) {
            [self updateStatus:DownloadStatusInProgress];
        }
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            NSLog(@"Downloaded %ld // time remaining: %f", _downloadProgressCount, [[UIApplication sharedApplication] backgroundTimeRemaining]);
        }
    }
}

- (void) downloadFullVersionAsync {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,
                                             (unsigned long)NULL), ^(void) {
        [self downloadFullVersion];
    });
}

- (void) downloadFigure:(FigureProxy *) proxy {
    NSError *err;
    if ([proxy.downloaded boolValue]) {
        NSLog(@"Figure already downloaded. not downloading again. %@", proxy.filename);
        return;
    }
    if ([self downloadFile:proxy.filename fromUrl:FIGUREURL_BARE toPath:[self figureBarePath]] &&
        [self downloadFile:proxy.filename fromUrl:FIGUREURL_LINES toPath:[self figureLinesPath]]) {
        
        [self increaseDownloadProgressBy:[proxy.totalfilesizebyte longValue]];
        _downloadProgressCount++;
        proxy.downloaded = [NSNumber numberWithBool:YES];
        if (_downloadProgressCount % 10 == 0) {
            [_managedObjectContext save:&err];
        }
    } else {
        NSLog(@"Error while downloading %@ (%@) ?!", proxy.figure_id, proxy.filename);
    }

}

- (void) downloadFullVersion {
    // now download it..
//    _downloadProgress = 0;
    [self calculateDownloadCountAndSum];
    _downloadTotalSize += _downloadProgress;
    
    if (_downloadTotalCount == 0 && _downloadTotalSize == 0) {
        NSLog(@"Nothing to download - total count is 0 and download total size is 0.");
        // make sure the status is done.
        [self updateStatus:DownloadStatusDone];
        return;
    }
    
    if (![self hasEnabledDownloading]) {
        [self updateStatus:DownloadStatusPaused];
        [self performSelectorOnMainThread:@selector(askToStartDownload) withObject:self waitUntilDone:NO];
//        [self askToStartDownload];
        return;
    }
    
    [self updateStatus:DownloadStatusInProgress];
    
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"FigureProxy" inManagedObjectContext:_managedObjectContext];
    req.predicate = [self figuresToDownloadPredicate];
    
    NSError *err;
    [_managedObjectContext lock];
    NSArray * ret = [_managedObjectContext executeFetchRequest:req error:&err];
    [_managedObjectContext unlock];
    NSLog(@"Starting download");
    if (err) {
        NSLog(@"Got an error: %@", err);
    }
    _bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"We must end downloading.");
        [self setStatus:DownloadStatusPaused];
    }];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    for (FigureProxy *proxy in ret) {
//        [NSThread sleepForTimeInterval:0.2];
        while (_prioritizeFigure != nil) {
            FigureProxy *tmp = _prioritizeFigure;
            _prioritizeFigure = nil;
            [self downloadFigure:tmp];
            if (_prioritizeFigure == nil) {
                [_managedObjectContext save:&err];
                [[NSNotificationCenter defaultCenter] postNotificationName:SOBPRIORITIZEDDOWNLOAD object:self];
                break;
            } else {
                NSLog(@"we have a new prioritized figure.");
            }
        }
        
        [self downloadFigure:proxy];
        
        
        if (_status == DownloadStatusPaused) {
            NSLog(@"User paused download. breaking");
            break;
        }
//        NSLog(@"filesize: %ld // %ld", [proxy.totalfilesizebyte longValue], _downloadProgress);
    }
    // store .downloaded attributes now, so remaining download can be calculated
    [_managedObjectContext save:&err];
    if (_status != DownloadStatusPaused) {
        
        [self calculateDownloadCountAndSum];
        if (_downloadTotalSize > 0) {
            _downloadTotalSize += _downloadProgress;
            [self updateStatus:DownloadStatusPaused];
        } else {
            [self updateStatus:DownloadStatusDone];
            [self updateCustomDimension];
            [self enableDownloading:NO];
        }
    }
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
    NSLog(@"Download done.");
}

- (BOOL) downloadFile:(NSString *)fileName fromUrl:(NSString *)url toPath:(NSString*) path {
    NSString *fileUrl = [NSString stringWithFormat:@"%@/%@.jpg", url, fileName];
    NSString *fileDest = [NSString stringWithFormat:@"%@/%@.jpg", path, fileName];
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:fileUrl]];
    req.downloadDestinationPath = fileDest;
    [req startSynchronous];
    return req.responseStatusCode == 200;
}

- (NSString*) figureBarePath {
    NSString *storagePath = [iOSDocumentMigrator storagePath];
    NSError *err;
    
    NSString *thumbnailPath = [NSString stringWithFormat:@"%@/figures/bare", storagePath];
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:thumbnailPath withIntermediateDirectories:YES attributes:nil error:&err]) {
        NSLog(@"Error creating directory %@", err);
    }
    return thumbnailPath;
}

- (NSString *) figureLinesPath {
    NSString *storagePath = [iOSDocumentMigrator storagePath];
    NSError *err;
    
    NSString *linesPath = [NSString stringWithFormat:@"%@/figures/lines", storagePath];
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:linesPath withIntermediateDirectories:YES attributes:nil error:&err]) {
        NSLog(@"Error creating directory %@", err);
    }
    return linesPath;
}

- (void)resumeDownload {
    [self enableDownloading:YES];
    [self syncStatus];
}

- (void)pauseDownload {
    [self enableDownloading:NO];
    [self updateStatus:DownloadStatusPaused];
}

- (NSPredicate *)figuresToDownloadPredicate {
    NSPredicate *ret;
    if (self.hasFullVersion) {
        ret = [NSPredicate predicateWithFormat:@"downloaded == %@", [NSNumber numberWithBool:NO]];
    } else {
        NSLog(@"check downloaded figures for chapters %@", [self purchasedChapterIds]);
        ret = [NSPredicate predicateWithFormat:@"downloaded == %@ AND level1_id IN %@", [NSNumber numberWithBool:NO], [self purchasedChapterIds]];
    }
    return ret;
}

- (BOOL) calculateDownloadCountAndSum {
    [_managedObjectContext lock];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"FigureProxy" inManagedObjectContext:_managedObjectContext];
    req.resultType = NSDictionaryResultType;
    req.predicate = [self figuresToDownloadPredicate];
    

    NSExpression *filesize = [NSExpression expressionForKeyPath:@"totalfilesizebyte"];
    NSExpression *sumFilesize = [NSExpression expressionForFunction:@"sum:" arguments:@[filesize]];
    NSExpressionDescription *sumFilesizeDescr = [[NSExpressionDescription alloc] init];
    [sumFilesizeDescr setName:@"sumFilesize"];
    [sumFilesizeDescr setExpression:sumFilesize];
    [sumFilesizeDescr setExpressionResultType:NSInteger32AttributeType];
    
    
    NSExpression *fid = [NSExpression expressionForKeyPath:@"figure_id"];
    NSExpression *count = [NSExpression expressionForFunction:@"count:" arguments:@[fid]];
    NSExpressionDescription *countDescr = [[NSExpressionDescription alloc] init];
    [countDescr setName:@"countFigures"];
    [countDescr setExpression:count];
    [countDescr setExpressionResultType:NSInteger32AttributeType];
    
    [req setPropertiesToFetch:@[sumFilesizeDescr, countDescr]];
    
    NSError *err;
    NSArray *ret = [_managedObjectContext executeFetchRequest:req error:&err];
    BOOL success = NO;
    if (ret && [ret count] > 0) {
        id obj = [ret objectAtIndex:0];
        long sumFileSize = [[obj valueForKey:@"sumFilesize"] longValue];
        long count = [[obj valueForKey:@"countFigures"] longValue];
        NSLog(@"sum filesize: %ld / count: %ld", sumFileSize, count);
        _downloadTotalCount = count;
        _downloadTotalSize = sumFileSize;
        success = YES;
    }
    
    [_managedObjectContext unlock];
    return success;
}

- (void)prioritizeFigure:(FigureProxy *)prioritizeFigure {
    _prioritizeFigure = prioritizeFigure;
}

#pragma mark - misc

- (NSString*) stringByDownloadStatus:(DownloadStatus) status {
    switch(status) {
        case DownloadStatusDone:
            return @"DownloadStatusDone";
        case DownloadStatusFree:
            return @"DownloadStatusFree";
        case DownloadStatusInit:
            return @"DownloadStatusInit";
        case DownloadStatusInProgress:
            return @"DownloadStatusInProgress";
        case DownloadStatusSync:
            return @"DownloadStatusSync";
        case DownloadStatusPaused:
            return @"DownloadStatusPaused";
    }
}

- (void) updateStatus:(DownloadStatus) status {
//    NSLog(@"Setting status to: %@", [self stringByDownloadStatus:status]);
    _status = status;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:SOBDOWNLOADSTATUSCHANGED object:self];
}

- (BOOL)hasPurchased {
    return [self purchasedBundleIds].count > 0 || self.hasFullVersion;
}

- (BOOL) hasFullVersion {
    if (_hasFullVersion == 0) {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if ([def boolForKey:PREF_HASFULLVERSION]) {
            _hasFullVersion = 1;
        } else {
            _hasFullVersion = -1;
        }
    }
    return _hasFullVersion == 1;
}

- (void) setHasFullVersion:(BOOL)hasFullVersion {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:hasFullVersion forKey:PREF_HASFULLVERSION];
    [def synchronize];
    _hasFullVersion = 0;
}

- (BOOL)isFullVersionProductId:(NSString *)productId {
    // For now, if the product id is not a bundle product id, we assume it's a full version id.
    return [[BundleService instance] bundleForProductId:productId] == nil;
}

- (NSArray<NSString *> *)purchasedBundleIds {
    if (!_cachedPurchasedBundleIds) {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        _cachedPurchasedBundleIds = [def objectForKey:PREF_PURCHASED_BUNDLE_IDS];
        if (!_cachedPurchasedBundleIds) {
            _cachedPurchasedBundleIds = @[];
        }
    }
    return _cachedPurchasedBundleIds;
}

- (void)purchasedBundleProductId:(NSString *)bundleProductId {
    BundleService *bundleService = [BundleService instance];
    Bundle *bundle = [bundleService bundleForProductId:bundleProductId];
    
    NSMutableArray<NSString *> *tmp = [self.purchasedBundleIds mutableCopy];
    [tmp addObject:bundle.bundleId];
    [self _updatePurchasedBundleIds:tmp];
    
}

- (void)purchasedBundles:(NSArray<Bundle *> *)bundles {
    NSMutableArray<NSString *> *tmp = [self.purchasedBundleIds mutableCopy];
    for (Bundle *bundle in bundles) {
        if (![tmp containsObject:bundle.bundleId]) {
            [tmp addObject:bundle.bundleId];
        }
    }
    [self _updatePurchasedBundleIds:tmp];
}

- (void)_updatePurchasedBundleIds:(NSArray<NSString *> *)newPurchasedBundleIds {
    NSArray <NSString *> *tmp = [self purchasedBundleIds];
    NSLog(@"updating purchased bundleids from %@ to %@", tmp, newPurchasedBundleIds);
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:newPurchasedBundleIds forKey:PREF_PURCHASED_BUNDLE_IDS];
    [def synchronize];
    _cachedPurchasedBundleIds = newPurchasedBundleIds;

    [[FigureDatasource defaultDatasource] reloadData];
    
    [self syncStatus];
}

- (NSArray<Bundle *> *)purchasedBundles {
    BundleService *bundleService = [BundleService instance];
    return [[self purchasedBundleIds] bk_map:^id(NSString *bundleId) {
        return [bundleService bundleById:bundleId];
    }];
}

- (NSArray<NSNumber *> *)purchasedChapterIds {
    NSMutableArray *ret = [NSMutableArray array];
    for (Bundle *bundle in [self purchasedBundles]) {
        [ret addObjectsFromArray:bundle.chapterIds];
    }
    return ret;
}

- (BOOL)hasPurchasedChapterId:(NSNumber *)chapterId {
    return [[self purchasedChapterIds] containsObject:chapterId];
}

- (BOOL)allowShowFigure:(FigureInfo *)figure {
    return figure.available || self.hasFullVersion || [[self purchasedChapterIds] containsObject:[NSNumber numberWithLong:figure.level1id]];
}

- (BOOL)allowShowSection:(SectionInfo *)sectionInfo {
    return sectionInfo.available || [self hasFullVersion] || [[self purchasedChapterIds] containsObject:sectionInfo.chapterId];
}

- (BOOL) hasDownloadedAllFigures {
    return _status == DownloadStatusDone;
}

- (BOOL) hasEnabledDownloading {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def boolForKey:PREF_ALLOW_DOWNLOAD];
}

- (void) enableDownloading:(BOOL)allowDownloading {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:allowDownloading forKey:PREF_ALLOW_DOWNLOAD];
    [def synchronize];
}

- (void) transformToFullVersion {
    if (![self hasFullVersion]) {
        [self setHasFullVersion:YES];
        [self syncStatus];
    } else {
        [DejalActivityView removeView];
        NSLog(@"Warning: (transformToFullVersion) user already has full version. doing nothing.");
    }
}

- (void) startFullInAppPurchase {
    [DejalBezelActivityView activityViewForView:self.baseView];
    [self startInAppPurchaseWith:PRODUCT_FULL];
}

- (void) startInAppPurchaseWithActivityView:(NSString *)productId {
    [DejalBezelActivityView activityViewForView:self.baseView];
    [self startInAppPurchaseWith:productId];
}

- (UIView *)baseView {
    UIViewController *rootController = [[[UIApplication sharedApplication].delegate window] rootViewController];
//    if (rootController.presentedViewController) {
//        [rootController dismissViewControllerAnimated:YES completion:nil];
//    }
    return rootController.view;
}

- (void) startInAppPurchaseWith:(NSString *)productId {
    [self startInAppPurchaseWith:productId skipBuyAllChapterReminder:NO];
}

- (void) startInAppPurchaseWith:(NSString *)productId skipBuyAllChapterReminder:(BOOL)skipBuyAllChapterReminder {
        if (![SKPaymentQueue canMakePayments]) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Purchases are not enabled", nil) message:NSLocalizedString(@"Purchases are currently disabled.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil];
        [view show];
        [DejalActivityView removeView];
        return;
    }
    
    // Check if it is a bundle purchase
    Bundle *bundle = [[BundleService instance] bundleForProductId:productId];
    if (!skipBuyAllChapterReminder && bundle && ![productId containsString:@"free"]) {
        // If this is the 2nd or 3rd purchase, ask the user if he knows what he wants to save money ;-)
        long bundleCount = self.purchasedBundleIds.count;
        NSLog(@"User purchased %ld bundles already.", bundleCount);
        if (bundleCount == 1 || bundleCount == 2) {
            UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:nil message:NSLocalizedString(@"Do you want to buy all chapters for only €69.99 instead?", nil)];
            [alert bk_addButtonWithTitle:[NSString stringWithFormat:NSLocalizedString(@"One chapter %@", nil), bundle.formattedPrice] handler:^{
                [self startInAppPurchaseWith:productId skipBuyAllChapterReminder:YES];
            }];
            [alert bk_addButtonWithTitle:NSLocalizedString(@"All chapters €69.99", nil) handler:^{
                [self startInAppPurchaseWith:PRODUCT_FULL skipBuyAllChapterReminder:YES];
            }];
            [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil) handler:^{
                
            }];
            [alert show];
            return;
        }
    }
    
#ifdef DEBUG
    if (YES) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"DEBUG" message:[NSString stringWithFormat:@"We are circumventing in app purchases for testig (debug build) - Fake purchasing %@?", productId]];
        
        [alertView bk_addButtonWithTitle:@"Use In App Purchase" handler:^{
            [self _startInAppPurchaseWith:productId];
        }];
        [alertView bk_addButtonWithTitle:@"Fake Purchase" handler:^{
            NSLog(@"circumventing app store for now.");
            [self purchasedBundleProductId:productId];
        }];
        [alertView show];
        return;
    }
#endif
    [self _startInAppPurchaseWith:productId];
}
- (void)_startInAppPurchaseWith:(NSString *)productId {
    [_dbController trackView:@"purchase/startPurchase"];
    [_dbController trackView:[NSString stringWithFormat:@"purchase/startPurchase/%@", productId]];
    NSLog(@"Requesting start In App Purchase for %@", productId);
    SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
    req.delegate = self;
    [req start];
}

- (void) askForVoucherOnBuyClick:(UIViewController *)parentViewController chapterId:(NSNumber *)chapterId {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Purchase" bundle:[NSBundle mainBundle]];
    UINavigationController *ctrl = [storyboard instantiateInitialViewController];
    ctrl.modalPresentationStyle = UIModalPresentationFormSheet;
    
    HasVoucherController *hasVoucherController = (HasVoucherController *)ctrl.topViewController;
    
    if (chapterId) {
        hasVoucherController.selectedBundle = [[BundleService instance] bundleForChapterId:chapterId];
    }
    
    [parentViewController presentViewController:ctrl animated:YES completion:nil];
}

- (void) askForVoucher {
    [_dbController trackView:@"purchase/askForVoucher"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Voucher", nil) message:NSLocalizedString(@"Please enter your voucher.", nill) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nill) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alertView.tag = TAG_VOUCHER_INPUT;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void) askToStartDownload {
    dispatch_async(dispatch_get_main_queue(), ^{
        [DejalActivityView removeView];
        NSLog(@"Removed view. waiting.");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Start Download?", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Sobotta requires to download %@ MB. Do you want to start this download now?", nil), [self formatSizeAsMB:_downloadTotalSize withPrecision:0]] delegate:self cancelButtonTitle:NSLocalizedString(@"Later", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alertView.tag = TAG_DOWNLOAD_SHOULDSTART;
        [alertView show];
    });
}


- (void) verifyVoucher:(NSString*) voucher {
    //bypass iap
    //if([voucher isEqualToString:@"free"]) {
    //    [self transformToFullVersion];
    //}
    // first check if an existing cached pin response worked.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *validVoucher = (NSString *)[defaults objectForKey:PREF_CACHE_VALIDVOUCHER];
    if (validVoucher != nil && [validVoucher isEqualToString:voucher]) {
        NSString *response = [defaults objectForKey:PREF_CACHE_VALIDVOUCHER_RESPONSE];
        if (response != nil) {
            NSLog(@"We have a cached response, so use it. %@", response);
            [self startInAppPurchaseWith:response];
            return;
        }
    }
    
    [DejalBezelActivityView activityViewForView:self.baseView];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?pin=%@", CHECKPINURL, voucher]];
    NSLog(@"requesting %@", url);
    __block ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:url];
    [req setCompletionBlock:^{
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[req responseData] options:nil error:&err];
        BOOL valid = [[dict objectForKey:@"valid"] boolValue];
        if (!valid) {
            [DejalActivityView removeView];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Voucher", nil) message:NSLocalizedString(@"Voucher is invalid.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        } else {
            NSString *productId = [dict objectForKey:@"productId"];
            [defaults setObject:voucher forKey:PREF_CACHE_VALIDVOUCHER];
            [defaults setObject:productId forKey:PREF_CACHE_VALIDVOUCHER_RESPONSE];
            [defaults synchronize];
            [self startInAppPurchaseWith:productId];
        }
    }];
    [req setFailedBlock:^{
        [DejalActivityView removeView];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error checking Voucher", nil) message:@"Unable to contact server. Please try again later." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }];
    [req startAsynchronous];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_VOUCHER_INPUT) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [self verifyVoucher:[alertView textFieldAtIndex:0].text];
        }
    } else if (alertView.tag == TAG_DOWNLOAD_SHOULDSTART) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [self enableDownloading:YES];
            [self downloadFullVersionAsync];
        }
    }
}


-(void) trackTransactionForGoogleAdwords {
    
   
    NSString *idfa = [[[ASIdentifierManager sharedManager]
                       advertisingIdentifier] UUIDString];
    NSString *bundleId =[[NSBundle mainBundle] bundleIdentifier];
    NSString *value =@"";
    NSString *currency =@"";
    
    if (self.tmpProduct != nil) {
        value = [self.tmpProduct.price stringValue];
        currency = [self.tmpProduct.priceLocale objectForKey:NSLocaleCurrencyCode];
        
        [FBSDKAppEvents logPurchase:self.tmpProduct.price.floatValue currency:currency];
        
    }
    
    NSString *dataUrl = [NSString stringWithFormat:@"https://www.googleadservices.com/pagead/conversion/980522511/?label=Jp3LCPSHtF8Qj6zG0wM&rdid=%@&bundleid=%@&idtype=idfa&lat=0&value=%@&currency=%@",idfa,bundleId,value,currency];
    NSURL *url = [NSURL URLWithString:dataUrl];
    NSURLSessionDataTask *requestTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                             
                                              if (error!= nil) {
                                                  NSLog(@"Error google adwords tracking IAP: %@",error.localizedDescription);
                                              } else {
                                                   NSLog(@"Successfully tracked IAP with google adwords");
                                              }
                                              
                                          }];
    
    [requestTask resume];

}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"productsRequest didReceiveREsponse");
    BOOL startedPayment = NO;
    for (NSString *productId in response.invalidProductIdentifiers) {
        NSLog(@"INVALID product: %@", productId);
    }
    for (SKProduct *product in response.products) {
        NSLog(@"We got a valid product. try to buy it.");
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        self.tmpProduct = product; //temporarily save product for tracking
        startedPayment = YES;
    }
    if (!startedPayment) {
        [DejalActivityView removeView];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request %@ didFailWithError %@", request, error);
    [DejalActivityView removeView];
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [view show];
}

- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"Request did finish %@", request);
}


#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                [DejalActivityView removeView];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                [DejalActivityView removeView];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Transaction purchasing ... ");
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction:(SKPaymentTransaction*) transaction {
    NSLog(@"Transaction completed %@", transaction.payment.productIdentifier);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [DejalActivityView removeView];
        
        NSString *productId = transaction.payment.productIdentifier;
        
        [_dbController trackView:@"purchase/completedTransaction"];
        [_dbController trackEventWithCategory:@"purchase" withAction:@"purchased" withLabel:[NSString stringWithFormat:@"successful purchase %@", transaction.payment.productIdentifier] withValue:[NSNumber numberWithInt:0]];
        [[SignInSync instance] syncReceipt];
        
        [self trackTransactionForGoogleAdwords];
        
        if ([self isFullVersionProductId:productId]) {
            [self transformToFullVersion];
        } else {
            [self purchasedBundleProductId:productId];
        }
        
    });
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction:(SKPaymentTransaction *) transaction {
    NSLog(@"Transaction failed %@", transaction.payment.productIdentifier);
    // Remove the transaction from the payment queue.
    [_dbController trackView:@"purchase/failedTransaction"];
    NSString *label = transaction.error.localizedDescription;
    [_dbController trackEventWithCategory:@"purchase" withAction:@"failed" withLabel:label withValue:[NSNumber numberWithInt:0]];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    UIAlertView *err = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Error while purchasing. Please try again later.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [err show];
}

- (void) restoreTransaction:(SKPaymentTransaction *) transaction {
    NSString *productId = transaction.payment.productIdentifier;
    DDLogDebug(@"Restore transaction: %@", productId);
    [_dbController trackEventWithCategory:@"purchase" withAction:@"restored" withLabel:[NSString stringWithFormat:@"successful restore %@", productId] withValue:[NSNumber numberWithInt:0]];
    if ([self isFullVersionProductId:productId]) {
        [self transformToFullVersion];
    } else {
        [self purchasedBundleProductId:productId];
    }
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

@end
