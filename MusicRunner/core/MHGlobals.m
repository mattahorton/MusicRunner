//
//  MHGlobals.m
//  MusicRunner
//
//  Created by Matthew Horton on 2/14/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//

#import "MHGlobals.h"

@implementation MHGlobals

+ (MHGlobals *)sharedInstance {
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

-(void)newCylonWithColumn:(int)col {
    [self.tsvc moveCylonWithCol:col];
}

@end
