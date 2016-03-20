//
//  CurriculumScheduleViewController.m
//  Daily
//
//  Created by 王冠宇 on 16/3/17.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "CurriculumScheduleViewController.h"
#import "ClassView.h"
#import "AddClassViewController.h"
#import "AppDelegate.h"
#import "DetailClassViewController.h"

static NSString * const kClassEntityName = @"Class";
static NSString * const kCourseNameKey = @"courseName";
static NSString * const kCourseRoomKey = @"courseRoom";
static NSString * const kCourseTeacherKey = @"courseTeacher";
static NSString * const kCourseDayKey = @"courseDay";
static NSString * const kCourseSectionKey = @"courseSection";

static const int CLASSVIEWWIDTH = 37;
static const int CLASSVIEWHEIGHT = 74;
static const int ORIGIN_X = 35;
static const int ORIGIN_Y = 94;

@interface CurriculumScheduleViewController ()

@property (strong, nonatomic) AppDelegate *delegate;

@property (strong, nonatomic) NSMutableArray *classNames;
@property (strong, nonatomic) NSMutableArray *classrooms;
@property (strong, nonatomic) NSMutableArray *classTeachers;
@property (strong, nonatomic) NSMutableArray *classDays;
@property (strong, nonatomic) NSMutableArray *classSections;

@end

@implementation CurriculumScheduleViewController

#pragma getter

- (NSMutableArray *)classNames {
    if (!_classNames) {
        _classNames = [[NSMutableArray alloc] init];
    }
    return _classNames;
}

- (NSMutableArray *)classrooms {
    if (!_classrooms) {
        _classrooms = [[NSMutableArray alloc] init];
    }
    return _classrooms;
}

- (NSMutableArray *)classTeachers {
    if (!_classTeachers) {
        _classTeachers = [[NSMutableArray alloc] init];
    }
    return _classTeachers;
}

- (NSMutableArray *)classDays {
    if (!_classDays) {
        _classDays = [[NSMutableArray alloc] init];
    }
    return _classDays;
}

- (NSMutableArray *)classSections {
    if (!_classSections) {
        _classSections = [[NSMutableArray alloc] init];
    }
    return _classSections;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateViewColor];
    
    [self loadClassFromDataBase];
    [self drawClasses];
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:app];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateViewColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - applicationWillResignActive

- (void)applicationWillResignActive:(NSNotification *)notification {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    for (int i = 0; i < self.classNames.count; i++) {
        NSString *theClassName = self.classNames[i];
        NSString *theClassroom = self.classrooms[i];
        NSString *theClassTeacher = self.classTeachers[i];
        NSString *theClassDay = self.classDays[i];
        NSString *theClassSection = self.classSections[i];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kClassEntityName];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(%K = %d)", kCourseNameKey, theClassName];
        [request setPredicate:pred];
        
        NSArray *objects = [context executeFetchRequest:request
                                                  error:&error];
        if (objects == nil) {
            NSLog(@"There was an error!");
        }
        
        NSManagedObject *theClass = nil;
        if ([objects count] > 0) {
            theClass = [objects objectAtIndex:0];
        } else {
            theClass = [NSEntityDescription insertNewObjectForEntityForName:kClassEntityName
                                                     inManagedObjectContext:context];
        }
        
        [theClass setValue:theClassName
                    forKey:kCourseNameKey];
        [theClass setValue:theClassroom
                    forKey:kCourseRoomKey];
        [theClass setValue:theClassTeacher
                    forKey:kCourseTeacherKey];
        [theClass setValue:theClassDay
                    forKey:kCourseDayKey];
        [theClass setValue:theClassSection
                    forKey:kCourseSectionKey];
    }
    [appDelegate saveContext];
}

#pragma mark - 从数据库加载课程到数据源数组

