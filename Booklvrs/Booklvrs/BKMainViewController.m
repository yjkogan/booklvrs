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
#import "BKNearbyUsersMapController.h"
#import <Parse/Parse.h>

@interface BKMainViewController ()

@property (nonatomic) BOOL showList;
@property (nonatomic) BOOL animateTransition;

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
    self.showList = YES;
    self.animateTransition = YES;
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    backgroundImage.image = [UIImage imageNamed:@"iphone_splash_nobuttons.png"];
    [self.view addSubview:backgroundImage];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (![PFUser currentUser]) {
        BKLogInViewController * logInVC = [[BKLogInViewController alloc] init];
        logInVC.delegate = self;
        [self presentViewController:logInVC animated:NO completion:nil];
    } else if (![[PFUser currentUser] objectForKey:@"GoodReadsUsername"]){
        BKUserInfoViewController *userInfoVC = [[BKUserInfoViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:userInfoVC animated:YES];
    } else {

        if (self.showList) {
            BKNearbyUsersTableViewController *nearbyUserListVC = [[BKNearbyUsersTableViewController alloc] initWithStyle:UITableViewStylePlain];
            nearbyUserListVC.delegate = self;
            
            PFQuery *nearbyUsersQuery = [PFUser query];
            [nearbyUsersQuery whereKey:@"facebookId" notEqualTo:[[PFUser currentUser] objectForKey:@"facebookId"]];
            [nearbyUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                nearbyUserListVC.nearbyUsers = objects;
                [self.navigationController pushViewController:nearbyUserListVC animated:self.animateTransition];
            }];
        } else {
            BKNearbyUsersMapController *nearbyUsersMapVC = [[BKNearbyUsersMapController alloc] initWithNibName:nil bundle:nil];
            nearbyUsersMapVC.delegate = self;
            PFQuery *nearbyUsersQuery = [PFUser query];
            [nearbyUsersQuery whereKey:@"facebookId" notEqualTo:[[PFUser currentUser] objectForKey:@"facebookId"]];
            [nearbyUsersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                nearbyUsersMapVC.nearbyUsers = objects;
                [self.navigationController pushViewController:nearbyUsersMapVC animated:self.animateTransition];
            }];
        }
    }
}

- (void)changeToMapViewFrom:(BKNearbyUsersTableViewController *)controller {
    self.showList = NO;
    self.animateTransition = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)changeToListViewFrom:(BKNearbyUsersMapController *)controller {
    self.showList = YES;
    self.animateTransition = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -- LogInView Delegate Methods --
- (void)logInViewController:(BKLogInViewController *)controller didLogInUser:(PFUser *)user {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [user setObject:[result objectForKey:@"id"] forKey:@"facebookId"];
        [user setObject:[result objectForKey:@"name"] forKey:@"name"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }];
}

@end
