//
//  BKProfileViewController.h
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface BKProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) PFObject *user;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@end
