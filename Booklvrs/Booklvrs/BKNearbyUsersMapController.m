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

#define ARC4RANDOM_MAX      0x100000000

CGFloat nycLat = 40.753083;
CGFloat nycLon = -73.989281;

@interface BKNearbyUsersMapController()
    
@property (nonatomic) BOOL isSimulator;

@end

@implementation BKNearbyUsersMapController

@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(toggleMaps:)];
    }
    return self;
}

- (void) toggleMaps: (id) sender {
    [self.delegate changeToListViewFrom:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Nearby Users";
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
    self.mapView.delegate = self;
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
    
    for (PFUser *nearbyUser in self.nearbyUsers) {
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
        for (PFUser *nearbyUser in self.nearbyUsers) {
            if ([[nearbyUser objectForKey:@"name"] isEqualToString:title]) {
                profileVC.user = nearbyUser;
                return [self.navigationController pushViewController:profileVC animated:YES];
            }
        }
    }
}

@end
