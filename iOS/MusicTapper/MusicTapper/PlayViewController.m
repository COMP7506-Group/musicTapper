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
@property (nonatomic, strong) NSString * songName;
@property (nonatomic, strong) NSString * playerName;
@property (nonatomic) TypePlayMode mode;
@property (nonatomic) int tempo;
@property (nonatomic) double pre;
@property (nonatomic) double offset;
@property (nonatomic) double diff;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) int life;
@property (nonatomic) int lifeCombo;

@property (nonatomic) int combo;
@property (nonatomic) int maxCombo;
@property (nonatomic) int perfectCount;
@property (nonatomic) int greatCount;
@property (nonatomic) int goodCount;
@property (nonatomic) int missCount;
@property (nonatomic) int score;
@property (nonatomic) int scoreMax;

@property (nonatomic, strong) UILabel * songNameLable;
@property (nonatomic, strong) UILabel * playerNameLabel;
@property (nonatomic, strong) NSArray * lifeArray;
@property (nonatomic, strong) UILabel * timeLable;
@property (nonatomic, strong) UILabel * comboLabel;
@property (nonatomic, strong) UILabel * scoreLabel;
@property (nonatomic, strong) UIView * timeBarBG;
@property (nonatomic, strong) UIView * timeBar;
@property (nonatomic, strong) ResultView * resultView;

@property (nonatomic, strong) UIView * pauseBG;
@property (nonatomic, strong) UIButton * backBtn;
@property (nonatomic, strong) UIButton * resumeBtn;
@property (nonatomic, strong) UIButton * retryBtn;

@end

#define LAYOUT_R    (230 * SCALE)
#define NOTE_SIZE   (78 * SCALE)
#define MAX_LIFE    10

#define BUTTON_TAG  1000

