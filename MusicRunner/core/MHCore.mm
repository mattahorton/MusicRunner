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
int prevNoteVal;
MHMediator *g_mediator;
float sampRate;


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
        g_mediator = self.mediator;
        filePath = [[NSBundle mainBundle] pathForResource:@"watchtower"
                                                   ofType:@"mid"];
        scoreReader = YScoreReader::YScoreReader();
        [self coreInit];
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
    
    sampRate = self.audioController.inputAudioDescription.mSampleRate;
    
    framesize = AEConvertSecondsToFrames(self.audioController, dur);
    
    audioOut = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp  *time,
                                                  UInt32 frames,
                                                  AudioBufferList *audio) {
        
        for ( int i=0; i<frames; i++ ) {
            ((float*)audio->mBuffers[0].mData)[i] = ((float*)audio->mBuffers[1].mData)[i] = 0;
        }
        
    }];
    
    
    // START AUDIO
    [self.audioController addChannels:@[audioOut]];
    
    //START BASS
    bassInit();
}

void nextMidiNote (int track){
    [MHCore sharedInstance]->scoreReader.next(track);
    const NoteEvent *note = [MHCore sharedInstance]->scoreReader.current(track);
    int startNext = [g_mediator getCurrentSamp];
    float untilNext;

    if(note){
//        NSLog(@"note");
        BASS_MIDI_StreamEvent(stream, 0,MIDI_EVENT_NOTE,MAKEWORD(prevNoteVal,0));
        BASS_MIDI_StreamEvent(stream, 0,MIDI_EVENT_NOTE,MAKEWORD((int)note->data2,20));
        prevNoteVal = (int)note->data2;
//        NSLog(@"%f",note->untilNext);
        untilNext = note->untilNext;
        untilNext = untilNext * -1;
        startNext = (int)untilNext + startNext;
//        NSLog(@"%d",startNext);
        [g_mediator registerCallbackWithCount: startNext andCallback:&nextMidiNote andArg:4];
    }
    
    
    
    delete note;
}

void bassInit(){
    
    int err;
    
    
    
    // check the correct BASS was loaded
    
    if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
        
        NSLog(@"An incorrect version of BASS was loaded");
        
    }
    
    
    
    // initialize default output device
    
    if (!BASS_Init(-1,sampRate,0,0,NULL))
        
        NSLog(@"Can't initialize output device");
    
    
    
    //might not need 16 input channels but it also might not hurt anything
    
    stream = BASS_MIDI_StreamCreateFile(false, [[[NSBundle mainBundle] pathForResource:@"watchtower" ofType:@"mid"] UTF8String], 0, 0, BASS_STREAM_AUTOFREE, 0);
    
    // set up midi sync to get midi events
    BASS_ChannelSetSync(stream, BASS_SYNC_MIDI_EVENT|BASS_SYNC_MIXTIME, MIDI_EVENT_NOTE, NoteProc, 0);
    
    
    
    BASS_ChannelSetAttribute(stream,BASS_ATTRIB_NOBUFFER,1); // no buffering for minimum latency
    
    
    
    for(int i = 0; i < NUM_CHANNELS; i++){
        
        BASS_ChannelPlay(stream,0); // start it
        
        err = BASS_ErrorGetCode();
        
        if (err) NSLog(@"bass error code %d after initializing channel %d", err, i);
        
    }
    
    
    
    HSOUNDFONT sfont1=BASS_MIDI_FontInit([[[NSBundle mainBundle] pathForResource: @"Gort" ofType: @"SF2"] UTF8String], 0);
    
    
    
    err = BASS_ErrorGetCode();
    
    if (err) NSLog(@"bass error code %d", err);
    
    
    
    
    fonts[0].font = sfont1;
    
    fonts[0].preset = -1;
    
    fonts[0].bank = 0;
    
    
    
    BASS_MIDI_StreamSetFonts(stream, fonts, 1);
    
}

void CALLBACK NoteProc(HSYNC handle, DWORD channel, DWORD data, void *user)
{
    return;
}

@end