//
//  BKUserInfoViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKUserInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

CGFloat kPaddingFromEdge = 10.0f;

@interface BKUserInfoViewController ()

@end

@implementation BKUserInfoViewController

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground.jpg"]];    
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(20.0,
                                                                    60.0,
                                                                    self.view.frame.size.width - 40.0,
                                                                    self.view.frame.size.height - navHeight - 120.0)];
    containerView.userInteractionEnabled = YES;
//    containerView.backgroundColor = [UIColor blueColor];

    UILabel *goodReadsUsernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                        kPaddingFromEdge,
                                                                        kPaddingFromEdge,
                                                                        containerView.frame.size.width - 2*kPaddingFromEdge,
                                                                         30.0)];
    goodReadsUsernameLabel.backgroundColor = [UIColor clearColor];
    goodReadsUsernameLabel.text = @"Goodreads Username";
    goodReadsUsernameLabel.textColor = [UIColor whiteColor];
    
    UITextField *goodReadsUsername = [[UITextField alloc] initWithFrame:CGRectMake(
                                                                                   kPaddingFromEdge,
                                                                                   goodReadsUsernameLabel.frame.size.height+ kPaddingFromEdge,
                                                                                   containerView.frame.size.width - 2*kPaddingFromEdge,
                                                                                   40)];
    goodReadsUsername.borderStyle = UITextBorderStyleRoundedRect;
//    goodReadsUsername.backgroundColor = [UIColor redColor];

    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitBtn.frame = CGRectMake(kPaddingFromEdge,
                                 goodReadsUsername.frame.origin.y +
                                 goodReadsUsername.frame.size.height  + kPaddingFromEdge,
                                 containerView.frame.size.width - 2*kPaddingFromEdge,
                                 40);
    [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:goodReadsUsernameLabel];
    [containerView addSubview:goodReadsUsername];
    [containerView addSubview:submitBtn];
    
    [self.view addSubview:containerView];
    
}

- (void)submitBtnTapped:(id)sender {
    NSLog(@"got tap");
}

@end
