//
//  DetailViewController.h
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Remind.h"

@protocol DetailViewControllerDelegate <NSObject>

-(void) didFinshUpdate:(Remind *)remind;

@end

@interface DetailViewController : UIViewController



@property(nonatomic) Remind *remind;
@property(nonatomic) id<DetailViewControllerDelegate> delegate;

@end
