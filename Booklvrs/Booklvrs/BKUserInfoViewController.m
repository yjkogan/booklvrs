//
//  BKUserInfoViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKUserInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

CGFloat kPaddingFromEdge = 10.0f;

@interface BKUserInfoViewController ()

@property (strong, nonatomic) UITextField *goodReadsUsername;
@property (strong, nonatomic) UITextField *lookingFor;

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
                                                                    10.0,
                                                                    self.view.frame.size.width - 40.0,
                                                                    self.view.frame.size.height - navHeight - 120.0)];
    containerView.userInteractionEnabled = YES;

    UILabel *goodReadsUsernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                        kPaddingFromEdge,
                                                                        kPaddingFromEdge,
                                                                        containerView.frame.size.width - 2*kPaddingFromEdge,
                                                                         30.0)];
    goodReadsUsernameLabel.backgroundColor = [UIColor clearColor];
    goodReadsUsernameLabel.text = @"Goodreads Username";
    goodReadsUsernameLabel.textColor = [UIColor whiteColor];
    
    self.goodReadsUsername = [[UITextField alloc] initWithFrame:CGRectMake(
                                                                                   kPaddingFromEdge,
                                                                                   goodReadsUsernameLabel.frame.size.height+ kPaddingFromEdge,
                                                                                   containerView.frame.size.width - 2*kPaddingFromEdge,
                                                                                   40)];
    self.goodReadsUsername.borderStyle = UITextBorderStyleRoundedRect;

    UILabel *lookingForLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingFromEdge,
                                                                        self.goodReadsUsername.frame.origin.y + self.goodReadsUsername.frame.size.height + kPaddingFromEdge,
                                                                        containerView.frame.size.width - 2*kPaddingFromEdge,
                                                                         30.0)];
    
    lookingForLabel.backgroundColor = [UIColor clearColor];
    lookingForLabel.text = @"What are you looking for?";
    lookingForLabel.textColor = [UIColor whiteColor];
    
    self.lookingFor = [[UITextField alloc] initWithFrame:CGRectMake(kPaddingFromEdge,
                                                                    lookingForLabel.frame.origin.y + lookingForLabel.frame.size.height + kPaddingFromEdge,
                                                                    containerView.frame.size.width - 2*kPaddingFromEdge,
                                                                    40.0)];
    self.lookingFor.borderStyle = UITextBorderStyleRoundedRect;
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitBtn.frame = CGRectMake(kPaddingFromEdge,
                                 self.lookingFor.frame.origin.y +
                                 self.lookingFor.frame.size.height  + kPaddingFromEdge,
                                 containerView.frame.size.width - 2*kPaddingFromEdge,
                                 40);
    
    [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *dismissKeyboardRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    
    [self.view addGestureRecognizer:dismissKeyboardRecognizer];
    [containerView addSubview:goodReadsUsernameLabel];
    [containerView addSubview:self.goodReadsUsername];
    [containerView addSubview:lookingForLabel];
    [containerView addSubview:self.lookingFor];
    [containerView addSubview:submitBtn];
    
    [self.view addSubview:containerView];
    
    
    
}

- (void)submitBtnTapped:(id)sender {
    [self.goodReadsUsername resignFirstResponder];
    [self.lookingFor resignFirstResponder];
    NSString *goodReadsUsername = self.goodReadsUsername.text;
    NSString *lookingFor = self.lookingFor.text;

    if (goodReadsUsername.length < 1 || lookingFor.length < 1) {
        UIAlertView *emptyField = [[UIAlertView alloc] initWithTitle:@"Missing Info" message:@"Please fill out all text fields. If you don't yet have a GoodReads username, you can add one on your account settings page" delegate:self cancelButtonTitle:@"Fine then" otherButtonTitles: nil];
        [emptyField show];
    } else {
        PFUser *currentUser = [PFUser currentUser];
        [currentUser setObject:goodReadsUsername forKey:@"GoodReadsUsername" ];
        [currentUser setObject:lookingFor forKey:@"LookingFor"];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)dismissKeyboard:(id)sender {
    [self.goodReadsUsername resignFirstResponder];
    [self.lookingFor resignFirstResponder];
}

@end
