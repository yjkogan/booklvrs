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
#import "OAuth1Controller.h"

@interface BKLogInViewController ()
@property (nonatomic, strong) OAuth1Controller *oauth1Controller;
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

- (OAuth1Controller *)oauth1Controller
{
    if (_oauth1Controller == nil) {
        _oauth1Controller = [[OAuth1Controller alloc] init];
    }
    return _oauth1Controller;
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    
    
    [self.oauth1Controller loginWithWebView:webView completion:^(NSDictionary *oauthTokens, NSError *error) {
        if (!error) {
            // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
            self.oauthToken = oauthTokens[@"oauth_token"];
            self.oauthTokenSecret = oauthTokens[@"oauth_token_secret"];
            
//            self.accessTokenLabel.text = self.oauthToken;
//            self.accessTokenSecretLabel.text = self.oauthTokenSecret;
        }
        else
        {
            NSLog(@"Error authenticating: %@", error.localizedDescription);
        }
        [self dismissViewControllerAnimated:YES completion: ^{
            self.oauth1Controller = nil;
        }];
    }];
}

@end
