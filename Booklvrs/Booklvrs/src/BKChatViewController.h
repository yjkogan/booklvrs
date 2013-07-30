//
//  UIChatViewController.h
//  Booklvrs
//
//  Created by Romotive on 5/19/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface BKChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong,nonatomic) PFObject *user;
@property (strong, nonatomic) IBOutlet UITextField *inputBox;

@end
