//
//  Apptimize.h
//  Apptimize
//
//  Created by Thorsten Blum on 4/23/13.
//  Copyright (c) 2013 Apptimize, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Availability.h>


#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_1
#error "The Apptimize library uses features only available in iOS SDK 5.1 and later."
#endif


typedef NS_ENUM(NSUInteger, ApptimizeLogLevel) {
    ApptimizeLogLevelVerbose,
    ApptimizeLogLevelDebug,
    ApptimizeLogLevelInfo,
    ApptimizeLogLevelWarn,
    ApptimizeLogLevelError,
    ApptimizeLogLevelOff, // default
};


@interface Apptimize : NSObject

+ (void)setUpWithApplicationKey:(NSString *)applicationKey;

+ (void)testWithExperimentID:(NSInteger)experimentID
                    baseline:(void (^)(void))baselineBlock
                  variations:(void (^)(void))firstVariation, ... NS_REQUIRES_NIL_TERMINATION;

+ (void)goalReachedWithID:(NSInteger)goalID;

+ (void)setLogLevel:(ApptimizeLogLevel)logLevel;

// Disabled by default. If enabled, keeps posting results in the background indefinitely until there are no more results to upload
+ (void)setAggressiveModeOn:(BOOL)aggressiveModeOn;

@end
