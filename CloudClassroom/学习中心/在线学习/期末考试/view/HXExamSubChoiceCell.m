//
//  HXExamSubChoiceCell.m
//  CloudClassroom
//
//  Created by mac on 2022/11/18.
//

#import "HXExamSubChoiceCell.h"
#import "IQTextView.h"
#import "NSString+Base64.h"
#import "HXPhotoManager.h"
#import "SDWebImage.h"
#import "GKPhotoBrowser.h"
#import "GKCover.h"
#import "UIViewController+HXExtension.h"

@interface HXExamSubChoiceCell ()<DTAttributedTextContentViewDelegate,DTLazyImageViewDelegate,UITextViewDelegate>
@property(nonatomic,assign) CGRect viewMaxRect;
@property(nonatomic,assign) CGRect choiceMaxRect;

@property(nonatomic,strong) UIScrollView *mainScrollView;
//问题标题
@property(nonatomic,strong) DTAttributedLabel *attributedTitleLabel;

//分数
@property(nonatomic,strong) UIImageView *fenShuBgImageView;
@property(nonatomic,strong) UILabel *fenShuLabel;

//A
@property(nonatomic,strong) UIView *aChoiceView;
@property(nonatomic,strong) UIImageView *aImageView;
@property(nonatomic,strong) DTAttributedLabel *aChoiceLabel;
@property(nonatomic,strong) UIView *aTapView;
//B
@property(nonatomic,strong) UIView *bChoiceView;
@property(nonatomic,strong) UIImageView *bImageView;
@property(nonatomic,strong) DTAttributedLabel *bChoiceLabel;
@property(nonatomic,strong) UIView *bTapView;
//C
@property(nonatomic,strong) UIView *cChoiceView;
@property(nonatomic,strong) UIImageView *cImageView;
@property(nonatomic,strong) DTAttributedLabel *cChoiceLabel;
@property(nonatomic,strong) UIView *cTapView;
//D
@property(nonatomic,strong) UIView *dChoiceView;
@property(nonatomic,strong) UIImageView *dImageView;
@property(nonatomic,strong) DTAttributedLabel *dChoiceLabel;
@property(nonatomic,strong) UIView *dTapView;
//E
@property(nonatomic,strong) UIView *eChoiceView;
@property(nonatomic,strong) UIImageView *eImageView;
@property(nonatomic,strong) DTAttributedLabel *eChoiceLabel;
@property(nonatomic,strong) UIView *eTapView;

@property(nonatomic,strong) UIView *grayView;
@property(nonatomic,strong) IQTextView *textView;

@property(nonatomic,strong) UIView *selectView;


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


@implementation HXExamSubChoiceCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.viewMaxRect = CGRectMake(0, 0, kScreenWidth-35, CGFLOAT_HEIGHT_UNKNOWN);
        self.choiceMaxRect = CGRectMake(0, 0, kScreenWidth-65, CGFLOAT_HEIGHT_UNKNOWN);
        self.photosArray = [NSMutableArray array];
        [self createUI];
    }
    return self;
}

#pragma mark - Event
-(void)selectChoice:(UIGestureRecognizer *)ges{
    
    UIView *sender = ges.view;
    if (sender==self.selectView) {
        return;
    }
    UIImageView *unSelectImagView = [self.selectView.superview viewWithTag:ExamChoiceImageViewTag];
    UIView *unSelectTapView = [self.selectView.superview viewWithTag:ExamChoiceTapViewTag];
    unSelectImagView.image = [UIImage imageNamed:@"noselect_icon"];
    unSelectTapView.backgroundColor = ExamUnSelectColor;
    
    UIImageView *selectImagView = [sender.superview viewWithTag:ExamChoiceImageViewTag];
    UIView *selectTapView = [sender.superview viewWithTag:ExamChoiceTapViewTag];
    selectImagView.image = [UIImage imageNamed:@"select_icon"];
    selectTapView.backgroundColor = ExamSelectColor;
    self.selectView = sender;
    NSInteger selectIndex;
    if (self.selectView==self.aTapView) {
        selectIndex=0;
    }else if (self.selectView==self.bTapView) {
        selectIndex=1;
    }else if (self.selectView==self.cTapView) {
        selectIndex=2;
    }else {
        selectIndex=3;
    }
    
    [self.examPaperSubQuestionModel.subQuestionChoices enumerateObjectsUsingBlock:^(HXExamSubQuestionChoicesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx==selectIndex) {
            obj.isSelected = YES;
            self.examPaperSubQuestionModel.answer = obj.subChoice_order;
        }else{
            obj.isSelected = NO;
        }
    }];
    
    
}

