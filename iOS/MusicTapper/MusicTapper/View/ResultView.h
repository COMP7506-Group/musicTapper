//
//  ResultView.h
//  MusicTapper
//
//  Created by Shou Tianxue on 1/12/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEY_RESULT_PREFECT  @"perfect"
#define KEY_RESULT_GREAT    @"great"
#define KEY_RESULT_GOOD     @"good"
#define KEY_RESULT_MISS     @"miss"
#define KEY_RESULT_SCORE    @"score"
#define KEY_RESULT_SCOREMAX @"scoreMax"
#define KEY_RESULT_NAME     @"name"

typedef enum {
    ResultOptionTypeBack,
    ResultOptionTypeRetry
}ResultOptionType;

@protocol ResultViewDelegate;

@interface ResultView : UIView

@property (nonatomic, assign) id delegate;

- (id)initWithResult:(NSDictionary *)result;
- (void)showInView:(UIView *)view;

@end

@protocol ResultViewDelegate

- (void)didSelectOption:(ResultOptionType)type;

@end
