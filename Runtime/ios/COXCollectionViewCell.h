//
//  COXCollectionViewCell.h
//  test
//
//  Created by 崔明辉 on 2016/12/29.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COXCollectionViewCell;

typedef void(^COXCollectionViewCellConfigurationBlock)(COXCollectionViewCell *cell);

@interface COXCollectionViewCell : UICollectionViewCell

+ (CGSize)requestCellSize:(UICollectionView *)collectionView
       configurationBlock:(COXCollectionViewCellConfigurationBlock)configurationBlock;

@end
