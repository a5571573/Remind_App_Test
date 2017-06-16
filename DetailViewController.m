//
//  DetailViewController.m
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import "DetailViewController.h"
#import "ListViewController.h"
#import "DateViewController.h"
#import "AppDelegate.h"
#import "ImageOperator.h"

@import GoogleMobileAds;
@import Photos;
@import UserNotifications;


@interface DetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate,DateViewControllerDelegate,GADInterstitialDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property(nonatomic) NSDate *pickerTime;
@property(nonatomic) NSDate *pickerDate;
@property(nonatomic) NSString *dateString;
@property(nonatomic) NSString *timeString;
@property(nonatomic) BOOL pickerType;
@property(nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation DetailViewController
#pragma mark - Core Data
-(void) saveToCoredata{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
    
    [context save:nil];
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleField.delegate = self;
    self.detailTextView.delegate = self;
    self.detailTextView.layer.cornerRadius = 5.0;
    
    self.titleField.text = self.remind.title;
    self.detailTextView.text = self.remind.detail;
    
    self.imageView.image = [self.remind image];

    self.imageView.layer.borderWidth = 5.0;
    self.imageView.layer.borderColor = [[UIColor colorWithRed:(71/255.0) green:(65/255.0) blue:(67/255.0) alpha:1.0]CGColor];
    self.imageView.layer.cornerRadius = 5.0;
    
    self.dateLabel.layer.cornerRadius = 5.0;
    self.dateLabel.layer.masksToBounds = YES;
    [self.dateLabel setText:[NSString stringWithFormat:@"%@ %@",self.remind.date,self.remind.time]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    if (self.remind.date == nil && self.remind.time == nil) {
        [self.dateLabel setText:@"請選取時間"];
    }
    
    if (self.remind.date != nil) {
        
        self.dateString = [NSString stringWithString:self.remind.date];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        self.pickerDate = [dateFormatter dateFromString:self.dateString];
        NSLog(@"%@",self.dateString);
        
    }
    if (self.remind.time != nil) {
        
        self.timeString = [NSString stringWithString:self.remind.time];
        [dateFormatter setDateFormat:@"hh:mm a"];
        self.pickerTime = [dateFormatter dateFromString:self.timeString];
        NSLog(@"%@",self.timeString);
        
    }
    
    
    self.interstitial = [[GADInterstitial alloc]
                         initWithAdUnitID:@"ca-app-pub-8119560259088202/7728763173"];
    GADRequest *request = [GADRequest request];
    [self.interstitial loadRequest:request];
    // Do any additional setup after loading the view.
}
- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-8119560259088202/7728763173"];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createAndLoadInterstitial];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Button Action
- (IBAction)save:(id)sender {
    
    
    
    if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:self];
    }
    
    // 若title跟時間日期未填入，會跳出alert警告使用者
    if (self.titleField.text.length == 0||[self.dateLabel.text isEqualToString:@"請選取時間"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注意" message:@"請輸入標題和時間" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            return ;
        }];
        
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        
        NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.8);
        NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *photos = [documents stringByAppendingPathComponent:@"Photos"];
        NSString *filePath = [photos stringByAppendingPathComponent:self.remind.imageFileName];
        [imageData writeToFile:filePath atomically:YES];
        
        // Save the image to Notification folder.
        UIImage *rotateImage = [ImageOperator rotateImage:self.imageView.image];
        
        NSData *rotateImageData = UIImageJPEGRepresentation(rotateImage, 0.8);
        
        NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
        NSString *NotificationImage = [library stringByAppendingPathComponent:@"NotificationImage"];
        NSURL *imageURL = [NSURL fileURLWithPath:[NotificationImage stringByAppendingPathComponent:self.remind.imageFileName]];
        [rotateImageData writeToURL:imageURL atomically:YES];
        
        // 將檔案寫進相簿裡儲存
        if (self.pickerType) {
            
            PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
            
            [photoLibrary performChanges:^{
                
                [PHAssetChangeRequest creationRequestForAssetFromImage:self.imageView.image];
                
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    NSLog(@"success");
                } else {
                    NSLog(@"Error : %@",error);
                }
            }];
        }
        
        self.remind.title = self.titleField.text;
        self.remind.detail = self.detailTextView.text;
        
        self.remind.date = self.dateString;
        self.remind.time = self.timeString;
        
        self.remind.switchOnOff = YES;
        
        
        [self saveToCoredata];
        [self.delegate didFinshUpdate:self.remind];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [self creatLocalNotification:imageURL];
    }
    
    
}
- (IBAction)cancel:(id)sender {
    
    [self.delegate didFinshUpdate:self.remind];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dateSelect:(id)sender {
    
    DateViewController *dateVC = [self.storyboard instantiateViewControllerWithIdentifier:@"dateViewController"];
    
    dateVC.delegate = self;
    
    if (self.pickerDate == nil) {
        self.pickerDate = [[NSDate alloc]init];
        
    }
    if (self.pickerTime == nil) {
        self.pickerTime = [[NSDate alloc]init];
    }
    
    dateVC.date = self.pickerDate;
    dateVC.time = self.pickerTime;
    
    [self presentViewController:dateVC animated:YES completion:nil];
    
}
#pragma mark - Creat LocalNotification
-(void)creatLocalNotification:(NSURL *)imageURL{
    
    // Create localNotification
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    
    
    content.title  = [NSString stringWithString:self.titleField.text];
    if ([self.detailTextView.text isEqualToString:@""]) {
        content.body = @"Notification";
    } else{
        content.body = [NSString stringWithFormat:@"%@",self.detailTextView.text];
    }
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = @"localNotification";
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
    
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",self.dateString,self.timeString]];
    //NSDate *correctDate = [NSDate dateWithTimeInterval:60*60*8 sinceDate:date];
    NSLog(@"date: %@",date);
    
    // Set Notification dateFormatter
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar]components:NSCalendarUnitYear+NSCalendarUnitMonth+NSCalendarUnitDay+NSCalendarUnitHour+NSCalendarUnitMinute fromDate:date];
    
    // Add Image to Notification
    NSLog(@"%@",imageURL);
    
    if (self.imageView.image != nil) {
        
        UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:self.remind.imageFileName URL:imageURL options:0 error:nil];
        content.attachments = @[attachment];
        
    }
    
    
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:self.remind.remindID content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        } else {
            NSLog(@"Notification setting success.");
            
        }
    }];
    
}

- (IBAction)camera:(id)sender {
    
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
#pragma mark - Camera Methods
-(void) takePhoto{
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
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

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.imageView.image = image;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
// 資料傳遞 DateViewController -> DetailViewController
#pragma mark - DateViewControllerDelegate
-(void)didFinshUpdate:(NSDate *)date Time:(NSDate *)time{
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    if (date == nil) {
        
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        self.dateString = [dateFormatter stringFromDate:self.pickerDate];
        
    } else {
        
        self.pickerDate = date;
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        self.dateString = [dateFormatter stringFromDate:date];
    }
    
    
    self.pickerTime = time;
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.timeString = [dateFormatter stringFromDate:time];
    
    NSLog(@"%@",self.dateString);
    NSLog(@"%@",self.timeString);
    
    [self.dateLabel setText:[NSString stringWithFormat:@"%@ %@",self.dateString,self.timeString]];
    
}
// 設定TextField的輸入換行
#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
    
}
// 設定TextView的輸入換行
#pragma mark - UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
