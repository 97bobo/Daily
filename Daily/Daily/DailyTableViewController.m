//
//  DailyTableViewController.m
//  Daily
//
//  Created by 王冠宇 on 16/3/8.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "DailyTableViewController.h"
#import "TypeViewController.h"
#import "AppDelegate.h"

static NSString * const kDiaryEntityName = @"Diary";
static NSString * const kDiaryDateKey = @"diaryDate";
static NSString * const kDiaryContentKey = @"diaryContent";

@interface DailyTableViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) AppDelegate *delegate;

@property (strong, nonatomic) NSMutableArray *dates;    // 日期数据源
@property (strong, nonatomic) NSMutableArray *contents; // 日记内容数据源

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@property (strong, nonatomic) NSNumber *index;          // 日记在数据源中的角标

@end

@implementation DailyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateViewColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.dates = [[NSMutableArray alloc]init];
    self.contents = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kDiaryEntityName];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    if (objects == nil) {
        NSLog(@"There was an error!");
    }
    
    for (int i = 0; i < objects.count; i++) {
        self.dates[i] = [[objects objectAtIndex:i] valueForKey:kDiaryDateKey];
        self.contents[i] = [[objects objectAtIndex:i] valueForKey:kDiaryContentKey];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:app];
        
    self.hidesBottomBarWhenPushed = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    self.tabBarController.tabBar.hidden = NO;
    [self updateButtonsToMatchTableState];
}

- (void)viewDidAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
    [self updateViewColor];
    [self.tableView reloadData];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    for (int i = 0; i < self.dates.count; i++) {
        NSDate *theDate = self.dates[i];
        NSString *theContent = self.contents[i];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kDiaryEntityName];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(%K = %d)", kDiaryDateKey, theDate];
        [request setPredicate:pred];
        
        NSArray *objects = [context executeFetchRequest:request
                                                  error:&error];
        if (objects == nil) {
            NSLog(@"There was an error!");
        }
        
        NSManagedObject *theDiary = nil;
        if ([objects count] > 0) {
            theDiary = [objects objectAtIndex:0];
        } else {
            theDiary = [NSEntityDescription insertNewObjectForEntityForName:kDiaryEntityName
                                                     inManagedObjectContext:context];
        }

        [theDiary setValue:theDate
                    forKey:kDiaryDateKey];
        [theDiary setValue:theContent
                    forKey:kDiaryContentKey];
    }
    [appDelegate saveContext];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dates.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = self.contents[indexPath.row];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:self.dates[indexPath.row]];
    
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    self.delegate = [[UIApplication sharedApplication] delegate];
    if (self.delegate.nightMode) {
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    
//    cell.backgroundColor = indexPath.row % 2?[UIColor colorWithRed: 240.0/255 green: 240.0/255 blue: 240.0/255 alpha: 1.0]: [UIColor whiteColor];
//    cell.textLabel.backgroundColor = [UIColor clearColor];
//    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *content = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    NSUInteger index = [self indexOfContentInContents:content];
    self.index = [NSNumber numberWithUnsignedInteger:index];
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateButtonsToMatchTableState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateButtonsToMatchTableState];
}

#pragma mark - Action Methods

- (IBAction)editAction:(id)sender {
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancelAction:(id)sender {
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // The user tapped one of the OK/Cancel buttons.
    if (buttonIndex == 0)
    {
        // Delete what the user selected.
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            // Delete the objects from our data model.
            
            [self deleteDiariesAtIndexesInDataBase:selectedRows];
            
            [self.dates removeObjectsAtIndexes:indicesOfItemsToDelete];
            [self.contents removeObjectsAtIndexes:indicesOfItemsToDelete];
            
            
            // Tell the tableView that we deleted the objects
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            [self deleteAllDiariesInDataBase];
            
            // Delete everything, delete the objects from our data model.
            [self.dates removeAllObjects];
            [self.contents removeAllObjects];
            
            // Tell the tableView that we deleted the objects.
            // Because we are deleting all the rows, just reload the current table section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        // Exit editing mode after the deletion.
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
    }

}

- (IBAction)deleteAction:(id)sender {
    // Open a dialog with just an OK button.
    NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"确定要删除这篇日记？", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"确定要删除这些日记？", @"");
    }
    
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (self.tableView.editing) {
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TypeSegue"] && !self.tableView.editing) {
        [(TypeViewController *)segue.destinationViewController setDates:self.dates];
        [(TypeViewController *)segue.destinationViewController setDiaryDate:[self.dates objectAtIndex:[self.index unsignedIntegerValue]]];
        [self hideTabBar];
    } else if ([segue.identifier isEqualToString:@"AddSegue"]) {
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        TypeViewController *typeViewController = (TypeViewController *)[controller.viewControllers objectAtIndex:0];
        [typeViewController setNewDiary:YES];
        [typeViewController setDates:self.dates];
    }
}

