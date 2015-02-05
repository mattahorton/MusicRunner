//
//  ViewController.h
//  MusicRunner
//
//  Created by Matthew Horton on 2/5/15.
//  Copyright (c) 2015 mattahorton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileScrollViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;

- (id) initWithImage:(UIImage*)cloudsImage verticalScroll:(BOOL)verticalScroll animationDuration:(CFTimeInterval)animationDuration andCoder:(NSCoder *) coder;


@end

