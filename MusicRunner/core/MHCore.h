//
//  MHCore.h
//  Mariah
//
//  Created by Matthew Horton on 1/16/15.
//  Copyright (c) 2015 Matt Horton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef __GLoiler__renderer__
#define __GLoiler__renderer__

// initialize the engine (audio, grx, interaction)
void GLoilerInit();

#endif /* defined(__GLoiler__renderer__) */

@interface MHCore : NSObject

-(void) coreInit;

@end