- (void)loadClassFromDataBase {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kClassEntityName];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    if (objects == nil) {
        NSLog(@"There was an error!");
    }
    
    for (int i = 0; i < objects.count; i++) {
        self.classNames[i] = [[objects objectAtIndex:i] valueForKey:kCourseNameKey];
        self.classrooms[i] = [[objects objectAtIndex:i] valueForKey:kCourseRoomKey];
        self.classTeachers[i] = [[objects objectAtIndex:i] valueForKey:kCourseTeacherKey];
        self.classDays[i] = [[objects objectAtIndex:i] valueForKey:kCourseDayKey];
        self.classSections[i] = [[objects objectAtIndex:i] valueForKey:kCourseSectionKey];
    }
}

#pragma mark - 绘图方法

- (void)drawClasses {
    for(UIView *view in [self.view subviews])
    {
        if ([view isKindOfClass:[ClassView class]]) {
            [view removeFromSuperview];
        }
    }
    
    for (int i = 0; i < self.classNames.count; i++) {
        int x = ORIGIN_X + CLASSVIEWWIDTH * ([self valueOfDay:self.classDays[i]] - 1);
        int y = ORIGIN_Y + CLASSVIEWHEIGHT / 2 * ([self valueOfSection:self.classSections[i]] - 1);
        
        ClassView *classView = [[ClassView alloc] initWithFrame:CGRectMake(x, y, CLASSVIEWWIDTH, CLASSVIEWHEIGHT)];
        classView.className = self.classNames[i];
        classView.classroom = self.classrooms[i];
        [self.view addSubview:classView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(actionTap:)];
        [classView addGestureRecognizer:tapGesture];
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
        [((UITabBarController *)self.parentViewController.parentViewController).tabBar setBarTintColor:[UIColor blackColor]];
    } else {
        for(UIView *view in [self.view subviews])
        {
            if ([view isKindOfClass:[UILabel class]]) {
                ((UILabel *)view).textColor = [UIColor blackColor];
            }
        }
        self.view.backgroundColor = [UIColor whiteColor];
        [((UINavigationController *)self.parentViewController).navigationBar setBarTintColor:[UIColor whiteColor]];
        [((UINavigationController *)self.parentViewController).navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil]];
        [((UITabBarController *)self.parentViewController.parentViewController).tabBar setBarTintColor:[UIColor whiteColor]];
    }
}

- (int)valueOfDay:(NSString *)classDay {
    if ([classDay isEqualToString:@"星期一"]) {
        return 1;
    } else if ([classDay isEqualToString:@"星期二"]) {
        return 2;
    } else if ([classDay isEqualToString:@"星期三"]) {
        return 3;
    } else if ([classDay isEqualToString:@"星期四"]) {
        return 4;
    } else if ([classDay isEqualToString:@"星期五"]) {
        return 5;
    } else if ([classDay isEqualToString:@"星期六"]) {
        return 6;
    } else if ([classDay isEqualToString:@"星期日"]) {
        return 7;
    }
    return 0;
}

- (int)valueOfSection:(NSString *)classSection {
    if ([classSection isEqualToString:@"1-2节"]) {
        return 1;
    } else if ([classSection isEqualToString:@"2-3节"]) {
        return 2;
    } else if ([classSection isEqualToString:@"3-4节"]) {
        return 3;
    } else if ([classSection isEqualToString:@"5-6节"]) {
        return 5;
    } else if ([classSection isEqualToString:@"6-7节"]) {
        return 6;
    } else if ([classSection isEqualToString:@"7-8节"]) {
        return 7;
    } else if ([classSection isEqualToString:@"8-9节"]) {
        return 8;
    } else if ([classSection isEqualToString:@"9-10节"]) {
        return 9;
    }
    return 0;
}

#pragma mark - unwind方法

