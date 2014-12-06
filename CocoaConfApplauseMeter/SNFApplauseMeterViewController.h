//
//  SNFDetailViewController.h
//  CocoaConfApplauseMeter
//
//  Created by Chris Adamson on 11/24/12.
//  Copyright (c) 2012 Subsequently & Furthermore, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNFApplauseStatistics.h"

@interface SNFApplauseMeterViewController : UIViewController

@property (strong, nonatomic) SNFApplauseStatistics *applauseStats;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@end
