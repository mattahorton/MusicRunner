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
#import "bassmidi.h"
#import "bass.h"

#define SRATE 24000
#define FRAMESIZE 512
#define NUM_CHANNELS 2
#define BPM 100

// buffer
SAMPLE g_vertices[FRAMESIZE*2];
UInt32 g_numFrames;

// buffer
float * g_buffer = NULL;

static HSTREAM stream;
static BASS_MIDI_FONT fonts[2];


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
    
//    NSLog(@"%@", filePath);
    
    scoreReader.load([filePath UTF8String]);
    double bpm = scoreReader.getBPM();
    
    
    //START BASS
    bassInit();
    
    

    // REGISTER BEAT CALLBACK
    
    [self.mediator registerCallbackWithPeriod:(framesize*60/(bpm*64)) andCallback:&nextMidiNote];
    
    
    // START AUDIO
    [self.audioController addChannels:@[audioOut]];
}

void nextMidiNote (/*YScoreReader reader*/){
//    NSLog(@"Note");
//    NSLog(@"%f",[MHCore sharedInstance]->scoreReader.getBPM());
    [MHCore sharedInstance]->scoreReader.next(7);
    const NoteEvent *note = [MHCore sharedInstance]->scoreReader.current(7);
//    NSLog(@"%d",note->data2);
    
    delete note;
}

void bassInit(){
    
    int err;
    
    
    
    // check the correct BASS was loaded
    
    if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
        
        NSLog(@"An incorrect version of BASS was loaded");
        
    }
    
    
    
    // initialize default output device
    
    if (!BASS_Init(-1,SRATE,0,0,NULL))
        
        NSLog(@"Can't initialize output device");
    
    
    
    //might not need 16 input channels but it also might not hurt anything
    
    stream=BASS_MIDI_StreamCreate(NUM_CHANNELS,0,1); // create the MIDI stream (16 MIDI channels for device input + 1 for keyboard input)
    
    
    
    BASS_ChannelSetAttribute(stream,BASS_ATTRIB_NOBUFFER,1); // no buffering for minimum latency
    
    
    
    for(int i = 0; i < NUM_CHANNELS; i++){
        
        BASS_ChannelPlay(stream,0); // start it
        
        err = BASS_ErrorGetCode();
        
        if (err) NSLog(@"bass error code %d after initializing channel %d", err, i);
        
    }
    
    
    
    HSOUNDFONT sfont1=BASS_MIDI_FontInit([[[NSBundle mainBundle] pathForResource: @"Gort" ofType: @"SF2"] UTF8String], 0);
    
    //HSOUNDFONT sfont2=BASS_MIDI_FontInit([[[NSBundle mainBundle] pathForResource: @"RolandChurchBells" ofType: @"sf2"] UTF8String], 0);
    
    //HSOUNDFONT sfont3=BASS_MIDI_FontInit([[[NSBundle mainBundle] pathForResource: @"rocking8m11e" ofType: @"sf2"] UTF8String], 0);
    
    //HSOUNDFONT sfont4=BASS_MIDI_FontInit([[[NSBundle mainBundle] pathForResource: @"SoloSynth" ofType: @"SF2"] UTF8String], 0);
    
    
    
    
    
    err = BASS_ErrorGetCode();
    
    NSLog(@"bass error code %d", err);
    
    
    
    //HSOUNDFONT sfont2=BASS_MIDI_FontInit("/Volumes/Bitchin\'ASSD/Andrew/Desktop/256/b/GLoiler/GLoiler/data/RolandChurchBells.sf2", 0);
    
    //err = BASS_ErrorGetCode();
    
    //NSLog(@"bass error code %d", err);
    
    
    
    
    fonts[0].font = sfont1;
    
    fonts[0].preset = -1;
    
    fonts[0].bank = 0;
    
    
    
    //fonts[1].font = sfont2;
    
    //fonts[1].preset = 10;
    
    //fonts[1].bank = 0;
    
    
    
    BASS_MIDI_StreamSetFonts(stream, fonts, 1);
    
    BASS_MIDI_StreamEvent(stream, 0,MIDI_EVENT_NOTE,MAKEWORD(64,100));
    
}

@end