- (IBAction)unwindToCurriculumScheduleViewController:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"Save"]) {
        AddClassViewController *sourceViewController = (AddClassViewController *)segue.sourceViewController;
        
        // 获取新课程信息
        NSString *className = sourceViewController.className;
        NSString *classroom = sourceViewController.classroom;
        NSString *classTeacher = sourceViewController.classTeacher;
        NSString *classDay = sourceViewController.classDay;
        NSString *classSection = sourceViewController.classSection;
        
        if (sourceViewController.oldClassName) {
            NSInteger index = [self indexOfNameInNames:sourceViewController.oldClassName];
            
            // 更新数据
            [self.classNames replaceObjectAtIndex:index withObject:className];
            [self.classrooms replaceObjectAtIndex:index withObject:classroom];
            [self.classTeachers replaceObjectAtIndex:index withObject:classTeacher];
            [self.classDays replaceObjectAtIndex:index withObject:classDay];
            [self.classSections replaceObjectAtIndex:index withObject:classSection];
        } else {
            // 写入数据源数组
            [self.classNames addObject:className];
            [self.classrooms addObject:classroom];
            [self.classTeachers addObject:classTeacher];
            [self.classDays addObject:classDay];
            [self.classSections addObject:classSection];
        }
        
        [self saveClassIntoDataBase];
        
        [self drawClasses];
    } else if ([segue.identifier isEqualToString:@"Delete"]) {
        AddClassViewController *sourceViewController = (AddClassViewController *)segue.sourceViewController;
        
        // 获取被删课程信息
        NSString *className = sourceViewController.className;
        NSString *classroom = sourceViewController.classroom;
        NSString *classTeacher = sourceViewController.classTeacher;
        NSString *classDay = sourceViewController.classDay;
        NSString *classSection = sourceViewController.classSection;
        
        // 从数据库中删除课程
        [self deleteClassInDataBase:className];
        
        // 从数据源数组删除
        [self.classNames removeObject:className];
        [self.classrooms removeObject:classroom];
        [self.classTeachers removeObject:classTeacher];
        [self.classDays removeObject:classDay];
        [self.classSections removeObject:classSection];
        
        [self drawClasses];
    }
}

#pragma mark - saveClassIntoDataBase

- (void)saveClassIntoDataBase {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error;
    
    for (int i = 0; i < self.classNames.count; i++) {
        NSString *theClassName = self.classNames[i];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kClassEntityName];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", kCourseNameKey, theClassName];
        [request setPredicate:pred];
        
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        NSManagedObject *theClass = nil;
        if ([objects count] > 0) {
            theClass = [objects objectAtIndex:0];
        } else {
            theClass = [NSEntityDescription insertNewObjectForEntityForName:kClassEntityName
                                                     inManagedObjectContext:context];
        }
        [theClass setValue:self.classNames[i] forKey:kCourseNameKey];
        [theClass setValue:self.classrooms[i] forKey:kCourseRoomKey];
        [theClass setValue:self.classTeachers[i] forKey:kCourseTeacherKey];
        [theClass setValue:self.classDays[i] forKey:kCourseDayKey];
        [theClass setValue:self.classSections[i] forKey:kCourseSectionKey];
    }
    [delegate saveContext];
}

#pragma mark - deleteClassInDataBase

- (void)deleteClassInDataBase:(NSString *)theClassName {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kClassEntityName];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", kCourseNameKey, theClassName];
    [request setPredicate:pred];
    
    NSArray *objects = [context executeFetchRequest:request error:&error];
        
    NSManagedObject *theClass = nil;
    if ([objects count] > 0) {
        theClass = [objects objectAtIndex:0];
    }
    [context deleteObject:theClass];
    [delegate saveContext];
}

#pragma mark - 按钮动作方法

- (void)actionTap:(UITapGestureRecognizer *)sender {
    ClassView *classView = (ClassView *)sender.view;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    DetailClassViewController *detailClassViewController = [storyboard instantiateViewControllerWithIdentifier:@"DetailClassViewController"];
    
    [self.navigationController pushViewController:detailClassViewController animated:YES];
    
    NSInteger index = [self indexOfNameInNames:classView.className];
    
    detailClassViewController.className = classView.className;
    detailClassViewController.classroom = classView.classroom;
    detailClassViewController.classTeacher = [self.classTeachers objectAtIndex:index];
    detailClassViewController.classDay = [self.classDays objectAtIndex:index];
    detailClassViewController.classSection = [self.classSections objectAtIndex:index];
}

#pragma mark - 索引

- (NSInteger)indexOfNameInNames:(NSString *)className {
    return [self.classNames indexOfObject:className];
}

@end








































