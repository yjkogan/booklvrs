//
//  BKMainViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKMainViewController.h"
#import "BKLogInViewController.h"
#import "BKAppDelegate.h"
#import "BKNearbyUsersTableViewController.h"
#import "BKNearbyUsersMapController.h"
#import "BKNearbyBooksViewController.h"
#import <Parse/Parse.h>

@interface BKMainViewController ()

@property (nonatomic) BKNearbyViewState viewState;
@property (nonatomic) BOOL animateTransition;
@property (strong, nonatomic) NSArray *nearbyUsers;
@property (weak, nonatomic) PFObject *currentUser;

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
    
    if (!self.currentUser) { // not logged in
        self.logInViewController.delegate = self;
        [self presentViewController:self.logInViewController animated:NO completion:nil];
    } else {
        
        if (!self.nearbyUsers) { // make sure nearby users is populated
            PFQuery *nearbyUsersQuery = [PFQuery queryWithClassName:@"GoodreadsUser"];
            
            [nearbyUsersQuery whereKey:@"GoodreadsID"
                            notEqualTo:[self.currentUser objectForKey:@"GoodreadsID"]];
            self.nearbyUsers = [nearbyUsersQuery findObjects];
        }
        
        // now we have nearby users
        
        UITabBarController *tabController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
        [self.navigationController pushViewController:tabController animated:self.animateTransition];
    }
}

#pragma mark -- LogInView Delegate Methods --
- (void)logInViewController:(BKLogInViewController *)controller didLogInUser:(PFObject *)user {
    if (user) {
        self.currentUser = user;
        ((BKAppDelegate *)[[UIApplication sharedApplication] delegate]).currentUser = user;
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        //        UIAlertView // alert about how failed to create a user
    }
}

@end
