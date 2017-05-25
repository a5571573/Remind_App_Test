//
//  DetailViewController.m
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import "DetailViewController.h"
#import "ListViewController.h"
#import "AppDelegate.h"

@interface DetailViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;

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
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)save:(id)sender {
    
    self.remind.title = self.titleField.text;
    self.remind.detail = self.detailTextView.text;
    
    [self saveToCoredata];
    
    [self.delegate didFinshUpdate:self.remind];
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
