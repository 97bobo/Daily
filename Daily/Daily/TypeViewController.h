//
//  TypeViewController.h
//  Daily
//
//  Created by 王冠宇 on 16/3/8.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeViewController : UIViewController

@property (strong, nonatomic) NSDate *diaryDate;                // 日记日期
@property (strong, nonatomic) NSMutableString *diaryContent;    // 日记内容
@property (strong, nonatomic) NSDate *updatedDiaryDate;         // 更新日期

@property (nonatomic, assign) BOOL newDiary;                    // 标记是否为新建日记
@property (nonatomic, assign) BOOL deleteDiary;

@property (nonatomic,strong) NSMutableArray *dates;

@end
