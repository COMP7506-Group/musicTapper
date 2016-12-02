//
//  PlayViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "PlayViewController.h"
#import "NoteView.h"
#import "ResultView.h"
#import "Const.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+EasingFunctions.h"
#import "easing.h"


@interface PlayViewController ()<AVAudioPlayerDelegate, ResultViewDelegate>

@property (nonatomic, strong) AVAudioPlayer * myBackMusic;
@property (nonatomic, strong) NSURL * goodSoundPath;
@property (nonatomic, strong) NSURL * badSoundPath;

@property (nonatomic, strong) NSArray * buttons;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, strong) NSArray * notes;
@property (nonatomic) int noteFlag;
@property (nonatomic, strong) NSMutableArray * sounds;
@property (nonatomic, strong) NSArray * tracks;
@property (nonatomic, strong) UIButton * pauseBtn;

@property (nonatomic, strong) NSString * songID;
@property (nonatomic, strong) NSString * name;
@property (nonatomic) TypePlayMode mode;
@property (nonatomic) int tempo;
@property (nonatomic) double pre;
@property (nonatomic) double offset;
@property (nonatomic) double diff;
@property (nonatomic) BOOL isPlaying;

@property (nonatomic) int combo;
@property (nonatomic) int perfectCount;
@property (nonatomic) int greatCount;
@property (nonatomic) int goodCount;
@property (nonatomic) int missCount;
@property (nonatomic) int score;
@property (nonatomic) int scoreMax;

@property (nonatomic, strong) UILabel * nameLable;
@property (nonatomic, strong) UILabel * timeLable;
@property (nonatomic, strong) UILabel * comboLabel;
@property (nonatomic, strong) UILabel * scoreLabel;

@property (nonatomic, strong) UIView * pauseBG;
@property (nonatomic, strong) UIButton * backBtn;
@property (nonatomic, strong) UIButton * resumeBtn;
@property (nonatomic, strong) UIButton * retryBtn;

@end

#define LAYOUT_R    (230 * SCALE)
#define NOTE_SIZE   (70 * SCALE)

#define BUTTON_TAG  1000

@implementation PlayViewController

- (id)initWithPlayMod:(TypePlayMode)mode songID:(NSString *)songID {
    self = [super init];
    if (self) {
        self.mode = mode;
        self.songID = songID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_mode == TypePlayModeTest) _songID = @"test";
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:_songID ofType:@"plist"];
    NSDictionary * dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary * info = [dic objectForKey:@"info"];
    self.name = [info objectForKey:@"name"];
    self.tempo = [(NSNumber *)[info objectForKey:@"tempo"] intValue];
    self.pre = [(NSNumber *)[info objectForKey:@"start"] doubleValue];
    self.notes = [dic objectForKey:@"notes"];
    if (_mode == TypePlayModeEasy) {
        self.scoreMax = [(NSNumber *)[info objectForKey:@"score_easy"] intValue];
    }
    else if (_mode == TypePlayModeHard) {
        self.scoreMax = [(NSNumber *)[info objectForKey:@"score_hard"] intValue];
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * offset = [defaults objectForKey:KEY_OFFSET];
    self.offset = (offset && _mode != TypePlayModeAuto) ? [offset doubleValue] : 0;
    
    if (!_buttons) {
        NSMutableArray * temp = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.layer.borderWidth = 3.0 * SCALE;
            button.layer.borderColor = [UIColor blueColor].CGColor;
            button.layer.cornerRadius = NOTE_SIZE / 2;
            button.frame = [self frameWithNoteNum:i progress:1];
            button.tag = BUTTON_TAG + i;
            
            if (_mode != TypePlayModeAuto) {
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
        [pauseBtn setTitle:@"Pause" forState:UIControlStateNormal];
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
    
    if (!_scoreLabel && (_mode == TypePlayModeHard || _mode == TypePlayModeEasy)) {
        UILabel * scoreLabel = [[UILabel alloc] init];
        scoreLabel.font = [UIFont systemFontOfSize:14];
        scoreLabel.frame = CGRectMake(500 * SCALE, 20 * SCALE, 0, 0);
        [self.view addSubview:scoreLabel];
        self.scoreLabel = scoreLabel;
    }
    
    if (!_displayLink) {
        CADisplayLink * displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_displayLink setPaused:YES];
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
    
    [self reset];
    
    [_myBackMusic setVolume:0.6];
    _myBackMusic.numberOfLoops = 0;
    [_myBackMusic play];
    [_displayLink setPaused:NO];
    self.isPlaying = YES;
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
        if (_mode == TypePlayModeTest) {
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
            ResultView * resultView = [[ResultView alloc] initWithResult:nil];
            resultView.delegate = self;
            [resultView showInView:self.view];
        }
    }
}

#pragma mark - ResultViewDelegate

- (void)didSelectOption:(ResultOptionType)type {
    if (type == ResultOptionTypeBack) {
        [self back];
    }
    else if (type == ResultOptionTypeRetry) {
        [self retry];
    }
}

#pragma mark - PlayAction

- (void)reset {
    _noteFlag = 0;
    _combo = 0;
    _diff = 0;
    _perfectCount = 0;
    _greatCount = 0;
    _goodCount = 0;
    _missCount = 0;
    _score = 0;
    
    for (NSMutableArray * array in _tracks) {
        for (NoteView * noteView in array) {
            noteView.isTapped = YES;
            noteView.alpha = 0;
        }
    }
    
    [self updateCombo];
    [self updateScore];
}

- (void)back {
    self.isPlaying = NO;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)retry {
    [_myBackMusic pause];
    [_displayLink setPaused:YES];
    self.isPlaying = NO;
    
    [self reset];
    
    self.myBackMusic.delegate = nil;
    self.myBackMusic = nil;
    
    NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:_songID ofType:@"mp3"];
    NSURL * musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
    AVAudioPlayer * myBackMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    myBackMusic.delegate = self;
    self.myBackMusic = myBackMusic;
    [_myBackMusic setVolume:0.6];
    _myBackMusic.numberOfLoops = 0;

    [_displayLink setPaused:NO];
    [_myBackMusic play];
    self.isPlaying = YES;
}