#define COLOR_ARRAY [NSArray arrayWithObjects:RGB(123, 167, 96, 1), RGB(243, 106, 53, 1), RGB(253, 245, 160, 1), RGB(151, 211, 207, 1), nil]

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
    
    UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playBG"]];
    backgroundView.frame = self.view.frame;
    [self.view addSubview:backgroundView];
    
    if (_mode == TypePlayModeTest) _songID = @"test";
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:_songID ofType:@"plist"];
    NSDictionary * dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary * info = [dic objectForKey:@"info"];
    self.songName = [info objectForKey:@"name"];
    self.tempo = [(NSNumber *)[info objectForKey:@"tempo"] intValue];
    self.pre = [(NSNumber *)[info objectForKey:@"start"] doubleValue];
    self.notes = [dic objectForKey:@"notes"];
    self.life = MAX_LIFE;
    if (_mode == TypePlayModeEasy) {
        self.scoreMax = [(NSNumber *)[info objectForKey:@"score_easy"] intValue];
    }
    else if (_mode == TypePlayModeHard) {
        self.scoreMax = [(NSNumber *)[info objectForKey:@"score_hard"] intValue];
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * offset = [defaults objectForKey:KEY_OFFSET];
    self.offset = (offset && _mode != TypePlayModeAuto) ? [offset doubleValue] : 0;
    NSString * playerName = [defaults objectForKey:KEY_PLAYER_NAME];
    self.playerName = (playerName && _mode != TypePlayModeAuto) ? [NSString stringWithString:playerName] : @"Noname";
    
    if (!_buttons) {
        NSMutableArray * temp = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.layer.borderWidth = 3.0 * SCALE;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
            button.layer.cornerRadius = NOTE_SIZE / 2;
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"note%d", i+1]] forState:UIControlStateNormal];
            button.frame = [self frameWithNoteNum:i progress:1];
            button.tag = BUTTON_TAG + i;
            button.clipsToBounds = NO;
            
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
        UIButton * pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [pauseBtn setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
        pauseBtn.backgroundColor = [UIColor clearColor];
        pauseBtn.frame = CGRectMake(self.view.frame.size.width - 70 * SCALE,
                                    20 * SCALE,
                                    50 * SCALE,
                                    50 * SCALE);
        [pauseBtn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:pauseBtn];
        self.pauseBtn = pauseBtn;
    }
    
    if (!_songNameLable) {
        UILabel * nameLabel = [[UILabel alloc] init];
        nameLabel.text = self.songName;
        nameLabel.font = [UIFont systemFontOfSize:20];
        nameLabel.textColor = [UIColor whiteColor];
        [nameLabel sizeToFit];
        CGRect frame = nameLabel.frame;
        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
        frame.origin.y = 20 * SCALE;
        nameLabel.frame = frame;
        [self.view addSubview:nameLabel];
        self.songNameLable = nameLabel;
    }
    
    if (!_playerNameLabel) {
        UILabel * label = [[UILabel alloc] init];
        label.text = self.playerName;
        label.font = [UIFont systemFontOfSize:20];
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        CGRect frame = label.frame;
        frame.origin.x = 20 * SCALE;
        frame.origin.y = 20 * SCALE;
        label.frame = frame;
        [self.view addSubview:label];
        self.playerNameLabel = label;
    }
    
    if (!_lifeArray) {
        NSMutableArray * array = [[NSMutableArray alloc] init];
        for (int i  = 0; i < MAX_LIFE; i++) {
            UIButton * heartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [heartBtn setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
            [heartBtn setImage:[UIImage imageNamed:@"white_heart"] forState:UIControlStateDisabled];
            heartBtn.userInteractionEnabled = NO;
            heartBtn.frame = CGRectMake(20 * SCALE + i * 20 * SCALE,
                                        CGRectGetMaxY(_playerNameLabel.frame) + 10 * SCALE,
                                        20 * SCALE,
                                        20 * SCALE);
            [array addObject:heartBtn];
            [self.view addSubview:heartBtn];
        }
        _lifeArray = [[NSArray alloc] initWithArray:array];
    }
    
    if (!_timeBarBG) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 400 * SCALE) / 2,
                                                                 CGRectGetMaxY(_songNameLable.frame) + 4 * SCALE,
                                                                 400 * SCALE,
                                                                 3 * SCALE)];
        view.layer.cornerRadius = view.frame.size.height / 2;
        view.backgroundColor = RGB(230, 230, 230, 1);
        view.layer.borderWidth = 1 * SCALE;
        view.layer.borderColor = RGB(180, 180, 180, 1).CGColor;
        [self.view addSubview:view];
        self.timeBarBG = view;
    }
    
    if (!_timeBar) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 400 * SCALE) / 2,
                                                                 CGRectGetMaxY(_songNameLable.frame) + 4 * SCALE,
                                                                 0,
                                                                 3 * SCALE)];
        view.layer.cornerRadius = view.frame.size.height / 2;
        view.backgroundColor = RGB(50, 159, 204, 1);
        [self.view addSubview:view];
        self.timeBar = view;
    }
    
    if (!_timeLable) {
        UILabel * timeLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_timeBarBG.frame) - 40 * SCALE,
                                                                        _timeBarBG.frame.origin.y - 15 * SCALE,
                                                                        40 * SCALE,
                                                                        15 * SCALE)];
        timeLable.textColor = [UIColor whiteColor];
        timeLable.font = [UIFont systemFontOfSize:12];
        [self.view addSubview:timeLable];
        self.timeLable = timeLable;
    }
    
    if (!_comboLabel) {
        UILabel * comboLabel = [[UILabel alloc] init];
        comboLabel.textColor = [UIColor whiteColor];
        comboLabel.font = [UIFont systemFontOfSize:18];
        comboLabel.alpha = 0;
        [self.view addSubview:comboLabel];
        self.comboLabel = comboLabel;
    }
    
    if (!_scoreLabel) {
        UILabel * scoreLabel = [[UILabel alloc] init];
        scoreLabel.textColor = [UIColor whiteColor];
        scoreLabel.font = [UIFont systemFontOfSize:14];
        scoreLabel.frame = CGRectMake(self.view.frame.size.width / 2 - 40 * SCALE,
                                      CGRectGetMaxY(_songNameLable.frame) + 10 * SCALE,
                                      0,
                                      0);
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
    
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.layer.borderWidth = 3.0 * SCALE;
        _backBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _backBtn.layer.cornerRadius = 8 * SCALE;
        [_backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(handlePauseSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_resumeBtn) {
        _resumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resumeBtn.layer.borderWidth = 3.0 * SCALE;
        _resumeBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _resumeBtn.layer.cornerRadius = 8 * SCALE;
        [_resumeBtn setImage:[UIImage imageNamed:@"Resume"] forState:UIControlStateNormal];
        [_resumeBtn addTarget:self action:@selector(handlePauseSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_retryBtn) {
        _retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryBtn.layer.borderWidth = 3.0 * SCALE;
        _retryBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _retryBtn.layer.cornerRadius = 8 * SCALE;
        [_retryBtn setImage:[UIImage imageNamed:@"Retry"] forState:UIControlStateNormal];
        [_retryBtn addTarget:self action:@selector(handlePauseSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self reset];
    
    float volume = [[defaults objectForKey:KEY_VOLUME] floatValue];
    [_myBackMusic setVolume:0.6 * volume];
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
            NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
            [result setObject:[NSNumber numberWithInt:_perfectCount] forKey:KEY_RESULT_PREFECT];
            [result setObject:[NSNumber numberWithInt:_greatCount] forKey:KEY_RESULT_GREAT];
            [result setObject:[NSNumber numberWithInt:_goodCount] forKey:KEY_RESULT_GOOD];
            [result setObject:[NSNumber numberWithInt:_missCount] forKey:KEY_RESULT_MISS];
            [result setObject:[NSNumber numberWithInt:_score] forKey:KEY_RESULT_SCORE];
            [result setObject:[NSNumber numberWithInt:_scoreMax] forKey:KEY_RESULT_SCOREMAX];
            [result setObject:[NSNumber numberWithInt:_maxCombo] forKey:KEY_RESULT_COMBO];
            [result setObject:_playerName forKey:KEY_RESULT_NAME];
            
            if (_resultView) {
                _resultView.delegate = nil;
                self.resultView = nil;
            }
            
            ResultView * resultView = [[ResultView alloc] initWithResult:result];
            resultView.delegate = self;
            self.resultView = resultView;
            [_resultView showInView:self.view];
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
    _maxCombo = 0;
    _diff = 0;
    _perfectCount = 0;
    _greatCount = 0;
    _goodCount = 0;
    _missCount = 0;
    _score = 0;
    _life = 10;
    _lifeCombo = 0;
    
    for (UIButton * heartBtn in _lifeArray) {
        heartBtn.enabled = YES;
    }
    
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
    if (_life != 0 && self.isPlaying == NO) {
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
    
    if (_life == 0) return;
    
    float btnWidth = 100 * SCALE;
    float btnHeight = 44 * SCALE;
    float padding = 50 * SCALE;
    float topOrigin = 250 * SCALE;
    
    if (!_pauseBG) {
        _pauseBG = [[UIView alloc] initWithFrame:self.view.frame];
    }
    _pauseBG.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self.view addSubview:_pauseBG];
    
    _backBtn.frame = CGRectMake((self.view.frame.size.width - 2 * btnWidth - 2 * padding) / 2,
                                topOrigin + btnHeight / 2,
                                0,
                                0);
    _backBtn.imageEdgeInsets = UIEdgeInsetsMake(- _backBtn.titleLabel.frame.size.height / 2,
                                                - _backBtn.titleLabel.frame.size.width / 2,
                                                0, 0);
    [self.view addSubview:_backBtn];
    
    _resumeBtn.frame = CGRectMake(self.view.frame.size.width / 2,
                                  topOrigin + btnHeight / 2,
                                  0,
                                  0);
    if (_life > 0) [self.view addSubview:_resumeBtn];
    
    _retryBtn.frame = CGRectMake((self.view.frame.size.width + 2 * btnWidth + 2 * padding) / 2,
                                 topOrigin + btnHeight / 2,
                                 0,
                                 0);
    [self.view addSubview:_retryBtn];
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _backBtn.frame = CGRectMake((self.view.frame.size.width - 3 * btnWidth - 2 * padding) / 2,
                                                     topOrigin,
                                                     btnWidth,
                                                     btnHeight);
                         _resumeBtn.frame = CGRectMake((self.view.frame.size.width - btnWidth) / 2,
                                                       topOrigin,
                                                       btnWidth,
                                                       btnHeight);
                         _retryBtn.frame = CGRectMake((self.view.frame.size.width + btnWidth + 2 * padding) / 2,
                                                      topOrigin,
                                                      btnWidth,
                                                      btnHeight);
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
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
        [self retry];
    }
}

#pragma mark - Action methods

- (void)buttonClicked:(id)sender {
    NSTimeInterval clickTime = self.myBackMusic.currentTime + SYSYTEM_OFFSET;
    
    UIButton * button = (UIButton *)sender;
    int track = (int) (button.tag - BUTTON_TAG);
    
    [self playBeatEffect:button];
    
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

- (void)playBeatEffect:(UIButton *)button {
    UIView * ring = [[UIView alloc] init];
    ring.layer.borderWidth = 2 * SCALE;
    ring.layer.borderColor = RGB(0x66, 0xCC, 0xFF, 0.8).CGColor;
    ring.frame = CGRectMake(0, 0, NOTE_SIZE, NOTE_SIZE);
    ring.userInteractionEnabled = NO;
    [button addSubview:ring];
    
    CABasicAnimation * cornerAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    cornerAnimation.duration = 0.3;
    cornerAnimation.fromValue = @(NOTE_SIZE / 2);
    cornerAnimation.toValue = @(NOTE_SIZE);
    cornerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    cornerAnimation.removedOnCompletion = NO;
    cornerAnimation.fillMode = kCAFillModeForwards;
    [ring.layer addAnimation:cornerAnimation forKey:@"cornerRadius"];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         ring.frame = CGRectMake(- NOTE_SIZE / 2,
                                                 - NOTE_SIZE / 2,
                                                 2 * NOTE_SIZE,
                                                 2 * NOTE_SIZE);
                         ring.alpha = 0.2;
                     }
                     completion:^(BOOL finished) {
                         [ring removeFromSuperview];
                     }];
}

- (void)playSoundEffectIsGood:(BOOL)isGood {
    if (self.isPlaying == NO) return;
    
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:isGood ? _goodSoundPath : _badSoundPath
                                                                    error:nil];
    player.delegate = self;
    [self.sounds addObject:player];
    
    [player setVolume:[[[NSUserDefaults standardUserDefaults] objectForKey:KEY_VOLUME] floatValue]];
    player.numberOfLoops = 0;
    [player play];
}

- (void)showMiss {
    if (_mode == TypePlayModeTest) return;
    
    _life--;
    UIButton * heartBtn = [_lifeArray objectAtIndex:_life];
    heartBtn.enabled = NO;
    
    if (_life == 0) {
        [self pause];
        [self audioPlayerDidFinishPlaying:_myBackMusic successfully:YES];
    }
    
    _combo = 0;
    _lifeCombo = 0;
    [self updateCombo];
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"miss"]];
    [imageView sizeToFit];
    imageView.frame = CGRectMake((self.view.frame.size.width - imageView.frame.size.width) / 2,
                             180 * SCALE,
                             imageView.frame.size.width,
                             imageView.frame.size.height);
    [self.view addSubview:imageView];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         imageView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [imageView removeFromSuperview];
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
        _lifeCombo = 0;
        
        _life--;
        UIButton * heartBtn = [_lifeArray objectAtIndex:_life];
        heartBtn.enabled = NO;
        
        if (_life == 0) {
            [self pause];
            [self audioPlayerDidFinishPlaying:_myBackMusic successfully:YES];
        }
    }
    else {
        diff > PERFECT_TIME ? _greatCount++ : _perfectCount++;
        _score += BASE_SCORE * [self comboRatio:_combo] * (diff > PERFECT_TIME ? GREAT_RATIO : PERFECT_RATIO);
        _combo ++;
        _maxCombo = fmax(_maxCombo, _combo);
        
        if (_life < 10) {
            _lifeCombo++;
            if (_lifeCombo >= 5) {
                UIButton * heartBtn = [_lifeArray objectAtIndex:_life];
                heartBtn.enabled = YES;
                
                _lifeCombo -= 5;
                _life ++;
            }
        }
    }
    
    [self updateScore];
    [self updateCombo];
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(diff > GREAT_TIME) ? @"good" : (diff > PERFECT_TIME ? @"great" : @"perfect")]];
    [imageView sizeToFit];
    imageView.frame = CGRectMake((self.view.frame.size.width - imageView.frame.size.width) / 2,
                                 180 * SCALE,
                                 imageView.frame.size.width,
                                 imageView.frame.size.height);
    
    [self.view addSubview:imageView];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         imageView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [imageView removeFromSuperview];
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
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    _timeLable.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_myBackMusic.duration - _myBackMusic.currentTime]];
    [_timeLable sizeToFit];
    
    CGRect frame = _timeBar.frame;
    frame.size.width = _timeBarBG.frame.size.width * _myBackMusic.currentTime / _myBackMusic.duration;
    _timeBar.frame = frame;
    
    if (_noteFlag >= _notes.count)
        return;
    
    
    NSDictionary * nodeData = _notes[_noteFlag];
    int type = [(NSNumber *)[nodeData objectForKey:@"type"] intValue];
    if ((_mode == TypePlayModeEasy) && type == 2) {
        _noteFlag++;
        return;
    }
    
    BOOL isAuto = (_mode == TypePlayModeAuto);
    double missTime = isAuto ? 0 : MISS_TIME;
    
    double timeBegin = [(NSNumber *)[nodeData objectForKey:@"timeBegin"] doubleValue] * 60 / _tempo + _pre;
    BOOL isLeft = ([(NSNumber *)[nodeData objectForKey:@"timeBegin"] intValue] / 4) % 2 == 0;
    int track = [(NSNumber *)[nodeData objectForKey:@"track"] intValue];
    if ((timeBegin - DROP_TIME) <= _myBackMusic.currentTime) {
        int count = isLeft ? 0 : 0;
        while (track > 0) {
            if (track % 2) {
                NoteView * noteView = [[NoteView alloc] init];
                double diff = (_myBackMusic.currentTime - (timeBegin - DROP_TIME));
                noteView.frame = [self frameWithNoteNum:count progress:(diff/DROP_TIME)];
                noteView.layer.cornerRadius = noteView.frame.size.width / 2;
                noteView.layer.borderWidth = 3 * SCALE;
                noteView.layer.borderColor = ((UIColor *)[COLOR_ARRAY objectAtIndex:count]).CGColor;
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
                                             if (self.isPlaying) {
                                                 _missCount ++;
                                                 [self showMiss];
                                             }
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
