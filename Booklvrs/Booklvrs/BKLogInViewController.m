//
//  BKLogInViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKLogInViewController.h"
#import <QuartzCore/QuartzCore.h>

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
    
    UIView *logo = [[UIView alloc] initWithFrame:CGRectMake(0,0,250,250)];
    
    UIImageView *logoLabel = [[UIImageView alloc] initWithFrame:CGRectMake(0,100,250,60)];
    logoLabel.image = [UIImage imageNamed:@"booklvr.png"];
    logoLabel.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImageView *subHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0,130,250,120)];
    subHeader.image = [UIImage imageNamed:@"booklvrs_read_discover_meet_subhead_blues.png"];
    subHeader.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImageView *goodReads = [[UIImageView alloc] initWithFrame:CGRectMake(0,220,250,40)];
    goodReads.image = [UIImage imageNamed:@"goodreads.png"];
    goodReads.contentMode = UIViewContentModeScaleAspectFit;
    
    [logo addSubview:logoLabel];
    [logo addSubview:subHeader];
    [logo addSubview:goodReads];
    
    self.logInView.logo = logo;
}

@end
