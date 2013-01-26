//
//  fciosFirstViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/26.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "fciosFirstViewController.h"

@interface fciosFirstViewController ()

@end

@implementation fciosFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
