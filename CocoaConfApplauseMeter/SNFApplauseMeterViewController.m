//
//  SNFDetailViewController.m
//  CocoaConfApplauseMeter
//
//  Created by Chris Adamson on 11/24/12.
//  Copyright (c) 2012 Subsequently & Furthermore, Inc. All rights reserved.
//

#import "SNFApplauseMeterViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SNFApplauseLevelMeterView.h"

#define TIMER_POLLING_INTERVAL 0.01

typedef enum {
	PollingTypeAveragePower,
	PollingTypePeakPower
} PollingType;

@interface SNFApplauseMeterViewController () <UITextFieldDelegate>
- (void)configureView;
@property (assign) AudioQueueRef audioQueue;
@property (strong, readonly) NSTimer *pollingTimer;
@property (strong, nonatomic) IBOutlet UIView *trivialLevelView;
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
- (IBAction)startStopButtonTapped:(id)sender;
-(void) startMetering;
-(void) stopMetering;
@property (weak, nonatomic) IBOutlet SNFApplauseLevelMeterView *applauseLevelMeterView;
@property (weak, nonatomic) IBOutlet UILabel *peakLevelLabel;
-(void) refreshPeakLevelLabel;
@property (assign) PollingType pollingType;
@property (weak) IBOutlet UILabel *pollingTypeLabel;
@end

@implementation SNFApplauseMeterViewController

@synthesize applauseStats = _applauseStats;
@synthesize audioQueue = _audioQueue;
@synthesize pollingTimer = _pollingTimer;

#pragma mark c forward declarations
void audioQueueInputCallback (
							  void                                *inUserData,
							  AudioQueueRef                       inAQ,
							  AudioQueueBufferRef                 inBuffer,
							  const AudioTimeStamp                *inStartTime,
							  UInt32                              inNumberPacketDescriptions,
							  const AudioStreamPacketDescription  *inPacketDescs
							  );


#pragma mark - Managing the detail item

