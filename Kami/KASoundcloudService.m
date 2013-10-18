#import "KASoundcloudService.h"
#import <CocoaSoundCloudAPI/SCAPI.h>
#import <CocoaSoundCloudUI/SCUI.h>
#import "KAAppDelegate.h"
#import <EnumeratorKit/EnumeratorKit.h>

#define SC_ID @"b084c1b817da22667cbde63f0da77255"
#define SC_SECRET @"6183cad44bbef2b8d75f4624881afd3b"

#define MIN_DURATION 30 * 60 * 1000 // 30 minutes
#define ERROR_DOMAIN @"au.com.rayh.soundcloud.error"
@implementation KASoundcloudService

+ (instancetype)sharedInstance
{
    static KASoundcloudService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KASoundcloudService alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    if(self = [super init])
    {
        [SCSoundCloud setClientID:SC_ID
                           secret:SC_SECRET
                      redirectURL:[NSURL URLWithString:@"au.com.rayh.soundcloud.Kami://oauth"]];
    }
    return self;
}

- (void)displayNotAuthenticatedAlert
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Auth Error"
                          message:@"Unable to login, please check your credentials and network access"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (void)logout
{
    [SCSoundCloud removeAccess];
}

- (RACSignal *)authenticate
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if([SCSoundCloud account])
        {
            [subscriber sendNext:[SCSoundCloud account]];
            return nil;
        }
    
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
            KAAppDelegate *delegate = [UIApplication sharedApplication].delegate;
            
            SCLoginViewController *loginViewController = [SCLoginViewController
                                   loginViewControllerWithPreparedURL:preparedURL
                                   completionHandler:^(NSError *error) {
                                       if (SC_CANCELED(error)) {
                                           NSLog(@"Canceled!");
                                           [subscriber sendError:[NSError errorWithDomain:ERROR_DOMAIN
                                                                                     code:KAErrorCodeUserCancelledLogin
                                                                                 userInfo:@{
                                                                                            NSLocalizedDescriptionKey:@"User cancelled the login"}]];

                                           // Do nothing
                                       } else if (error) {
                                           [self displayNotAuthenticatedAlert];
                                           NSLog(@"Error: %@", [error localizedDescription]);
                                           [subscriber sendError:error];
                                       } else {
                                           [subscriber sendNext:[SCSoundCloud account]];
                                       }
                                   }];
            
            [delegate.window.rootViewController presentViewController:loginViewController animated:YES completion:nil];
        }];
        
        return nil;
    }];
}

- (RACSignal*)fetchStream
{
    return [[self authenticate] flattenMap:^RACStream *(SCAccount *account) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

            NSString *resourceURL = @"https://api.soundcloud.com/tracks.json";
            [SCRequest performMethod:SCRequestMethodGET
                          onResource:[NSURL URLWithString:resourceURL]
                     usingParameters:@{@"bpm[from]":@"120", @"duration[from]":[@(MIN_DURATION) stringValue], @"filters":@"streamable"}
                         withAccount:account
              sendingProgressHandler:nil
                     responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                         @try {
                             NSError *jsonError = nil;
                             NSDictionary *activities = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                        options:0
                                                                                          error:&jsonError];
                             
                             if(jsonError)
                             {
                                 [subscriber sendError:jsonError];
                                 return;
                             }
                             
                             if(![activities isKindOfClass:[NSArray class]])
                             {
                                 [subscriber sendError:[NSError errorWithDomain:ERROR_DOMAIN
                                                                           code:KAErrorCodeInvalidJson
                                                                       userInfo:@{NSLocalizedDescriptionKey:@"JSON structure invalud"}]];
                                 return;
                             }
                         
                         
                             [subscriber sendNext:[activities filter:^BOOL(NSDictionary *obj) {
                                 return [obj valueForKeyPath:@"artwork_url"] != [NSNull null];
                             }]];
                         
                         }
                         @catch (NSException *exception) {
                             [subscriber sendError:[NSError errorWithDomain:ERROR_DOMAIN
                                                                       code:KAErrorCodeUnableToParseResponse
                                                                   userInfo:@{NSLocalizedDescriptionKey:[exception description], @"exception":exception}]];
                         }
                     }];
            
            return nil;
        }];
    }];
}


@end
