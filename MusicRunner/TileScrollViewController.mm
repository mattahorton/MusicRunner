//
//  ViewController.m
//  MusicRunner
//
//  Created by Matthew Horton on 2/5/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//
//  Adapted from http://stackoverflow.com/questions/8790079/animate-infinite-scrolling-of-an-image-in-a-seamless-loop

#import "TileScrollViewController.h"
#import "MHGlobals.h"

#define NUMCYLONS 48
#define DIVISOR 7
#define COL_MULT .125

static NSString *IMAGE_STRING = @"SpaceBlur";
static float dur = 2;

CGRect screenRect;
CGFloat screenWidth;
CGFloat screenHeight;

@interface TileScrollViewController ()

@end

@implementation TileScrollViewController {
    CALayer *bgLayer;
    CABasicAnimation *bgLayerAnimation;
    
    UIImage *bgImage;
    BOOL verticalScroll;
    CFTimeInterval animationDuration;
    
    CALayer *shipLayer;
    MHGlobals *globals;
    
    NSMutableArray *cylonArray;
    int currCylon;
    
    CADisplayLink *displayLink;
    UILabel * label;
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
        globals = [MHGlobals sharedInstance];
        globals.tsvc = self;
        currCylon = 0;
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
//    label = [[UILabel alloc] initWithFrame:CGRectMake(.8*screenWidth, .02*screenHeight, 100, 200)];
//    [label setText:@"00"];
//    [self.bgImageView addSubview:label];
//    [label setNeedsDisplay];
//
//    [self.bgImageView addSubview:self.scoreLabel];
    self.bgImageView.clipsToBounds = YES;
    const CGSize viewSize = self.bgImageView.bounds.size;
    const CGSize imageSize = bgImage.size;
    
    UIColor *bgPattern = [UIColor colorWithPatternImage:bgImage];
    bgLayer = [CALayer layer];
    bgLayer.backgroundColor = bgPattern.CGColor;
    bgLayer.transform = CATransform3DMakeScale(1, -1, 1);
    bgLayer.anchorPoint = CGPointMake(0, 1);
    bgLayer.zPosition = 0.0;
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
    
    
    shipLayer = [self newCALayerWithNSString:@"viper"
                            andCATransform3D:CATransform3DMakeScale(.3, -.3, .3)
                                  andCGPoint:CGPointMake(.5*screenWidth,.8333*screenHeight)];
    [self.bgImageView.layer addSublayer:shipLayer];
    
    
    // Load cylons
    cylonArray = [NSMutableArray array];
    for (int i = 0; i < NUMCYLONS; i++) {
        [cylonArray addObject:[self newCylon]];
    }
    [globals setCylons:cylonArray];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(collision)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) collision {
//    double currentTime = [displayLink timestamp];
    
    //Do some collision checking
    for (CALayer* cylon in cylonArray){
        if(CGRectIntersectsRect(((CALayer*)cylon.presentationLayer).frame,
                                ((CALayer*)shipLayer.presentationLayer).frame)) {
            //handle the collision
            [cylon setOpacity:0];
        }
    }
}

-(CALayer *)newCylon{
    CALayer *cylon = [self newCALayerWithNSString:@"Cylon"
                                 andCATransform3D:CATransform3DMakeScale(.1, -.1, .1)
                                       andCGPoint:CGPointMake(.05*currCylon*screenWidth,-.1*screenHeight)];
    
    [self.bgImageView.layer addSublayer:cylon];

    return cylon;
}

-(void)moveCylonWithCol:(int)col {
    if(currCylon >= NUMCYLONS) currCylon = 0;
//    [self moveCylon:(CALayer*)[cylonArray objectAtIndex:currCylon] withColumn:currCylon/DIVISOR+1];
    [self moveCylon:(CALayer*)[cylonArray objectAtIndex:currCylon] withColumn:col];
    currCylon++;
}


-(void)moveCylon:(CALayer*)cylon withColumn:(int)col {
    
    float sp4b = [globals.spb floatValue]*4*4*2;
    float toship = .8333*screenHeight;
    float offscreen = 1.2*screenHeight;
    float offscreendur = offscreen*sp4b/toship;
    
    [cylon setPosition:CGPointMake(COL_MULT*col*screenWidth,-.1*screenHeight)];
    [cylon setOpacity:1];
    
    CABasicAnimation *cylonAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    [cylonAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [cylonAnim setFromValue:[NSValue valueWithCGPoint:[cylon position]]];
    [cylonAnim setToValue:[NSValue valueWithCGPoint:CGPointMake([cylon position].x,offscreen)]];
    [cylonAnim setDuration:offscreendur];
    
    [cylon setPosition:CGPointMake([cylon position].x, offscreen)];
    
    [cylon addAnimation:cylonAnim forKey:@"cylon"];
    [CATransaction flush];
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


