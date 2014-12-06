//
//  SNFDetailViewController.h
//  CocoaConfApplauseMeter
//
//  Created by Chris Adamson on 11/24/12.
//  Copyright (c) 2014 Subsequently & Furthermore, Inc. CC0 License - http://creativecommons.org/about/cc0//
//

#import <UIKit/UIKit.h>
#import "SNFApplauseStatistics.h"

@interface SNFApplauseMeterViewController : UIViewController

@property (strong, nonatomic) SNFApplauseStatistics *applauseStats;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@end
