//
//  HXExamAnswerCell.m
//  CloudClassroom
//
//  Created by mac on 2022/11/17.
//

#import "HXExamAnswerCell.h"
#import "IQTextView.h"
#import "HXPhotoManager.h"
#import "SDWebImage.h"
#import "GKPhotoBrowser.h"
#import "GKCover.h"
#import "UIViewController+HXExtension.h"

@interface HXExamAnswerCell ()<DTAttributedTextContentViewDelegate,DTLazyImageViewDelegate,UITextViewDelegate>
@property(nonatomic,assign) CGRect viewMaxRect;


@property(nonatomic,strong) UIScrollView *mainScrollView;
//题型（单选提，判断题，简答题.....）
@property(nonatomic,strong) UILabel *tiXingNameLabel;
//问题标题
@property(nonatomic,strong) DTAttributedLabel *attributedTitleLabel;

//分数
@property(nonatomic,strong) UIImageView *fenShuBgImageView;
@property(nonatomic,strong) UILabel *fenShuLabel;

@property(nonatomic,strong) UIView *grayView;
@property(nonatomic,strong) IQTextView *textView;

//照片容器试图
@property(nonatomic,strong) UIView *photosContainerView;
//添加照片
@property(nonatomic,strong) UIButton *addPhotoBtn;
@property(nonatomic,strong) UILabel *photoTipLabel;
@property(nonatomic,strong) UIButton *deletePhotoBtn;

@property(nonatomic,strong) NSMutableArray *photosArray;

@property(nonatomic,strong) HXPhotoManager *photoManager;
/** 这里用weak是防止GKPhotoBrowser被强引用，导致不能释放 */
@property (nonatomic, weak) GKPhotoBrowser *browser;

//当前照片索引
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation HXExamAnswerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.viewMaxRect = CGRectMake(0, 0, kScreenWidth-20, CGFLOAT_HEIGHT_UNKNOWN);
        self.photosArray = [NSMutableArray array];
        [self createUI];
    }
    return self;
}

#pragma mark - Setter
-(void)setExamPaperSuitQuestionModel:(HXExamPaperSuitQuestionModel *)examPaperSuitQuestionModel{
    
    
    _examPaperSuitQuestionModel = examPaperSuitQuestionModel;
    
    self.tiXingNameLabel.text = examPaperSuitQuestionModel.pqt_title;
    
    CGSize textSize = [self getAttributedTextHeightHtml:examPaperSuitQuestionModel.serialNoHtmlTitle  with_viewMaxRect:self.viewMaxRect];
    self.attributedTitleLabel.sd_layout.heightIs(textSize.height);
    [self.attributedTitleLabel updateLayout];
    self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:examPaperSuitQuestionModel.serialNoHtmlTitle];
    
    //分数
    self.fenShuLabel.text = [examPaperSuitQuestionModel.psq_scoreStr stringByAppendingString:@"'"];
    
    self.textView.text = examPaperSuitQuestionModel.answer;
    
    //处理附件图片
    if (self.examPaperSuitQuestionModel.fuJianImages.count==0) {//初始化
        self.examPaperSuitQuestionModel.fuJianImages = [NSMutableArray array];
    }
    [self.photosArray removeAllObjects];
    [self.photosArray addObjectsFromArray:self.examPaperSuitQuestionModel.fuJianImages];
    [self refreshPhotosContainerViewLayout];
    
    
}


