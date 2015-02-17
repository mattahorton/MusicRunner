//
//  ViewController.h
//  MusicRunner
//
//  Created by Matthew Horton on 2/5/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHCore.h"

@interface TileScrollViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) MHCore *core;

- (id) initWithImage:(UIImage*)cloudsImage
      verticalScroll:(BOOL)verticalScroll
   animationDuration:(CFTimeInterval)animationDuration
            andCoder:(NSCoder *) coder;

-(CALayer *)newCylon;
-(void)moveCylon:(CALayer*)cylon withColumn:(int)column;
-(void)moveCylonWithCol:(int)col;


@end

