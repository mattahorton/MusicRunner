//
//  MHCore.m
//  Mariah
//
//  Created by Matthew Horton on 1/16/15.
//  Copyright (c) 2015 Matt Horton. All rights reserved.
//

#import "MHCore.h"
#import "mo-audio.h"
#import "mo-touch.h"

#define SRATE 24000
#define FRAMESIZE 512
#define NUM_CHANNELS 2

// buffer
SAMPLE g_vertices[FRAMESIZE*2];
UInt32 g_numFrames;

// buffer
float * g_buffer = NULL;


@implementation MHCore {
    long framesize;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        [self coreInit];
    }
    return self;
}

-(void) coreInit {
//    stk::Stk::setRawwavePath([[[NSBundle mainBundle] pathForResource:@"rawwaves" ofType:@"bundle"] UTF8String]);

    GLoilerInit();
}

@end



//  From file:
//  renderer.mm
//  GLoiler
//
//  Created by Ge Wang on 1/15/15.
//  Copyright (c) 2014 Ge Wang. All rights reserved.
//

//-----------------------------------------------------------------------------
// name: audio_callback()
// desc: audio callback, yeah
//-----------------------------------------------------------------------------
void audio_callback( Float32 * buffer, UInt32 numFrames, void * userData )
{
    // zero!!!
    memset( g_vertices, 0, sizeof(SAMPLE)*FRAMESIZE*2 );
    
    // save the num frames
    g_numFrames = numFrames;
    
//    NSLog( @"." );
}



//-----------------------------------------------------------------------------
// name: touch_callback()
// desc: the touch call back
//-----------------------------------------------------------------------------
void touch_callback( NSSet * touches, UIView * view,
                    std::vector<MoTouchTrack> & tracks,
                    void * data)
{
    // points
    CGPoint pt;
    CGPoint prev;
    
    // number of touches in set
    NSUInteger n = [touches count];
    NSLog( @"total number of touches: %d", (int)n );
    
    // iterate over all touch events
    for( UITouch * touch in touches )
    {
        // get the location (in window)
        pt = [touch locationInView:view];
        prev = [touch previousLocationInView:view];
        
        // check the touch phase
        switch( touch.phase )
        {
                // begin
            case UITouchPhaseBegan:
            {
                NSLog( @"touch began... %f %f", pt.x, pt.y );
                break;
            }
            case UITouchPhaseStationary:
            {
                NSLog( @"touch stationary... %f %f", pt.x, pt.y );
                break;
            }
            case UITouchPhaseMoved:
            {
                NSLog( @"touch moved... %f %f", pt.x, pt.y );
                break;
            }
                // ended or cancelled
            case UITouchPhaseEnded:
            {
                NSLog( @"touch ended... %f %f", pt.x, pt.y );
                break;
            }
            case UITouchPhaseCancelled:
            {
                NSLog( @"touch cancelled... %f %f", pt.x, pt.y );
                break;
            }
                // should not get here
            default:
                break;
        }
    }
}


// initialize the engine (audio, grx, interaction)
void GLoilerInit()
{
    NSLog( @"init..." );
    
    // set touch callback
    MoTouch::addCallback( touch_callback, NULL );
    
    // init
    bool result = MoAudio::init( SRATE, FRAMESIZE, NUM_CHANNELS );
    if( !result )
    {
        // do not do this:
        int * p = 0;
        *p = 0;
    }
    // start
    result = MoAudio::start( audio_callback, NULL );
    if( !result )
    {
        // do not do this:
        int * p = 0;
        *p = 0;
    }
}