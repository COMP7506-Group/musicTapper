//
//  ResultView.m
//  MusicTapper
//
//  Created by Shou Tianxue on 1/12/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "ResultView.h"
#import "Const.h"

@interface ResultView()

@property (nonatomic, strong) NSDictionary * result;
@property (nonatomic, strong) UIButton * backBtn;
@property (nonatomic, strong) UIButton * retryBtn;

@property (nonatomic, strong) UIImageView * rankView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * comboLabel;
@property (nonatomic, strong) UILabel * perfectLabel;
@property (nonatomic, strong) UILabel * greatLabel;
@property (nonatomic, strong) UILabel * goodLabel;
@property (nonatomic, strong) UILabel * missLabel;
@property (nonatomic, strong) UILabel * scoreLabel;
@property (nonatomic, strong) UIImageView * scoreImageView;

@end

@implementation ResultView

- (id)initWithResult:(NSDictionary *)result
{
    self = [super init];
    if (self) {
        self.result = result;
        self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        
        float left = 70 * SCALE;
        float top = 100 * SCALE;
        float labelWidth = 160 * SCALE;
        float labelHeight = 30 * SCALE;
        
        UIView * groupBG = [[UIView alloc] init];
        groupBG.backgroundColor = RGB(200, 200, 200, 1);
        groupBG.layer.cornerRadius = 10 * SCALE;
        groupBG.frame = CGRectMake(left - 10 * SCALE,
                                   top - 10 * SCALE,
                                   labelWidth + 10 * SCALE,
                                   labelHeight * 6 + 10 * SCALE);
        [self addSubview:groupBG];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.text = [NSString stringWithFormat:@"Player: %@", [_result objectForKey:KEY_RESULT_NAME]];
        _nameLabel.frame = CGRectMake(left, top, labelWidth, labelHeight);
        [self addSubview:_nameLabel];
        
        _comboLabel = [[UILabel alloc] init];
        _comboLabel.font = [UIFont systemFontOfSize:14];
        _comboLabel.text = [NSString stringWithFormat:@"Max Combo: %d", [[_result objectForKey:KEY_RESULT_COMBO] intValue]];
        _comboLabel.frame = CGRectMake(left, CGRectGetMaxY(_nameLabel.frame), labelWidth, labelHeight);
        [self addSubview:_comboLabel];
        
        _perfectLabel = [[UILabel alloc] init];
        _perfectLabel.font = [UIFont systemFontOfSize:14];
        _perfectLabel.text = [NSString stringWithFormat:@"Perfect: %d", [[_result objectForKey:KEY_RESULT_PREFECT] intValue]];
        _perfectLabel.frame = CGRectMake(left, CGRectGetMaxY(_comboLabel.frame), labelWidth, labelHeight);
        [self addSubview:_perfectLabel];
        
        _greatLabel = [[UILabel alloc] init];
        _greatLabel.font = [UIFont systemFontOfSize:14];
        _greatLabel.text = [NSString stringWithFormat:@"Great: %d", [[_result objectForKey:KEY_RESULT_GREAT] intValue]];
        _greatLabel.frame = CGRectMake(left, CGRectGetMaxY(_perfectLabel.frame), labelWidth, labelHeight);
        [self addSubview:_greatLabel];
        
        _goodLabel = [[UILabel alloc] init];
        _goodLabel.font = [UIFont systemFontOfSize:14];
        _goodLabel.text = [NSString stringWithFormat:@"Good: %d", [[_result objectForKey:KEY_RESULT_GOOD] intValue]];
        _goodLabel.frame = CGRectMake(left, CGRectGetMaxY(_greatLabel.frame), labelWidth, labelHeight);
        [self addSubview:_goodLabel];
        
        _missLabel = [[UILabel alloc] init];
        _missLabel.font = [UIFont systemFontOfSize:14];
        _missLabel.text = [NSString stringWithFormat:@"Miss: %d", [[_result objectForKey:KEY_RESULT_MISS] intValue]];
        _missLabel.frame = CGRectMake(left, CGRectGetMaxY(_goodLabel.frame), labelWidth, labelHeight);
        [self addSubview:_missLabel];
        
        int score = [[_result objectForKey:KEY_RESULT_SCORE] intValue];
        int scoreMax = [[_result objectForKey:KEY_RESULT_SCOREMAX] intValue];
        float ratio = (float)score / scoreMax;
        NSString * rankLevel;
        CGColorRef color;
        if (ratio >= 0.9) {
            rankLevel = [NSString stringWithFormat:@"Rank_S"];
            color = RGB(227, 193, 122, 1).CGColor;
        }
        else if (ratio >= 0.85) {
            rankLevel = [NSString stringWithFormat:@"Rank_A"];
            color = RGB(123, 125, 190, 1).CGColor;
        }
        else if (ratio >= 0.6) {
            rankLevel = [NSString stringWithFormat:@"Rank_B"];
            color = RGB(245, 92, 95, 1).CGColor;
        }
        else {
            rankLevel = [NSString stringWithFormat:@"Rank_C"];
            color = RGB(212, 212, 212, 1).CGColor;
        }
        _rankView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:rankLevel]];
        _rankView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - left - 150 * SCALE,
                                     top,
                                     150 * SCALE,
                                     150 * SCALE);
        _rankView.layer.borderWidth = 8 * SCALE;
        _rankView.layer.borderColor = color;
        _rankView.layer.cornerRadius = _rankView.frame.size.height / 2;
        [self addSubview:_rankView];
        
        _scoreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"score"]];
        _scoreImageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 150 * SCALE) / 2,
                                           top,
                                           150 * SCALE,
                                           60 * SCALE);
        [self addSubview:_scoreImageView];
        
        _scoreLabel = [[UILabel alloc] init];
        _scoreLabel.font = [UIFont systemFontOfSize:24];
        _scoreLabel.text = [NSString stringWithFormat:@"%d", score];
        [_scoreLabel sizeToFit];
        _scoreLabel.frame = CGRectMake(_scoreImageView.center.x - _scoreLabel.frame.size.width / 2,
                                       CGRectGetMaxY(_scoreImageView.frame) + 30 * SCALE,
                                       _scoreLabel.frame.size.width,
                                       _scoreLabel.frame.size.height);
        [_scoreLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:_scoreLabel];
        
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _backBtn.layer.borderWidth = 3 * SCALE;
        _backBtn.layer.cornerRadius = 8 * SCALE;
        [_backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 140 * SCALE,
                                    top + 6 * labelHeight + 20 * SCALE,
                                    80 * SCALE,
                                    40 * SCALE);
        [self addSubview:_backBtn];
        
        _retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _retryBtn.layer.borderWidth = 3 * SCALE;
        _retryBtn.layer.cornerRadius = 8 * SCALE;
        [_retryBtn setImage:[UIImage imageNamed:@"Retry"] forState:UIControlStateNormal];
        [_retryBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _retryBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 + 60 * SCALE,
                                    top + 6 * labelHeight + 20 * SCALE,
                                    80 * SCALE,
                                    40 * SCALE);
        [self addSubview:_retryBtn];
    }
    
    return self;
}

- (void)showInView:(UIView *)view
{
    float width = view.frame.size.width;
    float height = view.frame.size.height;
    
    self.frame = CGRectMake(0, 0, width, height);
    [view addSubview:self];
}

- (void)buttonClicked:(id)sender {
    [self removeFromSuperview];
    UIButton * button = (UIButton *)sender;
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectOption:)]) {
        [_delegate didSelectOption:(button == _backBtn ? ResultOptionTypeBack : ResultOptionTypeRetry)];
    }
}

- (void)dealloc {
    _delegate = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