- (void)pause {
    if (self.isPlaying == NO) {
        [self resume];
        return;
    }
    
    self.isPlaying = NO;
    
    [_displayLink setPaused:YES];
    [_myBackMusic pause];
    
    for (NSMutableArray * noteViews in _tracks) {
        for (NoteView * noteView in noteViews) {
            CFTimeInterval pausetime = [noteView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
            [noteView.layer setTimeOffset:pausetime];
            [noteView.layer setSpeed:0.0f];
        }
    }
    
    float btnWidth = 80 * SCALE;
    float btnHeight = 44 * SCALE;
    float padding = 50 * SCALE;
    float topOrigin = 250 * SCALE;
    
    if (!_pauseBG) {
        _pauseBG = [[UIView alloc] initWithFrame:self.view.frame];
    }
    _pauseBG.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self.view addSubview:_pauseBG];
    
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _backBtn.layer.borderWidth = 3.0 * SCALE;
        _backBtn.layer.borderColor = [UIColor redColor].CGColor;
        _backBtn.layer.cornerRadius = 5 * SCALE;
        [_backBtn addTarget:self action:@selector(handlePauseSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_backBtn setTitle:@"Back" forState:UIControlStateNormal];
    _backBtn.frame = CGRectMake((self.view.frame.size.width - 3 * btnWidth - 2 * padding) / 2,
                                topOrigin,
                                btnWidth,
                                btnHeight);
    [self.view addSubview:_backBtn];
    
    if (!_resumeBtn) {
        _resumeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _resumeBtn.layer.borderWidth = 3.0 * SCALE;
        _resumeBtn.layer.borderColor = [UIColor redColor].CGColor;
        _resumeBtn.layer.cornerRadius = 5 * SCALE;
        [_resumeBtn addTarget:self action:@selector(handlePauseSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_resumeBtn setTitle:@"Resume" forState:UIControlStateNormal];
    _resumeBtn.frame = CGRectMake((self.view.frame.size.width - btnWidth) / 2,
                                  topOrigin,
                                  btnWidth,
                                  btnHeight);
    [self.view addSubview:_resumeBtn];
    
    if (!_retryBtn) {
        _retryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _retryBtn.layer.borderWidth = 3.0 * SCALE;
        _retryBtn.layer.borderColor = [UIColor redColor].CGColor;
        _retryBtn.layer.cornerRadius = 5 * SCALE;
        [_retryBtn addTarget:self action:@selector(handlePauseSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_retryBtn setTitle:@"Retry" forState:UIControlStateNormal];
    _retryBtn.frame = CGRectMake((self.view.frame.size.width + btnWidth + 2 * padding) / 2,
                                 topOrigin,
                                 btnWidth,
                                 btnHeight);
    [self.view addSubview:_retryBtn];
    
    [UIView animateWithDuration:.6 animations:^{
        
        [_backBtn setEasingFunction:ElasticEaseOut forKeyPath:@"frame"];
        _backBtn.frame = CGRectMake((self.view.frame.size.width - 3 * btnWidth - 2 * padding) / 2,
                                    topOrigin,
                                    btnWidth,
                                    btnHeight);
        
    } completion:^(BOOL finished) {
        
        [_backBtn removeEasingFunctionForKeyPath:@"frame"];
        
    }];
}

- (void)resume {
    [_myBackMusic play];
    [_displayLink setPaused:NO];
    self.isPlaying = YES;
    
    for (NSMutableArray * noteViews in _tracks) {
        for (NoteView * noteView in noteViews) {
            CFTimeInterval pausetime = noteView.layer.timeOffset;
            CFTimeInterval starttime = CACurrentMediaTime() - pausetime;
            noteView.layer.timeOffset = 0.0;
            noteView.layer.beginTime = starttime;
            noteView.layer.speed = 1.0;
        }
    }
}

- (void)handlePauseSelect:(id)sender {
    [_pauseBG removeFromSuperview];
    [_backBtn removeFromSuperview];
    [_resumeBtn removeFromSuperview];
    [_retryBtn removeFromSuperview];
    
    if (sender == _backBtn) {
        [self back];
    }
    else if (sender == _resumeBtn) {
        [self resume];
    }
    else if (sender == _retryBtn) {
        [self pause];
        [self retry];
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
        
        NSLog(@"%f", clickTime - targetView.timePoint - _offset);
        
        _diff += clickTime - targetView.timePoint;
        
        [self playSoundEffectIsGood:ABS(targetView.timePoint - clickTime + _offset) <= GREAT_TIME];
        
        [self showTapResult:ABS(targetView.timePoint - clickTime + _offset)];
        
        if (_mode == TypePlayModeAuto) _offset = _diff / (_perfectCount + _greatCount + _goodCount);
        
        [targetView removeFromSuperview];
        [notes removeObject:targetView];
    }
}

- (void)playSoundEffectIsGood:(BOOL)isGood {
    if (self.isPlaying == NO) return;
    
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:isGood ? _goodSoundPath : _badSoundPath
                                                                    error:nil];
    player.delegate = self;
    [self.sounds addObject:player];
    
    [player setVolume:1];
    player.numberOfLoops = 0;
    [player play];
}

- (void)showMiss {
    if (_mode == TypePlayModeTest) return;
    
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

- (double)comboRatio:(int)combo {
    if (combo <= 50) {
        return COMBO_0;
    }
    else if (combo <= 100) {
        return COMBO_51;
    }
    else if (combo <= 200) {
        return COMBO_101;
    }
    else if (combo <= 400) {
        return COMBO_201;
    }
    
    return COMBO_401;
}

- (void)showTapResult:(NSTimeInterval)diff {
    if (_mode == TypePlayModeTest) return;
    
    if (diff > GREAT_TIME) {
        _goodCount++;
        _score += BASE_SCORE * GOOD_RATIO * [self comboRatio:_combo];
        _combo = 0;
    }
    else {
        diff > PERFECT_TIME ? _greatCount++ : _perfectCount++;
        _score += BASE_SCORE * [self comboRatio:_combo] * (diff > PERFECT_TIME ? GREAT_RATIO : PERFECT_RATIO);
        _combo ++;
    }
    
    [self updateScore];
    [self updateCombo];
    
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:18];
    label.text = (diff > GREAT_TIME) ? @"Good!" : (diff > PERFECT_TIME ? @"Great!" : @"Perfect!");
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

- (void)updateScore {
    if (_scoreLabel) {
        _scoreLabel.text = [NSString stringWithFormat:@"Score: %d", _score];
        [_scoreLabel sizeToFit];
    }
}

- (void)handleDisplayLink:(id)sender {
    
//    if (self.myBackMusic.currentTime > 10) {
//        [_myBackMusic stop];
//        [self audioPlayerDidFinishPlaying:_myBackMusic successfully:YES];
//        [_displayLink invalidate];
//    }
    
    self.timeLable.text = [NSString stringWithFormat:@"%.3f", self.myBackMusic.currentTime];
    [self.timeLable sizeToFit];
    
    if (_noteFlag >= self.notes.count)
        return;
    
    
    NSDictionary * nodeData = self.notes[_noteFlag];
    int type = [(NSNumber *)[nodeData objectForKey:@"type"] intValue];
    if ((_mode == TypePlayModeEasy) && type == 2) {
        _noteFlag++;
        return;
    }
    
    BOOL isAuto = (_mode == TypePlayModeAuto);
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
                noteView.layer.borderWidth = 3 * SCALE;
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
                                             _missCount ++;
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
