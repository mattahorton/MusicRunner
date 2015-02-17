//
//  MHMediator.h
//  MusicRunner
//
//  Created by Matthew Horton on 2/7/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (*Callback)(int);

@interface MHMediator : NSObject

+ (MHMediator *)sharedInstance;

-(void) updateCountWithSampleCount:(int)sampleCount;
-(int) getCurrentSamp;
-(void) registerCallbackWithPeriod:(int) period andCallback:(Callback) cb;
-(void)registerCallbackWithCount:(int) count andCallback: (Callback) cb andArg:(int) arg;

@end
