//
//  BKUser.m
//  
//
//  Created by Romotive on 7/7/13.
//
//

#import "BKUser.h"

@implementation BKUser

+ (BKUser *)currentUser {

    static BKUser *currentUser = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentUser = [[self alloc] init];
    });
    
    return currentUser;
}

- init {
  
    if (self = [super init]) {
        
    }
    
    return self;
}

@end
