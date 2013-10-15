#import "KATrackDetailViewController.h"

@interface KATrackDetailViewController ()
@property (nonatomic) NSDictionary *track;
@property (nonatomic) UIToolbar *backgroundView;
@end

@implementation KATrackDetailViewController

- (id)initWithTrack:(NSDictionary *)dict;
{
    self = [super init];
    if (self) {
        self.track = dict;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor clearColor];
 
    self.backgroundView = [[UIToolbar alloc] init];
    self.backgroundView.barStyle = UIBarStyleBlack;
    [self.view addSubview:self.backgroundView];
}

- (void)viewDidLayoutSubviews
{
    self.backgroundView.frame = self.view.bounds;
}
     
@end
