//
//  COXTableViewCell.h
//  test
//
//  Created by 崔明辉 on 2016/12/29.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COXTableViewCell;

typedef void(^COXTableViewCellConfigurationBlock)(COXTableViewCell *cell);

@interface COXTableViewCell : UITableViewCell

+ (CGFloat)requestRowHeight:(UITableView *)tableView
         configurationBlock:(COXTableViewCellConfigurationBlock)configurationBlock;

@end
