//
//  PlayViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "PlayViewController.h"
#import "NoteView.h"
#import "Const.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayViewController ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer * myBackMusic;
@property (nonatomic, strong) NSURL * goodSoundPath;
@property (nonatomic, strong) NSURL * badSoundPath;

@property (nonatomic, strong) NSArray * buttons;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, strong) NSArray * notes;
@property (nonatomic, strong) UIButton * pauseBtn;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSMutableArray * sounds;
@property (nonatomic, strong) NSArray * tracks;
@property (nonatomic) int noteFlag;
@property (nonatomic) int tempo;
@property (nonatomic) double pre;
@property (nonatomic) double offset;
@property (nonatomic) int combo;

@property (nonatomic) TypePlayMod mod;
@property (nonatomic) double diff;
@property (nonatomic, strong) NSString * songID;

@property (nonatomic, strong) UILabel * nameLable;
@property (nonatomic, strong) UILabel * timeLable;
@property (nonatomic, strong) UILabel * comboLabel;

@end

#define LAYOUT_R    (230 * SCALE)
#define NOTE_SIZE   (70 * SCALE)

#define BUTTON_TAG  1000

@implementation PlayViewController

- (id)initWithPlayMod:(TypePlayMod)mod songID:(NSString *)songID {
    self = [super init];
    if (self) {
        self.mod = mod;
        self.songID = songID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_mod == TypePlayModTest) _songID = @"test";
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:_songID ofType:@"plist"];
    NSDictionary * dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary * info = [dic objectForKey:@"info"];
    self.name = [info objectForKey:@"name"];
    self.tempo = [(NSNumber *)[info objectForKey:@"tempo"] intValue];
    self.pre = [(NSNumber *)[info objectForKey:@"start"] doubleValue];
    self.notes = [dic objectForKey:@"notes"];
    self.noteFlag = 0;
    self.combo = 0;
    self.diff = 0;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * offset = [defaults objectForKey:KEY_OFFSET];
    self.offset = offset ? [offset doubleValue] : 0;
    
    if (!_buttons) {
        NSMutableArray * temp = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.layer.borderWidth = 3.0;
            button.layer.borderColor = [UIColor blueColor].CGColor;
            button.layer.cornerRadius = NOTE_SIZE / 2;
            button.frame = [self frameWithNoteNum:i progress:1];
            button.tag = BUTTON_TAG + i;
            
            if (_mod != TypePlayModAuto) {
                [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
            }
            [temp addObject:button];
            [self.view addSubview:button];
        }
        self.buttons = [NSArray arrayWithArray:temp];
    }
    
    if (!_tracks) {
        NSMutableArray * tracks = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i++) {
            NSMutableArray * notes = [[NSMutableArray alloc] init];
            [tracks addObject:notes];
        }
        self.tracks = [[NSArray alloc] initWithArray:tracks];
    }
    
    if (!_pauseBtn) {
        UIButton * pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        pauseBtn.frame = CGRectMake(10 * SCALE, 10 * SCALE, 50 * SCALE, 30 * SCALE);
        [pauseBtn setTitle:@"Back" forState:UIControlStateNormal];
        [pauseBtn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:pauseBtn];
        self.pauseBtn = pauseBtn;
    }
    
    if (!_timeLable) {
        UILabel * timeLable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 50 * SCALE,
                                                                        40 * SCALE,
                                                                        0, 0)];
        [self.view addSubview:timeLable];
        self.timeLable = timeLable;
    }
    
    if (!_nameLable) {
        UILabel * nameLable = [[UILabel alloc] init];
        nameLable.text = self.name;
        nameLable.font = [UIFont systemFontOfSize:20];
        [nameLable sizeToFit];
        CGRect frame = nameLable.frame;
        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
        frame.origin.y = 20 * SCALE;
        nameLable.frame = frame;
        [self.view addSubview:nameLable];
        self.nameLable = nameLable;
    }
    
    if (!_comboLabel) {
        UILabel * comboLabel = [[UILabel alloc] init];
        comboLabel.font = [UIFont systemFontOfSize:18];
        comboLabel.alpha = 0;
        [self.view addSubview:comboLabel];
        self.comboLabel = comboLabel;
    }
    
    if (!_displayLink) {
        CADisplayLink * displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = displayLink;
    }
    
    if (!_goodSoundPath) {
        NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:@"good" ofType:@"mp3"];
        NSURL * musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
        self.goodSoundPath = musicURL;
    }
    
    if (!_badSoundPath) {
        NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:@"bad" ofType:@"mp3"];
        NSURL * musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
        self.badSoundPath = musicURL;
    }
    
    if (!_sounds) {
        self.sounds = [[NSMutableArray alloc] init];
    }
    
    if (!_myBackMusic) {
        NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:_songID ofType:@"mp3"];
        NSURL * musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
        AVAudioPlayer * myBackMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
        myBackMusic.delegate = self;
        self.myBackMusic = myBackMusic;
    }
    
    [_myBackMusic prepareToPlay];
    [_myBackMusic setVolume:0.6];
    _myBackMusic.numberOfLoops = 0;
    [_myBackMusic play];
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
    }
}

