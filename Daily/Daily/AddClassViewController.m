//
//  AddClassViewController.m
//  Daily
//
//  Created by 王冠宇 on 16/3/17.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "AddClassViewController.h"
#import "AppDelegate.h"

static const NSString *weekDays[7] = {
    @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", @"星期日"
};
static const NSString *sections[8] = {
    @"1-2节", @"2-3节", @"3-4节", @"5-6节", @"6-7节", @"7-8节", @"8-9节", @"9-10节"
};

@interface AddClassViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) AppDelegate *delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (weak, nonatomic) IBOutlet UITextField *classNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *classroomTextField;
@property (weak, nonatomic) IBOutlet UITextField *classTeacherTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *dayPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *sectionPicker;
@property (weak, nonatomic) IBOutlet UITextField *classDayTextField;
@property (weak, nonatomic) IBOutlet UITextField *classSectionTextField;

@end

@implementation AddClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateViewColor];
    
    self.dayPicker.delegate = self;
    self.dayPicker.dataSource = self;
    self.sectionPicker.delegate = self;
    self.sectionPicker.dataSource = self;
    
    self.classNameTextField.text = _className;
    self.classroomTextField.text = _classroom;
    self.classTeacherTextField.text = _classTeacher;
    self.classDayTextField.text = _classDay;
    self.classSectionTextField.text = _classSection;
    
    [self updateButtonState];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateViewColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateButtonState)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter

- (NSString *)className {
    return self.classNameTextField.text;
}

- (NSString *)classroom {
    return self.classroomTextField.text;
}

- (NSString *)classTeacher {
    return self.classTeacherTextField.text;
}

- (NSString *)classDay {
    return self.classDayTextField.text;
}

- (NSString *)classSection {
    return self.classSectionTextField.text;
}

#pragma mark - setter

//- (void)setClassName:(NSString *)className {
//    self.classNameTextField.text = className;
//}
//
//- (void)setClassroom:(NSString *)classroom {
//    self.classroomTextField.text = classroom;
//}
//
//- (void)setClassTeacher:(NSString *)classTeacher {
//    self.classTeacherTextField.text = classTeacher;
//}
//
//- (void)setClassDay:(NSString *)classDay {
//    self.classDayTextField.text = classDay;
//}
//
//- (void)setClassSection:(NSString *)classSection {
//    self.classSectionTextField.text = classSection;
//}

#pragma mark - UIPickerViewDataSource

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 0) {
        return 7;
    } else {
        return 8;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 0) {
        return weekDays[row];
    } else {
        return sections[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == 0) {
        self.classDayTextField.text = weekDays[row];
        [self updateButtonState];
    } else {
        self.classSectionTextField.text = sections[row];
        [self updateButtonState];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([pickerView rowSizeForComponent:component].width, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
    
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    if (self.delegate.nightMode) {
        label.textColor = [UIColor whiteColor];
    } else {
        label.textColor = [UIColor blackColor];
    }
    return label;
}

#pragma mark - 刷新按钮状态

- (void)updateButtonState {
//    NSLog(@"%@", self.className);
//    NSLog(@"%@", self.classroom);
//    NSLog(@"%@", self.classTeacher);
//    NSLog(@"%@", self.classDay);
//    NSLog(@"%@", self.classSection);
    
    if (![self.className isEqualToString:@""] && ![self.classroom isEqualToString:@""] && ![self.classTeacher isEqualToString:@""] && ![self.classDay isEqualToString:@""] && ![self.classSection isEqualToString:@""]) {
        self.navigationItem.leftBarButtonItem = self.saveButton;
    } else {
        self.navigationItem.leftBarButtonItem = self.backButton;
    }
}

#pragma mark - 收回键盘

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self.classNameTextField isExclusiveTouch] || ![self.classroomTextField isExclusiveTouch] || ![self.classTeacherTextField isExclusiveTouch]) {
        [self.classNameTextField resignFirstResponder];
        [self.classroomTextField resignFirstResponder];
        [self.classTeacherTextField resignFirstResponder];
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
            if ([view isKindOfClass:[UITextField class]]) {
                ((UITextField *)view).backgroundColor = [UIColor blackColor];
                ((UITextField *)view).textColor = [UIColor whiteColor];
                [((UITextField *)view) setBorderStyle:UITextBorderStyleBezel];
            }
        }
        self.view.backgroundColor = [UIColor blackColor];
        [((UINavigationController *)self.parentViewController).navigationBar setBarTintColor:[UIColor blackColor]];
        [((UINavigationController *)self.parentViewController).navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
        self.classNameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.classroomTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.classTeacherTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        for(UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UILabel class]]) {
                ((UILabel *)view).textColor = [UIColor blackColor];
                ((UITextField *)view).textColor = [UIColor blackColor];
            }
            if ([view isKindOfClass:[UITextField class]]) {
                ((UITextField *)view).backgroundColor = [UIColor whiteColor];
            }
        }
        self.view.backgroundColor = [UIColor whiteColor];
        [((UINavigationController *)self.parentViewController).navigationBar setBarTintColor:[UIColor whiteColor]];
        [((UINavigationController *)self.parentViewController).navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil]];
        self.classNameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.classroomTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.classTeacherTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    }
}

@end

































