//
//  Remind.m
//  Remind_App_Test
//
//  Created by 陳禹佑 on 2017/5/25.
//  Copyright © 2017年 陳禹佑. All rights reserved.
//

#import "Remind.h"

@implementation Remind

@dynamic title;
@dynamic detail;
@dynamic date;
@dynamic time;
@dynamic switchOnOff;
@dynamic remindID;
@dynamic imageFileName;

-(void)awakeFromInsert{
    
    NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *photos = [library stringByAppendingPathComponent:@"Photos"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:photos]){
        [fileManager createDirectoryAtPath:photos withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    self.remindID = [[NSUUID UUID] UUIDString];
    self.imageFileName= [NSString stringWithFormat:@"%@.jpg",self.remindID];
}

-(UIImage *)image{
    
    NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *photos = [library stringByAppendingPathComponent:@"Photos"];
    NSString *filePath = [photos stringByAppendingPathComponent:self.imageFileName];
    
    return [UIImage imageWithContentsOfFile:filePath];
    
}
-(UIImage *)thumbnailImage{
    
    UIImage *image = [self image];
    if (!image){
        return nil;
    }
        
        CGSize thumbnailSize = CGSizeMake(50,50); //設定縮圖大小
        CGFloat scale = [UIScreen mainScreen].scale; //找出目前螢幕的scale，是網膜技術為2.0
        //產生畫布，第一個參數指定大小，第二個參數YES:不透明(黑色底) NO表示背景透明，scale為螢幕scale
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, scale);
        
        //MAX 結果會等於 UIViewContentModeScaleAspectFill
        //MIN 結果會等於 UIViewContentModeScaleAspectFit
        CGFloat widthRatio = thumbnailSize.width / image.size.width;
        CGFloat heightRadio = thumbnailSize.height / image.size.height;
        CGFloat ratio = MAX(widthRatio,heightRadio);
        
        CGSize imageSize = CGSizeMake(image.size.width*ratio, image.size.height*ratio);
        
        //切成圓形
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height)];
        [circlePath addClip];
    
        [image drawInRect:CGRectMake(-(imageSize.width-thumbnailSize.width)/2.0,
                                     -(imageSize.height-thumbnailSize.height)/2.0,
                                     imageSize.width, imageSize.height)];
        
        //取得畫布上的縮圖
        image = UIGraphicsGetImageFromCurrentImageContext();
        //關掉畫布
        UIGraphicsEndImageContext();
        return image;
}

-(void)removeImageModel{
    
    NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *photos = [library stringByAppendingPathComponent:@"Photos"];
    NSString *filePath = [photos stringByAppendingPathComponent:self.imageFileName];
    
    if (filePath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    }
    
}

@end
