//
//  HXExamChoiceCell.m
//  CloudClassroom
//
//  Created by mac on 2022/11/16.
//

#import "HXExamChoiceCell.h"



@interface HXExamChoiceCell ()<DTAttributedTextContentViewDelegate,DTLazyImageViewDelegate>
@property(nonatomic,assign) CGRect viewMaxRect;
@property(nonatomic,assign) CGRect choiceMaxRect;

@property(nonatomic,strong) UIScrollView *mainScrollView;
//题型（单选提，判断题，简答题.....）
@property(nonatomic,strong) UILabel *tiXingNameLabel;
//问题标题
@property(nonatomic,strong) DTAttributedLabel *attributedTitleLabel;
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

@property(nonatomic,strong) UIView *selectView;

@property (nonatomic,copy)  NSString *html;

@end

@implementation HXExamChoiceCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.viewMaxRect = CGRectMake(0, 0, kScreenWidth-20, CGFLOAT_HEIGHT_UNKNOWN);
        self.choiceMaxRect = CGRectMake(0, 0, kScreenWidth-55, CGFLOAT_HEIGHT_UNKNOWN);
        [self createUI];
    }
    return self;
}

#pragma mark - Event
-(void)selectChoice:(UIGestureRecognizer *)ges{
    
    if (self.examPaperSuitQuestionModel.isDuoXuan) {
        UIView *sender = ges.view;
        UIImageView *selectImagView = [sender.superview viewWithTag:1111111];
        
        if (sender==self.aTapView) {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[0];
            choiceModel.isSelected = !choiceModel.isSelected;
            selectImagView.image = [UIImage imageNamed:(choiceModel.isSelected?@"select_icon":@"noselect_icon")];
        }else if (sender==self.bTapView) {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[1];
            choiceModel.isSelected = !choiceModel.isSelected;
            selectImagView.image = [UIImage imageNamed:(choiceModel.isSelected?@"select_icon":@"noselect_icon")];
        }else if (sender==self.cTapView) {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[2];
            choiceModel.isSelected = !choiceModel.isSelected;
            selectImagView.image = [UIImage imageNamed:(choiceModel.isSelected?@"select_icon":@"noselect_icon")];
        }else if (sender==self.dTapView) {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[3];
            choiceModel.isSelected = !choiceModel.isSelected;
            selectImagView.image = [UIImage imageNamed:(choiceModel.isSelected?@"select_icon":@"noselect_icon")];
        }else {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[4];
            choiceModel.isSelected = !choiceModel.isSelected;
            selectImagView.image = [UIImage imageNamed:(choiceModel.isSelected?@"select_icon":@"noselect_icon")];
        }
        
    }else{
        UIView *sender = ges.view;
        if (sender==self.selectView) {
            return;
        }
        UIImageView *unSelectImagView = [self.selectView.superview viewWithTag:1111111];
        unSelectImagView.image = [UIImage imageNamed:@"noselect_icon"];
        
        UIImageView *selectImagView = [sender.superview viewWithTag:1111111];
        selectImagView.image = [UIImage imageNamed:@"select_icon"];
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
        
        [self.examPaperSuitQuestionModel.questionChoices enumerateObjectsUsingBlock:^(HXExamQuestionChoiceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx==selectIndex) {
                obj.isSelected = YES;
            }else{
                obj.isSelected = NO;
            }
        }];
    }
    
    
}

