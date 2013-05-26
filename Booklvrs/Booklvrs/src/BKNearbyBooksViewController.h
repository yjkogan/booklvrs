//
//  BKNearbyBooksViewController.h
//  Booklvrs
//
//  Created by Romotive on 5/19/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BKNearbyBooksViewController;

@protocol BKNearbyBooksViewControllerDelegate <NSObject>

- (void)changeToListViewFrom:(UIViewController *)controller;
- (void)changeToMapViewFrom:(UIViewController *)controller;

@end

@interface BKNearbyBooksViewController : UIViewController

@property (strong,nonatomic) NSArray *nearbyUsers;
@property (weak, nonatomic) id<BKNearbyBooksViewControllerDelegate> delegate;

@end
