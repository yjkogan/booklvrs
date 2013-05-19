//
//  BKProfileViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKProfileViewController.h"
#import "BKAppDelegate.h"
#import "XMLDictionary.h"
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
    
    UIBarButtonItem *chatBtn = [[UIBarButtonItem alloc] initWithTitle:@"Message" style:UIBarButtonItemStylePlain target:self action:@selector(chatSelectUser:)];
    self.navigationItem.rightBarButtonItem = chatBtn;

    NSString *key = ((BKAppDelegate *)[[UIApplication sharedApplication] delegate]).goodReadsKey;
    NSString *username = [self.user objectForKey:@"GoodReadsUsername"];
    NSString *url = [NSString stringWithFormat:@"http://www.goodreads.com/user/show/?key=%@&username=%@", key, username];
    NSString *response = [self getDataFrom:url];
    
    self.goodReadsUserInfo = [NSDictionary dictionaryWithXMLString:response];
    
    UIScrollView *containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    
    containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground.jpg"]];
    containerView.scrollEnabled = YES;
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 100, kViewPadding, 200.0, 30.0)];
    userName.text = [self.user objectForKey:@"name"];
    userName.font = [UIFont fontWithName:@"Courier-Bold" size:24.0];
    userName.textAlignment = NSTextAlignmentCenter;
    userName.backgroundColor = [UIColor clearColor];
    [containerView addSubview:userName];
    
    NSString *profilePicPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=180&height=180", [self.user objectForKey:@"facebookId"]];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profilePicPath]]];
    
    UIImageView *profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-90,
                                                                             userName.frame.origin.y + userName.frame.size.height + kViewPadding,
                                                                             180.0,
                                                                              180.0)];
    profileImage.layer.masksToBounds = YES;
    profileImage.layer.cornerRadius = 45.0f;
    profileImage.image = image;
    
    [containerView addSubview:profileImage];
   
    UILabel *lookingFor = [[UILabel alloc] initWithFrame:CGRectMake(kViewPadding,
                                                                   profileImage.frame.origin.y + profileImage.frame.size.height + kViewPadding,
                                                                   self.view.frame.size.width - 2*kViewPadding,
                                                                    30.0)];
    lookingFor.text = [NSString stringWithFormat:@"Relationship Status: %@", [self.user objectForKey:@"LookingFor"]];
    lookingFor.backgroundColor = [UIColor clearColor];
    lookingFor.textAlignment = NSTextAlignmentCenter;
    lookingFor.font = [UIFont fontWithName:@"Courier-Bold" size:18.0];
    [containerView addSubview:lookingFor];
    
    self.favoriteAuthors = [[NSMutableArray alloc] init];
    
    for (NSDictionary *author in [self.goodReadsUserInfo valueForKeyPath:@"user.favorite_authors.author"]) {
        // There is a bug here if the user has less than two favorite authors
        [self.favoriteAuthors addObject:[author valueForKeyPath:@"name"]];
    }
    
    self.reviewedBooks = [[NSMutableArray alloc] init];
    for(NSDictionary *review in [self.goodReadsUserInfo valueForKeyPath:@"user.updates.update"]) {
        if ([[review valueForKeyPath:@"_type"] isEqualToString:@"review"]) {
            [self.reviewedBooks addObject:[review valueForKeyPath:@"object.book.title"]];
        }
    }
    
    UITableView *goodReadsTableView = [[UITableView alloc] initWithFrame:CGRectMake(kViewPadding,
                                                                                    profileImage.frame.origin.y + profileImage.frame.size.height + 4*kViewPadding,
                                                                                    self.view.frame.size.width - 2*kViewPadding,
                                                                                    0) style:UITableViewStyleGrouped];
    
    goodReadsTableView.delegate = self;
    goodReadsTableView.dataSource = self;
    goodReadsTableView.backgroundView = nil;
    goodReadsTableView.backgroundColor = [UIColor clearColor];
    goodReadsTableView.userInteractionEnabled = NO;
    
    [goodReadsTableView layoutIfNeeded];
    goodReadsTableView.frame = CGRectMake(goodReadsTableView.frame.origin.x,
                                          goodReadsTableView.frame.origin.y,
                                          goodReadsTableView.frame.size.width,
                                          goodReadsTableView.contentSize.height);
    
    [containerView addSubview:goodReadsTableView];
    
    CGFloat contentHeight = goodReadsTableView.contentSize.height + goodReadsTableView.frame.origin.y + 44.0;
    
    containerView.contentSize = CGSizeMake(self.view.frame.size.width,
                                           contentHeight);
    
    [self.view addSubview:containerView];
}

- (NSString *)getDataFrom:(NSString *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

#pragma mark - chat btn tapped

- (void)chatSelectUser:(id)sender {
    
    BKChatViewController *chatVC = [[BKChatViewController alloc] initWithNibName:nil bundle:nil];
    chatVC.user = self.user;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return self.favoriteAuthors.count;
    } else if (section==1) {
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
    if (indexPath.section == 0) {
        cell.textLabel.text = [self.favoriteAuthors objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [self.reviewedBooks objectAtIndex:indexPath.row];
        if([cell.textLabel.text isEqualToString:@"Lean In: Women, Work, and the Will to Lead"]) {
            UIImage *image = [UIImage imageNamed:@"cover_lean_in.png"];
            cell.imageView.image = image;
        } else if([cell.textLabel.text isEqualToString:@"The Casual Vacancy"]) {
            UIImage *image = [UIImage imageNamed:@"cover_casual_vacancy.png"];
            cell.imageView.image = image;
        } else if ([cell.textLabel.text isEqualToString:@"A Clockwork Orange"]) {
            UIImage *image = [UIImage imageNamed:@"cover_clockwork_orange.png"];
            cell.imageView.image = image;
        } else if ([cell.textLabel.text isEqualToString:@"For Whom the Bell Tolls"]) {
            UIImage *image = [UIImage imageNamed:@"for-whom-the-bell-tolls.jpg"];
            cell.imageView.image = image;
        } else if ([cell.textLabel.text isEqualToString:@"Ender's Game (Ender's Saga, #1)"]) {
            UIImage *image = [UIImage imageNamed:@"endersgame.jpg"];
            cell.imageView.image = image;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"Favorite Authors";
    } else if (section==1) {
        return @"Favorite Books";
    }
    return @"";
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
