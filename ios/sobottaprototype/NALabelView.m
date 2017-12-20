//
//  NALabelView.m
//  MedicalPrototype
//
//  Created by Stephan Kitzler-Walli on 13.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NALabelView.h"
#import "NAMapView.h"


@implementation NALabelView

@synthesize labels = _labels;
@synthesize textSize = _textSize;
@synthesize fontSize = _fontSize;
@synthesize xfactor  = _xfactor;
@synthesize yfactor  = _yfactor;
@synthesize delegate;

- (id)initWithLabel:(NALabel *)label onView:(UIView *)view {
	CGRect frame;
	NAMapView* map = (NAMapView*)view;
	frame = CGRectMake(0, 0, map.bounds.size.width, map.bounds.size.height);
	//[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	
	if(self = [super initWithFrame:frame]) {
		self.userInteractionEnabled = YES;
		[self setBackgroundColor:[UIColor clearColor]];
		
		if(!self.labels){
			self.labels = [[NSMutableArray alloc] init];
		}
		
		if(label)
			[self.labels addObject:label];
		
		self.fontSize = cLabelViewFont_Size;
		self.xfactor = 1;
		self.yfactor = 1;
				
		//self.layer.borderColor = [UIColor redColor].CGColor;
		//self.layer.borderWidth = 2.0f;
		
		[view addSubview:self];
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
	//KWLogDebug(@"[%@] LabelView Redraw", self.class);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	for (NALabel *label in self.labels) {
		if([label.title isEqual:[NSNull null]]) {
			//KWLogDebug(@"[%@] Label String was null", self.class);
			continue;
		}
		
		CGContextBeginPath(context);
		
		UIFont* font = [UIFont systemFontOfSize:self.fontSize];
		if(label.relevant)
			font = [UIFont boldSystemFontOfSize:self.fontSize];
		
		CGSize textSize = [self calculateMaxTextWidth:label.title forFont:font];
		
		CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
		
		
		if(label.disabled)
			CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
		if(label.selected)
			CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
		
		
		CGRect textRect = CGRectZero;
		CGRect noteImageRect = CGRectZero;
		if([label.align isEqualToString:@"l"]){
			textRect = CGRectMake((label.labelPoint.x*self.xfactor)-_offset.x, ((label.labelPoint.y*self.yfactor))-_offset.y, textSize.width, textSize.height);
			if(label.hasNote){
				noteImageRect = CGRectMake(textRect.origin.x + textSize.width + cNoteIndicatorImagePadding, textRect.origin.y, cNoteIndicatorImageWidth, cNoteIndicatorImageHeight);
				CGContextSetFillColorWithColor(context, label.noteColor.CGColor);
				CGContextFillRect(context, textRect);
				CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
			}
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [style setLineBreakMode:NSLineBreakByWordWrapping];
            [style setAlignment:NSTextAlignmentLeft];
            [label.title drawInRect:textRect withAttributes:@{NSFontAttributeName: font,
                                                              NSParagraphStyleAttributeName: style}];
		}
		else {
			textRect = CGRectMake(((label.labelPoint.x*self.xfactor)-textSize.width)-_offset.x, ((label.labelPoint.y*self.yfactor))-_offset.y, textSize.width, textSize.height);
			if(label.hasNote){
				noteImageRect = CGRectMake(textRect.origin.x - cNoteIndicatorImageWidth - cNoteIndicatorImagePadding, textRect.origin.y, cNoteIndicatorImageWidth, cNoteIndicatorImageHeight);
				CGContextSetFillColorWithColor(context, label.noteColor.CGColor);
				CGContextFillRect(context, textRect);
				CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
			}
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [style setLineBreakMode:NSLineBreakByWordWrapping];
            [style setAlignment:NSTextAlignmentRight];
            [label.title drawInRect:textRect withAttributes:@{NSFontAttributeName: font,
                                                              NSParagraphStyleAttributeName: style}];
		}
		
		if(label.hasNote){
			UIImage *noteImage = nil;
			if([label.noteColor isEqual:cNoteColorBlue]){
				noteImage = [UIImage imageNamed:@"notes-indicator-blue"];
			}
			else if ([label.noteColor isEqual:cNoteColorGreen]) {
				noteImage = [UIImage imageNamed:@"notes-indicator-green"];
			}
			else if ([label.noteColor isEqual:cNoteColorPink]) {
				noteImage = [UIImage imageNamed:@"notes-indicator-pink"];
			}
			else if ([label.noteColor isEqual:cNoteColorRed]) {
				noteImage = [UIImage imageNamed:@"notes-indicator-red"];
			}
			else if ([label.noteColor isEqual:cNoteColorViolet]) {
				noteImage = [UIImage imageNamed:@"notes-indicator-violet"];
			}
			
			if(noteImage != nil){
				[noteImage drawInRect:noteImageRect];
			}
		}
		
		CGContextStrokePath(context);
	}
}

