//
//  BKNearbyUsersTableViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKNearbyUsersTableViewController.h"
#import "BKNearbyUsersMapController.h"
#import "BKProfileViewController.h"
#import "BKUser.h"

@interface BKNearbyUsersTableViewController ()

@end

@implementation BKNearbyUsersTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.title = @"Nearby Users";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"booklvrs_bkground_new.png"]];
    [self.tableView setSeparatorColor:[UIColor blackColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [BKUser currentUser].nearbyUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PFUser *user = [[BKUser currentUser].nearbyUsers objectAtIndex:indexPath.row];
    
    NSString *profilePicPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [user objectForKey:@"facebookId"]];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profilePicPath]]];
    
    UIImageView *accessoryArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,25,25)];
    accessoryArrow.image = [UIImage imageNamed:@"booklvrs_arrow_blue.png"];
    
    cell.imageView.image = image;
    cell.accessoryView = accessoryArrow;
    cell.textLabel.text = [user objectForKey:@"name"];
    
    // Experiment "BooklvrsTest"
    [Apptimize testWithExperimentID:982 baseline:^{
        // Baseline variation "White Cell Background"
        cell.backgroundColor = [UIColor whiteColor];
    } variations:^{
        // Variation "Blue Cell Background"
        cell.backgroundColor = [UIColor blueColor];
    }, ^{
        // Variation "Light Gray Cell Background"
        cell.backgroundColor = [UIColor lightGrayColor];
    }, nil];
    
    return cell;
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
    // Goal "Click a cell"
    [Apptimize goalReachedWithID:1777];
    
    BKProfileViewController *profileVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"profile"];
    profileVC.user = [[BKUser currentUser].nearbyUsers objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:profileVC animated:YES];
}

@end
