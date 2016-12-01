//
//  ResultView.m
//  MusicTapper
//
//  Created by Shou Tianxue on 1/12/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "ResultView.h"

@interface ResultView()

@property (nonatomic, strong) NSDictionary * result;

@end

@implementation ResultView

- (id)initWithResult:(NSDictionary *)result
{
    self = [super init];
    if (self) {
        self.result = result;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
