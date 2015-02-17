//
//  MHGlobals.h
//  MusicRunner
//
//  Created by Matthew Horton on 2/14/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TileScrollViewController.h"

@interface MHGlobals : NSObject

@property (strong,nonatomic) NSMutableArray * cylons;
@property (strong,nonatomic) TileScrollViewController * tsvc;
@property (strong,nonatomic) NSNumber * spb;
@property (strong,nonatomic) NSNumber * survivors;

+ (MHGlobals *)sharedInstance;

-(void)newCylonWithColumn:(int)col;

@end
