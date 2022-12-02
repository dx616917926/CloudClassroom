//
//  BJPCatalogueCell.h
//  BJPlaybackUI
//
//  Created by 凡义 on 2021/1/12.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJVideoPlayerCore/BJPPPTCatalogueModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPCatalogueCell: UITableViewCell

@property (nonatomic, nullable) void (^clickCallback)(void);

- (void)updateCellWithModel:(BJPPPTCatalogueModel *)catalogue pptUrl:(nullable NSString *)pptUrl playing:(BOOL)playing;

@end

NS_ASSUME_NONNULL_END
