#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController <UITextFieldDelegate, AVAudioPlayerDelegate> {
   AVAudioPlayer *audioPlayer;
   NSTimer *playbackTimer;
}

- (IBAction)play;
- (IBAction)pause;
- (IBAction)stop;
- (IBAction)playtime;
- (IBAction)sliderChanged:(UISlider *)sender;

@property (weak, nonatomic) IBOutlet UISlider *timeLine;
@property (weak, nonatomic) IBOutlet UITextField *timeSeconds;
@property (weak, nonatomic) IBOutlet UILabel *commonTimeForPlaying;
@property (weak, nonatomic) IBOutlet UILabel *timer;
@property (weak, nonatomic) IBOutlet UITextView *tagInfo;

@end
