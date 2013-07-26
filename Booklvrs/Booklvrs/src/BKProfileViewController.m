//
//  BKProfileViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKProfileViewController.h"
#import "BKAppDelegate.h"
#import "GROAuth.h"
#import "BKChatViewController.h"
#import <QuartzCore/QuartzCore.h>

CGFloat kViewPadding = 5.0f;
CGFloat kCellViewHeight = 44.0f;

@interface BKProfileViewController ()

@property (strong,nonatomic) NSDictionary *goodReadsUserInfo;
@property (strong,nonatomic) NSMutableArray *favoriteAuthors;
@property (strong,nonatomic) NSMutableArray *reviewedBooks;

@end

@implementation BKProfileViewController

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
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *goodreadsID = [self.user objectForKey:@"goodreadsID"];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:goodreadsID, @"id", [GROAuth consumerKey], @"key", nil];
    NSDictionary *goodreadsUserInfo = [GROAuth dictionaryResponseForNonOAuthPath:@"user/show" parameters:parameters];
    
    NSString *profilePicPath = [goodreadsUserInfo valueForKeyPath:@"user.image_url"];
    self.profilePictureImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profilePicPath]]];

    self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.height/4;
    
    self.favoriteAuthors = [[NSMutableArray alloc] init];
    self.reviewedBooks = [[NSMutableArray alloc] init];
    
    for (NSDictionary *author in [goodreadsUserInfo valueForKeyPath:@"user.favorite_authors.author"]) {
        // less than two favorite authors = bug???
        [self.favoriteAuthors addObject: [author valueForKeyPath:@"name"]];
    }
    
    parameters = @{@"v": @(2),
                   @"id": goodreadsID,
                   @"sort": @"rating",
                   @"per_page": @(10),
                   @"key": [GROAuth consumerKey]};
    
    NSDictionary *reviews = [GROAuth dictionaryResponseForOAuthPath:@"review/list" parameters:parameters HTTPmethod:@"POST"];
    reviews = [reviews objectForKey:@"reviews"];
    
    for (NSDictionary *review in [reviews valueForKeyPath:@"review"]) {

        NSString *title = [review valueForKeyPath:@"book.title"];
        NSString *coverURL = [review valueForKeyPath:@"book.image_url"];
        [self.reviewedBooks addObject: @{@"title": title, @"cover": coverURL}];
    }

    self.navigationItem.title = [self.user objectForKey:@"name"];
    [self.chatBtn setTarget:self];
    [self.chatBtn setAction:@selector(chatBtnTapped:)];
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)chatBtnTapped:(id)sender {
    [self performSegueWithIdentifier:@"profileToChat" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        return self.favoriteAuthors.count;
    } else if (section==0) {
        return self.reviewedBooks.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 1) {
        cell.textLabel.text = [self.favoriteAuthors objectAtIndex:indexPath.row];
    } else if (indexPath.section == 0) {
        NSDictionary *book = [self.reviewedBooks objectAtIndex:indexPath.row];
        cell.textLabel.text = [book objectForKey:@"title"];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[book objectForKey:@"cover"]]]];
        cell.imageView.image = image;
    }
    
    [cell.textLabel setMinimumScaleFactor:10.0/[UIFont labelFontSize]];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @[@"Favorite Books", @"Favorite Authors"][section];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
