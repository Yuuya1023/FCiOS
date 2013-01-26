//
//  fciosSecondViewController.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/26.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "fciosSecondViewController.h"

@interface fciosSecondViewController ()

@end

@implementation fciosSecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
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
