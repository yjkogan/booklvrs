//
//  BKMainViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKMainViewController.h"
#import "BKLogInViewController.h"
#import "BKUserInfoViewController.h"
#import "BKAppDelegate.h"
#import <Parse/Parse.h>

@interface BKMainViewController ()

@end

@implementation BKMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground.jpg"]];
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOutCurrentUser:)];
    self.navigationItem.rightBarButtonItem = logOutButton;
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (![PFUser currentUser]) {
        BKLogInViewController * logInVC = [[BKLogInViewController alloc] init];
        logInVC.fields = PFLogInFieldsFacebook | PFLogInFieldsDismissButton;
        logInVC.delegate = self;
        [self presentViewController:logInVC animated:NO completion:nil];
    } else if (![[PFUser currentUser] objectForKey:@"GoodReadsUsername"]){
        BKUserInfoViewController *userInfoVC = [[BKUserInfoViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:userInfoVC animated:YES];
    } else {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"GET"];
        NSString *key = ((BKAppDelegate *)[[UIApplication sharedApplication] delegate]).goodReadsKey;
        
        NSString *url = [NSString stringWithFormat:@"http://www.goodreads.com/user/show/?key=%@&username=%@", key, [[PFUser currentUser] objectForKey:@"GoodReadsUsername"]];
        [request setURL:[NSURL URLWithString:url]];
    }
}

- (void)logOutCurrentUser:(id)sender {
    [PFUser logOut];
    UIAlertView *loggedOut = [[UIAlertView alloc] initWithTitle:@"Logged Out!" message:nil delegate:self cancelButtonTitle:@"Yay!" otherButtonTitles: nil];
    [loggedOut show];
}

#pragma mark -- LogInView Delegate Methods --
- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Didn't log in" message:@"I'm sorry but without loggin in you can't use this app..." delegate:self cancelButtonTitle:@"Okay..." otherButtonTitles: nil];
        [alert show];
    }];
}

@end
