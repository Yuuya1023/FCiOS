//
//  Utilities.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/03/01.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation Utilities

+ (void)showDefaultAlertWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:title
                               message:message
                              delegate:self
                     cancelButtonTitle:nil
                     otherButtonTitles:@"OK", nil];
    [alert show];
}


+ (void)showMessage:(NSString *)message cgRect:(CGRect)cgRect inView:(UIView *)inView{
    
    UIView *grayView = [[UIView alloc] initWithFrame:cgRect];
    grayView.backgroundColor = [UIColor blackColor];
    grayView.alpha = 0.0;
    
    [[grayView layer] setCornerRadius:8.0f];
    [[grayView layer] setMasksToBounds:YES];


    UILabel *label = [[UILabel alloc] initWithFrame:cgRect];
    label.text = message;
    label.font = DEFAULT_FONT;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.alpha = 0.0;
    label.textAlignment = NSTextAlignmentCenter;
    
    [inView addSubview:grayView];
    [inView addSubview:label];
    
    float fadeTime = 0.3f;
    
    [UIView animateWithDuration:fadeTime animations:^(void) {
        grayView.alpha = 0.7;
        label.alpha = 1.0;
        
    }completion:^(BOOL finished){
        [UIView animateWithDuration:1.5f animations:^(void) {
            grayView.alpha = 0.71;
            
        }completion:^(BOOL finished){
            [UIView animateWithDuration:fadeTime animations:^(void) {
                grayView.alpha = 0.0;
                label.alpha = 0.0;
                
                }completion:^(BOOL finished){
                    [grayView removeFromSuperview];
                    [label removeFromSuperview];
            }];
        }];
    }];
}

+ (BOOL)isOS4{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        return NO;
    }
    return YES;
}


+ (BOOL)isDevice5thGen{
    BOOL isDevice5thGen = NO;
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    if (frame.size.height == 548.0) {
        isDevice5thGen = YES;
    }
    else{
        isDevice5thGen = NO;
    }
    return isDevice5thGen;
}


@end
