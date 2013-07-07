//
//  BKLogInViewController.h
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import <Parse/Parse.h>

@class BKLogInViewController;

@protocol BKLogInViewDelegate <NSObject>

- (void)logInViewController:(BKLogInViewController *)controller didLogInUser:(PFUser *)user;

@end

@interface BKLogInViewController : UIViewController

@property (weak,nonatomic) IBOutlet id<BKLogInViewDelegate> delegate;

@end
