//
//  SNFMasterViewController.m
//  CocoaConfApplauseMeter
//
//  Created by Chris Adamson on 11/24/12.
//  Copyright (c) 2014 Subsequently & Furthermore, Inc. CC0 License - http://creativecommons.org/about/cc0//
//

#import "SNFMasterViewController.h"

#import "SNFApplauseMeterViewController.h"
#import "SNFApplauseStatistics.h"
#import "SNFMasterTableViewCell.h"

@interface SNFMasterViewController ()
@property (strong) NSMutableArray *allStats;
@property (assign) NSUInteger titleCounter;
@end

@implementation SNFMasterViewController

@synthesize allStats = _allStats;
@synthesize titleCounter = _titleCounter;

- (id)init
{
    self = [super init];
    if (self) {
        self.titleCounter = 0;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;
}

-(void) viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_allStats) {
        _allStats = [[NSMutableArray alloc] init];
    }
	SNFApplauseStatistics *stats = [[SNFApplauseStatistics alloc]
									initForCurrentDateWithTitle:[NSString stringWithFormat:@"Session %d",
																 ++_titleCounter]];
	[_allStats addObject:stats];
	
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.allStats count]-1
												inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableView selectRowAtIndexPath:indexPath
								animated:NO
						  scrollPosition:UITableViewScrollPositionNone];
	[self performSegueWithIdentifier:@"showStats" sender:self];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog (@"%d rows", [self.allStats count]);
	return _allStats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNFMasterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatsCell"
																   forIndexPath:indexPath];
	SNFApplauseStatistics *stats = (SNFApplauseStatistics*) _allStats[indexPath.row];
	cell.titleLabel.text = stats.title;
	cell.startedDateLabel.text = [stats.meteringStartedDate description];
	cell.maxLevelLabel.text = [NSString stringWithFormat:@"%0.3f", stats.maxLevel];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_allStats removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showStats"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SNFApplauseStatistics *stats = (SNFApplauseStatistics*) _allStats[indexPath.row];
        [[segue destinationViewController] setApplauseStats:stats];
    }
}

@end
