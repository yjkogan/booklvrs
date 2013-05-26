//
//  BKNearbyBooksViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/19/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKNearbyBooksViewController.h"
#import "BKProfileViewController.h"
#import "BKBookCoverCell.h"
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

- (void) loadBooks {
    self.books = [@[] mutableCopy];
    NSString *imageDirectoryPath = [[NSBundle mainBundle] resourcePath];
    NSLog(@"dir path is %@", imageDirectoryPath);
    NSArray *imageFiles = [NSBundle pathsForResourcesOfType:@".png" inDirectory:imageDirectoryPath];
    for ( NSString* imageFile in imageFiles) {
        if ([imageFile rangeOfString:@"/cover_"].location != NSNotFound) {
            [self.books addObject:[UIImage imageWithContentsOfFile:imageFile]];
        }
//        NSLog(@"%@",imageFile);
    }
    NSLog(@"books: %@", self.books);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBooks];
//    [self.collectionView registerClass:[BKBookCoverCell class] forCellWithReuseIdentifier:@"book"];
//    [self.collectionView setBackgroundColor:[UIColor colorWithPatternImage:self.books[1]]];
    self.navigationItem.title = @"Recommended";
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    UIScrollView *containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
//    containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground.jpg"]];

//    [self addBookCovers:containerView];
//    [self.view addSubview:containerView];
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

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.books.count;
//    NSString *searchTerm = self.searches[section];
//    return [self.searchResults[searchTerm] count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
//    return [self.searches count];
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BKBookCoverCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"book" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor colorWithPatternImage:self.books[indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
//    NSLog(@"indexpath section:");
//    NSLog(@"self.books[indexPath.row] = %@", self.books[indexPath.row]);
    cell.imageView.image = self.books[indexPath.row];
    return cell;
}
// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

@end
