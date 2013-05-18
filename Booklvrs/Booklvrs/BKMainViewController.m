//
//  BKMainViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKMainViewController.h"
#import "BKLogInViewController.h"
#import <Parse/Parse.h>

@interface BKMainViewController ()

@end

@implementation BKMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground.jpg"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (![PFUser currentUser]) {
        BKLogInViewController * logInVC = [[BKLogInViewController alloc] init];
        logInVC.fields = PFLogInFieldsFacebook | PFLogInFieldsDismissButton;
        logInVC.delegate = self;
        [self presentViewController:logInVC animated:NO completion:nil];
    } else {
        [PFUser logOut];
    }
}

#pragma mark -- LogInView Delegate Methods --
- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Didn't log in" message:@"I'm sorry but without loggin in you can't use this app..." delegate:self cancelButtonTitle:@"Okay..." otherButtonTitles: nil];
        [alert show];
    }];
}

@end
