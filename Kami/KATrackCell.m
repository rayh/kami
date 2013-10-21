#import "KATrackCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <UIColor-Utilities/UIColor+Expanded.h>
#import "UIImage+KAUtilities.h"
#import <NSDate+TimeAgo/NSDate+TimeAgo.h>
#import "UIImageView+KAUtilities.h"

@interface KATrackCell ()
@property (nonatomic) UIImageView *waveformImageView;
@property (nonatomic) UIImageView *authorImageView;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UILabel *titleLabel;
@end

@implementation KATrackCell

+ (NSDateFormatter *)parsingDateFormatter
{
    static NSDateFormatter *parsingDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parsingDateFormatter = [[NSDateFormatter alloc] init];
        [parsingDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
    });
    
    return parsingDateFormatter;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.contentView.layer.cornerRadius = 3;
//        self.contentView.layer.borderWidth = 1;
//        self.contentView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
//        self.contentView.layer.masksToBounds = YES;
        
        self.artworkImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.artworkImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.artworkImageView];
        
        self.waveformImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.waveformImageView.alpha = 1.0;
        self.waveformImageView.contentMode = UIViewContentModeScaleToFill;
        self.waveformImageView.tintColor = [[UIColor colorWithRGBHex:0xf0570c] colorWithAlphaComponent:0.];
//        self.waveformImageView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.];
        [self.contentView addSubview:self.waveformImageView];
        
        self.authorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.authorImageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        self.authorImageView.layer.borderWidth = 1.;
        self.authorImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.authorImageView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        self.timeLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.timeLabel];
        
        UIInterpolatingMotionEffect *horizontalShift = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalShift.maximumRelativeValue=@(-10);
        horizontalShift.minimumRelativeValue=@(10);
        
        UIInterpolatingMotionEffect *verticalShift = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalShift.maximumRelativeValue=@(-10);
        verticalShift.minimumRelativeValue=@(10);
        
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        group.motionEffects = @[horizontalShift, verticalShift];

        [self.titleLabel addMotionEffect:group];
        [self.timeLabel addMotionEffect:group];
        [self.authorImageView addMotionEffect:group];
        [self.artworkImageView addMotionEffect:group];
        
    }
    return self;
}

- (void)layoutSubviews
{
    self.artworkImageView.frame = CGRectMake(20, 100, self.bounds.size.width-40, self.bounds.size.width-40);
    self.artworkImageView.layer.masksToBounds = YES;
    
    self.waveformImageView.frame = CGRectMake(0, 32., self.bounds.size.width, 44.);

    self.authorImageView.frame = CGRectMake(20.,CGRectGetMaxY(self.artworkImageView.frame) + 10., 32., 32.);
    self.authorImageView.layer.cornerRadius = 16.;
    
    self.timeLabel.frame = CGRectMake(62.,
                                      CGRectGetMaxY(self.artworkImageView.frame) + 10.,
                                      self.bounds.size.width - 62. - 20.,
                                      12);
    
    CGRect boundingRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width-5.-62.-20., CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:self.titleLabel.font}
                                                             context:nil];
    self.titleLabel.frame = CGRectMake(62.,
                                       CGRectGetMaxY(self.timeLabel.frame),
                                       self.bounds.size.width-5.-62.-20.,
                                       ceilf(boundingRect.size.height));
}

- (void)configureWithTrack:(NSDictionary*)activityItem
{
    NSDate *date = [[KATrackCell parsingDateFormatter] dateFromString:[activityItem valueForKey:@"created_at"]];
    self.timeLabel.text = [[NSString stringWithFormat:@"%@ by %@", [date timeAgo], [activityItem valueForKeyPath:@"user.username"]] uppercaseString];
    self.titleLabel.text = [activityItem valueForKeyPath:@"title"];
    [self setNeedsLayout];
    
    // Load waveform
    [self.waveformImageView setImageWithURLString:[activityItem valueForKeyPath:@"waveform_url"] mutate:^UIImage *(UIImage *image) {
        return [[image cropToTopHalf] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }];
    
    // Load artwork
    [self.artworkImageView setImageWithURLString:[activityItem valueForKeyPath:@"artwork_url"] mutate:^UIImage *(UIImage *image) {
        return image;
    }];
    
    // Load avatar
    [self.authorImageView setImageWithURLString:[activityItem valueForKeyPath:@"user.avatar_url"] mutate:^UIImage *(UIImage *image) {
        return image;
    }];
}


@end
