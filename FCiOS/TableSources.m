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

@synthesize clearSortList = clearSortList_;
@synthesize levelSortList = levelSortList_;
@synthesize versionSortList = versionSortList_;
@synthesize sortingSortList = sortingSortList_;


- (id)init
{
    self = [super init];
    if (self) {
        self.clearList = [[NSArray alloc] initWithObjects:
                          @"FULLCOMBO",
                          @"EXHARD CLEAR",
                          @"HARD CLEAR",
                          @"CLEAR",
                          @"EASY CLEAR",
                          @"ASSIST CLEAR",
                          @"FAILED",
                          @"NO PLAY",
                          nil];
        self.levelList = [[NSArray alloc] initWithObjects:
                          @"LEVEL  1",
                          @"LEVEL  2",
                          @"LEVEL  3",
                          @"LEVEL  4",
                          @"LEVEL  5",
                          @"LEVEL  6",
                          @"LEVEL  7",
                          @"LEVEL  8",
                          @"LEVEL  9",
                          @"LEVEL 10",
                          @"LEVEL 11",
                          @"LEVEL 12",
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
                            @"11th IIDX RED",
                            @"12th HAPPY SKY",
                            @"13th DistorteD",
                            @"14th GOLD",
                            @"15th DJ TROOPERS",
                            @"16th EMPRESS",
                            @"17th SIRIUS",
                            @"18th Resort Anthem",
                            @"19th Lincle",
                            @"20th tricoro",
                            @"21th SPADA",
                            nil];
        
        //ソート用
        self.clearSortList = [[NSArray alloc] initWithObjects:
                              @"ALL",
                              @"FULLCOMBO",
                              @"EXHARD CLEAR",
                              @"HARD CLEAR",
                              @"CLEAR",
                              @"EASY CLEAR",
                              @"ASSIST CLEAR",
                              @"FAILED",
                              @"NO PLAY",
                              @"NOT FULLCOMBO",
                              @"NOT EXHARD CLEAR",
                              @"NOT HARD CLEAR",
                              @"NOT CLEAR",
                              @"NOT EASY CLEAR",
                              nil];
        self.levelSortList = [[NSArray alloc] initWithObjects:
                              @"ALL",
                              @"LEVEL  1",
                              @"LEVEL  2",
                              @"LEVEL  3",
                              @"LEVEL  4",
                              @"LEVEL  5",
                              @"LEVEL  6",
                              @"LEVEL  7",
                              @"LEVEL  8",
                              @"LEVEL  9",
                              @"LEVEL 10",
                              @"LEVEL 11",
                              @"LEVEL 12",
                              nil];
        self.versionSortList = [[NSArray alloc] initWithObjects:
                                @"ALL",
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
                                @"11th IIDX RED",
                                @"12th HAPPY SKY",
                                @"13th DistorteD",
                                @"14th GOLD",
                                @"15th DJ TROOPERS",
                                @"16th EMPRESS",
                                @"17th SIRIUS",
                                @"18th Resort Anthem",
                                @"19th Lincle",
                                @"20th tricoro",
                                @"21th SPADA",
                                nil];
        
        self.sortingSortList = [[NSArray alloc] initWithObjects:
                                @"Difficulity (ASC)",
                                @"Difficulity (DESC)",
                                @"CLEAR LAMP (ASC)",
                                @"CLEAR LAMP (DESC)",
                                nil];
        
        self.sortSetting = [[NSArray alloc] initWithObjects:
                            @"Difficulity (ASC)",
                            @"Difficulity (DESC)",
                            @"CLEAR LAMP (ASC)",
                            @"CLEAR LAMP (DESC)",
                            nil];
    }
    return self;
}

@end
