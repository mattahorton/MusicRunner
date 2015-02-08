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
#import "y-score-reader.h"
#import <vector>
#import <AVFoundation/AVFoundation.h>

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
    NSString *filePath;
}

+ (MHCore *)sharedInstance {
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


-(instancetype)init {
    self = [super init];
    if (self) {
        self.mediator = [MHMediator sharedInstance];
        filePath = [[NSBundle mainBundle] pathForResource:@"watchtower"
                                                   ofType:@"mid"];
        [self coreInit];
        _scoreReader = YScoreReader::YScoreReader();
        NSLog(@"%p",&_scoreReader);
    }
    return self;
}

-(void) coreInit {
//    stk::Stk::setRawwavePath([[[NSBundle mainBundle] pathForResource:@"rawwaves" ofType:@"bundle"] UTF8String]);

    GLoilerInit();
    
//    self.audioController = [[AEAudioController alloc]
//                               initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]
//                               inputEnabled:YES];
//    
//    NSError *errorAudioSetup = NULL;
//    BOOL result = [self.audioController start:&errorAudioSetup];
//    if ( !result ) {
//        NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
//    }
//    
//    NSTimeInterval dur = self.audioController.currentBufferDuration;
//    
//    framesize = AEConvertSecondsToFrames(self.audioController, dur);
    
    NSLog(@"%@", filePath);
    
//    _scoreReader.load([filePath UTF8String]);
//    NSLog(@"%p",&_scoreReader);
    
    NSLog(@"Note");
    NSLog(@"%f",_scoreReader.getBPM());
    _scoreReader.nextNoteOn(0);
    const NoteEvent *note = _scoreReader.current(0);
    
    NSLog(@"%@",note);
    
    delete note;

    
    [self.mediator registerCallbackWithPeriod:14400 andCallback:&nextMidiNote]; // 100 bpm
    _scoreReader.load([filePath UTF8String]);
    
//    [self PlayMIDI];
}

-(void) PlayMIDI {
    // midi music file
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"watchtower" withExtension:@"mid"];
    
    // midi bank file, you can download from http://www.sf2midi.com/
    NSURL *bank = [[NSBundle mainBundle] URLForResource:@"Gorts_Filters" withExtension:@"SF2"];
    
    NSLog(@"%@",url);
    NSLog(@"%@",bank);
    
    NSError *error = nil;
    
    AVMIDIPlayer *player = [[AVMIDIPlayer alloc] initWithContentsOfURL:url soundBankURL:bank error:&error];
    if (error) {
        NSLog(@"error = %@", error);
        return;
    }
    
    [player play:^(){
        NSLog(@"complete!");
    }];
    
    NSLog(@"%d", [player isPlaying]);
    NSLog(@"%f", [player currentPosition]);
}

void nextMidiNote (YScoreReader reader){
    NSLog(@"%p",&reader);
    NSLog(@"Note");
    NSLog(@"%f",reader.getBPM());
    reader.nextNoteOn(7);
    const NoteEvent *note = reader.current(7);
    
    NSLog(@"%@",note);
    
    delete note;
}


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
//    memset( buffer, 0, sizeof(Float32)*FRAMESIZE );
    
    // save the num frames
    g_numFrames = numFrames;
    
    int sampCount = [[MHMediator sharedInstance] getCurrentSamp];
    
    // fill
    for( int i = 0; i < numFrames; i++ )
    {
        buffer[i*2] = 0;
        buffer[i*2+1] = 0;
        
        sampCount++;
        
        [[MHMediator sharedInstance] updateCountWithSampleCount: sampCount];
    }
    
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
    //    NSLog( @"init..." );
    //
    //    // set touch callback
    //    MoTouch::addCallback( touch_callback, NULL );
    
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

@end