#pragma mark - Setter
-(void)setExamPaperSubQuestionModel:(HXExamPaperSubQuestionModel *)examPaperSubQuestionModel{
    
    _examPaperSubQuestionModel = examPaperSubQuestionModel;
    
    
    //设置偏移归位
    [self.mainScrollView setContentOffset:CGPointZero];
    
    CGSize textSize = [self getAttributedTextHeightHtml:examPaperSubQuestionModel.serialNoHtmlTitle  with_viewMaxRect:self.viewMaxRect];
    self.attributedTitleLabel.sd_layout.heightIs(textSize.height);
    [self.attributedTitleLabel updateLayout];
    self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:examPaperSubQuestionModel.serialNoHtmlTitle];
    //分数
    self.fenShuLabel.text = [examPaperSubQuestionModel.sub_scoreStr stringByAppendingString:@"'"];
    
    //选项
    self.aChoiceView.hidden = YES;
    self.bChoiceView.hidden = YES;
    self.cChoiceView.hidden = YES;
    self.dChoiceView.hidden = YES;
    self.eChoiceView.hidden = YES;
    self.grayView.hidden = YES;
    self.photosContainerView.hidden = YES;
    self.addPhotoBtn.hidden = YES;
    self.photoTipLabel.hidden = YES;
    self.selectView = nil;
    
    self.aTapView.backgroundColor = ExamUnSelectColor;
    self.bTapView.backgroundColor = ExamUnSelectColor;
    self.cTapView.backgroundColor = ExamUnSelectColor;
    self.dTapView.backgroundColor = ExamUnSelectColor;
    self.eTapView.backgroundColor = ExamUnSelectColor;
    
    if (examPaperSubQuestionModel.subQuestionChoices==0) {//问答题
        self.aChoiceView.hidden = YES;
        self.bChoiceView.hidden = YES;
        self.cChoiceView.hidden = YES;
        self.dChoiceView.hidden = YES;
        self.eChoiceView.hidden = YES;
        self.grayView.hidden = NO;
        self.photosContainerView.hidden = NO;
        self.addPhotoBtn.hidden = NO;
        self.photoTipLabel.hidden = NO;
        self.selectView = nil;
        self.textView.text = examPaperSubQuestionModel.answer;
        
        //处理附件图片
        if (examPaperSubQuestionModel.fuJianImages.count==0) {//初始化
            examPaperSubQuestionModel.fuJianImages = [NSMutableArray array];
        }
        [self.photosArray removeAllObjects];
        [self.photosArray addObjectsFromArray:examPaperSubQuestionModel.fuJianImages];
        [self refreshPhotosContainerViewLayout];
        
    }else{//选择题
        self.grayView.hidden = YES;
        if (examPaperSubQuestionModel.subQuestionChoices.count>0) {
            //A
            self.aChoiceView.hidden = NO;
            HXExamSubQuestionChoicesModel *aModel = examPaperSubQuestionModel.subQuestionChoices[0];
            CGSize AtextSize = [self getAttributedTextHeightHtml:aModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.aChoiceLabel.sd_layout.heightIs(AtextSize.height);
            [self.aChoiceLabel updateLayout];
            self.aChoiceLabel.attributedString = [self getAttributedStringWithHtml:aModel.subChoice_staticContent];
            [self.aChoiceLabel relayoutText];
            self.aImageView.image = [UIImage imageNamed:(aModel.isSelected?@"select_icon":@"noselect_icon")];
            if (aModel.isSelected) {
                self.selectView = self.aTapView;
                self.aTapView.backgroundColor = (aModel.isSelected?ExamSelectColor:ExamUnSelectColor);
            }
            
            //B
            self.bChoiceView.hidden = NO;
            HXExamSubQuestionChoicesModel *bModel = examPaperSubQuestionModel.subQuestionChoices[1];
            CGSize BtextSize = [self getAttributedTextHeightHtml:bModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.bChoiceLabel.sd_layout.heightIs(BtextSize.height);
            [self.bChoiceLabel updateLayout];
            self.bChoiceLabel.attributedString = [self getAttributedStringWithHtml:bModel.subChoice_staticContent];
            [self.bChoiceLabel relayoutText];
            self.bImageView.image = [UIImage imageNamed:(bModel.isSelected?@"select_icon":@"noselect_icon")];
            if (bModel.isSelected) {
                self.selectView = self.bTapView;
                self.bTapView.backgroundColor = (bModel.isSelected?ExamSelectColor:ExamUnSelectColor);
            }
            
            //C
            if (examPaperSubQuestionModel.subQuestionChoices.count>=3) {
                self.cChoiceView.hidden = NO;
                HXExamSubQuestionChoicesModel *cModel = examPaperSubQuestionModel.subQuestionChoices[2];
                CGSize CtextSize = [self getAttributedTextHeightHtml:cModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
                self.cChoiceLabel.sd_layout.heightIs(CtextSize.height);
                [self.cChoiceLabel updateLayout];
                self.cChoiceLabel.attributedString = [self getAttributedStringWithHtml:cModel.subChoice_staticContent];
                [self.cChoiceLabel relayoutText];
                self.cImageView.image = [UIImage imageNamed:(cModel.isSelected?@"select_icon":@"noselect_icon")];
                if (cModel.isSelected) {
                    self.selectView = self.cTapView;
                    self.cTapView.backgroundColor = (cModel.isSelected?ExamSelectColor:ExamUnSelectColor);
                }
            }
            
            //D
            if (examPaperSubQuestionModel.subQuestionChoices.count>=4) {
                self.dChoiceView.hidden = NO;
                HXExamSubQuestionChoicesModel *dModel = examPaperSubQuestionModel.subQuestionChoices[3];
                CGSize DtextSize = [self getAttributedTextHeightHtml:dModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
                self.dChoiceLabel.sd_layout.heightIs(DtextSize.height);
                [self.dChoiceLabel updateLayout];
                self.dChoiceLabel.attributedString = [self getAttributedStringWithHtml:dModel.subChoice_staticContent];
                [self.dChoiceLabel relayoutText];
                self.dImageView.image = [UIImage imageNamed:(dModel.isSelected?@"select_icon":@"noselect_icon")];
                if (dModel.isSelected) {
                    self.selectView = self.dTapView;
                    self.dTapView.backgroundColor = (dModel.isSelected?ExamSelectColor:ExamUnSelectColor);
                }
            }
            
            //E
            if (examPaperSubQuestionModel.subQuestionChoices.count>=5) {
                self.eChoiceView.hidden = NO;
                HXExamSubQuestionChoicesModel *eModel = examPaperSubQuestionModel.subQuestionChoices[4];
                CGSize EtextSize = [self getAttributedTextHeightHtml:eModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
                self.eChoiceLabel.sd_layout.heightIs(EtextSize.height);
                [self.eChoiceLabel updateLayout];
                self.eChoiceLabel.attributedString = [self getAttributedStringWithHtml:eModel.subChoice_staticContent];
                [self.eChoiceLabel relayoutText];
                self.eImageView.image = [UIImage imageNamed:(eModel.isSelected?@"select_icon":@"noselect_icon")];
                if (eModel.isSelected) {
                    self.selectView = self.eTapView;
                    self.eTapView.backgroundColor = (eModel.isSelected?ExamSelectColor:ExamUnSelectColor);
                }
            }
        }
    }
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
        [weakSelf.examPaperSubQuestionModel.fuJianImages addObject:image];
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
    [self.examPaperSubQuestionModel.fuJianImages removeObjectAtIndex:self.currentIndex];
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
    self.examPaperSubQuestionModel.answer = textView.text;
}



#pragma mark - Delegate：DTAttributedTextContentViewDelegate
//图片占位
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    
    if([attachment isKindOfClass:[DTImageTextAttachment class]]){
        NSString *imageURL = [NSString stringWithFormat:@"%@", attachment.contentURL];
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
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





#pragma mark  Delegate：DTLazyImageViewDelegate
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
    
    for (DTTextAttachment *oneAttachment in [self.aChoiceLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize attributedLabel:self.aChoiceLabel];
            didUpdate = YES;
        }
    }
    
    for (DTTextAttachment *oneAttachment in [self.bChoiceLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize attributedLabel:self.bChoiceLabel];
            didUpdate = YES;
        }
    }
    
    for (DTTextAttachment *oneAttachment in [self.cChoiceLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize attributedLabel:self.cChoiceLabel];
            didUpdate = YES;
        }
    }
    
    for (DTTextAttachment *oneAttachment in [self.dChoiceLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize attributedLabel:self.dChoiceLabel];
            didUpdate = YES;
        }
    }
    
    for (DTTextAttachment *oneAttachment in [self.eChoiceLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize attributedLabel:self.eChoiceLabel];
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
        if ([self.examPaperSubQuestionModel.serialNoHtmlTitle containsString:imageInfo]) {
            NSString *newHtml = [self.examPaperSubQuestionModel.serialNoHtmlTitle stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.viewMaxRect];
            self.attributedTitleLabel.sd_layout.heightIs(textSize.height);
            [self.attributedTitleLabel updateLayout];
            self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.attributedTitleLabel relayoutText];
        }
    }else if (attributedLabel == self.aChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[0];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.aChoiceLabel.sd_layout.heightIs(textSize.height);
            [self.aChoiceLabel updateLayout];
            self.aChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.aChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.bChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[1];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.bChoiceLabel.sd_layout.heightIs(textSize.height);
            [self.bChoiceLabel updateLayout];
            self.bChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.bChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.cChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[2];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.cChoiceLabel.sd_layout.heightIs(textSize.height);
            [self.cChoiceLabel updateLayout];
            self.cChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.cChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.dChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[3];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.dChoiceLabel.sd_layout.heightIs(textSize.height);
            [self.dChoiceLabel updateLayout];
            self.dChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.dChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.dChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[4];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.eChoiceLabel.sd_layout.heightIs(textSize.height);
            [self.eChoiceLabel updateLayout];
            self.eChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.eChoiceLabel relayoutText];
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
    NSMutableAttributedString *attributedString = [[[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL] mutableCopy];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}