#pragma mark - 添加照片
-(void)addPhoto:(UIButton *)button{
    [self endEditing:YES];
    if (self.photosArray.count>5) {
        [self.examVc.view showTostWithMessage:@"图片数量不能超过5个!"];
        return;
    }
    WeakSelf(weakSelf);
    [self.examVc hx_presentSelectPhotoControllerWithManager:self.photoManager didDone:^(NSArray<HXPhotoModel *> * _Nullable allList, NSArray<HXPhotoModel *> * _Nullable photoList, NSArray<HXPhotoModel *> * _Nullable videoList, BOOL isOriginal, UIViewController * _Nullable viewController, HXPhotoManager * _Nullable manager) {
        HXPhotoModel *photoModel = allList.firstObject;
        // 因为是编辑过的照片所以直接取
        UIImage *image = photoModel.photoEdit.editPreviewImage;
        [weakSelf.photosArray addObject:image];
        [weakSelf.examPaperSuitQuestionModel.fuJianImages addObject:image];
        [weakSelf refreshPhotosContainerViewLayout];
    } cancel:nil];
    
}

#pragma mark - 点击图片浏览
-(void)tapImageView:(UITapGestureRecognizer *)tap{
    [self endEditing:YES];
    UIImageView *imageView = (UIImageView *)tap.view;
    NSInteger index = imageView.tag-5000;
    self.currentIndex = index;
    NSMutableArray *photos = [NSMutableArray new];
    GKPhoto *photo = [GKPhoto new];
    photo.image = imageView.image;
    photo.sourceImageView = imageView;
    [photos addObject:photo];
    [self.browser resetPhotoBrowserWithPhotos:photos];
    [self.browser showFromVC:self.examVc];
}

#pragma mark - 删除照片
-(void)deletePhoto:(UIButton *)sender{
    [self.browser dismiss];
    [self.examPaperSuitQuestionModel.fuJianImages removeObjectAtIndex:self.currentIndex];
    [self.photosArray removeObjectAtIndex:self.currentIndex];
    //重新布局照片
    [self refreshPhotosContainerViewLayout];
}

#pragma mark - 重新布局照片
-(void)refreshPhotosContainerViewLayout{
    ///移除重新布局
    [self.photosContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    //记录布局的上一个视图
    __block UIView *lastview = self.photosContainerView;
    //记录高度
    __block CGFloat contentHeight = 0;
    [self.photosArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImage *image = obj;
        
        UIImageView *imageView =[[UIImageView alloc] init];
        imageView.tag = 5000+idx;
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = image;
        [self.photosContainerView addSubview:imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tap];
        
        CGSize size = image.size;
        CGFloat heightPx = 0;
        CGFloat maxWidth = kScreenWidth-20;
        if (size.width>=maxWidth) {
            CGFloat imgSizeScale = size.height/size.width;
            heightPx = maxWidth * imgSizeScale;
        }else{
            heightPx = size.height;
        }
        
        imageView.sd_layout
            .topSpaceToView(lastview, 10)
            .leftEqualToView(self.photosContainerView)
            .rightEqualToView(self.photosContainerView)
            .heightIs(heightPx);
        
        contentHeight += heightPx+10;
        lastview = imageView;
        
    }];
    //刷新布局
    self.photosContainerView.sd_layout.heightIs(contentHeight);
    [self.photosContainerView updateLayout];
}




#pragma mark - <UITextViewDelegate>
- (void)textViewDidChange:(UITextView *)textView{
    self.examPaperSuitQuestionModel.answer = textView.text;
}

#pragma mark - <DTAttributedTextContentViewDelegate>
//图片占位
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    
    if([attachment isKindOfClass:[DTImageTextAttachment class]]){
        NSString *imageURL = [NSString stringWithFormat:@"%@", attachment.contentURL];
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.image = [(DTImageTextAttachment *)attachment image];
        imageView.url = attachment.contentURL;
        imageView.userInteractionEnabled = NO;
        if ([imageURL containsString:@"gif"]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *gifData = [NSData dataWithContentsOfURL:attachment.contentURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = DTAnimatedGIFFromData(gifData);
                });
            });
        }else if([imageURL containsString:@"data:image/png;base64,"]){//base64字符串转为图片
            NSArray *array = [imageURL componentsSeparatedByString:@"data:image/png;base64,"];
            NSString *base64Str = array.lastObject;
            NSData *imageData =[[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:imageData];
                imageView.image = image;
            });
        }
        return imageView;
    }
    return nil;
}





