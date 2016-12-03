//
//  AboutViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 3/12/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "AboutViewController.h"
#import "Const.h"

@interface AboutViewController ()

@property (nonatomic, strong) UIButton * closeButton;
@property (nonatomic, strong) UILabel * titleLbael;
@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, strong) UILabel * nameTitleLabel;
@property (nonatomic, strong) UIImageView * imageView1;
@property (nonatomic, strong) UILabel * nameLabell;
@property (nonatomic, strong) UIImageView * imageView2;
@property (nonatomic, strong) UILabel * nameLabel2;
@property (nonatomic, strong) UIImageView * imageView3;
@property (nonatomic, strong) UILabel * nameLabel3;
@property (nonatomic, strong) UIImageView * imageView4;
@property (nonatomic, strong) UILabel * nameLabel4;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    _titleLbael = [[UILabel alloc] init];
    _titleLbael.font = [UIFont systemFontOfSize:24];
    _titleLbael.text = @"About MusicTapper";
    [_titleLbael sizeToFit];
    _titleLbael.frame = CGRectMake((self.view.frame.size.width - _titleLbael.frame.size.width) / 2,
                                   30 * SCALE,
                                   _titleLbael.frame.size.width,
                                   _titleLbael.frame.size.height);
    [self.view addSubview:_titleLbael];
    
    _textView = [[UITextView alloc] init];
    _textView.font = [UIFont systemFontOfSize:18];
    _textView.textAlignment = NSTextAlignmentCenter;
    [_textView setEditable:NO];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.frame = CGRectMake(30 * SCALE,
                                 CGRectGetMaxY(_titleLbael.frame),
                                 300 * SCALE,
                                 300 * SCALE);
    _textView.text = @"Please write something here to introduce this app.";
    [self.view addSubview:_textView];
    
    UIView * groupView = [[UIView alloc] init];
    groupView.backgroundColor = RGB(153, 211, 0, 0.8);
    groupView.layer.cornerRadius = 20 * SCALE;
    groupView.frame = CGRectMake(self.view.frame.size.width - 300 * SCALE,
                                 CGRectGetMaxY(_titleLbael.frame) + 5 * SCALE,
                                 250 * SCALE,
                                 300 * SCALE);
    [self.view addSubview:groupView];
    
    _nameTitleLabel = [[UILabel alloc] init];
    _nameTitleLabel.font = [UIFont systemFontOfSize:20];
    _nameTitleLabel.text = @"Created by:";
    [_nameTitleLabel sizeToFit];
    _nameTitleLabel.frame = CGRectMake(20 * SCALE,
                                       20 * SCALE,
                                       _nameTitleLabel.frame.size.width,
                                       _nameTitleLabel.frame.size.height);
    [groupView addSubview:_nameTitleLabel];
    
    float avatarSize = 70 * SCALE;
    
    _imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soso.JPG"]];
    _imageView1.layer.cornerRadius = avatarSize / 2;
    _imageView1.clipsToBounds = YES;
    _imageView1.frame = CGRectMake((groupView.frame.size.width - 2 * avatarSize) / 3,
                                   60 * SCALE,
                                   avatarSize,
                                   avatarSize);
    [groupView addSubview:_imageView1];
    
    _nameLabell = [[UILabel alloc] init];
    _nameLabell.text = @"Shou Tianxue";
    _nameLabell.font = [UIFont systemFontOfSize:12];
    [_nameLabell sizeToFit];
    _nameLabell.frame = CGRectMake(_imageView1.center.x - _nameLabell.frame.size.width / 2,
                                   CGRectGetMaxY(_imageView1.frame) + 5 * SCALE,
                                   _nameLabell.frame.size.width,
                                   _nameLabell.frame.size.height);
    [groupView addSubview:_nameLabell];
    
    _imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"szy.JPG"]];
    _imageView2.layer.cornerRadius = avatarSize / 2;
    _imageView2.clipsToBounds = YES;
    _imageView2.frame = CGRectMake((groupView.frame.size.width - 2 * avatarSize) / 3 + CGRectGetMaxX(_imageView1.frame),
                                   60 * SCALE,
                                   avatarSize,
                                   avatarSize);
    [groupView addSubview:_imageView2];
    
    _nameLabel2 = [[UILabel alloc] init];
    _nameLabel2.text = @"Shen Zhangyi";
    _nameLabel2.font = [UIFont systemFontOfSize:12];
    [_nameLabel2 sizeToFit];
    _nameLabel2.frame = CGRectMake(_imageView2.center.x - _nameLabel2.frame.size.width / 2,
                                   CGRectGetMaxY(_imageView2.frame) + 5 * SCALE,
                                   _nameLabel2.frame.size.width,
                                   _nameLabel2.frame.size.height);
    [groupView addSubview:_nameLabel2];
    
    _imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"showshowa.JPG"]];
    _imageView3.layer.cornerRadius = avatarSize / 2;
    _imageView3.clipsToBounds = YES;
    _imageView3.frame = CGRectMake((groupView.frame.size.width - 2 * avatarSize) / 3,
                                   CGRectGetMaxY(_imageView1.frame) + 40 * SCALE,
                                   avatarSize,
                                   avatarSize);
    [groupView addSubview:_imageView3];
    
    _nameLabel3 = [[UILabel alloc] init];
    _nameLabel3.text = @"Lin Yu";
    _nameLabel3.font = [UIFont systemFontOfSize:12];
    [_nameLabel3 sizeToFit];
    _nameLabel3.frame = CGRectMake(_imageView3.center.x - _nameLabel3.frame.size.width / 2,
                                   CGRectGetMaxY(_imageView3.frame) + 5 * SCALE,
                                   _nameLabel3.frame.size.width,
                                   _nameLabel3.frame.size.height);
    [groupView addSubview:_nameLabel3];
    
    _imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ZYZZ1103.JPG"]];
    _imageView4.layer.cornerRadius = avatarSize / 2;
    _imageView4.clipsToBounds = YES;
    _imageView4.frame = CGRectMake(_imageView2.frame.origin.x,
                                   _imageView3.frame.origin.y,
                                   avatarSize,
                                   avatarSize);
    [groupView addSubview:_imageView4];
    
    _nameLabel4 = [[UILabel alloc] init];
    _nameLabel4.text = @"Yang Zhan";
    _nameLabel4.font = [UIFont systemFontOfSize:12];
    [_nameLabel4 sizeToFit];
    _nameLabel4.frame = CGRectMake(_imageView4.center.x - _nameLabel4.frame.size.width / 2,
                                   CGRectGetMaxY(_imageView4.frame) + 5 * SCALE,
                                   _nameLabel4.frame.size.width,
                                   _nameLabel4.frame.size.height);
    [groupView addSubview:_nameLabel4];
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

@end
