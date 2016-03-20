//
//  ClassView.m
//  Daily
//
//  Created by 王冠宇 on 16/3/17.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "ClassView.h"

@interface ClassView()

@property(strong, nonatomic) UILabel *classNameLabel;
@property(strong, nonatomic) UILabel *classroomLabel;
@property(strong, nonatomic) UIColor *classColor;

@end

@implementation ClassView

- (UILabel *)classNameLabel {
    if (!_classNameLabel) {
        _classNameLabel = [[UILabel alloc] init];
    }
    return _classNameLabel;
}

- (UILabel *)classroomLabel {
    if (!_classroomLabel) {
        _classroomLabel = [[UILabel alloc] init];
    }
    return _classroomLabel;
}

- (NSString *)className {
    return self.classNameLabel.text;
}

- (NSString *)classroom {
    return self.classroomLabel.text;
}

- (void)setClassName:(NSString *)className {
    self.classNameLabel.text = className;
    [self.classNameLabel setNumberOfLines:0];
    self.classNameLabel.lineBreakMode = UILineBreakModeWordWrap;
    UIFont *font = [UIFont boldSystemFontOfSize:10.0];
    self.classNameLabel.font = font;
    CGSize size = CGSizeMake(34,300);
    CGSize labelSize = [className sizeWithFont:font
                               constrainedToSize:size
                                   lineBreakMode:UILineBreakModeWordWrap];
    [self.classNameLabel setFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
}

- (void)setClassroom:(NSString *)classroom {
    self.classroomLabel.text = classroom;
    [self.classroomLabel setNumberOfLines:0];
    self.classroomLabel.lineBreakMode = UILineBreakModeWordWrap;
    UIFont *font = [UIFont boldSystemFontOfSize:9.0];
    self.classroomLabel.font = font;
    CGSize size = CGSizeMake(34,300);
    CGSize labelSize = [classroom sizeWithFont:font
                             constrainedToSize:size
                                 lineBreakMode:UILineBreakModeWordWrap];
    [self.classroomLabel setFrame:CGRectMake(0, 50, labelSize.width, labelSize.height)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
        [self addSubview:self.classNameLabel];
        [self addSubview:self.classroomLabel];
    }
    return self;
}

@end






















