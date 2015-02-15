//
//  ViewController.m
//  MusicRunner
//
//  Created by Matthew Horton on 2/5/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//
//  Adapted from http://stackoverflow.com/questions/8790079/animate-infinite-scrolling-of-an-image-in-a-seamless-loop

#import "TileScrollViewController.h"

static NSString *IMAGE_STRING = @"SpaceBlur";
static float dur = 2;

@interface TileScrollViewController ()

@end

@implementation TileScrollViewController {
    CALayer *bgLayer;
    CABasicAnimation *bgLayerAnimation;
    
    UIImage *bgImage;
    BOOL verticalScroll;
    CFTimeInterval animationDuration;
    
    CALayer *shipLayer;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    bgImage = [UIImage imageNamed:IMAGE_STRING];
    self = [self initWithImage:bgImage verticalScroll:YES animationDuration:dur andCoder:aDecoder];
    return self;
}

- (id) init {
    bgImage = [UIImage imageNamed:IMAGE_STRING];
    self = [self initWithImage:bgImage verticalScroll:YES animationDuration:dur andCoder:nil];
    return self;
}

- (id) initWithImage:(UIImage*)image verticalScroll:(BOOL)vScroll animationDuration:(CFTimeInterval)duration andCoder:(NSCoder *) coder {
    self = [super initWithCoder:coder];
    if (self ) {
        bgImage = image;
        verticalScroll = vScroll;
        animationDuration = duration;
        _core = [MHCore sharedInstance];
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
    
    CGPoint startPoint;
    CGPoint endPoint = CGPointZero;
    if (verticalScroll) {
        startPoint = CGPointMake(0, -imageSize.height);
        bgLayer.frame = CGRectMake(0, 0, viewSize.width, viewSize.height + imageSize.height);
    } else {
        startPoint = CGPointMake(-imageSize.width, 0);
        bgLayer.frame = CGRectMake(0, 0, viewSize.width + imageSize.width, viewSize.height);
    }
    
    bgLayerAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    bgLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    bgLayerAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
    bgLayerAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
    bgLayerAnimation.repeatCount = HUGE_VALF;
    bgLayerAnimation.duration = animationDuration;
    [self applyBgLayerAnimation];
    
    
    shipLayer = [self newCALayerWithNSString:@"viper" andCATransform3D:CATransform3DMakeScale(.3, -.3, .3) andCGPoint:CGPointMake(100.0,400.0)];
    [self.bgImageView.layer addSublayer:shipLayer];
    
    CALayer *cylon = [self newCALayerWithNSString:@"Cylon" andCATransform3D:CATransform3DMakeScale(.3, -.3, .3) andCGPoint:CGPointMake(100.0,100.0)];
    [self.bgImageView.layer addSublayer:cylon];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Use animation to move ship a large distance
    
    [shipLayer setPosition:[[shipLayer presentationLayer] position]];
    [shipLayer removeAllAnimations];
    
    UITouch *t = [touches anyObject];
    [self moveShipWithTouch:t];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // Move ship instantly to point being touched
    
    CGPoint p = [[touches anyObject] locationInView:self.bgImageView];
    
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    [shipLayer setPosition:CGPointMake(p.x, [[shipLayer presentationLayer] position].y)];
    [CATransaction commit];
}

-(void) moveShipWithTouch:(UITouch *)t {
    CGPoint p = [t locationInView:self.bgImageView];
    
    CABasicAnimation *shipAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    [shipAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [shipAnim setFromValue:[NSValue valueWithCGPoint:[[shipLayer presentationLayer] position]]];
    [shipAnim setToValue:[NSValue valueWithCGPoint:CGPointMake(p.x, [[shipLayer presentationLayer] position].y)]];
    [shipAnim setDuration:(p.x - [[shipLayer presentationLayer]position].y)/self.bgImageView.frame.size.width];
    
    [shipLayer setPosition:CGPointMake(p.x, [[shipLayer presentationLayer] position].y)];
    
    [shipLayer addAnimation:shipAnim forKey:@"ship"];
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

-(CALayer *)newCALayerWithNSString:(NSString *)imageName
                  andCATransform3D:(CATransform3D)transform
                        andCGPoint:(CGPoint)point {
    CALayer *outputLayer = [CALayer layer];
    UIImage *img = [UIImage imageNamed:imageName];
    outputLayer.backgroundColor = [UIColor colorWithPatternImage:img].CGColor;
    [outputLayer setBounds:CGRectMake(0.0, 0.0, img.size.width, img.size.height)];
    outputLayer.transform = transform;
    [outputLayer setPosition:point];
    [outputLayer setZPosition:5.0];
    
    return outputLayer;
}
@end


