//
//  Remind.h
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;
@interface Remind : NSManagedObject

@property NSString *title;
@property NSString *detail;
@property NSString *date;
@property NSString *time;

@end
