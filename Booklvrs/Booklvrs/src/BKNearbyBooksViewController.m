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
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground.jpg"]];

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
