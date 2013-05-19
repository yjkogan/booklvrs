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
#import "XMLDictionary.h"
#import "BKNearbyUsersTableViewController.h"
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
        logInVC.delegate = self;
        [self presentViewController:logInVC animated:NO completion:nil];
    } else if (![[PFUser currentUser] objectForKey:@"GoodReadsUsername"]){
        BKUserInfoViewController *userInfoVC = [[BKUserInfoViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:userInfoVC animated:YES];
    } else {

        BKNearbyUsersTableViewController *nearbyUserListVC = [[BKNearbyUsersTableViewController alloc] initWithStyle:UITableViewStylePlain];
        
        PFQuery *nearbyUsersQuery = [PFUser query];
        [nearbyUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            nearbyUserListVC.nearbyUsers = objects;
            [self.navigationController pushViewController:nearbyUserListVC animated:YES];
        }];
    }
}

- (void)logOutCurrentUser:(id)sender {
    [PFUser logOut];
    UIAlertView *loggedOut = [[UIAlertView alloc] initWithTitle:@"Logged Out!" message:nil delegate:self cancelButtonTitle:@"Yay!" otherButtonTitles: nil];
    [loggedOut show];
}

#pragma mark -- LogInView Delegate Methods --
- (void)logInViewController:(BKLogInViewController *)controller didLogInUser:(PFUser *)user {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [user setObject:[result objectForKey:@"id"] forKey:@"facebookId"];
        [user setObject:[result objectForKey:@"name"] forKey:@"name"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
}

@end
