//
//  SNFMasterTableViewCell.h
//  CocoaConfApplauseMeter
//
//  Created by Chris Adamson on 11/24/12.
//  Copyright (c) 2012 Subsequently & Furthermore, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNFMasterTableViewCell : UITableViewCell

@property (strong) IBOutlet UILabel *titleLabel;
@property (strong) IBOutlet UILabel *startedDateLabel;
@property (strong) IBOutlet UILabel *maxLevelLabel;

@end