- (void)setApplauseStats:(SNFApplauseStatistics *)applauseStats	
{
    if (_applauseStats != applauseStats) {
        _applauseStats = applauseStats;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

	if (self.applauseStats) {
	    self.titleField.text = self.applauseStats.title;
		[self refreshPeakLevelLabel];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
	[self stopMetering];
}

#pragma mark property override
// lazily create the audio queue
-(AudioQueueRef) audioQueue {
	if (! _audioQueue) {
		OSStatus audioErr = noErr;
		AudioStreamBasicDescription inputFormat = {0};
		inputFormat.mSampleRate = 22050.0;
		inputFormat.mFormatID = kAudioFormatLinearPCM;
		inputFormat.mFormatFlags = kAudioFormatFlagsCanonical;
		inputFormat.mChannelsPerFrame = 1; // mono
		inputFormat.mBitsPerChannel = 16;
		inputFormat.mBytesPerFrame = inputFormat.mChannelsPerFrame * inputFormat.mBitsPerChannel / 8;
		inputFormat.mFramesPerPacket = 1;
		inputFormat.mBytesPerPacket = inputFormat.mBytesPerFrame * inputFormat.mFramesPerPacket;

		
		audioErr = AudioQueueNewInput(&inputFormat,
									  audioQueueInputCallback,
									  (__bridge void*) self,
									  NULL,
									  kCFRunLoopDefaultMode,
									  0,
									  &_audioQueue);
		if (audioErr) {
			NSLog (@"couldn't create audio queue: %ld", audioErr);
		}
		
		// enable metering
		UInt32 enabledFlag = 1;
		UInt32 propSize = sizeof(enabledFlag);
		audioErr = AudioQueueSetProperty(_audioQueue,
										 kAudioQueueProperty_EnableLevelMetering,
										 &enabledFlag,
										 propSize);
		if (audioErr) {
			NSLog (@"couldn't enable audio queue metering: %ld", audioErr);
		}

		// create and enqueue buffers
		UInt32 bufferSize = (UInt32) (inputFormat.mSampleRate * inputFormat.mBytesPerFrame * 1.0); // 1 sec of audio
		for (int i=0; i<3; i++) {
			AudioQueueBufferRef buffer;
			audioErr = AudioQueueAllocateBuffer(self.audioQueue,
												bufferSize,
												&buffer);
			if (audioErr) {
				NSLog (@"couldn't create audio queue buffer[%d]: %ld", i, audioErr);
			} else {
				audioErr = AudioQueueEnqueueBuffer(self.audioQueue,
												   buffer,
												   0,
												   NULL);
				if (audioErr) {
					NSLog (@"couldn't enqueue audio queue buffer[%d]: %ld", i, audioErr);
				}
			}
			
		}
		
	}
	
	return _audioQueue;
}

-(void) setAudioQueue:(AudioQueueRef)audioQueue	 {
	_audioQueue = audioQueue;
}

-(NSTimer*) pollingTimer {
	if (!_pollingTimer) {
		_pollingTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_POLLING_INTERVAL
														 target:self
													   selector:@selector(pollingTimerCallback:)
													   userInfo:self
														repeats:YES];
	}
	return _pollingTimer;
}


#pragma mark aq callback
void audioQueueInputCallback (
							  void                                *inUserData,
							  AudioQueueRef                       inAQ,
							  AudioQueueBufferRef                 inBuffer,
							  const AudioTimeStamp                *inStartTime,
							  UInt32                              inNumberPacketDescriptions,
							  const AudioStreamPacketDescription  *inPacketDescs
							  ) {
//	NSLog (@"audioQueueInputCallback");
	// don't care, just re-enqueue
	OSStatus audioErr = noErr;
	SNFApplauseMeterViewController *vc = (__bridge SNFApplauseMeterViewController*) inUserData;
	audioErr = AudioQueueEnqueueBuffer(vc.audioQueue,
									   inBuffer,
									   0,
									   NULL);

}

#pragma mark timer callback
-(void) pollingTimerCallback: (NSTimer*) timer {
	OSStatus audioErr = noErr;
	AudioQueueLevelMeterState levelMeterStates[1];
	UInt32 propSize = sizeof (levelMeterStates);
	audioErr = AudioQueueGetProperty(self.audioQueue,
									 kAudioQueueProperty_CurrentLevelMeter,
									 &levelMeterStates,
									 &propSize);
	Float32 currentLevel = (self.pollingType == PollingTypePeakPower) ?
	levelMeterStates[0].mPeakPower :
	levelMeterStates[0].mAveragePower;
	self.applauseLevelMeterView.level = currentLevel;
	[self.applauseLevelMeterView setNeedsDisplay];
	if (currentLevel > self.applauseStats.maxLevel) {
		self.applauseStats.maxLevel = currentLevel;
		[self refreshPeakLevelLabel];
	}
}

-(void) startMetering {
	self.pollingType = [[[NSUserDefaults standardUserDefaults]
						valueForKey:@"PollingType"]
						intValue];
	self.pollingTypeLabel.text = (self.pollingType == PollingTypePeakPower) ?
	@"Peak Power" : @"Average Power";
	OSStatus audioErr = noErr;
	audioErr = AudioQueueStart(self.audioQueue,
							   NULL);
	if (audioErr) {
		NSLog (@"couldn't start audio queue: %ld", audioErr);
	}
	NSLog (@"started audio queue");
	// also start timer
	self.applauseStats.meteringStartedDate = [NSDate date];
	self.pollingTimer; // ugly: getters should not be used for side effects

}

-(void) stopMetering {
	OSStatus audioErr = noErr;
	audioErr = AudioQueueStop(self.audioQueue, true);
	audioErr = AudioQueueDispose(self.audioQueue, true);
	self.audioQueue = nil;
	[self.pollingTimer invalidate];
	_pollingTimer = nil;
	self.applauseStats.meteringEndedDate = [NSDate date];
}

- (IBAction)startStopButtonTapped:(id)sender {
	if (self.startStopButton.selected) {
		// currently metering, should stop
		[self stopMetering];
		self.startStopButton.selected = NO;
	} else {
		// not metering, should start
		[self startMetering];
		self.startStopButton.selected = YES;
	}
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	self.applauseStats.title = textField.text;
	return YES;
}

-(void) refreshPeakLevelLabel {
	self.peakLevelLabel.text = [NSString stringWithFormat:@"%0.3f", self.applauseStats.maxLevel];
}

@end
