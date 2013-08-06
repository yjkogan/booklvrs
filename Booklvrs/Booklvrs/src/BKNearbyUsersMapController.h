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

@interface BKNearbyUsersMapController : UIViewController <MKMapViewDelegate>

@property (strong,nonatomic) IBOutlet MKMapView *mapView;

@end
