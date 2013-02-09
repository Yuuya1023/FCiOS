//
//  HomeDetailCell.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/02/09.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "HomeDetailCell.h"

@implementation HomeDetailCell
@synthesize nameLabel = nameLabel_;
@synthesize folderDetailLabel = folderDetailLabel_;
@synthesize clearLamp = clearLamp_;
@synthesize difficulityType = difficulityType_;
@synthesize clearLampType = clearLampType_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //名前
//        NSLog(@"init cell");
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -5, [UIScreen mainScreen].bounds.size.width - 60,40)];
        self.nameLabel.font =  [UIFont fontWithName:@"GillSans" size:18];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.nameLabel];
        
        //フォルダデータ
        self.folderDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width - 60,15)];
        self.folderDetailLabel.font = [UIFont fontWithName:@"GillSans" size:18];
        self.folderDetailLabel.backgroundColor = [UIColor clearColor];
        self.folderDetailLabel.textColor = [UIColor grayColor];
        self.folderDetailLabel.textAlignment = NSTextAlignmentLeft;
        self.folderDetailLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.folderDetailLabel];
        
        //クリアランプ
        self.clearLamp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 40)];
        [self addSubview:self.clearLamp];
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
