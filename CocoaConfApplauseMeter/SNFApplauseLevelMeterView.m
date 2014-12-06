//
//  SNFApplauseLevelMeterView.m
//  CocoaConfApplauseMeter
//
//  Created by Chris Adamson on 11/30/12.
//  Copyright (c) 2014 Subsequently & Furthermore, Inc. CC0 License - http://creativecommons.org/about/cc0//
//

#import "SNFApplauseLevelMeterView.h"

#define SHOW_AVERAGE_LEVEL_TEXT

@implementation SNFApplauseLevelMeterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
- (void)drawRect:(CGRect)rect
{
	
	float levelHeight = self.bounds.size.height * self.level;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
	CGRect fillRect = CGRectMake(self.bounds.origin.x,
								 self.bounds.origin.y + self.bounds.size.height - levelHeight,
								 self.bounds.size.width,
								 levelHeight);
	CGContextFillRect(context, fillRect);

#ifdef SHOW_AVERAGE_LEVEL_TEXT
	// debug
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0.0, -1 * self.bounds.size.height);
    CGContextSelectFont(context, "Helvetica", 20, kCGEncodingMacRoman);
	CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
	NSString *debugLevelString = [NSString stringWithFormat:@"%0.3f", self.level];
	const char *str = [debugLevelString UTF8String];
	CGContextShowTextAtPoint(context,
							 10.0,
							 self.bounds.size.height - 40,
							 str,strlen(str));
#endif
	
	
	CGContextRestoreGState(context);
}

@end
