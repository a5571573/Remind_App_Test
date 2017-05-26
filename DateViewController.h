//
//  DateViewController.h
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateViewControllerDelegate <NSObject>

-(void) didFinshUpdate:(NSDate *)date Time:(NSDate *)time;

@end

@interface DateViewController : UIViewController

@property(nonatomic) id<DateViewControllerDelegate>delegate;
@property(nonatomic) NSDate *date;
@property(nonatomic) NSDate *time;

@end
