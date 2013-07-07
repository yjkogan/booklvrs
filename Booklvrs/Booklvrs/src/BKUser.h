//
//  BKUser.h
//  
//
//  Created by Romotive on 7/7/13.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface BKUser : NSObject

@property (strong, nonatomic) PFObject *parseUser;
@property (strong, nonatomic) NSArray *nearbyUsers;

+ (BKUser *)currentUser;
+ (PFObject *)parseUserWithGoodreadsID:(NSString *)goodreadsID;

@end
