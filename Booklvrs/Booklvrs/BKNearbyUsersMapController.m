//
//  BKNearbyUsersMapController.m
//  Booklvrs
//
//  Created by Zachary Fisher on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKNearbyUsersMapController.h"

@implementation BKNearbyUsersMapController

@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"hello, world!");
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    
//    NSString *key = ((BKAppDelegate *)[[UIApplication sharedApplication] delegate]).goodReadsKey;
//    NSString *username = [self.user objectForKey:@"GoodReadsUsername"];
//    NSString *url = [NSString stringWithFormat:@"http://www.goodreads.com/user/show/?key=%@&username=%@", key, username];
//    NSString *response = [self getDataFrom:url];
//    
//    self.goodReadsUserInfo = [NSDictionary dictionaryWithXMLString:response];
//    
//    NSLog(@"%@", [self.goodReadsUserInfo valueForKeyPath:@"user.name"]);
//    for (NSDictionary *author in [self.goodReadsUserInfo valueForKeyPath:@"user.favorite_authors.author"]) {
//        NSLog(@"%@",[author valueForKeyPath:@"name"]);
//    }
//    
//    UIScrollView *containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
//    containerView.backgroundColor = [UIColor redColor];
//    
//    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x - 100, 5.0, 200.0, 40.0)];
//    userName.text = [self.goodReadsUserInfo valueForKeyPath:@"user.name"];
//    userName.textAlignment = NSTextAlignmentCenter;
//    [containerView addSubview:userName];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
    if(![self.mapView userLocation].location) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01f, 0.01f);
        CLLocationCoordinate2D coordinate = {40.753083,-73.989281};
        MKCoordinateRegion region = {coordinate, span};
        
        
        MKCoordinateRegion regionThatFits = [self.mapView regionThatFits:region];
        
        MKAnnotationView *nycLocation = [MKAnnotationView alloc] initWithAnnotation:<#(id<MKAnnotation>)#> reuseIdentifier:<#(NSString *)#>
        
        [self.mapView setRegion:regionThatFits animated:YES];
//        CLLocationCoordinate2D NYC = {40.753083,-73.989281};
//        mapView.centerCoordinate = NYC;
    }
    
    [self.view addSubview:mapView];
}

@end
