//
//  TestViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 29/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "TestViewController.h"
#import "NoteView.h"
#import "Const.h"
#import <AVFoundation/AVFoundation.h>

@interface TestViewController ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer * myBackMusic;
@property (nonatomic, strong) NSURL * goodSoundPath;
@property (nonatomic, strong) NSURL * badSoundPath;
@property (nonatomic, strong) NSArray * buttons;
@property (nonatomic, strong) UIButton * pauseBtn;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, strong) NSArray * notes;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSMutableArray * sounds;
@property (nonatomic, strong) NSArray * tracks;
@property (nonatomic) int noteFlag;
@property (nonatomic) int tempo;
@property (nonatomic) double pre;
@property (nonatomic) int combo;

@property (nonatomic, strong) UILabel * nameLable;
@property (nonatomic, strong) UILabel * timeLable;
@property (nonatomic, strong) UILabel * comboLabel;

@end

#define LAYOUT_R    (230 * SCALE)
#define NOTE_SIZE   (70 * SCALE)

#define BUTTON_TAG  1000

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"001" ofType:@"plist"];
    NSDictionary * dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary * info = [dic objectForKey:@"info"];
    self.name = [info objectForKey:@"name"];
    self.tempo = [(NSNumber *)[info objectForKey:@"tempo"] intValue];
    self.pre = [(NSNumber *)[info objectForKey:@"start"] doubleValue];
    self.notes = [dic objectForKey:@"nodes"];
    self.noteFlag = 0;
    self.combo = 0;
    
    if (!_buttons) {
        NSMutableArray * temp = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.layer.borderWidth = 3.0;
            button.layer.borderColor = [UIColor blueColor].CGColor;
            button.layer.cornerRadius = NOTE_SIZE / 2;
            button.frame = [self frameWithNoteNum:i progress:1];
            button.tag = BUTTON_TAG + i;
            
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
            [temp addObject:button];
            [self.view addSubview:button];
        }
        self.buttons = [NSArray arrayWithArray:temp];
    }
    
    if (!_tracks) {
        NSMutableArray * tracks = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9; i++) {
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
        NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:@"001" ofType:@"mp3"];
        NSURL * musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
        AVAudioPlayer * myBackMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
        self.myBackMusic = myBackMusic;
    }
    
    [_myBackMusic prepareToPlay];
    [_myBackMusic setVolume:0.6];
    _myBackMusic.numberOfLoops = 0;
    [_myBackMusic play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_displayLink invalidate];
    [_myBackMusic stop];
    
    for (AVAudioPlayer * player in _sounds) {
        player.delegate = nil;
        [_sounds removeObject:player];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (CGRect)frameWithNoteNum:(int)i progress:(float)p {
    float size = 10  * SCALE + (NOTE_SIZE - 10 * SCALE) * p;
    float x = self.view.frame.size.width / 2 - LAYOUT_R * cos(i * M_PI / 8) * p - size / 2;
    float y = 100 * SCALE + LAYOUT_R * sin(i * M_PI / 8) * p - size / 2;
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
}


#pragma mark - Action methods

- (void)buttonClicked:(id)sender {
    NSTimeInterval clickTime = self.myBackMusic.currentTime;
    
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
        
        [self playSoundEffectIsGood:ABS(targetView.timePoint - clickTime) <= GOOD_TIME];
        
        [self showTapResult:ABS(targetView.timePoint - clickTime)];
        
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
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
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
    double timeBegin = [(NSNumber *)[nodeData objectForKey:@"timeBegin"] doubleValue] * 60 / self.tempo + self.pre;
    BOOL isLeft = ([(NSNumber *)[nodeData objectForKey:@"timeBegin"] intValue] / 4) % 2 == 0;
    int track = [(NSNumber *)[nodeData objectForKey:@"track"] intValue];
    if ((timeBegin - DROP_TIME - OFFSET) <= self.myBackMusic.currentTime) {
        int count = isLeft ? 0 : 5;
        while (track > 0) {
            if (track % 2) {
                NoteView * noteView = [[NoteView alloc] init];
                double diff = (self.myBackMusic.currentTime - (timeBegin - DROP_TIME - OFFSET));
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
                cornerAnimation.duration = DROP_TIME - diff + MISS_TIME;
                cornerAnimation.fromValue = @([self frameWithNoteNum:count progress:diff/DROP_TIME].size.width / 2);
                cornerAnimation.toValue = @([self frameWithNoteNum:count progress:1 + MISS_TIME / DROP_TIME].size.width / 2);
                cornerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                cornerAnimation.removedOnCompletion = NO;
                cornerAnimation.fillMode = kCAFillModeForwards;
                [noteView.layer addAnimation:cornerAnimation forKey:@"cornerRadius"];
                
//                CABasicAnimation * positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
//                positionAnimation.duration = _dropTime - diff;
//                positionAnimation.fromValue = [self frameWithNoteNum:count progress:diff/_dropTime].size.width / 2;
//                positionAnimation.toValue = [self frameWithNoteNum:count progress:1].size.width / 2;
//                positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//                positionAnimation.removedOnCompletion = NO;
//                positionAnimation.fillMode = kCAFillModeForwards;
//                [noteView.layer addAnimation:animation forKey:@"cornerRadius"];
                
                [UIView animateWithDuration:DROP_TIME - diff + MISS_TIME
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     noteView.frame = [self frameWithNoteNum:count progress:1 + MISS_TIME / DROP_TIME];
                                     noteView.layer.cornerRadius = noteView.frame.size.width / 2;
                                 }
                                 completion:^(BOOL finished) {
                                     if (!noteView.isTapped) {
                                         [self showMiss];
                                         NSMutableArray * notes = [_tracks objectAtIndex:noteView.track];
                                         [notes removeObject:noteView];
                                         [noteView removeFromSuperview];
//                                         [self buttonClicked:[_buttons objectAtIndex:noteView.track]];
                                     }
                                 }];
            }
            track = track / 2;
            count++;
        }
        self.noteFlag++;
    }
}

@end
