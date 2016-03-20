//
//  DiscoveryViewController.m
//  Daily
//
//  Created by 王冠宇 on 16/3/17.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "AppDelegate.h"

@interface DiscoveryViewController()

@property (strong, nonatomic) AppDelegate *delegate;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *mottoLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) UIImage *imageToShow;
@property (strong, nonatomic) NSString *mottoToShow;
@property (strong, nonatomic) NSDate *dateToShow;

@end

@implementation DiscoveryViewController

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UILabel *)mottoLabel {
    if (!_mottoLabel) {
        _mottoLabel = [[UILabel alloc] init];
    }
    return _mottoLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
    }
    return _dateLabel;
}

- (UIImage *)imageToShow {
    return self.imageView.image;
}

- (NSString *)mottoToShow {
    return self.mottoLabel.text;
}

- (NSDate *)dateToShow {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    return [formatter dateFromString:self.dateLabel.text];
}

- (void)setImageToShow:(UIImage *)imageToShow {
    self.imageView.image = imageToShow;
}

- (void)setMottoToShow:(NSString *)mottoToShow {
    self.mottoLabel.text = mottoToShow;
    [self.mottoLabel setNumberOfLines:0];
    self.mottoLabel.lineBreakMode = UILineBreakModeWordWrap;
    UIFont *font = [UIFont fontWithName:@"Arial" size:12];
    CGSize size = CGSizeMake(320,2000);
    CGSize labelSize = [mottoToShow sizeWithFont:font
                               constrainedToSize:size
                                   lineBreakMode:UILineBreakModeWordWrap];
    [self.mottoLabel setFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
}

- (void)setDateToShow:(NSDate *)dateToShow {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    self.dateLabel.text = [formatter stringFromDate:dateToShow];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateViewColor];
    
    [self setRamdomImageAndMotto];
    [self setDateToShow:[NSDate date]];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateViewColor];
}

- (void)setRamdomImageAndMotto {
    int ramdom = arc4random() % 8;
    NSString *picName = [NSString stringWithFormat:@"pic_%@", [NSString stringWithFormat:@"%d", ramdom]];
    NSString *mottoKey = [NSString stringWithFormat:@"motto_%@", [NSString stringWithFormat:@"%d", ramdom]];
    
    // 加载图片
    self.imageToShow = [UIImage imageNamed:picName];
    
    // 加载格言
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"mottoList"
                                                          ofType:@"plist"];
    NSMutableDictionary *mottos = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.mottoToShow = [mottos valueForKey:mottoKey];
}

// 根据nightMode更新界面颜色
-(void)updateViewColor {
    self.delegate = [[UIApplication sharedApplication] delegate];
    if (self.delegate.nightMode) {
        self.view.backgroundColor = [UIColor blackColor];
        [((UITabBarController *)self.parentViewController.parentViewController).tabBar setBarTintColor:[UIColor blackColor]];
        self.mottoLabel.textColor = [UIColor whiteColor];
        self.dateLabel.textColor = [UIColor whiteColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        [((UITabBarController *)self.parentViewController.parentViewController).tabBar setBarTintColor:[UIColor whiteColor]];
        self.mottoLabel.textColor = [UIColor blackColor];
        self.dateLabel.textColor = [UIColor blackColor];
    }
}

@end

