#pragma mark - <DTLazyImageViewDelegate>
//懒加载获取图片大小
- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    NSURL *url = lazyImageView.url;
    CGSize imageSize = size;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    BOOL didUpdate = NO;
    // update all attachments that match this URL (possibly multiple images with same size)
    for (DTTextAttachment *oneAttachment in [self.attributedTitleLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize attributedLabel:self.attributedTitleLabel];
            didUpdate = YES;
        }
    }
    
    
    
}


//字符串中一些图片没有宽高，懒加载图片之后，在此方法中得到图片宽高
//这个把宽高替换原来的html,然后重新设置富文本
- (void)configNoSizeImageView:(NSString *)url size:(CGSize)size attributedLabel:(DTAttributedLabel *)attributedLabel
{
    CGFloat widthPx = 0;
    CGFloat heightPx = 0;
    if (size.width>=self.viewMaxRect.size.width) {
        CGFloat imgSizeScale = size.height/size.width;
        widthPx = self.viewMaxRect.size.width;
        heightPx = widthPx * imgSizeScale;
    }else{
        widthPx = size.width;
        heightPx = size.height;
    }
    
    NSString *imageInfo = [NSString stringWithFormat:@"src=\"%@\"",url];
    NSString *sizeString = [NSString stringWithFormat:@" style=\"width:%.fpx; height:%.fpx;\"",widthPx,heightPx];
    NSString *newImageInfo = [NSString stringWithFormat:@"src=\"%@\"%@",url,sizeString];
    
    if (attributedLabel == self.attributedTitleLabel) {
        if ([self.examPaperSuitQuestionModel.serialNoHtmlTitle containsString:imageInfo]) {
            NSString *newHtml = [self.examPaperSuitQuestionModel.serialNoHtmlTitle stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.viewMaxRect];
            self.attributedTitleLabel.sd_layout.heightIs(textSize.height);
            [self.attributedTitleLabel updateLayout];
            self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
        }
    }
    
}

#pragma mark - private Methods
//使用HtmlString,和最大左右间距，计算视图的高度
- (CGSize)getAttributedTextHeightHtml:(NSString *)htmlString with_viewMaxRect:(CGRect)_viewMaxRect{
    //获取富文本
    NSAttributedString *attributedString =  [self getAttributedStringWithHtml:htmlString];
    //获取布局器
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attributedString];
    NSRange entireString = NSMakeRange(0, [attributedString length]);
    //获取Frame
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:_viewMaxRect range:entireString];
    //得到大小
    CGSize sizeNeeded = [layoutFrame frame].size;
    return sizeNeeded;
}

//Html->富文本NSAttributedString
- (NSAttributedString *)getAttributedStringWithHtml:(NSString *)htmlString{
    //获取富文本
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 10;//字体的行间距
    paragraphStyle.minimumLineHeight = 10;//最低行高
    paragraphStyle.minimumLineHeight = 18;//最大行高
    paragraphStyle.paragraphSpacing = 10;//段与段之间的间距
    paragraphStyle.firstLineHeadIndent = 0;//首行缩进
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSMutableAttributedString *attributedString = [[[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL] mutableCopy];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}



#pragma mark - UI布局
-(void)createUI{
    [self addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.tiXingNameLabel];
    [self.mainScrollView addSubview:self.attributedTitleLabel];
    [self.mainScrollView addSubview:self.fenShuBgImageView];
    
    [self.mainScrollView addSubview:self.grayView];
    [self.grayView addSubview:self.textView];
    
    
    [self.mainScrollView addSubview:self.photosContainerView];
    [self.mainScrollView addSubview:self.addPhotoBtn];
    [self.mainScrollView addSubview:self.photoTipLabel];
    
    self.mainScrollView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    self.tiXingNameLabel.sd_layout
        .topSpaceToView(self.mainScrollView, 20)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10)
        .autoHeightRatio(0);
    
    self.attributedTitleLabel.sd_layout
        .topSpaceToView(self.tiXingNameLabel, 15)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10)
        .heightIs(50);
    
    self.fenShuBgImageView.sd_layout
        .topSpaceToView(self.mainScrollView, 0)
        .rightEqualToView(self.mainScrollView)
        .widthIs(32)
        .heightEqualToWidth();
    
    self.fenShuLabel.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 5, 0, 0));
    
    
    self.grayView.sd_layout
        .topSpaceToView(self.attributedTitleLabel, 20)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10)
        .heightIs(200);
    
    
    self.textView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(10, 10, 10, 10));
    
    self.photosContainerView.sd_layout
        .topSpaceToView(self.grayView, 10)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10)
        .heightIs(0);
    
    
    self.addPhotoBtn.sd_layout
        .topSpaceToView(self.photosContainerView, 10)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10)
        .heightIs(40);
    self.addPhotoBtn.sd_cornerRadius=@4;
    
    self.photoTipLabel.sd_layout
        .topSpaceToView(self.addPhotoBtn, 10)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10)
        .autoHeightRatio(0);
    
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.photoTipLabel bottomMargin:50];
    
    
}

