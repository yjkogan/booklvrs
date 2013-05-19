//
//  BKNearbyBooksViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/19/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKNearbyBooksViewController.h"
#import "BKProfileViewController.h"
#import <Parse/Parse.h>

CGFloat kBookPadding = 12.5f;

@interface BKNearbyBooksViewController ()

@end

@implementation BKNearbyBooksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(toggleMaps:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(toggleList:)];
    }
    return self;
}

- (void) toggleMaps: (id) sender {
    [self.delegate changeToMapViewFrom:self];
}

- (void) toggleList: (id) sender {
    [self.delegate changeToListViewFrom:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Recommended";
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIScrollView *containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground.jpg"]];

    [self addBookCovers:containerView];
    [self.view addSubview:containerView];
}

- (void)addBookCovers:(UIScrollView *)containerView {
    
    
    
    CGFloat kBookWidth = 90.0f;
    CGFloat kBookHeight = 139.0f;
    CGFloat xPosition = kBookPadding;
    CGFloat yPosition = kBookPadding;
    
    NSArray *firstRow = [[NSArray alloc] initWithObjects:@"cover_1984.png", @"cover_casual_vacancy.png", @"cover_catcher_in_the_rye.png", nil];
    NSArray *secondRow = [[NSArray alloc] initWithObjects:@"cover_clockwork_orange.png", @"endersgame.jpg", @"cover_delivering_happiness.png", nil];
    NSArray *thirdRow = [[NSArray alloc] initWithObjects:@"cover_collapse.png", @"cover_gone_girl.png", @"cover_hunger_games.png", nil];
    NSArray *fourthRow = [[NSArray alloc] initWithObjects:@"cover_in_cold_blood.png", @"cover_invisible_man.png", @"cover_kite_runner.png", nil];
    NSArray *fifthRow = [[NSArray alloc] initWithObjects:@"cover_lean_in.png", @"cover_lean_startup.png", @"cover_made_to_stick.png", nil];
    NSArray *sixthRow = [[NSArray alloc] initWithObjects:@"cover_predictably_irrational.png", @"cover_rise_of_creative_class.png", @"cover_white_teeth.png", nil];
    NSArray *seventhRow = [[NSArray alloc] initWithObjects:@"cover_stumbling_upon_happiness.png", @"for-whom-the-bell-tolls.jpg", nil];
    
    NSArray *bookCovers = [[NSArray alloc] initWithObjects:firstRow,
                           secondRow,
                           thirdRow,
                           fourthRow,
                           fifthRow,
                           sixthRow,
                           seventhRow,
                           nil];
    
    UITapGestureRecognizer *tapEndersGame = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showYK:)];
    
    for (NSArray *bookRow in bookCovers) {
        for (NSString *book in bookRow) {
            UIImageView *bookCover = [[UIImageView alloc] initWithFrame:CGRectMake(xPosition, yPosition, kBookWidth, kBookHeight)];
            bookCover.image = [UIImage imageNamed:book];
            
            if ([book isEqualToString:@"endersgame.jpg"]) {
                bookCover.userInteractionEnabled = YES;
                [bookCover addGestureRecognizer:tapEndersGame];
            }
            
            [containerView addSubview:bookCover];
            xPosition += kBookWidth + kBookPadding;
        }
        xPosition = kBookPadding;
        yPosition += kBookHeight + kBookPadding;
    }
    
    containerView.contentSize = CGSizeMake(self.view.frame.size.width, yPosition + 3*kBookPadding);

}

- (void)showYK:(id)sender {
    BKProfileViewController *profileVC = [[BKProfileViewController alloc] initWithNibName:nil bundle:nil];    
    for (PFUser *nearbyUser in self.nearbyUsers) {
        if ([[nearbyUser objectForKey:@"facebookId"] isEqualToString:@"1055040075"]) {
            profileVC.user = nearbyUser;
            return [self.navigationController pushViewController:profileVC animated:YES];
        }
    }
}

@end
