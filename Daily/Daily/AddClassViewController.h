//
//  AddClassViewController.h
//  Daily
//
//  Created by 王冠宇 on 16/3/17.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddClassViewController : UIViewController

@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *classroom;
@property (strong, nonatomic) NSString *classTeacher;
@property (strong, nonatomic) NSString *classDay;
@property (strong, nonatomic) NSString *classSection;

// 存储旧课程名称，在课程信息被修改时使用
@property (strong, nonatomic) NSString *oldClassName;

@end
