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


@interface DetailViewController ()<UITextFieldDelegate,UITextViewDelegate,DateViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

@end

@implementation DetailViewController

-(void) saveToCoredata{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [appDelegate persistentContainer].viewContext;
    
    [context save:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleField.delegate = self;
    self.detailTextView.delegate = self;
    self.detailTextView.layer.cornerRadius = 5;
    
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)save:(id)sender {
    
    self.remind.title = self.titleField.text;
    self.remind.detail = self.detailTextView.text;
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
    
    [self presentViewController:dateVC animated:YES completion:nil];

}
#pragma mark - DateViewControllerDelegate
-(void)didFinshUpdate:(NSString *)dateString Time:(NSString *)timeString{
    
    if(dateString == nil){
        
        
        
    } else if(timeString == nil){
        
        
        
    }
    
    NSString *buttonTitle = [NSString stringWithFormat:@"%@ %@",dateString,timeString];
    [self.dateButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    
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
