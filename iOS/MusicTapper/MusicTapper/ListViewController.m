//
//  ListViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "ListViewController.h"
#import "PlayViewController.h"
#import "Const.h"

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self prefersStatusBarHidden];
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TypePlayMod mod;
    switch (indexPath.row) {
        case 0:
            mod = TypePlayModEasy;
            break;
        case 1:
            mod = TypePlayModHard;
            break;
        case 2:
            mod = TypePlayModTest;
            break;
        case 3:
            mod = TypePlayModAuto;
            break;
            
        default:
            mod = TypePlayModEasy;
            break;
    }
    
    PlayViewController * controller = [[PlayViewController alloc] initWithPlayMod:mod songID:@"001"];
    [self presentViewController:controller animated:YES completion:NULL];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * offset = [defaults objectForKey:KEY_OFFSET];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Easy mod";
            break;
        case 1:
            cell.textLabel.text = @"Hard mod";
            break;
        case 2:
            if (offset) {
                cell.textLabel.text = [NSString stringWithFormat:@"Test mod (offset = %3f)", [offset doubleValue]];
            }
            else {
                cell.textLabel.text = @"Test mod (offset = 0)";
            }
            break;
        case 3:
            cell.textLabel.text = @"Auto mod";
            break;
            
        default:
            cell.textLabel.text = @"Easy mod";
            break;
    }
    
    return cell;
}

@end
