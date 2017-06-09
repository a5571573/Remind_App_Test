//
//  ListViewController.m
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import "ListViewController.h"
#import "Remind.h"
#import "RemindTableViewCell.h"
#import "DetailViewController.h"
#import "AppDelegate.h"

@import UserNotifications;
@import Photos;
@import CoreData;

@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource,DetailViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UNUserNotificationCenterDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic) NSMutableArray <Remind *>*reminds;
@property(nonatomic) Remind *photoRemind;
@property(nonatomic) BOOL pickerType;

@end

@implementation ListViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.reminds = [[NSMutableArray alloc]init];
        [self reloadCell];
    }
    
    return self;
}

#pragma mark - Core Data

-(void) reloadCell{
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Remind"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [context executeRequest:fetchRequest error:nil];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if(error){
        NSLog(@"error %@",error);
    } else {
        self.reminds = [results mutableCopy];
        for (int i = 0; i<self.reminds.count; i++) {
            Remind *remind = self.reminds[i];
            if (remind.title.length == 0 || remind.date.length == 0 || remind.time.length == 0) {
                [context deleteObject:remind];
                [self.reminds removeObject:remind];
                [self saveToCoredata];
            }
        }
        
    }
    
}

-(void) saveToCoredata{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
    
    [context save:nil];
}

-(void) deleteCoredata:(NSManagedObject *)sender{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
    
    [context deleteObject:sender];
    
}


#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    NSLog(@"%@",NSHomeDirectory());
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delete Remind

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:YES];
    [self.tableView setEditing:editing animated:YES];
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        Remind *remind = self.reminds[indexPath.row];
        [remind removeImageModel];
        [self.reminds removeObject:remind];
        
        [self deleteCoredata:remind];
        [self saveToCoredata];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self setTagWhenCellCanged];
        
    }
}

#pragma mark - UITableViewDataSource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.reminds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RemindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindCell" forIndexPath:indexPath];
    
    Remind *remind = self.reminds[indexPath.row];
    [cell.switchButton setTag:indexPath.row+1];
    
    [self switchOnOff:cell Remind:remind];
    
    cell.titleLabel.text = remind.title;
    cell.detailLabel.text = remind.detail;
    cell.dateLabel.text = remind.date;
    cell.timeLabel.text = remind.time;
    
    cell.imageButton.remindData = remind;
    
    [cell.imageButton setImage:[remind thumbnailImage] forState:UIControlStateNormal];
    
    if ([remind thumbnailImage] == nil) {
        [cell.imageButton setImage:[UIImage imageNamed:@"circle.png"] forState:UIControlStateNormal];
    }
    
    return cell;
}

#pragma mark - Push the thumbnailImage Changed Image
- (IBAction)photoChanged:(ImageButton *)sender {
    
    self.photoRemind = sender.remindData;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"選取方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] == YES) {
        
        UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"相機" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self takePhoto];
        }];
        [alert addAction:takePhoto];
    }
    
    UIAlertAction *photoLibrary = [UIAlertAction actionWithTitle:@"相簿" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self photoLibrary];
    }];
    [alert addAction:photoLibrary];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return ;
    }];
    [cancel setValue:[UIColor redColor] forKey:@"titleTextColor"];
    
    
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void) takePhoto{
    
    UIImagePickerController *pickerController =[[UIImagePickerController alloc]init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    pickerController.showsCameraControls = YES;
    pickerController.delegate = self;
    self.pickerType = YES;
    [self presentViewController:pickerController animated:YES completion:nil];
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    
}

-(void) photoLibrary{
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.delegate = self;
    self.pickerType = NO;
    [self presentViewController:pickerController animated:YES completion:nil];
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    
}
#pragma mark - UNUserNotificationCenterDelegate
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    
    
    completionHandler();
    
    
}
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    completionHandler(UNAuthorizationOptionAlert+UNAuthorizationOptionSound+UNAuthorizationOptionBadge);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:notification.request.content.title message:notification.request.content.body preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *photos = [documents stringByAppendingPathComponent:@"Photos"];
    NSString *filePath = [photos stringByAppendingPathComponent:notification.request.identifier];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    
    
    
    UIAlertAction *correct = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return ;
    }];
    
    [alert addAction:correct];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *photos = [documents stringByAppendingPathComponent:@"Photos"];
    NSString *filePath = [photos stringByAppendingPathComponent:self.photoRemind.imageFileName];
    [imageData writeToFile:filePath atomically:YES];
    
    // Save the image to Notification folder.
    NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *NotificationImage = [library stringByAppendingPathComponent:@"NotificationImage"];
    NSURL *imageURL = [NSURL fileURLWithPath:[NotificationImage stringByAppendingPathComponent:self.photoRemind.imageFileName]];
    [imageData writeToURL:imageURL atomically:YES];
    
    if (self.pickerType) {
        
        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        
        [photoLibrary performChanges:^{
            
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"success");
            } else {
                NSLog(@"Error : %@",error);
            }
        }];
    }
    
    NSInteger index = [self.reminds indexOfObject:self.photoRemind];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (self.photoRemind.switchOnOff == YES) {
        
         [self addNotification:self.photoRemind];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SetTagWhenCellCanged

-(void)setTagWhenCellCanged{
    
    for(NSInteger i=0;i<=self.reminds.count+1;i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        RemindTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell.switchButton setTag:i+1];
    }
    
    
    
}
#pragma mark - Switch ON&OFF
-(void)switchOnOff:(RemindTableViewCell *)cell Remind:(Remind *)remind{
    
    if(remind.switchOnOff == YES){
        [cell.switchButton setOn:YES];
    } else {
        [cell.switchButton setOn:NO];
    }
    
}

