//
//  SOBButtonImage.m
//  sobottaprototype
//
//  Created by Herbert Poul on 9/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import "SOBButtonImage.h"
#import "Theme/Theme.h"

@implementation SOBButtonImage

+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)image
                                   text:(NSString*)text
                                 target:(id)target
                                 action:(SEL) selector {
    SOBButtonImage *btn = [[SOBButtonImage alloc] initButtonOfType:BARBUTTON withImage:image andText:text];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}


- (void)awakeFromNib {
	[super awakeFromNib];
	
	id<SOTheme> theme = [SOThemeManager sharedTheme];
	float hpadding = [theme barButtonHorizontalPadding];
	float spacing = [theme barButtonImageSpacing];
	
	UIImage *image = [self imageForState:UIControlStateNormal];
	NSString *text = [self titleForState:UIControlStateNormal];
	
	[self setTitle:nil forState:UIControlStateNormal];
	[self setImage:nil forState:UIControlStateNormal];
	
	UILabel *label = nil;
	UIImageView *imageView = nil;
	float labelUsedWidth = 0;
	float height = self.frame.size.height;
    NSLog(@"awake from nib.");
	
    
    if (!image) {
        spacing = 0;
    }
    spacing = 0;
	if (text) {
		label = [[UILabel alloc] init];
		label.backgroundColor = [UIColor clearColor];
		label.text = text;
		label.shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.];
		label.font = [theme barButtonFont];
        if ([_sobtype isEqualToString:@"barbutton"]) {
            [theme barButtonPrepareLabel:label];
        } else {
            [theme contentButtonPrepareLabel:label];
        }
//        label.backgroundColor = [UIColor redColor];
		label.contentMode = UIViewContentModeCenter;
		[label sizeToFit];
		label.frame = CGRectMake(hpadding, 0, label.frame.size.width+2*hpadding, height-15);
//        label.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
		labelUsedWidth = label.frame.size.width + spacing;
//		label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	}
	if (image) {
		imageView = [[UIImageView alloc] initWithImage:image];
		
		imageView.frame = CGRectMake(labelUsedWidth + hpadding, 0, image.size.width, height-15);
		imageView.contentMode = UIViewContentModeCenter;
		imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	}
	if (image && text) {
		NSLog(@"setting frame.");
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, label.frame.size.width + image.size.width + (2*hpadding) + spacing, MAX(image.size.height, label.frame.size.height));
		
		[self addSubview:label];
		[self addSubview:imageView];
		
	} else if (image) {
		//[self setImage:image forState:UIControlStateNormal];
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, imageView.frame.size.width + 2*hpadding, imageView.frame.size.height);
		[self addSubview:imageView];
	} else if (text) {
		//[self setTitle:text forState:UIControlStateNormal];
        label.textAlignment = NSTextAlignmentCenter;
        float newWidth = label.frame.size.width + 2*hpadding;
        // center the button relative to the old position.
        float oldWidth = self.frame.size.width;
        float diff = oldWidth - newWidth;
        float offset = MAX(diff/2, 0);
        NSLog(@"old frame: %@, new Width: %f, diff: %f", NSStringFromCGRect(self.frame), newWidth, diff);
		self.frame = CGRectMake(self.frame.origin.x + offset, self.frame.origin.y, newWidth, label.frame.size.height);
//        label.frame = CGRectMake(self.bounds.origin.x+5, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
		[self addSubview:label];
//        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	}
	
	UIImage *bg = nil;
	UIImage *bg2 = nil;
    NSLog(@"sobtype: %@", _sobtype);
    if ([_sobtype isEqualToString:@"barbutton" ]) {
        bg = [theme barButtonBackgroundForState:UIBarButtonItemStylePlain style:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        bg2 = [theme barButtonBackgroundForState:UIControlStateSelected style:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//        bg3 = [theme barButtonBackgroundForState:UIControlStateDisabled style:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    } else {
		bg = [theme contentButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
		bg2 = [theme contentButtonBackgroundForState:UIControlStateNormal style:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    }
	if (bg) {
		[self setBackgroundImage:bg forState:UIControlStateNormal];
	}
	if (bg2) {
		[self setBackgroundImage:bg2 forState:UIControlStateSelected];
	}
	
	self.autoresizesSubviews = YES;
    _sobLabel = label;
    _sobImageView = imageView;
}

- (id) initContentButtonWithImage:(UIImage*)image andText:(NSString*)text {
    return [self initButtonOfType:CONTENTBUTTON withImage:image andText:text];
}

- (id) initWithImage:(UIImage*)image andText:(NSString*)text {
    return [self initButtonOfType:BARBUTTON withImage:image andText:text];
}

- (id) initButtonOfType:(ButtonType)type withImage:(UIImage*)image andText:(NSString*)text {

    self = [super init];
    _type = type;
    
    id<SOTheme> theme = [SOThemeManager sharedTheme];
    
    if (self) {
        float hpadding = [theme barButtonHorizontalPadding];
        float leftpadding = hpadding;
        float spacing = [theme barButtonImageSpacing];
        
        UILabel *label = nil;
        UIImageView *imageView = nil;
        float labelUsedWidth = 0;
        float height = 40;
        
        if (type == BARBACKBUTTON) {
            leftpadding = hpadding + 8;
        }

        if (text) {
            label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor clearColor];
            label.text = text;
            label.shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.];
            label.font = [theme barButtonFont];
            if (type == BARBUTTON || type == BARBACKBUTTON) {
                [theme barButtonPrepareLabel:label];
            } else if (type == CONTENTBUTTON) {
                [theme contentButtonPrepareLabel:label];
            }
            label.contentMode = UIViewContentModeCenter;
            [label sizeToFit];
            label.frame = CGRectMake(leftpadding, 0, label.frame.size.width, height-15);
            labelUsedWidth = label.frame.size.width + spacing;
            label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        }
        if (image) {
            imageView = [[UIImageView alloc] initWithImage:image];
            
            imageView.frame = CGRectMake(labelUsedWidth + leftpadding, 0, image.size.width, height-5);
            imageView.contentMode = UIViewContentModeCenter;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        }
        if (image && text) {
            NSLog(@"setting frame.");
            self.frame = CGRectMake(0, 0, label.frame.size.width + image.size.width + (leftpadding + hpadding) + spacing, MAX(image.size.height, label.frame.size.height));
            
            [self addSubview:label];
            [self addSubview:imageView];
            
        } else if (image) {
            //[self setImage:image forState:UIControlStateNormal];
            self.frame = CGRectMake(0, 0, imageView.frame.size.width + leftpadding + hpadding, imageView.frame.size.height);
            [self addSubview:imageView];
        } else if (text) {
            //[self setTitle:text forState:UIControlStateNormal];
            self.frame = CGRectMake(0, 0, label.frame.size.width + leftpadding + hpadding, label.frame.size.height);
            [self addSubview:label];
        }
        
        UIImage *bg = nil;
        UIImage *bg2 = nil;
        UIImage *bg3 = nil;
        if (type == BARBUTTON) {
            bg = [theme barButtonBackgroundForState:UIBarButtonItemStylePlain style:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            bg2 = [theme barButtonBackgroundForState:UIControlStateSelected style:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            bg3 = [theme barButtonBackgroundForState:UIControlStateDisabled style:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        } else if (type == CONTENTBUTTON) {
            bg = [theme contentButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
            bg2 = [theme contentButtonBackgroundForState:UIControlStateNormal style:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        } else if (type == BARBACKBUTTON) {
            bg = [theme barBackButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
            bg2 = [theme barBackButtonBackgroundForState:UIControlStateNormal style:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        }
        self.autoresizesSubviews = YES;
        if (bg) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, bg.size.height);
            [self setBackgroundImage:bg forState:UIControlStateNormal];
        }
        if (bg2) {
            [self setBackgroundImage:bg2 forState:UIControlStateSelected];
        }
        if (bg3){
            [self setBackgroundImage:bg3 forState:UIControlStateDisabled];
        }
        
        _sobLabel = label;
        _sobImageView = imageView;
    }
    return self;
}

- (void) fakeDisable:(BOOL)fake {
    if (fake) {
        id<SOTheme> theme = [SOThemeManager sharedTheme];
        UIImage *bg = nil;
        if (_type == BARBUTTON) {
            bg = [theme barButtonBackgroundForState:UIControlStateDisabled style:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            _sobLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
            _sobLabel.textColor = [UIColor colorWithRed:129/255. green:179/255. blue:210/255. alpha:1];
//            _sobLabel.
            _sobImageView.layer.opacity = 0.5;
        }
        if (bg) {
//            [self setBackgroundImage:bg forState:UIControlStateNormal];
//            [self setBackgroundImage:bg forState:UIControlStateSelected];
            
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
