//
//  MKJCollectionViewCell.m
//  PhotoAnimationScrollDemo
//
//  Created by MKJING on 16/8/9.
//  Copyright © 2016年 MKJING. All rights reserved.
//

#import "MKJCollectionViewCell.h"
#import "Const.h"

@implementation MKJCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.heroImageVIew.layer.cornerRadius = 5.0f * SCALE;
    self.heroImageVIew.layer.masksToBounds = YES;
    self.backView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.backView.layer.shadowOpacity = 0.7;
    self.backView.layer.shadowRadius = 5.0f * SCALE;
    self.backView.layer.shadowOffset = CGSizeMake(2 * SCALE, 6 * SCALE);
    self.backView.layer.cornerRadius = 15.0 * SCALE;
    self.backView.layer.masksToBounds = YES;
}

@end