- (void)dealloc {
    [_displayLink invalidate];
    [_myBackMusic stop];
    _myBackMusic.delegate = nil;
    
    for (AVAudioPlayer * player in _sounds) {
        player.delegate = nil;
        [_sounds removeObject:player];
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (CGRect)frameWithNoteNum:(int)i progress:(float)p {
    float size = 10  * SCALE + (NOTE_SIZE - 10 * SCALE) * p;
    float angle = (1 + 2 * i) * M_PI / 8;
    float x = self.view.frame.size.width / 2 - LAYOUT_R * cos(angle) * p - size / 2;
    float y = 100 * SCALE + LAYOUT_R * sin(angle) * p - size / 2;
    return CGRectMake(x, y, size, size);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        return YES;
    }
    
    return NO;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (player != _myBackMusic) {
        player.delegate = nil;
        [_sounds removeObject:player];
    }
    else {
        if (_mod == TypePlayModTest) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Test result"
                                                                                      message:[NSString stringWithFormat:@"Your tap's offset is:%.3f",(_diff / _notes.count)]
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                                                                    [userDefaults setObject:[NSNumber numberWithDouble:(_diff / _notes.count)]
                                                                                     forKey:KEY_OFFSET];
                                                                    [self back];
                                                                }];
            [alertController addAction:saveAction];

            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      [self back];
                                                                  }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:NULL];
        }
        else {
            
        }
    }
}

#pragma mark - Action methods

- (void)buttonClicked:(id)sender {
    NSTimeInterval clickTime = self.myBackMusic.currentTime + SYSYTEM_OFFSET;
    
    UIButton * button = (UIButton *)sender;
    int track = (int) (button.tag - BUTTON_TAG);
    
    NSMutableArray * notes = [_tracks objectAtIndex:track];
    
    NoteView * targetView;
    for (NoteView * noteView in notes) {
        if (noteView.timePoint - clickTime < MISS_TIME) {
            if (!targetView || noteView.timePoint < targetView.timePoint) {
                targetView = noteView;
            }
        }
    }
    
    if (targetView) {
        targetView.isTapped = YES;
        
        NSLog(@"%f", clickTime - targetView.timePoint);
        
        _diff += clickTime - targetView.timePoint;
        
        [self playSoundEffectIsGood:ABS(targetView.timePoint - clickTime - _offset) <= GOOD_TIME];
        
        [self showTapResult:ABS(targetView.timePoint - clickTime - _offset)];
        
        [targetView removeFromSuperview];
        [notes removeObject:targetView];
    }
}

- (void)playSoundEffectIsGood:(BOOL)isGood {
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:isGood ? _goodSoundPath : _badSoundPath
                                                                    error:nil];
    player.delegate = self;
    [self.sounds addObject:player];
    
    [player prepareToPlay];
    [player setVolume:1];
    player.numberOfLoops = 0;
    [player play];
}

- (void)showMiss {
    if (_mod == TypePlayModTest) return;
    
    _combo = 0;
    [self updateCombo];
    
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:18];
    label.text = @"Miss!";
    [label sizeToFit];
    label.frame = CGRectMake((self.view.frame.size.width - label.frame.size.width) / 2,
                             180 * SCALE,
                             label.frame.size.width,
                             label.frame.size.height);
    
    [self.view addSubview:label];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         label.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [label removeFromSuperview];
                     }];
}

- (void)showTapResult:(NSTimeInterval)diff {
    if (_mod == TypePlayModTest) return;
    
    if (diff > GOOD_TIME) {
        _combo = 0;
    }
    else {
        _combo ++;
    }
    [self updateCombo];
    
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:18];
    label.text = (diff > GOOD_TIME) ? @"Bad!" : (diff > PERFECT_TIME ? @"Good!" : @"Perfect!");
    [label sizeToFit];
    label.frame = CGRectMake((self.view.frame.size.width - label.frame.size.width) / 2,
                             180 * SCALE,
                             label.frame.size.width,
                             label.frame.size.height);
    
    [self.view addSubview:label];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         label.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [label removeFromSuperview];
                     }];
}

