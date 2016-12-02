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

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
    UIButton * testBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [testBtn setTitle:@"push" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = self.view.frame;
    testBtn.frame = CGRectMake((frame.size.width - 100 * SCALE) / 2,
                               (frame.size.height - 44 * SCALE) / 2,
                               100 * SCALE,
                               44 * SCALE);
    [self.view addSubview:testBtn];
    
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

- (void)push {
    [self.popView showInSuperView:self.view];
}

#pragma mark - MKJMainPopoutViewDelegate

- (void)selectedItem:(MKJItemModel *)item withType:(int)type {
    
    TypePlayMode mode = (type == 0 ? TypePlayModeEasy : TypePlayModeHard);
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
        
        for (NSInteger i = 0; i < 3; i ++) {
            NSDictionary * dic = [songs objectAtIndex:(i % songs.count)];
            MKJItemModel *model = [[MKJItemModel alloc] init];
            model.imageName = [dic objectForKey:@"filename"];
            model.titleName = [dic objectForKey:@"name"];
            [_dataSource addObject:model];
        }
    }
    return _dataSource;
}

@end
