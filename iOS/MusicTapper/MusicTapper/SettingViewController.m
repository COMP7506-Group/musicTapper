//
//  SettingViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 3/12/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "SettingViewController.h"
#import "PlayViewController.h"
#import "Const.h"

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * closeButton;
@property (nonatomic, strong) UIView * popupView;
@property (nonatomic, strong) UILabel * volumeLabel;
@property (nonatomic, strong) UISlider * volumeSlider;

@end

#define CELL_HEIGHT 60 * SCALE

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBG"]];
    [backgroundView sizeToFit];
    [self.view addSubview:backgroundView];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.frame = CGRectMake(self.view.frame.size.width - 40 * SCALE,
                                    10 * SCALE,
                                    30 * SCALE,
                                    30 * SCALE);
    [self.view addSubview:_closeButton];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:24];
    _titleLabel.text = @"Setting";
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake((self.view.frame.size.width - _titleLabel.frame.size.width) / 2,
                                   30 * SCALE,
                                   _titleLabel.frame.size.width,
                                   _titleLabel.frame.size.height);
    [self.view addSubview:_titleLabel];
    
    _tableView = [[UITableView alloc] init];
    _tableView.frame = CGRectMake(0, 0, 350 * SCALE, 3 * CELL_HEIGHT);
    _tableView.center = self.view.center;
    _tableView.clipsToBounds = YES;
    [_tableView setScrollEnabled:NO];
    _tableView.layer.cornerRadius = 15 * SCALE;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Action

- (void)close {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)changeName {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * name = [defaults objectForKey:KEY_PLAYER_NAME];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Change Name"
                                                                              message:@""
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter your name here.";
        if (name) {
            textField.text = name;
        }
    }];
    
    UIAlertAction * saveAction = [UIAlertAction actionWithTitle:@"Save"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                                                            UITextField * textField = [alertController.textFields objectAtIndex:0];
                                                            [userDefaults setObject:[NSString stringWithFormat:@"%@", textField.text]
                                                                             forKey:KEY_PLAYER_NAME];
                                                            [_tableView reloadData];
                                                        }];
    [alertController addAction:saveAction];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                          }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)changeVolume {
    if (!_popupView) {
        _popupView = [[UIView alloc] init];
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        float volume = [[defaults objectForKey:KEY_VOLUME] floatValue];
        
        
        UILabel * label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"Volume: %.0f%%", volume * 100];
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        label.frame = CGRectMake((400 * SCALE - label.frame.size.width) / 2,
                                 80 * SCALE,
                                 label.frame.size.width,
                                 label.frame.size.height);
        self.volumeLabel = label;
        [_popupView addSubview:label];

        UISlider * slider = [[UISlider alloc] init];
        slider.frame = CGRectMake(80 * SCALE,
                                  150 * SCALE,
                                  250 * SCALE,
                                  10 * SCALE);
        slider.value = volume;
        [slider addTarget:self action:@selector(volumeChanged:) forControlEvents:UIControlEventValueChanged];
        self.volumeSlider = slider;
        [_popupView addSubview:slider];
    }
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = self.view.frame;
    [button addTarget:self action:@selector(volumeChangeFinished:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _popupView.frame = CGRectZero;
    _popupView.center = self.view.center;
    _popupView.backgroundColor = RGB(0, 0, 0, 0.8);
    _popupView.layer.cornerRadius = 30 * SCALE;
    [self.view addSubview:_popupView];
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         _popupView.frame = CGRectMake(0, 0, 400 * SCALE, 300 * SCALE);
                         _popupView.center = self.view.center;
                     }
                     completion:^(BOOL finished) {
                         //nothing
                     }];
}

- (void)volumeChanged:(UISlider *)slider {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithFloat:slider.value] forKey:KEY_VOLUME];
    
    _volumeLabel.text = [NSString stringWithFormat:@"Volume: %.0f%%", slider.value * 100];
    [_volumeLabel sizeToFit];
    _volumeLabel.frame = CGRectMake((400 * SCALE - _volumeLabel.frame.size.width) / 2,
                                    80 * SCALE,
                                    _volumeLabel.frame.size.width,
                                    _volumeLabel.frame.size.height);
}

- (void)volumeChangeFinished:(UIButton *)button {
    [_popupView removeFromSuperview];
    [button removeFromSuperview];
}

- (void)test {
    PlayViewController * controller = [[PlayViewController alloc] initWithPlayMod:TypePlayModeTest songID:@"test"];
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0:
            [self changeName];
            break;
            
        case 1:
            [self changeVolume];
            break;
            
        case 2:
            [self test];
            break;
            
        default:
            break;
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * identifier = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = RGB(0x66, 0xCC, 0xFF, 1);
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * offset = [defaults objectForKey:KEY_OFFSET];
    NSString * name = [defaults objectForKey:KEY_PLAYER_NAME];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"Change Name: %@", name ? name : @"NoName"];
            break;
        case 1:
            cell.textLabel.text = @"Volume";
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"Test (offset = %.0fms)", (offset ? [offset doubleValue] * 1000 : 0)];
            break;
            
        default:
            break;
    }
    
    
    
    return cell;
}

@end
