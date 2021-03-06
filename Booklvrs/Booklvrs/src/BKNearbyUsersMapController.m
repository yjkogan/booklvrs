//
//  BKNearbyUsersMapController.m
//  Booklvrs
//
//  Created by Zachary Fisher on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import "BKNearbyUsersMapController.h"
#import "BKProfileViewController.h"
#import <Parse/Parse.h>
#import "BKUser.h"

#define ARC4RANDOM_MAX      0x100000000

CGFloat nycLat = 40.753083;
CGFloat nycLon = -73.989281;

@interface BKNearbyUsersMapController()
    
@property (nonatomic) BOOL isSimulator;

@end

@implementation BKNearbyUsersMapController

@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(![self.mapView userLocation].location) {
        self.isSimulator = YES;
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
        MKCoordinateSpan span = MKCoordinateSpanMake(0.03f, 0.03f);
        CLLocationCoordinate2D coordinate = {nycLat,nycLon};
        MKCoordinateRegion region = {coordinate, span};
        
        MKCoordinateRegion regionThatFits = [self.mapView regionThatFits:region];
        
        [self.mapView setRegion:regionThatFits animated:YES];
    }
    
    [self.view addSubview:mapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinate;
    // Add an annotation
    if (self.isSimulator) {
        CLLocationCoordinate2D nyc = {nycLat,nycLon};
        coordinate = nyc;
    } else {
        coordinate = userLocation.coordinate;
    }

    point.coordinate = coordinate;
    point.title = @"Your location";
    
    [self.mapView addAnnotation:point];
    
    for (PFObject *nearbyUser in [BKUser currentUser].nearbyUsers) {
        MKPointAnnotation *userPoint = [[MKPointAnnotation alloc] init];
        CGFloat offsetx = ((double)arc4random() / ARC4RANDOM_MAX) * .01f;
        CGFloat offsety = ((double)arc4random() / ARC4RANDOM_MAX) * .01f;
        CLLocationCoordinate2D userCoordinate = {nycLat + offsetx,nycLon + offsety};
        userPoint.coordinate = userCoordinate;
        userPoint.title = [nearbyUser objectForKey:@"name"];
        
        [self.mapView addAnnotation:userPoint];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSString *title = view.annotation.title;
    if (![title isEqualToString:@"Your location"]) {
        
        BKProfileViewController *profileVC = [[BKProfileViewController alloc] initWithNibName:nil bundle:nil];
        for (PFObject *nearbyUser in [BKUser currentUser].nearbyUsers) {
            if ([[nearbyUser objectForKey:@"name"] isEqualToString:title]) {
                profileVC.user = nearbyUser;
                return [self.navigationController pushViewController:profileVC animated:YES];
            }
        }
    }
}

@end
