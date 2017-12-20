//
//  SOBButtonImage.h
//  sobottaprototype
//
//  Created by Herbert Poul on 9/12/12.
//  Copyright (c) 2012 Stephan Kitzler-Walli. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  BARBUTTON = 1,
  CONTENTBUTTON = 2,
  BARBACKBUTTON = 3
} ButtonType;

@interface SOBButtonImage : UIButton {
    ButtonType _type;
}


@property (strong, nonatomic) UILabel *sobLabel;
@property (strong, nonatomic) UIImageView *sobImageView;
@property (assign) NSString *sobtype;

- (id) initWithImage:(UIImage*)image andText:(NSString*)text;
- (id) initContentButtonWithImage:(UIImage*)image andText:(NSString*)text;

- (id) initButtonOfType:(ButtonType)type withImage:(UIImage*)image andText:(NSString*)text;

+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)image
                                   text:(NSString*)text
                                 target:(id)target
                                 action:(SEL) selector;

- (void) fakeDisable:(BOOL)fake;

@end
