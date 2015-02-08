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

#ifndef __GLoiler__renderer__
#define __GLoiler__renderer__

// initialize the engine (audio, grx, interaction)
void GLoilerInit();

#endif /* defined(__GLoiler__renderer__) */

@interface MHCore : NSObject

@property (nonatomic) AEAudioController *audioController;
@property (strong, nonatomic) MHMediator *mediator;
@property (assign, nonatomic) YScoreReader scoreReader;

+ (MHCore *)sharedInstance;

-(void) coreInit;
-(void) PlayMIDI;

@end
