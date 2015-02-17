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

@interface MHCore : NSObject

+ (MHCore *)sharedInstance;

-(void) coreInit;
-(void)stopStream;

@end