#pragma mark - UI布局
-(void)createUI{
    [self addSubview:self.mainScrollView];
   
    [self.mainScrollView addSubview:self.attributedTitleLabel];
    [self.mainScrollView addSubview:self.fenShuBgImageView];
    
    
    [self.mainScrollView addSubview:self.aChoiceView];
    [self.mainScrollView addSubview:self.bChoiceView];
    [self.mainScrollView addSubview:self.cChoiceView];
    [self.mainScrollView addSubview:self.dChoiceView];
    [self.mainScrollView addSubview:self.eChoiceView];
    
    [self.mainScrollView addSubview:self.grayView];
    [self.grayView addSubview:self.textView];
    
    [self.mainScrollView addSubview:self.photosContainerView];
    [self.mainScrollView addSubview:self.addPhotoBtn];
    [self.mainScrollView addSubview:self.photoTipLabel];
    
    self.mainScrollView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    
    self.attributedTitleLabel.sd_layout
    .topSpaceToView(self.mainScrollView, 10)
    .leftSpaceToView(self.mainScrollView, 10)
    .rightSpaceToView(self.mainScrollView, 25)
    .heightIs(50);
    
    self.fenShuBgImageView.sd_layout
    .topSpaceToView(self.mainScrollView, 0)
    .rightEqualToView(self.mainScrollView)
    .widthIs(35)
    .heightEqualToWidth();
    
    self.fenShuLabel.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    //A
    self.aChoiceView.sd_layout
    .topSpaceToView(self.attributedTitleLabel, 10)
    .leftSpaceToView(self.mainScrollView, 10)
    .rightSpaceToView(self.mainScrollView, 10);
    
    self.aImageView.sd_layout
    .centerYEqualToView(self.aChoiceView)
    .leftSpaceToView(self.aChoiceView, 10)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.aChoiceLabel.sd_layout
    .topSpaceToView(self.aChoiceView, 10)
    .leftSpaceToView(self.aImageView, 10)
    .rightSpaceToView(self.aChoiceView, 0)
    .heightIs(50);
    
    [self.aChoiceView setupAutoHeightWithBottomView:self.aChoiceLabel bottomMargin:10];
    self.aTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    self.aTapView.sd_cornerRadius = @4;
    
    //B
    self.bChoiceView.sd_layout
    .topSpaceToView(self.aChoiceView, 10)
    .leftEqualToView(self.aChoiceView)
    .rightEqualToView(self.aChoiceView);
    
    self.bImageView.sd_layout
    .centerYEqualToView(self.bChoiceView)
    .leftSpaceToView(self.bChoiceView, 10)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.bChoiceLabel.sd_layout
    .topSpaceToView(self.bChoiceView, 10)
    .leftSpaceToView(self.bImageView, 10)
    .rightSpaceToView(self.bChoiceView, 0)
    .heightIs(50);
    
    [self.bChoiceView setupAutoHeightWithBottomView:self.bChoiceLabel bottomMargin:10];
    self.bTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    self.bTapView.sd_cornerRadius = @4;
    //C
    self.cChoiceView.sd_layout
    .topSpaceToView(self.bChoiceView, 10)
    .leftEqualToView(self.aChoiceView)
    .rightEqualToView(self.aChoiceView);
    
    self.cImageView.sd_layout
    .centerYEqualToView(self.cChoiceView)
    .leftSpaceToView(self.cChoiceView, 10)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.cChoiceLabel.sd_layout
    .topSpaceToView(self.cChoiceView, 10)
    .leftSpaceToView(self.cImageView, 10)
    .rightSpaceToView(self.cChoiceView, 0)
    .heightIs(50);
    
    [self.cChoiceView setupAutoHeightWithBottomView:self.cChoiceLabel bottomMargin:10];
    self.cTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    self.cTapView.sd_cornerRadius = @4;
    
    //D
    self.dChoiceView.sd_layout
    .topSpaceToView(self.cChoiceView, 10)
    .leftEqualToView(self.aChoiceView)
    .rightEqualToView(self.aChoiceView);
    
    self.dImageView.sd_layout
    .centerYEqualToView(self.dChoiceView)
    .leftSpaceToView(self.dChoiceView, 10)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.dChoiceLabel.sd_layout
    .topSpaceToView(self.dChoiceView, 10)
    .leftSpaceToView(self.dImageView, 10)
    .rightSpaceToView(self.dChoiceView, 0)
    .heightIs(50);
    
    [self.dChoiceView setupAutoHeightWithBottomView:self.dChoiceLabel bottomMargin:10];
    self.dTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    self.dTapView.sd_cornerRadius = @4;
    
    //E
    self.eChoiceView.sd_layout
    .topSpaceToView(self.dChoiceView, 10)
    .leftEqualToView(self.aChoiceView)
    .rightEqualToView(self.aChoiceView);
    
    self.eImageView.sd_layout
    .centerYEqualToView(self.eChoiceView)
    .leftSpaceToView(self.eChoiceView, 10)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.eChoiceLabel.sd_layout
    .topSpaceToView(self.eChoiceView, 10)
    .leftSpaceToView(self.eImageView, 10)
    .rightSpaceToView(self.eChoiceView, 0)
    .heightIs(50);
    
    [self.eChoiceView setupAutoHeightWithBottomView:self.eChoiceLabel bottomMargin:10];
    self.eTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    self.eTapView.sd_cornerRadius = @4;
    
    ///
    self.grayView.sd_layout
    .topSpaceToView(self.attributedTitleLabel, 10)
    .leftSpaceToView(self.mainScrollView, 10)
    .rightSpaceToView(self.mainScrollView, 10)
    .heightIs(200);

    [self.grayView updateLayout];
    
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
    
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.photoTipLabel bottomMargin:ExamSubChoiceCellHeight];
    

   
}

