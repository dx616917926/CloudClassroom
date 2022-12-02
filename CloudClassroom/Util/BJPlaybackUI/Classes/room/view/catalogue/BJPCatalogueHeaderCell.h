//
//  BJPCatalogueHeaderCell.h
//  BJPlaybackUI
//
//  Created by 凡义 on 2021/1/12.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveBase/BJLDocument.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPCatalogueHeaderCell: UITableViewCell

- (void)updateCellWithModel:(BJLDocument *)document;

@end

NS_ASSUME_NONNULL_END
