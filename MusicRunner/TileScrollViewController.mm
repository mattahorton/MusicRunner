//
//  ViewController.m
//  MusicRunner
//
//  Created by Matthew Horton on 2/5/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//
//  Adapted from http://stackoverflow.com/questions/8790079/animate-infinite-scrolling-of-an-image-in-a-seamless-loop

#import "TileScrollViewController.h"

static NSString *IMAGE_STRING = @"Space";
static float dur = 10;

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
    
    
    
    shipLayer = [CALayer layer];
    UIImage *viper = [UIImage imageNamed:@"viper"];
    shipLayer.backgroundColor = [UIColor colorWithPatternImage:viper].CGColor;
    [shipLayer setBounds:CGRectMake(0.0, 0.0, viper.size.width, viper.size.height)];
    shipLayer.transform = CATransform3DMakeScale(.3, -.3, .3);
    [shipLayer setPosition:CGPointMake(100.0,400.0)];
    [shipLayer setZPosition:5.0];
    [self.bgImageView.layer addSublayer:shipLayer];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    for (UITouch *touch in touches) {
//        CGPoint touchLocation = [touch locationInView:self.view];
//        for (id sublayer in self.view.layer.sublayers) {
//            BOOL touchInLayer = NO;
//            if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
//                CAShapeLayer *shapeLayer = sublayer;
//                if (CGPathContainsPoint(shapeLayer.path, 0, touchLocation, YES)) {
//                    // This touch is in this shape layer
//                    touchInLayer = YES;
//                }
//            } else {
//                CALayer *layer = sublayer;
//                if (CGRectContainsPoint(layer.frame, touchLocation)) {
//                    // Touch is in this rectangular layer
//                    touchInLayer = YES;
//                }
//            }
//            
//            if(touchInLayer) {
//                CGPoint p = [touch locationInView:self.bgImageView];
//                
//                CABasicAnimation *shipAnim = [CABasicAnimation animationWithKeyPath:@"position"];
//                [shipAnim setFromValue:[NSValue valueWithCGPoint:[shipLayer position]]];
//                [shipAnim setToValue:[NSValue valueWithCGPoint:CGPointMake(p.x, [shipLayer position].y)]];
//                [shipAnim setDuration:1.0];
//                
//                [shipLayer setPosition:CGPointMake(p.x, [shipLayer position].y)];
//                
//                [shipLayer addAnimation:shipAnim forKey:@"ship"];
//            }
//        }
//    }
    
//    shipLayer.frame = [[shipLayer presentationLayer] frame];
    [shipLayer setPosition:[[shipLayer presentationLayer] position]];
    [shipLayer removeAllAnimations];
    
    UITouch *t = [touches anyObject];
    [self moveShipWithTouch:t];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [shipLayer setPosition:[[shipLayer presentationLayer] position]];
    [shipLayer removeAllAnimations];
    
    UITouch *t = [touches anyObject];
    [self moveShipWithTouch:t];

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
@end


