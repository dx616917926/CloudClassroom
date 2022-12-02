//
//  BJLPhotoBrowserView.h
//  BJLiveUI
//
//  Created by Ney on 3/11/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJLPhotoListViewController.h"

@interface BJLPhotoBrowserView: UIView
@property (nonatomic, nullable) void (^hideCallback)(BJLPhotoBrowserView *_Nonnull view);

- (instancetype _Nonnull)initWithPhotos:(NSArray<BJLPhotoMode *> *_Nullable)photo currentPhoto:(BJLPhotoMode *_Nullable)currentPhoto;

- (void)updatePhotos:(NSMutableArray<BJLPhotoMode *> *_Nullable)photo;
- (void)updatePhotosWithImageURLs:(NSArray<NSString *> *_Nullable)photoURLs;
- (void)updateCurrentPhoto:(BJLPhotoMode *_Nullable)currentPhoto;
- (void)updateCurrentIndex:(NSInteger)index;
@end