#pragma mark - SwitchChanged

- (IBAction)switchChanged:(UISwitch *)sender {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    Remind *remind = self.reminds[sender.tag-1];
    
    //NSLog(@"%ld",sender.tag);
    
    // When switch changed must be write the image back to the Notification folder.
    UIImage *image = [remind image];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *NotificationImage = [library stringByAppendingPathComponent:@"NotificationImage"];
    NSURL *imageURL = [NSURL fileURLWithPath:[NotificationImage stringByAppendingPathComponent:remind.imageFileName]];
    [imageData writeToURL:imageURL atomically:YES];
    
    if (sender.on) {
        
        remind.switchOnOff = YES;
        [self addNotification:remind];
        
    } else {
        
        remind.switchOnOff = NO;
        [center removePendingNotificationRequestsWithIdentifiers:@[remind.remindID]];
        [center removeDeliveredNotificationsWithIdentifiers:@[remind.remindID]];
        
    }
    [self saveToCoredata];
    
}
-(void) addNotification:(Remind *)remind{
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title  = [NSString stringWithString:remind.title];
    if (remind.detail.length == 0) {
        content.body = @"Notification";
    } else{
        content.body = [NSString stringWithFormat:@"%@",remind.detail];
    }
    content.sound = [UNNotificationSound defaultSound];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
    
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",remind.date,remind.time]];
    //NSDate *correctDate = [NSDate dateWithTimeInterval:60*60*8 sinceDate:date];
    
    NSLog(@"date : %@",date);
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar]components:NSCalendarUnitYear+NSCalendarUnitMonth+NSCalendarUnitDay+NSCalendarUnitHour+NSCalendarUnitMinute fromDate:date];
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];
    
    NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *NotificationImage = [library stringByAppendingPathComponent:@"NotificationImage"];
    NSURL *imageURL = [NSURL fileURLWithPath:[NotificationImage stringByAppendingPathComponent:remind.imageFileName]];
    
    if ([remind image] != nil) {
        
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:remind.imageFileName URL:imageURL options:nil error:nil];
        content.attachments = @[attachment];
        
    }
    
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:remind.remindID content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        } else {
            NSLog(@"Notification setting success.");
        }
    }];
}
// 資料傳遞 ListViewController -> DetailViewController
#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"addSegue"]){
        
        DetailViewController *detailVC = segue.destinationViewController;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
        
        Remind *remind = [NSEntityDescription insertNewObjectForEntityForName:@"Remind" inManagedObjectContext:context];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.reminds insertObject:remind atIndex:0];
        [self saveToCoredata];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        detailVC.remind = remind;
        detailVC.delegate = self;
        
    }
    
    if([segue.identifier isEqualToString:@"cellSegue"]){
        
        DetailViewController *detailVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        
        Remind *remind = self.reminds[indexPath.row];
        
        detailVC.remind = remind;
        detailVC.delegate = self;
        
    }
}
// 資料傳遞 DetailViewController -> ListViewController
#pragma mark - didFinshUpdate
-(void)didFinshUpdate:(Remind *)remind{
    
    NSInteger index = [self.reminds indexOfObject:remind];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    if(remind.title == nil && remind.detail == nil){
        
        [self.reminds removeObject:remind];
        [self deleteCoredata:remind];
        [self saveToCoredata];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else {
        
        [self reloadCell];
        [self.tableView reloadData];
        
    }
}
@end
