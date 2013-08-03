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
#import "BKUser.h"
#import "GROAuth.h"

CGFloat kBookPadding = 12.5f;

@interface BKNearbyBooksViewController ()

@end

@implementation BKNearbyBooksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) loadBooks {

    self.books = [@[] mutableCopy];

    // For now we're pulling 5 covers for every nearby user...
    for (PFObject *nearbyUser in [BKUser currentUser].nearbyUsers) {
        NSDictionary *parameters = @{@"v": @(2),
                                       @"id": [nearbyUser objectForKey:@"goodreadsID"],
                                       @"sort": @"rating",
                                       @"per_page": @(5),
                                       @"key": [GROAuth consumerKey]};
        
        NSDictionary *reviews = [GROAuth dictionaryResponseForOAuthPath:@"review/list" parameters:parameters HTTPmethod:@"POST"];
        reviews = [reviews objectForKey:@"reviews"];
        
        for (NSDictionary *review in [reviews valueForKeyPath:@"review"]) {
            NSString *coverURL = [review valueForKeyPath:@"book.image_url"];
            // Only add the cover if goodreads has a cove
            if ([coverURL rangeOfString:@"nocover"].location == NSNotFound) {
                UIImage *bookCover = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:coverURL]]];
                NSDictionary *coverDict = [NSDictionary dictionaryWithObjectsAndKeys:nearbyUser,@"user",bookCover,@"coverImage", nil];
                [self.books addObject:coverDict];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadBooks];
//    self.navigationItem.title = @"Recommended";
//    self.navigationItem.hidesBackButton = YES;
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground.jpg"]];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.books.count;
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
//    return [self.searches count];
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BKBookCoverCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"book" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = [self.books[indexPath.row] objectForKey:@"coverImage"];
    return cell;
}
// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

// 5
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *nearbyUser = [[self.books objectAtIndex:indexPath.row] objectForKey:@"user"];
    BKProfileViewController *profileVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"profile"];
    profileVC.user = nearbyUser;
    [self.navigationController pushViewController:profileVC animated:YES];
}

@end
