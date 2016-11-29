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


@implementation PlayViewController

- (void)viewDidLoad {
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
        for (int i = 0; i < 4; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.layer.borderWidth = 3.0;
            button.layer.borderColor = [UIColor blueColor].CGColor;
            button.frame = CGRectMake((self.view.frame.size.width - 4 * 60)/2 + i * 60, 495, 60, 50);
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

- (void)viewWillAppear:(BOOL)animated {
    
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
                NoteView * nodeView = [[NoteView alloc] init];
                double diff = (self.myBackMusic.currentTime - (timeBegin - _dropTime - _offset));
                nodeView.frame = CGRectMake(self.view.frame.size.width / 2 - 2 * 60 + count * 60 + 10,
                                            -30 + 530 * diff / _dropTime,
                                            40,
                                            20);
                nodeView.backgroundColor = [UIColor redColor];
                nodeView.layer.cornerRadius = 5;
                [self.view addSubview:nodeView];
                
                [UIView animateWithDuration:_dropTime - diff
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     CGRect frame = nodeView.frame;
                                     frame.origin.y = 500;
                                     [nodeView setFrame:frame];
                                 }
                                 completion:^(BOOL finished) {
                                     [nodeView removeFromSuperview];
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
