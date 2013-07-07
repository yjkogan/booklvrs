//
//  BKMainViewController.h
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "BKLogInViewController.h"
#import "BKNearbyUsersMapController.h"
#import "BKNearbyUsersTableViewController.h"
#import "BKNearbyBooksViewController.h"
#import "BKTabBarController.h"

typedef enum BKNearbyViewState {
    BKNearbyMapsView,
    BKNearbyListView,
    BKNearbyBooksView
} BKNearbyViewState;

@interface BKMainViewController : UIViewController <BKLogInViewDelegate>

@property (weak, nonatomic) IBOutlet BKLogInViewController *logInViewController;

@end
