//
//  DateViewController.m
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import "DateViewController.h"
#import <FSCalendar/FSCalendar.h>

@interface DateViewController ()<FSCalendarDelegate,FSCalendarDataSource>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet FSCalendar *calendar;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end

@implementation DateViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.calendar.delegate = self;
    
//    self.dateLabel.layer.cornerRadius = 10.0;
//    self.dateLabel.layer.masksToBounds = YES;
//    
//    self.timeLabel.layer.cornerRadius = 10.0;
//    self.timeLabel.layer.masksToBounds = YES;
    
    self.timePicker.backgroundColor = [UIColor colorWithRed:(231/255.0) green:(226/255.0) blue:(218/255.0) alpha:1.0];
    
        [self.calendar selectDate:self.date scrollToDate:YES];
        [self.timePicker setDate:self.time animated:YES];
        

    
    

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Button Action
- (IBAction)save:(id)sender {
    
    self.time = self.timePicker.date;
    
    [self.delegate didFinshUpdate:self.date Time:self.time];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{

    self.date = date;
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
