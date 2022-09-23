//
//  HXCustomBtn.m
//  HXXiaoGuan
//
//  Created by mac on 2021/5/31.
//

#import "HXCustomBtn.h"

@implementation HXCustomBtn

-(void)setTxtRect:(CGRect)txtRect{
    _txtRect = txtRect;
}
-(void)setImgRect:(CGRect)imgRect{
    _imgRect = imgRect;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (_txtRect.size.width != 0) {
        self.titleLabel.frame = _txtRect;
    }
    if (_imgRect.size.width != 0) {
        self.imageView.frame = _imgRect;
    }
}

@end
