//
//  PlayViewController.h
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TypePlayModEasy,
    TypePlayModHard,
    TypePlayModAuto,
    TypePlayModTest
}TypePlayMod;

@interface PlayViewController : UIViewController

- (id)initWithPlayMod:(TypePlayMod)mod songID:(NSString *)songID;

@end
