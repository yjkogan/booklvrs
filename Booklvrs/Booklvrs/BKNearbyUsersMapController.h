//
//  BKNearbyUsersMapController.h
//  Booklvrs
//
//  Created by Zachary Fisher on 5/18/13.
//  Copyright (c) 2013 Booklvrs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class BKNearbyUsersMapController;

@protocol BKNearbyUsersMapControllerDelegate <NSObject>

- (void)changeToListViewFrom:(UIViewController *)controller;
- (void)changeToBooksViewFrom:(UIViewController *)controller;

@end

@interface BKNearbyUsersMapController : UIViewController <MKMapViewDelegate>

@property (strong,nonatomic) MKMapView *mapView;
@property (strong,nonatomic) NSArray *nearbyUsers;
@property (weak, nonatomic) id<BKNearbyUsersMapControllerDelegate> delegate;

@end
