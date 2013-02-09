//
//  HomeDetailCell.h
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/02/09.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeDetailCell : UITableViewCell{
    UILabel *nameLabel_;
    UILabel *folderDetailLabel_;
    UIImageView *clearLamp_;
    int difficulityType_;
    int clearLampType_;
}

@property (nonatomic ,retain) UILabel *nameLabel;
@property (nonatomic ,retain) UILabel *folderDetailLabel;
@property (nonatomic ,retain) UIImageView *clearLamp;
@property (nonatomic ,assign) int difficulityType;
@property (nonatomic ,assign) int clearLampType;


@end
