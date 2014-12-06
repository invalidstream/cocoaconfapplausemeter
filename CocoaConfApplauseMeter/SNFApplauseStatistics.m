//
//  SNFApplauseStatistics.m
//  CocoaConfApplauseMeter
//
//  Created by Chris Adamson on 11/24/12.
//  Copyright (c) 2012 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "SNFApplauseStatistics.h"

@implementation SNFApplauseStatistics

@synthesize meteringStartedDate	= _meteringStartedDate;
@synthesize meteringEndedDate = _meteringEndedDate;
@synthesize maxLevel = _maxLevel;

#pragma mark init/dealloc

-(id) initWithTitle: (NSString*) title startedDate: (NSDate*) startedDate endedDate: (NSDate*) endedDate maxLevel: (Float32) maxLevel {
    self = [super init];
    if (self) {
		self.title = title;
        self.meteringStartedDate = startedDate;
		self.meteringEndedDate = endedDate;
		self.maxLevel = maxLevel;
    }
    return self;
}
	

-(id) initForCurrentDateWithTitle: (NSString*) title {
	return [self initWithTitle: title startedDate: [NSDate date] endedDate: nil maxLevel: 0.0];
}



#pragma mark util
-(NSString*) description {
	return [NSString stringWithFormat:@"%@: started: %@, ended: %@, max: %0.3f",
			self.title,
			self.meteringStartedDate, self.meteringStartedDate, self.maxLevel];
}

@end
