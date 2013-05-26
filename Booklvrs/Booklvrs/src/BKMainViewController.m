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
    NSLog(@"nav controller: %@", self.navigationController);
    self.viewState = BKNearbyBooksView;
    self.animateTransition = YES;
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    backgroundImage.image = [UIImage imageNamed:@"iphone_4_splash.jpg"];
    [self.view addSubview:backgroundImage];
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"iphone_4_splash@2x.jpg"]]];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (![PFUser currentUser]) { // not logged in
        BKLogInViewController * logInVC = [[BKLogInViewController alloc] init];
        logInVC.delegate = self;
        [self presentViewController:logInVC animated:NO completion:nil];
    } else if (![[PFUser currentUser] objectForKey:@"GoodReadsUsername"]){ // logged in, no goodreads login
        BKUserInfoViewController *userInfoVC = [[BKUserInfoViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:userInfoVC animated:YES];
    } else {
        
        if (!self.nearbyUsers) { // make sure nearby users is populated
            PFQuery *nearbyUsersQuery = [PFUser query];
            [nearbyUsersQuery whereKey:@"facebookId" notEqualTo:[[PFUser currentUser] objectForKey:@"facebookId"]];
            self.nearbyUsers = [nearbyUsersQuery findObjects];
        }
        // now we have nearby users
        
        UITabBarController *tabController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
        [self.navigationController pushViewController:tabController animated:self.animateTransition];
        
//        if (self.viewState == BKNearbyListView) { // redirect to the appropriate list view controller
//            BKNearbyUsersTableViewController *nearbyUserListVC = [[BKNearbyUsersTableViewController alloc] initWithStyle:UITableViewStylePlain];
//            nearbyUserListVC.delegate = self;
//            
//            nearbyUserListVC.nearbyUsers = self.nearbyUsers;
//            [self.navigationController pushViewController:nearbyUserListVC animated:self.animateTransition];
//        } else if (self.viewState == BKNearbyMapsView) { // redirect to maps
//            BKNearbyUsersMapController *nearbyUsersMapVC = [[BKNearbyUsersMapController alloc] initWithNibName:nil bundle:nil];
//            nearbyUsersMapVC.delegate = self;
//
//            nearbyUsersMapVC.nearbyUsers = self.nearbyUsers;
//            [self.navigationController pushViewController:nearbyUsersMapVC animated:self.animateTransition];
//        } else if (self.viewState == BKNearbyBooksView) {// redirect to books
//            BKNearbyBooksViewController *nearbyBookVC = (BKNearbyBooksViewController *)[self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"bookController"];
//            //[[BKNearbyBooksViewController alloc] initWithNibName:nil bundle:nil];
//            nearbyBookVC.delegate = self;
//            nearbyBookVC.nearbyUsers = self.nearbyUsers;
//            
//            [self.navigationController pushViewController:nearbyBookVC animated:self.animateTransition];
//        }
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
