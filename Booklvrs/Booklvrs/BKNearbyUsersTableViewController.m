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

@interface BKNearbyUsersTableViewController ()

@end

@implementation BKNearbyUsersTableViewController

@synthesize mapsButtonItem;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.mapsButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(toggleMaps:)];
    }
    return self;
}

- (void) toggleMaps: (id) sender {
    NSLog(@"hello");
    BKNearbyUsersMapController *mapVC = [[BKNearbyUsersMapController alloc] initWithNibName:nil bundle:nil];
//    profileVC.user = [self.nearbyUsers objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:mapVC animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = self.mapsButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.nearbyUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PFUser *user = [self.nearbyUsers objectAtIndex:indexPath.row];
    
    NSString *profilePicPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small", [user objectForKey:@"facebookId"]];
    
    [FBRequestConnection startWithGraphPath:profilePicPath completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        }
        NSLog(@"%@",result);
    }];
    
    cell.textLabel.text = [user objectForKey:@"name"];
    
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
    BKProfileViewController *profileVC = [[BKProfileViewController alloc] initWithNibName:nil bundle:nil];
    profileVC.user = [self.nearbyUsers objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:profileVC animated:YES];
}

@end
