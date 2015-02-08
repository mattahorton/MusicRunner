//
//  MHCore.h
//  Mariah
//
//  Created by Matthew Horton on 1/16/15.
//  Copyright (c) 2015 Matt Horton. All rights reserved.
//

@class AEAudioController;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MHMediator.h"
#import "y-score-reader.h"
#import "AEAudioController.h"

@interface MHCore : NSObject {
    YScoreReader scoreReader;
}

@property (strong, nonatomic) AEAudioController *audioController;
@property (strong, nonatomic) MHMediator *mediator;
//@property (assign) YScoreReader scoreReader;

+ (MHCore *)sharedInstance;

-(void) coreInit;

@end
