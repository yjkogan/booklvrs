//
//  BKLogInViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKLogInViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "GROAuth.h"
#import "BKUser.h"
#import "Leanplum.h"

DEFINE_VAR_FLOAT(Powerups_Speed_Price, 10);

@interface BKLogInViewController ()
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;
@end

@implementation BKLogInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    backgroundImage.image = [UIImage imageNamed:@"iphone_4_splash.jpg"];
    
    UIImageView *facebookBtn = [[UIImageView alloc] initWithFrame:CGRectMake(50,380,self.view.frame.size.width - 100,40)];
    facebookBtn.image = [UIImage imageNamed:@"fb_button.png"];
    facebookBtn.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *loginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logInBtnTapped:)];
    [facebookBtn addGestureRecognizer:loginTap];
    
    [self.view addSubview:backgroundImage];
    [self.view addSubview:facebookBtn];
}

- (void)logInBtnTapped:(id)sender {
    
    [GROAuth loginWithGoodreadsWithCompletion:^(NSDictionary *authParams, NSError *error) {
        NSDictionary *result = [GROAuth dictionaryResponseForOAuthPath:@"api/auth_user" parameters:nil HTTPmethod:@"GET"];
        NSDictionary *user = [result objectForKey:@"user"];
        
        // See if this user already exists
        NSString *goodreadsID = [user objectForKey:@"_id"];
        [self.delegate logInViewController:self didLogInUser: [BKUser parseUserWithGoodreadsID:goodreadsID]];
    }];
}

@end
