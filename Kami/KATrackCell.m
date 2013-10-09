#import "KATrackCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <UIColor-Utilities/UIColor+Expanded.h>
#import "UIImage+KAUtilities.h"
#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

@interface KATrackCell ()
@property (nonatomic) UIImageView *waveformImageView;
@property (nonatomic) UIImageView *artworkImageView;
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
//        self.contentView.layer.cornerRadius = 4;
        self.contentView.backgroundColor = [UIColor colorWithRGBHex:0xefefef];
        self.contentView.layer.masksToBounds = YES;
        
        self.waveformImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        self.waveformImageView.alpha = 0.3;
        self.waveformImageView.contentMode = UIViewContentModeScaleToFill;
        self.waveformImageView.backgroundColor = [UIColor colorWithRGBHex:0xe0e0e0];
//        self.waveformImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.waveformImageView];
        
        self.artworkImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.artworkImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.artworkImageView];


        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        self.titleLabel.textColor = [UIColor colorWithRGBHex:0x0E2430];
        self.titleLabel.numberOfLines = 3;
        self.titleLabel.shadowColor = [UIColor colorWithWhite:1. alpha:0.5];
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];

        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:8];
        self.timeLabel.textColor = [[UIColor colorWithRGBHex:0x0E2430] colorWithAlphaComponent:0.6];
        self.timeLabel.shadowColor = [UIColor colorWithWhite:1. alpha:0.5];
        self.timeLabel.shadowOffset = CGSizeMake(0, 1);
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    self.waveformImageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

    self.artworkImageView.frame = CGRectMake(5., 0., self.bounds.size.height, self.bounds.size.height);
    self.artworkImageView.layer.cornerRadius = self.artworkImageView.frame.size.height/2;
    self.artworkImageView.layer.masksToBounds = YES;
    
    self.timeLabel.frame = CGRectMake(self.bounds.size.height+10.,
                                      2.,
                                      self.bounds.size.width-self.bounds.size.height-15.,
                                      10);
    
    CGRect boundingRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width-self.bounds.size.height-15, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:self.titleLabel.font}
                                                             context:nil];
    self.titleLabel.frame = CGRectMake(self.bounds.size.height+10.,
                                       CGRectGetMaxY(self.timeLabel.frame),
                                       self.bounds.size.width-self.bounds.size.height-15,
                                       ceilf(boundingRect.size.height));
}

- (void)configureWithTrack:(NSDictionary*)activityItem
{
    NSDate *date = [[KATrackCell parsingDateFormatter] dateFromString:[activityItem valueForKey:@"created_at"]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ by %@", [date timeAgo], [activityItem valueForKeyPath:@"origin.user.username"]];
    self.titleLabel.text = [activityItem valueForKeyPath:@"origin.title"];
    [self setNeedsLayout];
    
    // Load waveform
    UIImageView *imageView = self.waveformImageView;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[activityItem valueForKeyPath:@"origin.waveform_url"]]];
    [self.waveformImageView setImageWithURLRequest:request
                                  placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               imageView.image = [[image cropToTopHalf] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                                           } failure:nil];
    
    // Load artwork
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:[activityItem valueForKeyPath:@"origin.artwork_url"]]
                          placeholderImage:nil];
}


@end
