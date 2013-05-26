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
#import "BKNearbyBooksViewController.h"
#import <Parse/Parse.h>

@interface BKMainViewController ()

@property (nonatomic) BKNearbyViewState viewState;
@property (nonatomic) BOOL animateTransition;
@property (strong, nonatomic) NSArray *nearbyUsers;

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
    self.viewState = BKNearbyBooksView;
    self.animateTransition = YES;
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    backgroundImage.image = [UIImage imageNamed:@"iphone_4_splash.jpg"];
    [self.view addSubview:backgroundImage];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
        
        if (!self.nearbyUsers) {
            PFQuery *nearbyUsersQuery = [PFUser query];
            [nearbyUsersQuery whereKey:@"facebookId" notEqualTo:[[PFUser currentUser] objectForKey:@"facebookId"]];
            self.nearbyUsers = [nearbyUsersQuery findObjects];
        }
        
        if (self.viewState == BKNearbyListView) {
            BKNearbyUsersTableViewController *nearbyUserListVC = [[BKNearbyUsersTableViewController alloc] initWithStyle:UITableViewStylePlain];
            nearbyUserListVC.delegate = self;
            
            nearbyUserListVC.nearbyUsers = self.nearbyUsers;
            [self.navigationController pushViewController:nearbyUserListVC animated:self.animateTransition];
        } else if (self.viewState == BKNearbyMapsView) {
            BKNearbyUsersMapController *nearbyUsersMapVC = [[BKNearbyUsersMapController alloc] initWithNibName:nil bundle:nil];
            nearbyUsersMapVC.delegate = self;

            nearbyUsersMapVC.nearbyUsers = self.nearbyUsers;
            [self.navigationController pushViewController:nearbyUsersMapVC animated:self.animateTransition];
        } else if (self.viewState == BKNearbyBooksView) {
            BKNearbyBooksViewController *nearbyBookVC = [[BKNearbyBooksViewController alloc] initWithNibName:nil bundle:nil];
            nearbyBookVC.delegate = self;
            nearbyBookVC.nearbyUsers = self.nearbyUsers;
            [self.navigationController pushViewController:nearbyBookVC animated:self.animateTransition];
        }
    }
}

- (void)changeToMapViewFrom:(UIViewController *)controller {
    self.viewState = BKNearbyMapsView;
    self.animateTransition = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)changeToListViewFrom:(UIViewController *)controller {
    self.viewState = BKNearbyListView;
    self.animateTransition = NO;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)changeToBooksViewFrom:(UIViewController *)controller {
    self.viewState = BKNearbyBooksView;
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
