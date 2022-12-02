//
//  BJPDocumentCatalogueModel.h
//  BJVideoPlayerCore
//
//  Created by 凡义 on 2021/1/14.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BJPPPTCatalogueModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJPDocumentCatalogueModel: NSObject <BJLYYModel>

@property (nonatomic, readonly, copy) BJLDocument *document;
@property (nonatomic, readonly, nullable) NSArray<BJPPPTCatalogueModel *> *catalogueList;

@end

NS_ASSUME_NONNULL_END
