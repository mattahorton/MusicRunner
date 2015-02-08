//
//  MHMediator.h
//  MusicRunner
//
//  Created by Matthew Horton on 2/7/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "y-score-reader.h"

typedef void (*Callback)();

@interface MHMediator : NSObject

+ (MHMediator *)sharedInstance;

-(void) updateCountWithSampleCount:(int)sampleCount;
-(int) getCurrentSamp;
-(void) registerCallbackWithPeriod:(int) period andCallback:(Callback) cb;

@end
