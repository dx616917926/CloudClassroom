//
//  BJLPhotoListCell.h
//  BJLiveUI
//
//  Created by Ney on 3/5/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BJLPhotoMode;

NS_ASSUME_NONNULL_BEGIN

@interface BJLPhotoListCell: UICollectionViewCell
@property (nonatomic, strong) BJLPhotoMode *imageData;
@property (nonatomic, assign) BOOL showDeleteIcon;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) void (^deleteEventCallBack)(BJLPhotoListCell *cell);
@property (nonatomic, strong) void (^tapEventCallBack)(BJLPhotoListCell *cell);
@end

@interface BJLPhotoListAddNewCell: UICollectionViewCell
@property (nonatomic, strong) void (^addNewImageEventCallBack)(BJLPhotoListAddNewCell *cell);
@end

NS_ASSUME_NONNULL_END
