//
//  UIChatViewController.m
//  Booklvrs
//
//  Created by Romotive on 5/19/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKChatViewController.h"

@interface BKChatViewController ()

@property (strong,nonatomic) NSMutableArray *messages;
@property (nonatomic) CGPoint messageBoxNaturalCenter;
@property (strong,nonatomic) UITableView *chatTableView;

@end

@implementation BKChatViewController

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
    NSArray *messageInfo = [[NSArray alloc] initWithObjects:@"notYou",@"I love Ender's game too!", nil];
    NSArray *messageKeys = [[NSArray alloc] initWithObjects:@"sender",@"text", nil];
    NSDictionary *message = [[NSDictionary alloc] initWithObjects:messageInfo forKeys:messageKeys];
    self.messages = [[NSMutableArray alloc] initWithObjects:message, nil];
    self.navigationItem.title = [NSString stringWithFormat:@"%@", [self.user objectForKey:@"name"]];

    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.frame];
    background.image = [UIImage imageNamed:@"iphone_splash_nobuttons.png"];
    [self.view addSubview:background];
    
    UITextField *messageBox = [[UITextField alloc] initWithFrame:CGRectMake(5.0,
                                                                         self.view.frame.size.height - 75.0,
                                                                         self.view.frame.size.width - 10.0,
                                                                          30.0)];
    [messageBox setBorderStyle:UITextBorderStyleRoundedRect];

    messageBox.returnKeyType = UIReturnKeySend;
    messageBox.delegate = self;
    [self.view addSubview:messageBox];
    self.messageBoxNaturalCenter = messageBox.center;
    
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                               5.0,
                                                                               self.view.frame.size.width,
                                                                               messageBox.frame.origin.y - 2*5.0)
                                                              style:UITableViewStylePlain];
    
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.chatTableView.backgroundView = nil;
    self.chatTableView.backgroundColor = [UIColor clearColor];
    [self.chatTableView setSeparatorColor:[UIColor blackColor]];
    
    [self.view addSubview:self.chatTableView];
}

#pragma mark --UITextField Delegate--

- (BOOL)textFieldShouldReturn:(UITextField *)textField {


    
    NSArray *messageInfo = [[NSArray alloc] initWithObjects:@"You",textField.text, nil];
    NSArray *messageKeys = [[NSArray alloc] initWithObjects:@"sender",@"text", nil];
    NSDictionary *message = [[NSDictionary alloc] initWithObjects:messageInfo forKeys:messageKeys];
    
    [self.messages addObject:message];
    
    textField.text = @"";
    
    [textField resignFirstResponder];
    textField.center = self.messageBoxNaturalCenter;
    [self.chatTableView reloadData];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.center = CGPointMake(self.view.center.x,self.view.center.y - 13.0);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *message = [self.messages objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [message objectForKey:@"text"];
    cell.textLabel.font = [UIFont fontWithName:@"Courier" size:18];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    if  ([[message objectForKey:@"sender"] isEqualToString:@"notYou"]) {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
