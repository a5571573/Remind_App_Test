//
//  DateViewController.m
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import "DateViewController.h"
#import <FSCalendar/FSCalendar.h>

@interface DateViewController ()<FSCalendarDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end

@implementation DateViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.calendar.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)save:(id)sender {
    
    NSDate *time = self.timePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"HH:mm a"];
    
    self.timeString = [dateFormatter stringFromDate:time];
    
    [self.delegate didFinshUpdate:self.dateString Time:self.timeString];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    
    self.dateString = [dateFormatter stringFromDate:date];
    
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
