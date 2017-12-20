//
//  NAPrintRenderer.m
//  sobottaprototype
//
//  Created by Stephan Kitzler-Walli on 21.09.12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "NAPrintRenderer.h"

@implementation NAPrintRenderer

- (id)init {
    self = [super init];
    if (self) {
        self.footerHeight = 20.;
    }
    return self;
}

-(NSInteger)numberOfPages {
	return 1;
}

- (void)drawFooterForPageAtIndex:(NSInteger)index inRect:(CGRect)footerRect {
    NSString *footer = NSLocalizedString(@"© Elsevier GmbH 2012, Sobotta - Atlas of Human Anatomy, http://sobottadigital.elsevier.de", nil);
    
    [footer drawInRect:footerRect withFont:[UIFont systemFontOfSize:10.] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
//    [footer drawInRect:footerRect withFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}


@end
