//
//  NoteView.h
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteView : UIView

@property (nonatomic) int track;
@property (nonatomic) NSTimeInterval timePoint;
@property (nonatomic) BOOL isTapped;

@end
