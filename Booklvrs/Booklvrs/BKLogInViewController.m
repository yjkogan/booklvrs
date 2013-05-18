//
//  BKLogInViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKLogInViewController.h"

@interface BKLogInViewController ()

@end

@implementation BKLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground_blue.jpg"]];
    
    UIImageView *logoLabel = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,250,120)];
    logoLabel.image = [UIImage imageNamed:@"booklvrs_logo_white.png"];
    logoLabel.contentMode = UIViewContentModeScaleAspectFit;
    self.logInView.logo = logoLabel;
}

@end