#pragma mark - LazyLoad
-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = UIColor.clearColor;
        _mainScrollView.bounces = NO;
        _mainScrollView.showsVerticalScrollIndicator = YES;
    }
    return _mainScrollView;
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
        _fenShuLabel.textAlignment= NSTextAlignmentCenter;
        _fenShuLabel.textColor = COLOR_WITH_ALPHA(0xF8A528, 1);
        _fenShuLabel.font = HXFont(9);
    }
    return _fenShuLabel;
}

-(UIView *)aChoiceView{
    if (!_aChoiceView) {
        _aChoiceView = [[UIView alloc] init];
        [_aChoiceView addSubview:self.aImageView];
        [_aChoiceView addSubview:self.aChoiceLabel];
        [_aChoiceView addSubview:self.aTapView];
    }
    return _aChoiceView;
}

-(UIView *)aTapView{
    if (!_aTapView) {
        _aTapView = [[UIView alloc] init];
        _aTapView.tag = ExamChoiceTapViewTag;
        _aTapView.backgroundColor =  ExamUnSelectColor;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_aTapView addGestureRecognizer:tap];
    }
    return _aTapView;
}

-(UIImageView *)aImageView{
    if (!_aImageView) {
        _aImageView = [[UIImageView alloc] init];
        _aImageView.tag = ExamChoiceImageViewTag;
        _aImageView.image = [UIImage imageNamed:@"noselect_icon"];
        _aImageView.userInteractionEnabled = NO;
    }
    return _aImageView;
}