#pragma mark - LazyLoad
-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = UIColor.clearColor;
        _mainScrollView.bounces = NO;
        _mainScrollView.showsVerticalScrollIndicator = NO;
    }
    return _mainScrollView;
}

-(UILabel *)tiXingNameLabel{
    if (!_tiXingNameLabel) {
        _tiXingNameLabel = [[UILabel alloc] init];
        _tiXingNameLabel.numberOfLines=0;
        _tiXingNameLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _tiXingNameLabel.font = HXBoldFont(17);
    }
    return _tiXingNameLabel;
}

- (DTAttributedLabel *)attributedTitleLabel{
    if (!_attributedTitleLabel) {
        _attributedTitleLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _attributedTitleLabel.delegate = self;
    }
    return _attributedTitleLabel;
}

-(UIImageView *)fenShuBgImageView{
    if (!_fenShuBgImageView) {
        _fenShuBgImageView = [[UIImageView alloc] init];
        _fenShuBgImageView.clipsToBounds = YES;
        _fenShuBgImageView.image = [UIImage imageNamed:@"exam_score"];
        [_fenShuBgImageView addSubview:self.fenShuLabel];
    }
    return _fenShuBgImageView;
}

-(UILabel *)fenShuLabel{
    if (!_fenShuLabel) {
        _fenShuLabel = [[UILabel alloc] init];
        _fenShuLabel.textAlignment=NSTextAlignmentCenter;
        _fenShuLabel.textColor = COLOR_WITH_ALPHA(0xF8A528, 1);
        _fenShuLabel.font = HXFont(12);
    }
    return _fenShuLabel;
}

-(UIView *)grayView{
    if (!_grayView) {
        _grayView = [[UIView alloc] init];
        _grayView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.05);
    }
    return _grayView;
}

-(IQTextView *)textView{
    if (!_textView) {
        _textView = [[IQTextView alloc] init];
        _textView.backgroundColor = UIColor.clearColor;
        _textView.font = HXFont(16);
        _textView.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _textView.delegate = self;
        _textView.placeholder = @"请填写答案";
        _textView.placeholderTextColor = COLOR_WITH_ALPHA(0x999999, 1);
    }
    return _textView;
}

-(UIView *)photosContainerView{
    if (!_photosContainerView) {
        _photosContainerView = [[UIView alloc] init];
        _photosContainerView.backgroundColor = UIColor.clearColor;
    }
    return _photosContainerView;
}

