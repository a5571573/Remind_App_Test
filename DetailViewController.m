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


@interface DetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate,DateViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property(nonatomic) NSDate *pickerTime;
@property(nonatomic) NSDate *pickerDate;
@property(nonatomic) NSString *dateString;
@property(nonatomic) NSString *timeString;

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
    self.detailTextView.layer.cornerRadius = 5;
    
    self.titleField.text = self.remind.title;
    self.detailTextView.text = self.remind.detail;
    
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
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Button Action
- (IBAction)save:(id)sender {
    
    self.remind.title = self.titleField.text;
    self.remind.detail = self.detailTextView.text;
    
    self.remind.date = self.dateString;
    self.remind.time = self.timeString;
    
    self.remind.switchOnOff = YES;
    
    
    [self saveToCoredata];
    
    [self.delegate didFinshUpdate:self.remind];
    
    [self.navigationController popViewControllerAnimated:YES];
    
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

- (IBAction)camera:(id)sender {
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    self.timeString = [dateFormatter stringFromDate:time];
    
    [self.dateLabel setText:[NSString stringWithFormat:@"%@ %@",self.dateString,self.timeString]];
    
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
    
}

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
