//
//  TableSources.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/01/27.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "TableSources.h"

@implementation TableSources
@synthesize clearList = clearList_;
@synthesize levelList = levelList_;
@synthesize versionList = versionList_;

@synthesize sortingList = sortingList_;

- (id)init
{
    self = [super init];
    if (self) {
        self.clearList = [[NSArray alloc] initWithObjects:
                          @"NO PLAY",
                          @"FAILED",
                          @"ASSIST CLEAR",
                          @"EASY CLEAR",
                          @"CLEAR",
                          @"HARD CLEAR",
                          @"EXHARD CLEAR",
                          @"FULLCOMBO",
                          nil];
        self.levelList = [[NSArray alloc] initWithObjects:
                          @"☆1",
                          @"☆2",
                          @"☆3",
                          @"☆4",
                          @"☆5",
                          @"☆6",
                          @"☆7",
                          @"☆8",
                          @"☆9",
                          @"☆10",
                          @"☆11",
                          @"☆12",
                          nil];
        self.versionList = [[NSArray alloc] initWithObjects:
                            @"1st & substream",
                            @"2nd style",
                            @"3rd style",
                            @"4th style",
                            @"5th style",
                            @"6th style",
                            @"7th style",
                            @"8th style",
                            @"9th style",
                            @"10th style",
                            @"11 IIDX RED",
                            @"12 HAPPY SKY",
                            @"13 DistorteD",
                            @"14 GOLD",
                            @"15 DJ TROOPERS",
                            @"16 EMPRESS",
                            @"17 SIRIUS",
                            @"18 Resort Anthem",
                            @"19 Lincle",
                            @"20 tricoro",
                            nil];
        self.sortingList = [[NSArray alloc] initWithObjects:
                            @"1",
                            @"2",
                            @"3",
                            nil];
    }
    return self;
}

@end
