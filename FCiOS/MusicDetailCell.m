//
//  MusicDetailCell.m
//  FCiOS
//
//  Created by 南部 祐耶 on 2013/02/09.
//  Copyright (c) 2013年 Yuya Nambu. All rights reserved.
//

#import "MusicDetailCell.h"

@implementation MusicDetailCell
@synthesize nameLabel = nameLabel_;
@synthesize difficulityLabel = difficulityLabel_;
@synthesize clearLamp = clearLamp_;
@synthesize difficulityType = difficulityType_;
@synthesize clearLampType = clearLampType_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //名前
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, [UIScreen mainScreen].bounds.size.width - 80,40)];
        self.nameLabel.font =  DEFAULT_FONT;
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
//        self.nameLabel.textColor = [UIColor whiteColor];
//        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.nameLabel];
        
        //難易度
        self.difficulityLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 20, 40)];
        self.difficulityLabel.font = DEFAULT_FONT;
        self.difficulityLabel.textAlignment = NSTextAlignmentCenter;
//        switch (self.difficulityType) {
//            case 0:
//                self.difficulityLabel.textColor = [UIColor blueColor];
//                break;
//            case 1:
//                self.difficulityLabel.textColor = [UIColor yellowColor];
//                break;
//            case 2:
//                self.difficulityLabel.textColor = [UIColor redColor];
//                break;
//                
//            default:
//                break;
//        }
        [self addSubview:self.difficulityLabel];
        
        //クリアランプ
        self.clearLamp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 40)];
        [self addSubview:self.clearLamp];
        
    }
    return self;
}

- (void)editMode:(BOOL)editMode{
    if (editMode) {
        self.nameLabel.frame = CGRectMake(50, 0, [UIScreen mainScreen].bounds.size.width - 80,40);
    }
    else{
        self.nameLabel.frame = CGRectMake(50, 0, [UIScreen mainScreen].bounds.size.width - 50,40);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
