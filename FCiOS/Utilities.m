//
//  Utilities.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/03/01.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+(void)showDefaultAlertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:title
                               message:message
                              delegate:self
                     cancelButtonTitle:nil
                     otherButtonTitles:@"OK", nil];
    [alert show];
}

+ (BOOL)isOS4{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        return NO;
    }
    return YES;
}
@end