- (DTAttributedLabel *)aChoiceLabel{
    if (!_aChoiceLabel) {
        _aChoiceLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _aChoiceLabel.delegate = self;
        _aChoiceLabel.userInteractionEnabled = NO;
    }
    return _aChoiceLabel;
}

-(UIView *)bChoiceView{
    if (!_bChoiceView) {
        _bChoiceView = [[UIView alloc] init];
        [_bChoiceView addSubview:self.bImageView];
        [_bChoiceView addSubview:self.bChoiceLabel];
        [_bChoiceView addSubview:self.bTapView];
    }
    return _bChoiceView;
}

-(UIView *)bTapView{
    if (!_bTapView) {
        _bTapView = [[UIView alloc] init];
        _bTapView.tag = ExamChoiceTapViewTag;
        _bTapView.backgroundColor =  ExamUnSelectColor;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_bTapView addGestureRecognizer:tap];
    }
    return _bTapView;
}


-(UIImageView *)bImageView{
    if (!_bImageView) {
        _bImageView = [[UIImageView alloc] init];
        _bImageView.tag = ExamChoiceImageViewTag;
        _bImageView.image = [UIImage imageNamed:@"noselect_icon"];
        _bImageView.userInteractionEnabled = NO;
    }
    return _bImageView;
}

