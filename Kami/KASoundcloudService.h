#import <Foundation/Foundation.h>

typedef enum {
    KAErrorCodeInvalidJson,
    KAErrorCodeUnableToParseResponse,
    KAErrorCodeUserCancelledLogin
} KAErrorCode;

@interface KASoundcloudService : NSObject
+ (instancetype)sharedInstance;

- (RACSignal*)fetchStream;
- (void)logout;
@end
