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
#import "AEBlockChannel.h"

#define SRATE 24000
#define FRAMESIZE 512
#define NUM_CHANNELS 2
#define BPM 100

// buffer
SAMPLE g_vertices[FRAMESIZE*2];
UInt32 g_numFrames;

// buffer
float * g_buffer = NULL;


@implementation MHCore {
    long framesize;
    NSString *filePath;
    AEBlockChannel *audioOut;
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
        scoreReader = YScoreReader::YScoreReader();
        [self coreInit];
        NSLog(@"%p reader init",&scoreReader);
    }
    return self;
}

-(void) coreInit {
//    stk::Stk::setRawwavePath([[[NSBundle mainBundle] pathForResource:@"rawwaves" ofType:@"bundle"] UTF8String]);
    
    //SET UP TAAE
    
    self.audioController = [[AEAudioController alloc]
                               initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription]
                               inputEnabled:YES];
    
    NSError *errorAudioSetup = NULL;
    BOOL result = [self.audioController start:&errorAudioSetup];
    if ( !result ) {
        NSLog(@"Error starting audio engine: %@", errorAudioSetup.localizedDescription);
    }
    
    NSTimeInterval dur = self.audioController.currentBufferDuration;
    
    framesize = AEConvertSecondsToFrames(self.audioController, dur);
    
    audioOut = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp  *time,
                                                  UInt32 frames,
                                                  AudioBufferList *audio) {
        
        int sampCount = [[MHMediator sharedInstance] getCurrentSamp];
        
        for ( int i=0; i<frames; i++ ) {
            ((float*)audio->mBuffers[0].mData)[i] = ((float*)audio->mBuffers[1].mData)[i] = 0;
            
            sampCount++;
            
            [[MHMediator sharedInstance] updateCountWithSampleCount: sampCount];
        }
        
    }];
    
    
    
    
    //LOAD MIDI
    
    NSLog(@"%@", filePath);
    
    scoreReader.load([filePath UTF8String]);
    double bpm = scoreReader.getBPM();
    
    

    // REGISTER BEAT CALLBACK
    
    [self.mediator registerCallbackWithPeriod:(framesize*60/(bpm*64)) andCallback:&nextMidiNote];
    
    
    // START AUDIO
    [self.audioController addChannels:@[audioOut]];
}

void nextMidiNote (/*YScoreReader reader*/){
    NSLog(@"Note");
    NSLog(@"%f",[MHCore sharedInstance]->scoreReader.getBPM());
    [MHCore sharedInstance]->scoreReader.next(7);
    const NoteEvent *note = [MHCore sharedInstance]->scoreReader.current(7);
//    NSLog(@"%d",note->data2);
    
    delete note;
}

@end