-(UIButton *)addPhotoBtn{
    if (!_addPhotoBtn) {
        _addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addPhotoBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _addPhotoBtn.titleLabel.font = HXBoldFont(15);
        [_addPhotoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addPhotoBtn setTitle:@"添加照片" forState:UIControlStateNormal];
        _addPhotoBtn.backgroundColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        [_addPhotoBtn addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addPhotoBtn;
}

-(UILabel *)photoTipLabel{
    if (!_photoTipLabel) {
        _photoTipLabel = [[UILabel alloc] init];
        _photoTipLabel.textAlignment = NSTextAlignmentLeft;
        _photoTipLabel.font = HXFont(14);
        _photoTipLabel.textColor = COLOR_WITH_ALPHA(0xEF5959, 1);
        _photoTipLabel.numberOfLines = 0;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineSpacing = 10;//字体的行间距
        paragraphStyle.minimumLineHeight = 10;//最低行高
        paragraphStyle.minimumLineHeight = 18;//最大行高
        paragraphStyle.paragraphSpacing = 10;//段与段之间的间距
        paragraphStyle.firstLineHeadIndent = 0;//首行缩进
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        NSMutableAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:@"答题需要画图或者写计算过程的可以在纸张上完成，拍照成一张图片上传。如需删除图片，可以点击图片，右上角删除。"] mutableCopy];
        [attributedString addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        _photoTipLabel.attributedText = attributedString;
        _photoTipLabel.isAttributedContent = YES;
    }
    return _photoTipLabel;
}

-(UIButton *)deletePhotoBtn{
    if (!_deletePhotoBtn) {
        _deletePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deletePhotoBtn setImage:[UIImage imageNamed:@"trash_green"] forState:UIControlStateNormal];
        [_deletePhotoBtn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deletePhotoBtn;
}


- (HXPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _photoManager.selectPhotoFinishDismissAnimated = NO;
        _photoManager.cameraFinishDismissAnimated = YES;
        _photoManager.type = HXPhotoManagerSelectedTypePhoto;
        _photoManager.configuration.singleJumpEdit = YES;
        _photoManager.configuration.singleSelected = YES;
        _photoManager.configuration.lookGifPhoto = NO;
        _photoManager.configuration.lookLivePhoto = NO;
        _photoManager.configuration.photoEditConfigur.aspectRatio = HXPhotoEditAspectRatioType_Custom;
        _photoManager.configuration.photoEditConfigur.onlyCliping = YES;
    }
    return _photoManager;
}

-(GKPhotoBrowser *)browser{
    if (!_browser) {
        _browser = [GKPhotoBrowser photoBrowserWithPhotos:[NSArray array] currentIndex:0];
        _browser.showStyle = GKPhotoBrowserShowStyleZoom;        // 缩放显示
        _browser.hideStyle = GKPhotoBrowserHideStyleZoomScale;   // 缩放隐藏
        _browser.loadStyle = GKPhotoBrowserLoadStyleIndeterminateMask; // 不明确的加载方式带阴影
        _browser.maxZoomScale = 5.0f;
        _browser.doubleZoomScale = 2.0f;
        _browser.isAdaptiveSafeArea = YES;
        _browser.hidesCountLabel = YES;
        _browser.pageControl.hidden = YES;
        _browser.isScreenRotateDisabled = YES;
        _browser.isHideSourceView = NO;
        //为浏览器添加自定义遮罩视图
        [_browser setupCoverViews:@[self.deletePhotoBtn] layoutBlock:^(GKPhotoBrowser * _Nonnull photoBrowser, CGRect superFrame) {
            if (self.deletePhotoBtn) {
                self.deletePhotoBtn.sd_layout
                .rightSpaceToView(photoBrowser.contentView, 0)
                .topSpaceToView(photoBrowser.contentView, kNavigationBarHeight-kStatusBarHeight)
                .widthIs(60)
                .heightIs(60);
                
                self.deletePhotoBtn.imageView.sd_layout
                .centerXEqualToView(self.deletePhotoBtn)
                .centerYEqualToView(self.deletePhotoBtn)
                .widthIs(30)
                .heightEqualToWidth();
            }
        }];
    }
    return _browser;
}

@end

