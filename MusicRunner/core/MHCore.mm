//
//  MHCore.m
//  Mariah
//
//  Created by Matthew Horton on 1/16/15.
//  Copyright (c) 2015 Matt Horton. All rights reserved.
//

#import "MHCore.h"
#import "bassmidi.h"
#import "bass.h"

#define SRATE 24000
#define FRAMESIZE 512
#define NUM_CHANNELS 2
#define BPM 100
#define FILE "watchtower"
//#define FILE "taylor_swift-shake_it_off"
//#define FILE "katy_perry-roar"
//#define FILE "ariana_grande-problem_ft_iggy_azalea"
//#define FILE "idina_menzel-let_it_go"
//#define FILE "katy_perry-firework"
//#define FILE "david_guetta_ft_sia-titanium"
//#define FILE "sam_smith-im_not_the_only_one"
//#define FILE "sam_smith-stay_with_me"

static HSTREAM stream;
static BASS_MIDI_FONT fonts[2];


@implementation MHCore {
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
        [self coreInit];
    }
    return self;
}

-(void) coreInit {
    //START BASS
    bassInit();
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
    
    stream = BASS_MIDI_StreamCreateFile(false, [[[NSBundle mainBundle] pathForResource:@FILE ofType:@"mid"] UTF8String], 0, 0, BASS_STREAM_AUTOFREE, 0);
    
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
    DWORD midichan = HIWORD(data);
    DWORD param = LOWORD(data);
//    NSLog(@"%d",midichan);
    if (midichan == 2) { NSLog(@"uhh...");}
    return;
}

@end