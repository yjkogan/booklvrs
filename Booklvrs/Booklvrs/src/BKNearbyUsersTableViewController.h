//
//  BKNearbyUsersTableViewController.h
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BKNearbyUsersTableViewController;

@protocol BKNearbyUsersTableViewControllerDelegate <NSObject>

- (void)changeToMapViewFrom:(UIViewController *)controller;
- (void)changeToBooksViewFrom:(UIViewController *)controller;

@end

@interface BKNearbyUsersTableViewController : UITableViewController

@property (strong,nonatomic) NSArray *nearbyUsers;
@property (strong) UIBarButtonItem *mapsButtonItem;
@property (weak, nonatomic) id<BKNearbyUsersTableViewControllerDelegate> delegate;

@end