- (DTAttributedLabel *)bChoiceLabel{
    if (!_bChoiceLabel) {
        _bChoiceLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _bChoiceLabel.delegate = self;
        _bChoiceLabel.userInteractionEnabled = NO;
    }
    return _bChoiceLabel;
}

-(UIView *)cChoiceView{
    if (!_cChoiceView) {
        _cChoiceView = [[UIView alloc] init];
        [_cChoiceView addSubview:self.cImageView];
        [_cChoiceView addSubview:self.cChoiceLabel];
        [_cChoiceView addSubview:self.cTapView];
    }
    return _cChoiceView;
}

-(UIView *)cTapView{
    if (!_cTapView) {
        _cTapView = [[UIView alloc] init];
        _cTapView.tag = ExamChoiceTapViewTag;
        _cTapView.backgroundColor =  ExamUnSelectColor;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_cTapView addGestureRecognizer:tap];
    }
    return _cTapView;
}

-(UIImageView *)cImageView{
    if (!_cImageView) {
        _cImageView = [[UIImageView alloc] init];
        _cImageView.tag = ExamChoiceImageViewTag;
        _cImageView.image = [UIImage imageNamed:@"noselect_icon"];
        _cImageView.userInteractionEnabled = NO;
    }
    return _cImageView;
}