#pragma mark - Setter
-(void)setExamPaperSuitQuestionModel:(HXExamPaperSuitQuestionModel *)examPaperSuitQuestionModel{
    
    _examPaperSuitQuestionModel = examPaperSuitQuestionModel;
    
    self.tiXingNameLabel.text = examPaperSuitQuestionModel.pqt_title;
    
    CGSize textSize = [self getAttributedTextHeightHtml:examPaperSuitQuestionModel.serialNoHtmlTitle  with_viewMaxRect:self.viewMaxRect];
    self.attributedTitleLabel.sd_layout.heightIs(textSize.height);
    [self.attributedTitleLabel updateLayout];
    self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:examPaperSuitQuestionModel.serialNoHtmlTitle];
    [self.attributedTitleLabel relayoutText];
    
    //选项
    self.aChoiceView.hidden = YES;
    self.bChoiceView.hidden = YES;
    self.cChoiceView.hidden = YES;
    self.dChoiceView.hidden = YES;
    self.eChoiceView.hidden = YES;
    self.selectView = nil;
    
    BOOL isDuoXuan= self.examPaperSuitQuestionModel.isDuoXuan;
    
    if (examPaperSuitQuestionModel.questionChoices.count>0) {
        //A
        self.aChoiceView.hidden = NO;
        HXExamQuestionChoiceModel *aModel = examPaperSuitQuestionModel.questionChoices[0];
        CGSize AtextSize = [self getAttributedTextHeightHtml:aModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
        self.aChoiceLabel.sd_layout.heightIs(AtextSize.height);
        [self.aChoiceLabel updateLayout];
        self.aChoiceLabel.attributedString = [self getAttributedStringWithHtml:aModel.choice_staticContent];
        [self.aChoiceLabel relayoutText];
        self.aImageView.image = [UIImage imageNamed:(aModel.isSelected?@"select_icon":@"noselect_icon")];
        if (aModel.isSelected&&!isDuoXuan) {
            self.selectView = self.aTapView;
        }
        
        //B
        self.bChoiceView.hidden = NO;
        HXExamQuestionChoiceModel *bModel = examPaperSuitQuestionModel.questionChoices[1];
        CGSize BtextSize = [self getAttributedTextHeightHtml:bModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
        self.bChoiceLabel.sd_layout.heightIs(BtextSize.height);
        [self.bChoiceLabel updateLayout];
        self.bChoiceLabel.attributedString = [self getAttributedStringWithHtml:bModel.choice_staticContent];
        [self.bChoiceLabel relayoutText];
        self.bImageView.image = [UIImage imageNamed:(bModel.isSelected?@"select_icon":@"noselect_icon")];
        if (bModel.isSelected&&!isDuoXuan) {
            self.selectView = self.bTapView;
        }
        
        //C
        if (examPaperSuitQuestionModel.questionChoices.count>=3) {
            self.cChoiceView.hidden = NO;
            HXExamQuestionChoiceModel *cModel = examPaperSuitQuestionModel.questionChoices[2];
            CGSize CtextSize = [self getAttributedTextHeightHtml:cModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.cChoiceLabel.sd_layout.heightIs(CtextSize.height);
            [self.cChoiceLabel updateLayout];
            self.cChoiceLabel.attributedString = [self getAttributedStringWithHtml:cModel.choice_staticContent];
            [self.cChoiceLabel relayoutText];
            self.cImageView.image = [UIImage imageNamed:(cModel.isSelected?@"select_icon":@"noselect_icon")];
            if (cModel.isSelected&&!isDuoXuan) {
                self.selectView = self.cTapView;
            }
        }
        
        //D
        if (examPaperSuitQuestionModel.questionChoices.count>=4) {
            self.dChoiceView.hidden = NO;
            HXExamQuestionChoiceModel *dModel = examPaperSuitQuestionModel.questionChoices[3];
            CGSize DtextSize = [self getAttributedTextHeightHtml:dModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.dChoiceLabel.sd_layout.heightIs(DtextSize.height);
            [self.dChoiceLabel updateLayout];
            self.dChoiceLabel.attributedString = [self getAttributedStringWithHtml:dModel.choice_staticContent];
            [self.dChoiceLabel relayoutText];
            self.dImageView.image = [UIImage imageNamed:(dModel.isSelected?@"select_icon":@"noselect_icon")];
            if (dModel.isSelected&&!isDuoXuan) {
                self.selectView = self.dTapView;
            }
        }
        
        //E
        if (examPaperSuitQuestionModel.questionChoices.count>=5) {
            self.eChoiceView.hidden = NO;
            HXExamQuestionChoiceModel *eModel = examPaperSuitQuestionModel.questionChoices[4];
            CGSize EtextSize = [self getAttributedTextHeightHtml:eModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.eChoiceLabel.sd_layout.heightIs(EtextSize.height);
            [self.eChoiceLabel updateLayout];
            self.eChoiceLabel.attributedString = [self getAttributedStringWithHtml:eModel.choice_staticContent];
            [self.eChoiceLabel relayoutText];
            self.eImageView.image = [UIImage imageNamed:(eModel.isSelected?@"select_icon":@"noselect_icon")];
            if (eModel.isSelected&&!isDuoXuan) {
                self.selectView = self.eTapView;
            }
        }
    }
   
    
    
}


#pragma mark - Delegate：DTAttributedTextContentViewDelegate
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
        if ([self.examPaperSuitQuestionModel.serialNoHtmlTitle containsString:imageInfo]) {
            NSString *newHtml = [self.examPaperSuitQuestionModel.serialNoHtmlTitle stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.viewMaxRect];
            self.attributedTitleLabel.sd_layout.heightIs(textSize.height);
            [self.attributedTitleLabel updateLayout];
            self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.attributedTitleLabel relayoutText];
        }
    }else if (attributedLabel == self.aChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[0];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.aChoiceLabel.sd_layout.heightIs(textSize.height);
            [self.aChoiceLabel updateLayout];
            self.aChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.aChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.bChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[1];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.bChoiceLabel.sd_layout.heightIs(textSize.height);
            [self.bChoiceLabel updateLayout];
            self.bChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.bChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.cChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[2];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.cChoiceLabel.sd_layout.heightIs(textSize.height);
            [self.cChoiceLabel updateLayout];
            self.cChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.cChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.dChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[3];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.dChoiceLabel.sd_layout.heightIs(textSize.height);
            [self.dChoiceLabel updateLayout];
            self.dChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
            [self.dChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.dChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[4];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
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
    [self.mainScrollView addSubview:self.tiXingNameLabel];
    [self.mainScrollView addSubview:self.attributedTitleLabel];
    
    [self.mainScrollView addSubview:self.aChoiceView];
    [self.mainScrollView addSubview:self.bChoiceView];
    [self.mainScrollView addSubview:self.cChoiceView];
    [self.mainScrollView addSubview:self.dChoiceView];
    [self.mainScrollView addSubview:self.eChoiceView];
    
    self.mainScrollView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    self.tiXingNameLabel.sd_layout
    .topSpaceToView(self.mainScrollView, 20)
    .leftSpaceToView(self.mainScrollView, 10)
    .rightSpaceToView(self.mainScrollView, 10)
    .autoHeightRatio(0);
    
    self.attributedTitleLabel.sd_layout
    .topSpaceToView(self.tiXingNameLabel, 20)
    .leftSpaceToView(self.mainScrollView, 10)
    .rightSpaceToView(self.mainScrollView, 10)
    .heightIs(50);
    
    //A
    self.aChoiceView.sd_layout
    .topSpaceToView(self.attributedTitleLabel, 10)
    .leftSpaceToView(self.mainScrollView, 10)
    .rightSpaceToView(self.mainScrollView, 10);
    
    self.aImageView.sd_layout
    .centerYEqualToView(self.aChoiceView)
    .leftSpaceToView(self.aChoiceView, 0)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.aChoiceLabel.sd_layout
    .topSpaceToView(self.aChoiceView, 10)
    .leftSpaceToView(self.aImageView, 10)
    .rightSpaceToView(self.aChoiceView, 0)
    .heightIs(50);
    
    [self.aChoiceView setupAutoHeightWithBottomView:self.aChoiceLabel bottomMargin:10];
    self.aTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    //B
    self.bChoiceView.sd_layout
    .topSpaceToView(self.aChoiceView, 10)
    .leftEqualToView(self.aChoiceView)
    .rightEqualToView(self.aChoiceView);
    
    self.bImageView.sd_layout
    .centerYEqualToView(self.bChoiceView)
    .leftSpaceToView(self.bChoiceView, 0)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.bChoiceLabel.sd_layout
    .topSpaceToView(self.bChoiceView, 10)
    .leftSpaceToView(self.bImageView, 10)
    .rightSpaceToView(self.bChoiceView, 0)
    .heightIs(50);
    
    [self.bChoiceView setupAutoHeightWithBottomView:self.bChoiceLabel bottomMargin:10];
    self.bTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    //C
    self.cChoiceView.sd_layout
    .topSpaceToView(self.bChoiceView, 10)
    .leftEqualToView(self.aChoiceView)
    .rightEqualToView(self.aChoiceView);
    
    self.cImageView.sd_layout
    .centerYEqualToView(self.cChoiceView)
    .leftSpaceToView(self.cChoiceView, 0)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.cChoiceLabel.sd_layout
    .topSpaceToView(self.cChoiceView, 10)
    .leftSpaceToView(self.cImageView, 10)
    .rightSpaceToView(self.cChoiceView, 0)
    .heightIs(50);
    
    [self.cChoiceView setupAutoHeightWithBottomView:self.cChoiceLabel bottomMargin:10];
    self.cTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    //D
    self.dChoiceView.sd_layout
    .topSpaceToView(self.cChoiceView, 10)
    .leftEqualToView(self.aChoiceView)
    .rightEqualToView(self.aChoiceView);
    
    self.dImageView.sd_layout
    .centerYEqualToView(self.dChoiceView)
    .leftSpaceToView(self.dChoiceView, 0)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.dChoiceLabel.sd_layout
    .topSpaceToView(self.dChoiceView, 10)
    .leftSpaceToView(self.dImageView, 10)
    .rightSpaceToView(self.dChoiceView, 0)
    .heightIs(50);
    
    [self.dChoiceView setupAutoHeightWithBottomView:self.dChoiceLabel bottomMargin:10];
    self.dTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    //E
    self.eChoiceView.sd_layout
    .topSpaceToView(self.dChoiceView, 10)
    .leftEqualToView(self.aChoiceView)
    .rightEqualToView(self.aChoiceView);
    
    self.eImageView.sd_layout
    .centerYEqualToView(self.eChoiceView)
    .leftSpaceToView(self.eChoiceView, 0)
    .widthIs(25)
    .heightEqualToWidth();
    
    self.eChoiceLabel.sd_layout
    .topSpaceToView(self.eChoiceView, 10)
    .leftSpaceToView(self.eImageView, 10)
    .rightSpaceToView(self.eChoiceView, 0)
    .heightIs(50);
    
    [self.eChoiceView setupAutoHeightWithBottomView:self.eChoiceLabel bottomMargin:10];
    self.eTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.eChoiceView bottomMargin:50];
    
   
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
        _aTapView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.05);
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_aTapView addGestureRecognizer:tap];
    }
    return _aTapView;
}

