//
//  Remind.h
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@import CoreData;
@interface Remind : NSManagedObject

@property (nonatomic)NSString *title;
@property (nonatomic)NSString *detail;
@property (nonatomic)NSString *date;
@property (nonatomic)NSString *time;
@property (nonatomic)BOOL switchOnOff;
@property (nonatomic)NSString *remindID;
@property (nonatomic)NSString *imageFileName;

-(UIImage *)image;
-(UIImage *) thumbnailImage;
-(void) removeImageModel;
@end