- (void)updateCombo {
    if (_combo <= 1) {
        _comboLabel.alpha = 0;
    }
    else {
        _comboLabel.text = [NSString stringWithFormat:@"Combo %d!", _combo];
        [_comboLabel sizeToFit];
        _comboLabel.frame = CGRectMake((self.view.frame.size.width - _comboLabel.frame.size.width) / 2,
                                       180 * SCALE - _comboLabel.frame.size.height - 10 * SCALE,
                                       _comboLabel.frame.size.width,
                                       _comboLabel.frame.size.height);
        _comboLabel.alpha = 1;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             CGRect frame = _comboLabel.frame;
                             frame.origin.y += 10 * SCALE;
                             _comboLabel.frame = frame;
                         }];
    }
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)pause {
    [self.displayLink setPaused:YES];
    [self.myBackMusic pause];
    
    [self back];
}

- (void)handleDisplayLink:(id)sender {
    
    self.timeLable.text = [NSString stringWithFormat:@"%.3f", self.myBackMusic.currentTime];
    [self.timeLable sizeToFit];
    
    if (_noteFlag >= self.notes.count)
        return;
    
    
    NSDictionary * nodeData = self.notes[_noteFlag];
    int type = [(NSNumber *)[nodeData objectForKey:@"type"] intValue];
    if (_mod == TypePlayModEasy && type == 2) {
        _noteFlag++;
        return;
    }
    
    BOOL isAuto = _mod == TypePlayModAuto;
    double missTime = isAuto ? 0 : MISS_TIME;
    
    double timeBegin = [(NSNumber *)[nodeData objectForKey:@"timeBegin"] doubleValue] * 60 / self.tempo + self.pre;
    BOOL isLeft = ([(NSNumber *)[nodeData objectForKey:@"timeBegin"] intValue] / 4) % 2 == 0;
    int track = [(NSNumber *)[nodeData objectForKey:@"track"] intValue];
    if ((timeBegin - DROP_TIME) <= self.myBackMusic.currentTime) {
        int count = isLeft ? 0 : 0;
        while (track > 0) {
            if (track % 2) {
                NoteView * noteView = [[NoteView alloc] init];
                double diff = (self.myBackMusic.currentTime - (timeBegin - DROP_TIME));
                noteView.frame = [self frameWithNoteNum:count progress:(diff/DROP_TIME)];
                noteView.layer.cornerRadius = noteView.frame.size.width / 2;
                noteView.layer.borderWidth = 3;
                noteView.layer.borderColor = [UIColor redColor].CGColor;
                noteView.track = count;
                noteView.timePoint = (NSTimeInterval)timeBegin;
                noteView.isTapped = NO;
                NSMutableArray * notes = [_tracks objectAtIndex:count];
                [notes addObject:noteView];
                
                [self.view addSubview:noteView];
                
                CABasicAnimation * cornerAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                cornerAnimation.duration = DROP_TIME - diff + missTime - SYSYTEM_OFFSET;
                cornerAnimation.fromValue = @([self frameWithNoteNum:count progress:diff/DROP_TIME].size.width / 2);
                cornerAnimation.toValue = @([self frameWithNoteNum:count progress:1 + missTime / DROP_TIME].size.width / 2);
                cornerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                cornerAnimation.removedOnCompletion = NO;
                cornerAnimation.fillMode = kCAFillModeForwards;
                [noteView.layer addAnimation:cornerAnimation forKey:@"cornerRadius"];
                
                [UIView animateWithDuration:DROP_TIME - diff + missTime - SYSYTEM_OFFSET
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     noteView.frame = [self frameWithNoteNum:count progress:1 + missTime / DROP_TIME];
                                     noteView.layer.cornerRadius = noteView.frame.size.width / 2;
                                 }
                                 completion:^(BOOL finished) {
                                     if (!noteView.isTapped) {
                                         if (isAuto) {
                                             [self buttonClicked:[_buttons objectAtIndex:noteView.track]];
                                         }
                                         else {
                                             [self showMiss];
                                         }
                                         
                                         NSMutableArray * notes = [_tracks objectAtIndex:noteView.track];
                                         [notes removeObject:noteView];
                                         [noteView removeFromSuperview];
                                     }
                                 }];
            }
            track = track / 2;
            count++;
        }
        _noteFlag++;
    }
}

@end