-(UIImageView *)aImageView{
    if (!_aImageView) {
        _aImageView = [[UIImageView alloc] init];
        _aImageView.tag = 1111111;
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
        _bTapView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.05);
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_bTapView addGestureRecognizer:tap];
    }
    return _bTapView;
}


-(UIImageView *)bImageView{
    if (!_bImageView) {
        _bImageView = [[UIImageView alloc] init];
        _bImageView.tag = 1111111;
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
        _cTapView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.05);
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_cTapView addGestureRecognizer:tap];
    }
    return _cTapView;
}

-(UIImageView *)cImageView{
    if (!_cImageView) {
        _cImageView = [[UIImageView alloc] init];
        _cImageView.tag = 1111111;
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
        _dTapView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.05);
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_dTapView addGestureRecognizer:tap];
    }
    return _dTapView;
}

-(UIImageView *)dImageView{
    if (!_dImageView) {
        _dImageView = [[UIImageView alloc] init];
        _dImageView.tag = 1111111;
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
        _eTapView.backgroundColor = COLOR_WITH_ALPHA(0x000000, 0.05);
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_eTapView addGestureRecognizer:tap];
    }
    return _eTapView;
}

-(UIImageView *)eImageView{
    if (!_eImageView) {
        _eImageView = [[UIImageView alloc] init];
        _eImageView.tag = 1111111;
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

@end
