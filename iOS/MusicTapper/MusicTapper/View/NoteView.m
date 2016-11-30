//
//  NoteView.m
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "NoteView.h"

@interface NoteView()


@end


@implementation NoteView

@synthesize track;
@synthesize timePoint;
@synthesize isTapped;

- (id)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
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
