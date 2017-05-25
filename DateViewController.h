//
//  DateViewController.h
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateViewControllerDelegate <NSObject>

-(void) didFinshUpdate:(NSString *)dateString Time:(NSString *)timeString;

@end

@interface DateViewController : UIViewController

@property(nonatomic) id<DateViewControllerDelegate>delegate;
@property(nonatomic) NSString *dateString;
@property(nonatomic) NSString *timeString;

@end
