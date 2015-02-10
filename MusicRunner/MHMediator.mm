//
//  MHMediator.mm
//  MusicRunner
//
//  Created by Matthew Horton on 2/7/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//

#import "MHMediator.h"
#import "MHCore.h"
#import <vector>


@implementation MHMediator {
    int currentSamp;
    std::vector<int> periods;
    std::vector<Callback> callbacks;
    std::vector<int> intArgs;
}

+ (MHMediator *)sharedInstance {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

-(void)updateCountWithSampleCount:(int)sampleCount {
    currentSamp = sampleCount;
    int per;
    Callback cb;
    int intArg;
    
    for (int i = 0; i < periods.size(); i++) {
        per = periods.at(i);
        cb = callbacks.at(i);
        intArg = intArgs.at(i);
        
//        if ((sampleCount % per) == 0) {
//            
//            // callback on period
//            cb();
//        }
        
        if (sampleCount == per) {
            cb(intArg);
        }
        
    }
}

-(int) getCurrentSamp {
    return currentSamp;
}

-(void)registerCallbackWithPeriod:(int) period andCallback: (Callback) cb{
    periods.push_back(period);
    callbacks.push_back(cb);
}

-(void)registerCallbackWithCount:(int) count andCallback: (Callback) cb andArg:(int) arg{
    periods.push_back(count);
    callbacks.push_back(cb);
    intArgs.push_back(arg);
}

@end
