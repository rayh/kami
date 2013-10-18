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
@property (nonatomic) UIView *topBorderView;
@property (nonatomic) UIToolbar *waveformBackgroundView;
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
        
        self.waveformBackgroundView = [[UIToolbar alloc] initWithFrame:CGRectZero];
        self.waveformBackgroundView.barStyle = UIBarStyleBlack;
        [self.contentView addSubview:self.waveformBackgroundView];
        
        self.waveformImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.waveformImageView.alpha = 1.0;
        self.waveformImageView.contentMode = UIViewContentModeScaleToFill;
        self.waveformImageView.tintColor = [UIColor colorWithWhite:1. alpha:0.1];
//        self.waveformImageView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.];
        [self.contentView addSubview:self.waveformImageView];
        
        self.topBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        self.topBorderView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.contentView addSubview:self.topBorderView];
        
        self.authorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.authorImageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
        self.authorImageView.layer.borderWidth = 1.;
        self.authorImageView.layer.cornerRadius = 17.;
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
        self.timeLabel.textColor = [UIColor colorWithWhite:1 alpha:0.7];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat overlayHeight = ceilf(self.bounds.size.height/3.);
    
    self.topBorderView.frame = CGRectMake(0, 0, self.bounds.size.width, 1);

    self.artworkImageView.frame = self.bounds;
//    self.artworkImageView.layer.cornerRadius = self.artworkImageView.frame.size.height/2;
    self.artworkImageView.layer.masksToBounds = YES;
    
    self.waveformImageView.frame = CGRectMake(0, self.bounds.size.height - overlayHeight, self.bounds.size.width, overlayHeight);
    self.waveformBackgroundView.frame = self.waveformImageView.frame;
    
    self.authorImageView.frame = CGRectMake(5.,self.bounds.size.height - overlayHeight + 5., 34., 34.);
    
    self.timeLabel.frame = CGRectMake(44.,
                                      self.bounds.size.height - overlayHeight + 5.,
                                      self.bounds.size.width - 10.,
                                      12);
    
    CGRect boundingRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width-5.-44., CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:self.titleLabel.font}
                                                             context:nil];
    self.titleLabel.frame = CGRectMake(44.,
                                       CGRectGetMaxY(self.timeLabel.frame),
                                       self.bounds.size.width-5.-44.,
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
