//
//  TypeViewController.m
//  Daily
//
//  Created by 王冠宇 on 16/3/8.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "TypeViewController.h"
#import "AppDelegate.h"

static NSString * const kDiaryEntityName = @"Diary";
static NSString * const kDiaryDateKey = @"diaryDate";
static NSString * const kDiaryContentKey = @"diaryContent";

@interface TypeViewController () <UITextViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) AppDelegate *delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TypeViewController

- (NSString *)diaryContent {
    return self.textView.text;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateViewColor];
    
    self.updatedDiaryDate = nil;
    _diaryContent =  self.diaryContent;
    if (self.newDiary) {
        [self setDiaryDate:[NSDate date]];
    }
    
    // 从数据库中读取日记
    [self setTextFromDataBase:self.diaryDate];
    
    self.textView.delegate = self;
    self.textView.scrollEnabled = YES;
    
    // 禁用编辑功能，显示editButton
    self.textView.editable = NO;
    self.navigationItem.rightBarButtonItem = self.editButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateViewColor];
    
    // 注册通知，监听键盘出现
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    // 注册通知，监听键盘消失
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardDidHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    // 注册通知，监听键盘输入
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSaveButtonTitleAndDiaryDate)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

- (void)handleKeyboardDidShow:(NSNotification *)notification {
    // 获取键盘高度
    NSValue *keyboardRectAsObject = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect;
    [keyboardRectAsObject getValue:&keyboardRect];
    
    self.textView.contentInset = UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0);
}

- (void)handleKeyboardDidHidden:(NSNotification *)notification {
    self.textView.contentInset = UIEdgeInsetsZero;
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = self.editButton;
    self.textView.editable = NO;
}

- (IBAction)editAction:(id)sender {
    self.textView.editable = YES;
    [self.textView becomeFirstResponder];
}

- (IBAction)doneAction:(id)sender {
    [self.textView resignFirstResponder];
}

- (void)setTextFromDataBase:(NSDate *)date {
    // 如果不是新建日记，则需要加载数据到textView
    if (!self.newDiary) {
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [delegate managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kDiaryEntityName];
        NSError *error;
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", kDiaryDateKey, date];
        [request setPredicate:pred];
        
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        NSString *content = [objects[0] valueForKey:kDiaryContentKey];
    
        [self.textView setText:content];
    } 
}

// 返回date在数组dates中的角标，用于定位数据源
- (NSUInteger)indexOfDateInDates:(NSDate *)date {
    return [self.dates indexOfObject:date];
}

- (void)updateSaveButtonTitleAndDiaryDate {
    if ([self.textView.text isEqualToString:@""]) {
        self.saveButton.titleLabel.text = @"返回";
    } else {
        self.saveButton.titleLabel.text = @"保存";
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextViewTextDidChangeNotification object:nil];
    }
    
    // 更新日记时间
    [self setUpdatedDiaryDate:[NSDate date]];
}

// 根据nightMode更新界面颜色
-(void)updateViewColor {
    self.delegate = [[UIApplication sharedApplication] delegate];
    if (self.delegate.nightMode) {
        self.textView.backgroundColor = [UIColor blackColor];
        self.textView.textColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor blackColor];
        [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
        self.textView.keyboardAppearance = UIKeyboardAppearanceDark;
    } else {
        self.textView.backgroundColor = [UIColor whiteColor];
        self.textView.textColor = [UIColor blackColor];
        self.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil]];
        self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;

    }
}

- (IBAction)deleteAction:(id)sender {
    NSString *actionTitle;
    actionTitle = NSLocalizedString(@"确定要删除这篇日记？", @"");
    
    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    // Show from our table view (pops up in the middle of the table).
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        self.deleteDiary = YES;
        [self.saveButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        self.deleteDiary = NO;
    }
}


@end

