- (CGSize)calculateMaxTextWidth:(NSString *)title forFont:(UIFont*)font {
	if([title isEqual:[NSNull null]])
		return CGSizeZero;
	
	NSArray *parts = [title componentsSeparatedByString:@"\n"];
	int maxwidth = 0;
	for (NSString *part in parts) {
		int width = [part sizeWithFont:font].width;
		if(width > maxwidth)
			maxwidth = width;
	}
	return [title sizeWithFont:font constrainedToSize:CGSizeMake(maxwidth+5, 500) lineBreakMode:UILineBreakModeWordWrap];
}

- (void)addLabel:(NALabel *)label {
	[self.labels addObject:label];
	[self setNeedsDisplay];
}

- (void)updatePositions {
	NAMapView* mapView = (NAMapView*)self.superview;
	self.xfactor = (mapView.contentSize.width / mapView.orignalSize.width);
	self.yfactor = (mapView.contentSize.height / mapView.orignalSize.height);
	self.fontSize = self.xfactor * cLabelViewFont_Size;
	
	CGRect frameToPos = self.frame;
	frameToPos.origin.x = mapView.contentOffset.x;
	frameToPos.origin.y = mapView.contentOffset.y;
	self.frame = frameToPos;
	
	CGSize boundsSize = mapView.bounds.size;
	CGRect frameToCenter = mapView.customMap.frame;
	
	//center horizontally
	if(frameToCenter.size.width < boundsSize.width)
		frameToCenter.origin.x = (boundsSize.width- frameToCenter.size.width) /2;
	else
		frameToCenter.origin.x = 0;
	
	//center vertically
	if(frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2;
	else
		frameToCenter.origin.y = 0;
	
	_offset = CGPointMake(mapView.contentOffset.x-frameToCenter.origin.x-(mapView.imageView.frame.origin.x*self.xfactor), mapView.contentOffset.y-frameToCenter.origin.y-(mapView.imageView.frame.origin.y*self.yfactor));
	
	[self setNeedsDisplay];
}

- (BOOL)isTouchOnLabel:(UITouch*)touch {
	CGPoint location = [touch locationInView:self];
	
	for (NALabel *label in self.labels) {
		//Create textbox size:
		UIFont* font = [UIFont systemFontOfSize:self.fontSize];
		CGSize textSize = [self calculateMaxTextWidth:label.title forFont:font];
		CGPoint labelPoint = CGPointZero;
		if([label.align isEqualToString:@"l"]){
			labelPoint = CGPointMake((label.labelPoint.x*self.xfactor)-_offset.x, (label.labelPoint.y*self.yfactor)-_offset.y);
		}
		else {
			labelPoint = CGPointMake(((label.labelPoint.x*self.xfactor)-textSize.width)-_offset.x, ((label.labelPoint.y*self.yfactor))-_offset.y);
			
		}
		if(labelPoint.x <= location.x && (labelPoint.x+textSize.width) >= location.x &&
		   labelPoint.y <= location.y && (labelPoint.y+textSize.height) >= location.y)
			return YES;
	}
	return NO;
}

- (NALabel*)getLabelInTouch:(UITouch*)touch {
	CGPoint location = [touch locationInView:self];
	
	for (NALabel *label in self.labels) {
		//Create textbox size:
		UIFont* font = [UIFont systemFontOfSize:self.fontSize];
		CGSize textSize = [self calculateMaxTextWidth:label.title forFont:font];
		CGPoint labelPoint = CGPointZero;
		if([label.align isEqualToString:@"l"]){
			labelPoint = CGPointMake((label.labelPoint.x*self.xfactor)-_offset.x, (label.labelPoint.y*self.yfactor)-_offset.y);
		}
		else {
			labelPoint = CGPointMake(((label.labelPoint.x*self.xfactor)-textSize.width)-_offset.x, ((label.labelPoint.y*self.yfactor))-_offset.y);
			
		}
		if(labelPoint.x <= location.x && (labelPoint.x+textSize.width) >= location.x &&
		   labelPoint.y <= location.y && (labelPoint.y+textSize.height) >= location.y)
			return label;
	}
	return nil;
}

/*
 Checks if the touch on the LabelView should be handled or passed to the GestureRecognizer on ImageViewController
 */
- (BOOL)checkTouch:(UITouch*)touch {
	if(touch.tapCount != 1)
		return NO;
	
	return [self isTouchOnLabel:touch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	NALabel* label = [self getLabelInTouch:touch];
	if(label != nil){
		
		//Check if label is in the left or the right area of the image
		NSInteger position = cNotePositionRight;
		NAMapView* mapView = (NAMapView*)self.superview;
		if(label.labelPoint.x > (mapView.imageView.image.size.width/2))
			position = cNotePositionLeft;
		
		if(delegate)
			[delegate labelSelected:label atPosition:position];
	}
	else {
		if(delegate)
			[delegate labelDeselected];
	}
	[self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	//KWLogDebug(@"[%@] touchesCancelled", self.class);
	if(delegate)
		[delegate labelDeselected];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//KWLogDebug(@"[%@] touchesBegan", self.class);
}

@end
