//
//  Utilities.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/03/01.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (void)showDefaultAlertWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showMessage:(NSString *)message cgRect:(CGRect)cgRect inView:(UIView *)inView;

+ (BOOL)isDevice5thGen;
+ (BOOL)isOS4;

@end
