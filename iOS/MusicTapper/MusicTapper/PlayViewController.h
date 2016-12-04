//
//  PlayViewController.h
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TypePlayModeEasy,
    TypePlayModeHard,
    TypePlayModeAuto,
    TypePlayModeTest
}TypePlayMode;

@interface PlayViewController : UIViewController

- (id)initWithPlayMod:(TypePlayMode)mode songID:(NSString *)songID;

@end
