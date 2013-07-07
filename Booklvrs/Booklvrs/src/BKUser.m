//
//  BKUser.m
//  
//
//  Created by Romotive on 7/7/13.
//
//

#import "BKUser.h"
#import "GROAuth.h"

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
        self.nearbyUsers = [NSArray array];
    }
    
    return self;
}

+ (PFObject *)parseUserWithGoodreadsID:(NSString *)goodreadsID {
    PFQuery *userQuery = [PFQuery queryWithClassName:@"GoodreadsUser"];
    [userQuery whereKey:@"goodreadsID" equalTo:goodreadsID];
    PFObject *object = [userQuery getFirstObject];
    if (object) {
        return object;
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:goodreadsID,@"id",[GROAuth consumerKey],@"key",nil];
        NSDictionary *result = [GROAuth dictionaryResponseForNonOAuthPath:@"user/show" parameters:parameters];
        NSDictionary *user = [result objectForKey:@"user"];
        
          PFObject *goodreadsUser = [PFObject objectWithClassName:@"GoodreadsUser"];
            [goodreadsUser setObject:[user objectForKey:@"name"] forKey:@"name"];
            [goodreadsUser setObject:goodreadsID forKey:@"goodreadsID"];
        
            if ([goodreadsUser save]) {
                return goodreadsUser;
            } else {
                return nil;
            }
    }
    return nil;
}

@end
