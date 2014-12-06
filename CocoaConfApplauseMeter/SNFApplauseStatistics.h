//
//  SNFApplauseStatistics.h
//  CocoaConfApplauseMeter
//
//  Created by Chris Adamson on 11/24/12.
//  Copyright (c) 2014 Subsequently & Furthermore, Inc. CC0 License - http://creativecommons.org/about/cc0//
//

#import <Foundation/Foundation.h>

@interface SNFApplauseStatistics : NSObject

@property (copy) NSString *title;
@property (copy) NSDate *meteringStartedDate;
@property (copy) NSDate *meteringEndedDate;
@property (assign) Float32 maxLevel;

-(id) initForCurrentDateWithTitle: (NSString*) title;

-(id) initWithTitle: (NSString*) title startedDate: (NSDate*) startedDate endedDate: (NSDate*) endedDate maxLevel: (Float32) maxLevel;



@end
