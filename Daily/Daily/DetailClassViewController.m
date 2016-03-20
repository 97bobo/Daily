//
//  DetailClassViewController.m
//  Daily
//
//  Created by 王冠宇 on 16/3/17.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "DetailClassViewController.h"
#import "AddClassViewController.h"
#import "AppDelegate.h"

@interface DetailClassViewController ()

@property (strong, nonatomic) AppDelegate *delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *classroomLabel;
@property (strong, nonatomic) IBOutlet UILabel *classTeacherLabel;
@property (strong, nonatomic) IBOutlet UILabel *classDayLabel;
@property (strong, nonatomic) IBOutlet UILabel *classSectionLabel;

@end

@implementation DetailClassViewController

#pragma mark - getter

- (UIBarButtonItem *)editButton {
    if (!_editButton) {
        _editButton = [[UIBarButtonItem alloc] init];
        _editButton.title = @"编辑";
    }
    return _editButton;
}

//- (NSString *)className {
//    return self.classNameLabel.text;
//}
//
//- (NSString *)classroom {
//    return self.classroomLabel.text;
//}
//
//- (NSString *)classTeacher {
//    return self.classTeacherLabel.text;
//}
//
//- (NSString *)classDay {
//    return self.classDayLabel.text;
//}
//
//- (NSString *)classSection {
//    return self.classSectionLabel.text;
//}

//- (UILabel *)classNameLabel {
//    if (!_classNameLabel) {
//        _classNameLabel = [[UILabel alloc] init];
//    }
//    return _classNameLabel;
//}
//
//- (UILabel *)classroomLabel {
//    if (!_classroomLabel) {
//        _classroomLabel = [[UILabel alloc] init];
//    }
//    return _classroomLabel;
//}
//
//- (UILabel *)classTeacherLabel {
//    if (!_classTeacherLabel) {
//        _classTeacherLabel = [[UILabel alloc] init];
//    }
//    return _classTeacherLabel;
//}
//
//- (UILabel *)classDayLabel {
//    if (!_classDayLabel) {
//        _classDayLabel = [[UILabel alloc] init];
//    }
//    return _classDayLabel;
//}
//
//- (UILabel *)classSectionLabel {
//    if (!_classSectionLabel) {
//        _classSectionLabel = [[UILabel alloc] init];
//    }
//    return _classSectionLabel;
//}

#pragma mark - setter

//- (void)setClassName:(NSString *)className {
//    self.classNameLabel.text = className;
//    [self.classNameLabel setNumberOfLines:0];
//    self.classNameLabel.lineBreakMode = UILineBreakModeWordWrap;
//    UIFont *font = [UIFont boldSystemFontOfSize:10.0];
//    self.classNameLabel.font = font;
//    CGSize size = CGSizeMake(34,300);
//    CGSize labelSize = [className sizeWithFont:font
//                             constrainedToSize:size
//                                 lineBreakMode:UILineBreakModeWordWrap];
//    [self.classNameLabel setFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
//}
//
//- (void)setClassroom:(NSString *)classroom {
//    self.classroomLabel.text = classroom;
//}
//
//- (void)setClassTeacher:(NSString *)classTeacher {
//    self.classTeacherLabel.text = classTeacher;
//}
//
//- (void)setClassDay:(NSString *)classDay {
//    self.classDayLabel.text = classDay;
//}
//
//- (void)setClassSection:(NSString *)classSection {
//    self.classSectionLabel.text = classSection;
//}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateViewColor];
    
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    self.classNameLabel.text = self.className;
    [self.classNameLabel setNumberOfLines:0];
    self.classNameLabel.lineBreakMode = UILineBreakModeWordWrap;
    UIFont *font = [UIFont boldSystemFontOfSize:30];
    self.classNameLabel.font = font;
    CGSize size = CGSizeMake(300,20000.0f);
    CGSize labelSize = [self.className sizeWithFont:font
                             constrainedToSize:size
                                 lineBreakMode:UILineBreakModeWordWrap];
    [self.classNameLabel setFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    
    self.classroomLabel.text = self.classroom;
    
    self.classTeacherLabel.text = self.classTeacher;
    
    self.classDayLabel.text = self.classDay;
    
    self.classSectionLabel.text = self.classSection;
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateViewColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DCVCModalToACVC"]) {
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        AddClassViewController *destinationViewController = (AddClassViewController *)[controller.viewControllers objectAtIndex:0];
        
        destinationViewController.className = self.className;
        destinationViewController.classroom = self.classroom;
        destinationViewController.classTeacher = self.classTeacher;
        destinationViewController.classDay = self.classDay;
        destinationViewController.classSection = self.classSection;
        
        destinationViewController.oldClassName = self.className;
    }
}

// 根据nightMode更新界面颜色
-(void)updateViewColor {
    self.delegate = [[UIApplication sharedApplication] delegate];
    if (self.delegate.nightMode) {
        for(UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UILabel class]]) {
                ((UILabel *)view).textColor = [UIColor whiteColor];
            }
        }
        self.view.backgroundColor = [UIColor blackColor];
        [((UINavigationController *)self.parentViewController).navigationBar setBarTintColor:[UIColor blackColor]];
        [((UINavigationController *)self.parentViewController).navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    } else {
        for(UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UILabel class]]) {
                ((UILabel *)view).textColor = [UIColor blackColor];
                ((UITextField *)view).textColor = [UIColor blackColor];
            }
        }
        self.view.backgroundColor = [UIColor whiteColor];
        [((UINavigationController *)self.parentViewController).navigationBar setBarTintColor:[UIColor whiteColor]];
        [((UINavigationController *)self.parentViewController).navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil]];
    }
}

@end




































