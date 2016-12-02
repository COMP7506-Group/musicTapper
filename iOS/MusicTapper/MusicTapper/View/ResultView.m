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

@end

@implementation ResultView

- (id)initWithResult:(NSDictionary *)result
{
    self = [super init];
    if (self) {
        self.result = result;
        self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        
        _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _backBtn.layer.borderColor = [UIColor blackColor].CGColor;
        [_backBtn setTitle:@"Back" forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backBtn];
        
        _retryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _retryBtn.layer.borderColor = [UIColor blackColor].CGColor;
        [_retryBtn setTitle:@"Retry" forState:UIControlStateNormal];
        [_retryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_retryBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_retryBtn];
    }
    
    return self;
}

- (void)showInView:(UIView *)view
{
    float width = view.frame.size.width;
    float height = view.frame.size.height;
    
    self.frame = CGRectMake(0, 0, width, height);
    self.alpha = 0;
    [view addSubview:self];
    
    _backBtn.frame = CGRectMake(width * 0.2,
                                height * 0.7,
                                width * 0.2,
                                height * 0.2);
    _retryBtn.frame = CGRectMake(width * 0.6,
                                 height * 0.7,
                                 width * 0.2,
                                 height * 0.2);
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
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
