//
//  UIChatViewController.h
//  Booklvrs
//
//  Created by Romotive on 5/19/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface BKChatViewController : UITableViewController

@property (strong,nonatomic) PFObject *user;

@end