- (IBAction)unwindToDailyTableViewController:(UIStoryboardSegue*)segue {
    TypeViewController *sourceViewController = (TypeViewController *)[segue sourceViewController];
    if ([segue.identifier  isEqualToString: @"UnwindToDailyTableViewController"]) {
        if (sourceViewController.newDiary) {
            
            if (![sourceViewController.diaryContent isEqual:@""] && !sourceViewController.deleteDiary ) {
                NSDate *newDate = sourceViewController.diaryDate;
                NSString *newContent = sourceViewController.diaryContent;
                
                [self.dates addObject:newDate];
                [self.contents addObject:newContent];
                
                [self saveDiaryIntoDataBase];
                
                [self.tableView reloadData];
            }
        } else {
            if (![sourceViewController.diaryContent isEqual:@""] && !sourceViewController.deleteDiary ) {
                NSDate *theDate = sourceViewController.diaryDate;
                NSString *theContent = sourceViewController.diaryContent;
                
                NSUInteger index = [self indexOfDateInDates:theDate];
                
                if (sourceViewController.updatedDiaryDate) {
                    [self.dates replaceObjectAtIndex:index withObject:sourceViewController.updatedDiaryDate];
                } else {
                    [self.dates replaceObjectAtIndex:index withObject:theDate];
                }
                
                [self.contents replaceObjectAtIndex:index withObject:theContent];
                
                [self saveDiaryIntoDataBase];
                
                [self.tableView reloadData];
            } else {
                NSUInteger index = [self indexOfDateInDates:sourceViewController.diaryDate];
                
                [self deleteDiariesAtIndexesInDataBase:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:index
                                                                                                           inSection:0], nil]];
                
                [self.dates removeObjectAtIndex:index];
                [self.contents removeObjectAtIndex:index];
                
                [self.tableView reloadData];
            }
        }
    }
    [self showTabBar];
    [self updateButtonsToMatchTableState];
    [self updateViewColor];
}

// 保存日记到数据库中
- (void)saveDiaryIntoDataBase {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error;
    for (int i = 0; i < self.dates.count; i++) {
        NSDate *theDate = self.dates[i];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kDiaryEntityName];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", kDiaryDateKey, theDate];
        [request setPredicate:pred];
        
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        NSManagedObject *theDiary = nil;
        if ([objects count] > 0) {
            theDiary = [objects objectAtIndex:0];
        } else {
            theDiary = [NSEntityDescription insertNewObjectForEntityForName:kDiaryEntityName
                                                     inManagedObjectContext:context];
        }
        [theDiary setValue:self.dates[i] forKey:kDiaryDateKey];
        [theDiary setValue:self.contents[i] forKey:kDiaryContentKey];
    }
    [delegate saveContext];
}

// 删除数据库中的所有日记
- (void)deleteAllDiariesInDataBase {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error;
    for (int i = 0; i < self.dates.count; i++) {
        NSDate *theDate = self.dates[i];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kDiaryEntityName];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", kDiaryDateKey, theDate];
        [request setPredicate:pred];
        
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        NSManagedObject *theDiary = nil;
        if ([objects count] > 0) {
            theDiary = [objects objectAtIndex:0];
        }
        [context deleteObject:theDiary];
    }
    [delegate saveContext];
}

// 删除数据库中的部分日记
- (void)deleteDiariesAtIndexesInDataBase:(NSArray<NSIndexPath *> *)selectedRows {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error;
    for (int i = 0; i < selectedRows.count; i++) {
        NSDate *theDate = self.dates[selectedRows[i].row];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kDiaryEntityName];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K = %@", kDiaryDateKey, theDate];
        [request setPredicate:pred];
        
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        NSManagedObject *theDiary = nil;
        if ([objects count] > 0) {
            theDiary = [objects objectAtIndex:0];
        }
        [context deleteObject:theDiary];
    }
    [delegate saveContext];
}

#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState {
    if (self.tableView.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
        [self updateDeleteButtonTitle];
        
        // Show the delete button.
        self.navigationItem.leftBarButtonItem = self.deleteButton;
    }
    else
    {
        // Not in editing mode.
        self.navigationItem.leftBarButtonItem = self.addButton;
        
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (self.contents.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
}

- (void)updateDeleteButtonTitle {
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == self.dates.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"全部删除", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"删除 (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}

- (void)showTabBar {
    if (self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (void)hideTabBar {
    if (!self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = YES;
    }
}

// 返回date在数组dates中的角标，用于定位数据源
- (NSUInteger)indexOfDateInDates:(NSDate *)date {
    return [self.dates indexOfObject:date];
}
         
- (NSUInteger)indexOfContentInContents:(NSString *)content {
    return [self.contents indexOfObject:content];
}

// 根据nightMode更新界面颜色
-(void)updateViewColor {
    self.delegate = [[UIApplication sharedApplication] delegate];
    if (self.delegate.nightMode) {
        self.view.backgroundColor = [UIColor blackColor];
        [((UINavigationController *)self.parentViewController).navigationBar setBarTintColor:[UIColor blackColor]];
        [((UINavigationController *)self.parentViewController).navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
        [((UITabBarController *)self.parentViewController.parentViewController).tabBar setBarTintColor:[UIColor blackColor]];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        [((UINavigationController *)self.parentViewController).navigationBar setBarTintColor:[UIColor whiteColor]];
        [((UINavigationController *)self.parentViewController).navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil]];
        [((UITabBarController *)self.parentViewController.parentViewController).tabBar setBarTintColor:[UIColor whiteColor]];
    }
}
         
@end
