//
//  BJLPhotoListCell.m
//  BJLiveUI
//
//  Created by Ney on 3/5/21.
//  Copyright © 2021 BaijiaYun. All rights reserved.
//

#import "BJLPhotoListCell.h"
#import "BJL_iCloudLoading.h"
#import "BJLPhotoListViewController.h"
#import <BJLiveBase/BJLiveBase+UIKit.h>
#import "BJLAppearance.h"

@interface BJLPhotoListCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteButton;
@end

@implementation BJLPhotoListCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.deleteButton];

    [self.imageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.deleteButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(4);
        make.right.equalTo(self.contentView).offset(-4);
    }];

    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 3;
}

- (void)setImageData:(BJLPhotoMode *)imageData {
    _imageData = imageData;
    if (imageData.rawImageMode) {
        self.imageView.image = imageData.rawImageMode.thumbnail;
    }
    else if (imageData.urlDownloadedImage) {
        self.imageView.image = imageData.urlDownloadedImage;
    }
    else if (imageData.urlMode) {
        [self.imageView bjl_setImageWithURL:[NSURL URLWithString:imageData.urlMode] placeholder:nil completion:^(UIImage *_Nullable image, NSError *_Nullable error, NSURL *_Nullable imageURL) {
            imageData.urlDownloadedImage = image;
        }];
    }
}

- (void)setShowDeleteIcon:(BOOL)showDeleteIcon {
    _showDeleteIcon = showDeleteIcon;
    self.deleteButton.hidden = !_showDeleteIcon;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.accessibilityIdentifier = @"_imageView";
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        bjl_weakify(self);
        UITapGestureRecognizer *tap = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer *_Nullable gesture) {
            bjl_strongify(self);
            if (self.tapEventCallBack) {
                self.tapEventCallBack(self);
            }
        }];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage bjl_imageNamed:@"bjl_image_list_delete_normal"] forState:UIControlStateNormal];
        _deleteButton.accessibilityIdentifier = @"_deleteButton";

        bjl_weakify(self);
        [_deleteButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.deleteEventCallBack) {
                self.deleteEventCallBack(self);
            }
        }];
    }
    return _deleteButton;
}
@end

@interface BJLPhotoListAddNewCell ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIButton *addNewImageButton;
@end

@implementation BJLPhotoListAddNewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    [self.contentView addSubview:self.bgView];
    [self.contentView addSubview:self.addNewImageButton];

    [self.bgView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.addNewImageButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 3;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [[UIColor bjl_colorWithHexString:@"#9FA8B5"] colorWithAlphaComponent:0.2];
        _bgView.accessibilityIdentifier = @"_bgView";
    }
    return _bgView;
}

- (UIButton *)addNewImageButton {
    if (!_addNewImageButton) {
        _addNewImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addNewImageButton setImage:[UIImage bjl_imageNamed:@"bjl_image_list_add"] forState:UIControlStateNormal];
        _addNewImageButton.accessibilityIdentifier = @"_addNewImageButton";
        _addNewImageButton.contentMode = UIViewContentModeCenter;

        bjl_weakify(self);
        [_addNewImageButton bjl_addHandler:^(UIButton *_Nonnull button) {
            bjl_strongify(self);
            if (self.addNewImageEventCallBack) {
                self.addNewImageEventCallBack(self);
            }
        }];
    }
    return _addNewImageButton;
}
@end
