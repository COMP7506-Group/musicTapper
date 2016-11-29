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
@property (nonatomic) int noteFlag;
@property (nonatomic) int tempo;
@property (nonatomic) double pre;
@property (nonatomic) double offset;
@property (nonatomic) double dropTime;

@property (nonatomic, strong) UILabel * nameLable;
@property (nonatomic, strong) UILabel * timeLable;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    
    self.offset = 0.2;
    self.dropTime = 1;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"001" ofType:@"plist"];
    NSDictionary * dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary * info = [dic objectForKey:@"info"];
    self.name = [info objectForKey:@"name"];
    self.tempo = [(NSNumber *)[info objectForKey:@"tempo"] intValue];
    self.pre = [(NSNumber *)[info objectForKey:@"start"] doubleValue];
    self.notes = [dic objectForKey:@"nodes"];
    self.noteFlag = 0;
    
    if (!_buttons) {
        NSMutableArray * temp = [[NSMutableArray alloc] init];
        for (int i = 0; i < 9; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.layer.borderWidth = 3.0;
            button.layer.borderColor = [UIColor blueColor].CGColor;
            button.layer.cornerRadius = 30;
            
            button.frame = [self frameWithNoteNum:i progress:1];
            
            [button addTarget:self action:@selector(goodBtnClicked) forControlEvents:UIControlEventTouchDown];
            [temp addObject:button];
            [self.view addSubview:button];
        }
        self.buttons = [NSArray arrayWithArray:temp];
    }
    
    if (!_pauseBtn) {
        UIButton * pauseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        pauseBtn.frame = CGRectMake(10, 10, 50, 30);
        [pauseBtn setTitle:@"Back" forState:UIControlStateNormal];
        [pauseBtn addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:pauseBtn];
        self.pauseBtn = pauseBtn;
    }
    
    if (!_timeLable) {
        UILabel * timeLable = [[UILabel alloc] initWithFrame:CGRectMake(200, 30, 0, 0)];
        [self.view addSubview:self.timeLable];
        self.timeLable = timeLable;
    }
    
    if (!_nameLable) {
        UILabel * nameLable = [[UILabel alloc] init];
        nameLable.text = self.name;
        nameLable.font = [UIFont systemFontOfSize:20];
        [nameLable sizeToFit];
        CGRect frame = nameLable.frame;
        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
        frame.origin.y = 20;
        nameLable.frame = frame;
        [self.view addSubview:self.nameLable];
        self.nameLable = nameLable;
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
    _myBackMusic.numberOfLoops = -1;
    [_myBackMusic play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_displayLink invalidate];
    [_myBackMusic stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
    }
}

- (CGRect)frameWithNoteNum:(int)i progress:(float)p {
    float size = 30 + 30 * p;
    float x = self.view.frame.size.width / 2 - 230 * cos(i * M_PI / 8) * p - size / 2;
    float y = 100 + 230 * sin(i * M_PI / 8) * p - size / 2;
    return CGRectMake(x, y, size, size);
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (player != _myBackMusic) {
        [_sounds removeObject:player];
    }
}


#pragma mark - Action methods

- (void)goodBtnClicked {
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:_goodSoundPath error:nil];
    player.delegate = self;
    [self.sounds addObject:player];
    
    [player prepareToPlay];
    [player setVolume:1];
    player.numberOfLoops = 0;
    [player play];
}

- (void)badBtnClicked {
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:_badSoundPath error:nil];
    player.delegate = self;
    [self.sounds addObject:player];
    
    [player prepareToPlay];
    [player setVolume:1];
    player.numberOfLoops = 0;
    [player play];
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
    double timeBegin = [(NSNumber *)[nodeData objectForKey:@"timeBegin"] doubleValue] * 60 / self.tempo + self.pre;
    int track = [(NSNumber *)[nodeData objectForKey:@"track"] intValue];
    if ((timeBegin - _dropTime - _offset) <= self.myBackMusic.currentTime) {
        int count = 0;
        while (track > 0) {
            if (track % 2) {
                NoteView * noteView = [[NoteView alloc] init];
                double diff = (self.myBackMusic.currentTime - (timeBegin - _dropTime - _offset));
                noteView.frame = [self frameWithNoteNum:count progress:(diff/_dropTime)];
                noteView.layer.cornerRadius = noteView.frame.size.width / 2;
                noteView.layer.borderWidth = 3;
                noteView.layer.borderColor = [UIColor redColor].CGColor;
                
                [self.view addSubview:noteView];
                
                CABasicAnimation * cornerAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                cornerAnimation.duration = _dropTime - diff;
                cornerAnimation.fromValue = @([self frameWithNoteNum:count progress:diff/_dropTime].size.width / 2);
                cornerAnimation.toValue = @([self frameWithNoteNum:count progress:1].size.width / 2);
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
                
                [UIView animateWithDuration:_dropTime - diff
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     noteView.frame = [self frameWithNoteNum:count progress:1];
                                     noteView.layer.cornerRadius = noteView.frame.size.width / 2;
                                 }
                                 completion:^(BOOL finished) {
                                     [noteView removeFromSuperview];
//                                     [self goodBtnClicked];
                                 }];
            }
            track = track / 2;
            count++;
        }
        self.noteFlag++;
    }
}

@end