- (DTAttributedLabel *)cChoiceLabel{
    if (!_cChoiceLabel) {
        _cChoiceLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _cChoiceLabel.delegate = self;
        _cChoiceLabel.userInteractionEnabled = NO;
    }
    return _cChoiceLabel;
}

-(UIView *)dChoiceView{
    if (!_dChoiceView) {
        _dChoiceView = [[UIView alloc] init];
        [_dChoiceView addSubview:self.dImageView];
        [_dChoiceView addSubview:self.dChoiceLabel];
        [_dChoiceView addSubview:self.dTapView];
    }
    return _dChoiceView;
}

-(UIView *)dTapView{
    if (!_dTapView) {
        _dTapView = [[UIView alloc] init];
        _dTapView.tag = ExamChoiceTapViewTag;
        _dTapView.backgroundColor =  ExamUnSelectColor;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_dTapView addGestureRecognizer:tap];
    }
    return _dTapView;
}

-(UIImageView *)dImageView{
    if (!_dImageView) {
        _dImageView = [[UIImageView alloc] init];
        _dImageView.tag = ExamChoiceImageViewTag;
        _dImageView.image = [UIImage imageNamed:@"noselect_icon"];
        _dImageView.userInteractionEnabled = NO;
    }
    return _dImageView;
}

- (DTAttributedLabel *)dChoiceLabel{
    if (!_dChoiceLabel) {
        _dChoiceLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _dChoiceLabel.delegate = self;
        _dChoiceLabel.userInteractionEnabled = NO;
    }
    return _dChoiceLabel;
}

-(UIView *)eChoiceView{
    if (!_eChoiceView) {
        _eChoiceView = [[UIView alloc] init];
        [_eChoiceView addSubview:self.eImageView];
        [_eChoiceView addSubview:self.eChoiceLabel];
        [_eChoiceView addSubview:self.eTapView];
    }
    return _eChoiceView;
}

-(UIView *)eTapView{
    if (!_eTapView) {
        _eTapView = [[UIView alloc] init];
        _eTapView.tag = ExamChoiceTapViewTag;
        _eTapView.backgroundColor =  ExamUnSelectColor;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_eTapView addGestureRecognizer:tap];
    }
    return _eTapView;
}

-(UIImageView *)eImageView{
    if (!_eImageView) {
        _eImageView = [[UIImageView alloc] init];
        _eImageView.tag = ExamChoiceImageViewTag;
        _eImageView.image = [UIImage imageNamed:@"noselect_icon"];
        _eImageView.userInteractionEnabled = NO;
    }
    return _eImageView;
}

- (DTAttributedLabel *)eChoiceLabel{
    if (!_eChoiceLabel) {
        _eChoiceLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _eChoiceLabel.delegate = self;
        _eChoiceLabel.userInteractionEnabled = NO;
    }
    return _eChoiceLabel;
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

