//
//  ViewController.m
//  MusicRunner
//
//  Created by Matthew Horton on 2/5/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//
//  Adapted from http://stackoverflow.com/questions/8790079/animate-infinite-scrolling-of-an-image-in-a-seamless-loop

#import "TileScrollViewController.h"

static NSString *IMAGE_STRING = @"road";

@interface TileScrollViewController ()

@end

@implementation TileScrollViewController {
    CALayer *bgLayer;
    CABasicAnimation *bgLayerAnimation;
    
    UIImage *bgImage;
    BOOL verticalScroll;
    CFTimeInterval animationDuration;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    bgImage = [UIImage imageNamed:IMAGE_STRING];
    self = [self initWithImage:bgImage verticalScroll:YES animationDuration:3.0 andCoder:aDecoder];
    return self;
}

- (id) init {
    bgImage = [UIImage imageNamed:IMAGE_STRING];
    self = [self initWithImage:bgImage verticalScroll:YES animationDuration:3.0 andCoder:nil];
    return self;
}

- (id) initWithImage:(UIImage*)image verticalScroll:(BOOL)vScroll animationDuration:(CFTimeInterval)duration andCoder:(NSCoder *) coder {
    self = [super initWithCoder:coder];
    if (self ) {
        bgImage = image;
        verticalScroll = vScroll;
        animationDuration = duration;
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.bgImageView.clipsToBounds = YES;
    const CGSize viewSize = self.bgImageView.bounds.size;
    const CGSize imageSize = bgImage.size;
    
    UIColor *bgPattern = [UIColor colorWithPatternImage:bgImage];
    bgLayer = [CALayer layer];
    bgLayer.backgroundColor = bgPattern.CGColor;
    bgLayer.transform = CATransform3DMakeScale(1, -1, 1);
    bgLayer.anchorPoint = CGPointMake(0, 1);
    [self.bgImageView.layer addSublayer:bgLayer];
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint;
    NSLog(@"%d", verticalScroll);
    NSLog(@"%f", animationDuration);
    if (verticalScroll) {
        endPoint = CGPointMake(0, -imageSize.height);
        bgLayer.frame = CGRectMake(0, 0, viewSize.width, viewSize.height + imageSize.height);
    } else {
        endPoint = CGPointMake(-imageSize.width, 0);
        bgLayer.frame = CGRectMake(0, 0, viewSize.width + imageSize.width, viewSize.height);
    }
    
    bgLayerAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    bgLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    bgLayerAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
    bgLayerAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
    bgLayerAnimation.repeatCount = HUGE_VALF;
    bgLayerAnimation.duration = animationDuration;
    [self applyBgLayerAnimation];
}

- (void) viewDidUnload {
    bgLayer = nil;
    bgLayerAnimation = nil;
    [super viewDidUnload];
}

- (void) applyBgLayerAnimation {
    [bgLayer addAnimation:bgLayerAnimation forKey:@"position"];
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    [self applyBgLayerAnimation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
@end


