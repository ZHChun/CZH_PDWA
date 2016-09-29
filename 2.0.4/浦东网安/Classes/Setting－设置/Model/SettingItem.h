//
//  settingItem.h
//  浦东网安
//
//  Created by jiji on 15/6/16.
//  Copyright (c) 2015年 PengYue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingItem : NSObject
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *icon;
+(instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title;
@end
