//
//  ViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "MainViewController.h"
#import "PlayViewController.h"
#import "Const.h"
#import "MKJConstant.h"
#import "MKJItemModel.h"
#import "MKJMainPopoutView.h"

@interface MainViewController ()<MKJMainPopoutViewDelegate>

@property (nonatomic, strong) MKJMainPopoutView * popView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) UIImageView * logoView;
@property (nonatomic, strong) UIButton * playButton;
@property (nonatomic, strong) UIButton * settingButton;
@property (nonatomic, strong) UIButton * aboutButton;
@property (nonatomic, strong) UILabel * playerNameLabel;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBG"]];
    [backgroundView sizeToFit];
    [self.view addSubview:backgroundView];
    
    _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    _logoView.frame = CGRectMake((width - 120 * SCALE) / 2,
                                 40 * SCALE,
                                 120 * SCALE,
                                 80 * SCALE);
    [self.view addSubview:_logoView];
    
    
    _playerNameLabel = [[UILabel alloc] init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * playerName = [[defaults objectForKey:KEY_PLAYER_NAME] stringValue];
    _playerNameLabel.text = [NSString stringWithFormat:@"Hello, %@!", (playerName ? playerName : @"Player")];
    _playerNameLabel.font = [UIFont systemFontOfSize:20];
    [_playerNameLabel sizeToFit];
    _playerNameLabel.frame = CGRectMake((width - _playerNameLabel.frame.size.width) / 2,
                                        CGRectGetMaxY(_logoView.frame),
                                        _playerNameLabel.frame.size.width,
                                        _playerNameLabel.frame.size.height);
    [self.view addSubview:_playerNameLabel];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    _playButton.layer.borderWidth = 3 * SCALE;
    _playButton.layer.borderColor = [UIColor blackColor].CGColor;
    _playButton.layer.cornerRadius = 5 * SCALE;
    [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    _playButton.frame = CGRectMake((width - 100 * SCALE) / 2,
                                   CGRectGetMaxY(_playerNameLabel.frame) + 10 * SCALE,
                                   100 * SCALE,
                                   44 * SCALE);
    [self.view addSubview:_playButton];
    
    _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_settingButton setTitle:@"Setting" forState:UIControlStateNormal];
    _settingButton.layer.borderWidth = 3 * SCALE;
    _settingButton.layer.borderColor = [UIColor blackColor].CGColor;
    _settingButton.layer.cornerRadius = 5 * SCALE;
    [_settingButton addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
    _settingButton.frame = CGRectMake((width - 100 * SCALE) / 2,
                                   CGRectGetMaxY(_playButton.frame) + 10 * SCALE,
                                   100 * SCALE,
                                   44 * SCALE);
    [self.view addSubview:_settingButton];
    
    _aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_aboutButton setTitle:@"About" forState:UIControlStateNormal];
    _aboutButton.layer.borderWidth = 3 * SCALE;
    _aboutButton.layer.borderColor = [UIColor blackColor].CGColor;
    _aboutButton.layer.cornerRadius = 5 * SCALE;
    [_aboutButton addTarget:self action:@selector(about) forControlEvents:UIControlEventTouchUpInside];
    _aboutButton.frame = CGRectMake((width - 100 * SCALE) / 2,
                                   CGRectGetMaxY(_settingButton.frame) + 10 * SCALE,
                                   100 * SCALE,
                                   44 * SCALE);
    [self.view addSubview:_aboutButton];
    
    
//    [self convertFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)convertFile {
    NSString * notesPath = [[NSBundle mainBundle] pathForResource:@"notes" ofType:@"txt"];
    NSString * notesContent = [[NSString alloc] initWithContentsOfFile:notesPath encoding:NSUTF16StringEncoding error:nil];
    NSArray * array = [notesContent componentsSeparatedByString:@"\r\n"];
    
    NSMutableDictionary * info = [[NSMutableDictionary alloc] init];
    NSString * infoString = [array objectAtIndex:0];
    NSArray * infoArray = [infoString componentsSeparatedByString:@"\t"];
    
    [info setObject:[infoArray objectAtIndex:0] forKey:@"name"];
    [info setObject:[NSNumber numberWithInt:[[infoArray objectAtIndex:1] intValue]] forKey:@"tempo"];
    [info setObject:[NSNumber numberWithFloat:[[infoArray objectAtIndex:2] floatValue]] forKey:@"start"];
    
    NSMutableArray * resultsArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger j = 1; j < array.count; j++){
        NSString * note = [array objectAtIndex:j];
        NSArray * noteArray = [note componentsSeparatedByString:@"\t"];
        [resultsArr addObject:@{@"type":[NSNumber numberWithInt:[[noteArray objectAtIndex:0] intValue]],
                                @"track":[NSNumber numberWithInt:[[noteArray objectAtIndex:1] intValue]],
                                @"timeBegin":[NSNumber numberWithFloat:[[noteArray objectAtIndex:2] floatValue]],
                                @"duration":[NSNumber numberWithFloat:[[noteArray objectAtIndex:3] floatValue]]}];
    }
    
    NSDictionary * plistContent = [[NSDictionary alloc] initWithObjectsAndKeys:info, @"info", resultsArr, @"notes", nil];
    NSString * plistPath = [NSHomeDirectory() stringByAppendingPathComponent:@"notes.plist"];
    [plistContent writeToFile:plistPath atomically:YES];
}

#pragma mark - Action methods

- (void)play {
    [self.popView showInSuperView:self.view];
}

- (void)setting {
    
}

- (void)about {
    
}

#pragma mark - MKJMainPopoutViewDelegate

- (void)selectedItem:(MKJItemModel *)item withType:(int)type {
    
    TypePlayMode mode = (type == 0 ? TypePlayModeEasy : (type == 1 ? TypePlayModeHard : TypePlayModeAuto));
    PlayViewController * controller = [[PlayViewController alloc] initWithPlayMod:mode songID:item.imageName];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)closePopView {
    [self.popView removeFromSuperview];
}

- (MKJMainPopoutView *)popView
{
    if (_popView == nil) {
        _popView = [[MKJMainPopoutView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _popView.dataSource = self.dataSource;
        _popView.delegate = self;
    }
    return _popView;
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
        
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"songList" ofType:@"plist"];
        NSArray * songs = [[NSArray alloc] initWithContentsOfFile:plistPath];
        
        for (int i = 0; i < 10; i ++) {
            NSDictionary * dic = [songs objectAtIndex:(i % songs.count)];
            MKJItemModel *model = [[MKJItemModel alloc] init];
            model.imageName = [dic objectForKey:@"filename"];
            model.titleName = [NSString stringWithFormat:@"Song No.%d", (i + 1)];
            [_dataSource addObject:model];
        }
    }
    return _dataSource;
}

@end
