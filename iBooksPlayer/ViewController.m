#import "ViewController.h"
#import "metadataRetriever.h"

#define FILE @"%@/Adrift On Celestial Seas.mp3"

@implementation ViewController
@synthesize timeLine = _timeLine;
@synthesize timeSeconds = _timeSeconds;
@synthesize commonTimeForPlaying = _commonTimeForPlaying;
@synthesize timer = _timer;
@synthesize tagInfo = _tagInfo;

- (void)viewDidLoad {
   [super viewDidLoad];
   
   NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:FILE, [[NSBundle mainBundle] resourcePath]]];
	NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];

   [audioPlayer setNumberOfLoops:0];
   [audioPlayer setVolume:0.6];
   [audioPlayer prepareToPlay];
   
   [_timeSeconds setDelegate:self];
   
   playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                    target:self
                                                  selector:@selector(updateSlider)
                                                  userInfo:nil
                                                   repeats:YES];
   
   [_timeLine setMaximumValue:audioPlayer.duration];
   [_timeLine addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
   
   [self setCommonTime];
   [self setComments];
}

- (void)updateSlider {
   [_timeLine setValue:audioPlayer.currentTime];
}

- (void)viewDidUnload {
   [self setTimeSeconds:nil];
   [self setTimeLine:nil];
   [self setCommonTimeForPlaying:nil];
   [self setTimer:nil];
   [self setTagInfo:nil];
   [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)play {
   playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    target:self
                                                  selector:@selector(updateTime)
                                                  userInfo:nil
                                                   repeats:YES];
   [audioPlayer play];
}

- (IBAction)pause {
   [audioPlayer pause];
}

- (IBAction)stop {
   [audioPlayer stop];
   [audioPlayer setCurrentTime:0];
}

- (IBAction)playtime {
   [self stopAndStartPlaying:_timeSeconds.text];
}

- (IBAction)sliderChanged:(UISlider *)sender {
   [self stopAndStartPlaying:[NSString stringWithFormat:@"%f", _timeLine.value]];
}

- (void)stopAndStartPlaying: (NSString *)seconds {
   [audioPlayer stop];
   [audioPlayer setCurrentTime:[seconds doubleValue]];
   [audioPlayer prepareToPlay];
   [audioPlayer play];
}

- (void)updateTime {
   [_timer setText:[self createFormatingForTime: audioPlayer.currentTime]];
}

- (void)setCommonTime {
   [_commonTimeForPlaying setText:[self createFormatingForTime: audioPlayer.duration]];
}

- (NSString *)createFormatingForTime: (float)time {
   NSString *minutes = [NSString stringWithFormat:@"%0.0f", floor(time / 60)];
   NSString *seconds = [NSString stringWithFormat:@"%0.0f", time - ([minutes floatValue] * 60)];
   
   if ( minutes.length == 1 )
      minutes = [NSString stringWithFormat:@"0%@", minutes];
   
   if ( seconds.length == 1 )
      seconds = [NSString stringWithFormat:@"0%@", seconds];
   
   return [NSString stringWithFormat:@"%@:%@", minutes, seconds];
}

- (void)setComments {
   NSArray *metadataArray = [metadataRetriever getMetadataForFile:[NSString stringWithFormat:FILE, [[NSBundle mainBundle] resourcePath]]];
   NSString *comments = [metadataArray objectAtIndex:3];
   comments = [comments stringByReplacingOccurrencesOfString:@"|" withString:@"\n"];
   [_tagInfo setText:comments];
}

- (BOOL)textFieldShouldReturn:(UITextField*) textField {
   [textField resignFirstResponder]; 
   return YES;
}

@end
