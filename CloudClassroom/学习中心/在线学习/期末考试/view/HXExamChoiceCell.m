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
//作答情况
@property(nonatomic,strong) UILabel *answerTipLabel;
//分数
@property(nonatomic,strong) UIImageView *fenShuBgImageView;
@property(nonatomic,strong) UILabel *fenShuLabel;
//A
@property(nonatomic,strong) UIView *aChoiceView;
@property(nonatomic,strong) UILabel *aLabel;
@property(nonatomic,strong) DTAttributedLabel *aChoiceLabel;
@property(nonatomic,strong) UIView *aTapView;
//B
@property(nonatomic,strong) UIView *bChoiceView;
@property(nonatomic,strong) UILabel *bLabel;
@property(nonatomic,strong) DTAttributedLabel *bChoiceLabel;
@property(nonatomic,strong) UIView *bTapView;
//C
@property(nonatomic,strong) UIView *cChoiceView;
@property(nonatomic,strong) UILabel *cLabel;
@property(nonatomic,strong) DTAttributedLabel *cChoiceLabel;
@property(nonatomic,strong) UIView *cTapView;
//D
@property(nonatomic,strong) UIView *dChoiceView;
@property(nonatomic,strong) UILabel *dLabel;
@property(nonatomic,strong) DTAttributedLabel *dChoiceLabel;
@property(nonatomic,strong) UIView *dTapView;
//E
@property(nonatomic,strong) UIView *eChoiceView;
@property(nonatomic,strong) UILabel *eLabel;
@property(nonatomic,strong) DTAttributedLabel *eChoiceLabel;
@property(nonatomic,strong) UIView *eTapView;

@property(nonatomic,strong) UIView *selectView;

@property (nonatomic,copy)  NSString *html;

@property(nonatomic,strong) UIView *answerView;
//正确答案：
@property(nonatomic,strong) UILabel *rightLabel;
@property(nonatomic,strong) UILabel *rightContentLabel;
//已选答案：
@property(nonatomic,strong) UILabel *selectLabel;
@property(nonatomic,strong) UILabel *selectContentLabel;
//解析
@property(nonatomic,strong) UIView *jieXiView;
@property(nonatomic,strong) DTAttributedLabel *jieXiLabel;

@end

@implementation HXExamChoiceCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.viewMaxRect = CGRectMake(0, 0, kScreenWidth-20, CGFLOAT_HEIGHT_UNKNOWN);
        self.choiceMaxRect = CGRectMake(0, 0, kScreenWidth-65, CGFLOAT_HEIGHT_UNKNOWN);
        [self createUI];
    }
    return self;
}

#pragma mark - Event  选择题点击
-(void)selectChoice:(UIGestureRecognizer *)ges{
    
    if (self.examPaperSuitQuestionModel.isDuoXuan) {
        UIView *sender = ges.view;
        
        
        __block NSMutableArray *choices = [NSMutableArray array];
        
        [self.examPaperSuitQuestionModel.questionChoices enumerateObjectsUsingBlock:^(HXExamQuestionChoiceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HXExamQuestionChoiceModel *examQuestionChoiceModel = obj;
            if (examQuestionChoiceModel.isSelected) {
                [choices addObject:examQuestionChoiceModel.choice_order];
            }
        }];
        
        if (sender==self.aTapView) {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[0];
            choiceModel.isSelected = !choiceModel.isSelected;
            
            self.aTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.choice_order];
            }else{
                [choices removeObject:choiceModel.choice_order];
            }
        }else if (sender==self.bTapView) {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[1];
            choiceModel.isSelected = !choiceModel.isSelected;
            
            self.bTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.choice_order];
            }else{
                [choices removeObject:choiceModel.choice_order];
            }
        }else if (sender==self.cTapView) {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[2];
            choiceModel.isSelected = !choiceModel.isSelected;
            
            self.cTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.choice_order];
            }else{
                [choices removeObject:choiceModel.choice_order];
            }
        }else if (sender==self.dTapView) {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[3];
            choiceModel.isSelected = !choiceModel.isSelected;
            
            self.dTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.choice_order];
            }else{
                [choices removeObject:choiceModel.choice_order];
            }
        }else {
            HXExamQuestionChoiceModel *choiceModel = self.examPaperSuitQuestionModel.questionChoices[4];
            choiceModel.isSelected = !choiceModel.isSelected;
            
            self.eTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.choice_order];
            }else{
                [choices removeObject:choiceModel.choice_order];
            }
        }
        if (choices.count>0) {
            //数组按字母升序排序
            NSArray*result = [choices sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1 , id _Nonnull obj2){
                return [obj1 compare:obj2 options:NSLiteralSearch]; //升序
            }];
            self.examPaperSuitQuestionModel.answer = [result componentsJoinedByString:@""];
        }else{
            self.examPaperSuitQuestionModel.answer = @"";
        }
        
    }else{
        UIView *sender = ges.view;
        if (sender==self.selectView) {
            return;
        }
        
        UIView *unSelectTapView = [self.selectView.superview viewWithTag:ExamChoiceTapViewTag];
        unSelectTapView.backgroundColor = ExamUnSelectColor;
        
        
        UIView *selectTapView = [sender.superview viewWithTag:ExamChoiceTapViewTag];
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
        
        [self.examPaperSuitQuestionModel.questionChoices enumerateObjectsUsingBlock:^(HXExamQuestionChoiceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx==selectIndex) {
                obj.isSelected = YES;
                self.examPaperSuitQuestionModel.answer =obj.choice_order;
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
    self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:examPaperSuitQuestionModel.serialNoHtmlTitle fontColor:nil];
    [self.attributedTitleLabel relayoutText];
    //分数
    self.fenShuLabel.text = [examPaperSuitQuestionModel.psq_scoreStr stringByAppendingString:@"'"];
    
    
    self.answerTipLabel.sd_layout
        .topSpaceToView(self.attributedTitleLabel, 20)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10)
        .heightIs(20);
    
    //选项
    self.aChoiceView.hidden = YES;
    self.bChoiceView.hidden = YES;
    self.cChoiceView.hidden = YES;
    self.dChoiceView.hidden = YES;
    self.eChoiceView.hidden = YES;
    self.selectView = nil;
    self.aTapView.backgroundColor = ExamUnSelectColor;
    self.bTapView.backgroundColor = ExamUnSelectColor;
    self.cTapView.backgroundColor = ExamUnSelectColor;
    self.dTapView.backgroundColor = ExamUnSelectColor;
    self.eTapView.backgroundColor = ExamUnSelectColor;
    //查看答卷，不能作答，禁用选择
    self.aTapView.userInteractionEnabled = self.bTapView.userInteractionEnabled = self.cTapView.userInteractionEnabled = self.dTapView.userInteractionEnabled = self.eTapView.userInteractionEnabled = examPaperSuitQuestionModel.isContinuerExam;
    
    
    BOOL isDuoXuan= self.examPaperSuitQuestionModel.isDuoXuan;
    
    if (examPaperSuitQuestionModel.questionChoices.count>0) {
        //A
        self.aChoiceView.hidden = NO;
        HXExamQuestionChoiceModel *aModel = examPaperSuitQuestionModel.questionChoices[0];
        CGSize AtextSize = [self getAttributedTextHeightHtml:aModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
        self.aChoiceLabel.sd_layout.heightIs(AtextSize.height);
        [self.aChoiceLabel updateLayout];
        self.aChoiceLabel.attributedString = [self getAttributedStringWithHtml:aModel.choice_staticContent fontColor:nil];
        [self.aChoiceLabel relayoutText];
        if (aModel.isSelected&&!isDuoXuan) {
            self.selectView = self.aTapView;
            self.aTapView.backgroundColor =  ExamSelectColor;
        }else{
            self.aTapView.backgroundColor = (aModel.isSelected?ExamSelectColor:ExamUnSelectColor);
        }
        
        if (examPaperSuitQuestionModel.questionChoices.count>=2) {
            //B
            self.bChoiceView.hidden = NO;
            HXExamQuestionChoiceModel *bModel = examPaperSuitQuestionModel.questionChoices[1];
            CGSize BtextSize = [self getAttributedTextHeightHtml:bModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.bChoiceLabel.sd_layout.topSpaceToView(self.bChoiceView, 10).heightIs(BtextSize.height);
            [self.bChoiceLabel updateLayout];
            self.bChoiceLabel.attributedString = [self getAttributedStringWithHtml:bModel.choice_staticContent fontColor:nil];
            [self.bChoiceLabel relayoutText];
            
            if (bModel.isSelected&&!isDuoXuan) {
                self.selectView = self.bTapView;
                self.bTapView.backgroundColor =  ExamSelectColor;
            }else{
                self.bTapView.backgroundColor = (bModel.isSelected?ExamSelectColor:ExamUnSelectColor);
            }
        }else{
            self.bChoiceLabel.sd_layout.topSpaceToView(self.bChoiceView, 0).heightIs(0);
            [self.bChoiceLabel updateLayout];
        }
        
        
        //C
        if (examPaperSuitQuestionModel.questionChoices.count>=3) {
            self.cChoiceView.hidden = NO;
            HXExamQuestionChoiceModel *cModel = examPaperSuitQuestionModel.questionChoices[2];
            CGSize CtextSize = [self getAttributedTextHeightHtml:cModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.cChoiceLabel.sd_layout.topSpaceToView(self.cChoiceView, 10).heightIs(CtextSize.height);
            [self.cChoiceLabel updateLayout];
            self.cChoiceLabel.attributedString = [self getAttributedStringWithHtml:cModel.choice_staticContent fontColor:nil];
            [self.cChoiceLabel relayoutText];
            
            if (cModel.isSelected&&!isDuoXuan) {
                self.selectView = self.cTapView;
                self.cTapView.backgroundColor =  ExamSelectColor;
            }else{
                self.cTapView.backgroundColor = (cModel.isSelected?ExamSelectColor:ExamUnSelectColor);
            }
        }else{
            self.cChoiceLabel.sd_layout.topSpaceToView(self.cChoiceView, 0).heightIs(0);
            [self.cChoiceLabel updateLayout];
        }
        
        //D
        if (examPaperSuitQuestionModel.questionChoices.count>=4) {
            self.dChoiceView.hidden = NO;
            HXExamQuestionChoiceModel *dModel = examPaperSuitQuestionModel.questionChoices[3];
            CGSize DtextSize = [self getAttributedTextHeightHtml:dModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.dChoiceLabel.sd_layout.topSpaceToView(self.dChoiceView, 10).heightIs(DtextSize.height);
            [self.dChoiceLabel updateLayout];
            self.dChoiceLabel.attributedString = [self getAttributedStringWithHtml:dModel.choice_staticContent fontColor:nil];
            [self.dChoiceLabel relayoutText];
            
            if (dModel.isSelected&&!isDuoXuan) {
                self.selectView = self.dTapView;
                self.dTapView.backgroundColor =  ExamSelectColor;
            }else{
                self.dTapView.backgroundColor = (dModel.isSelected?ExamSelectColor:ExamUnSelectColor);
            }
        }else{
            self.dChoiceLabel.sd_layout.topSpaceToView(self.dChoiceView, 0).heightIs(0);
            [self.dChoiceLabel updateLayout];
        }
        
        //E
        if (examPaperSuitQuestionModel.questionChoices.count>=5) {
            self.eChoiceView.hidden = NO;
            HXExamQuestionChoiceModel *eModel = examPaperSuitQuestionModel.questionChoices[4];
            CGSize EtextSize = [self getAttributedTextHeightHtml:eModel.choice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.eChoiceLabel.sd_layout.topSpaceToView(self.eChoiceView, 10).heightIs(EtextSize.height);
            [self.eChoiceLabel updateLayout];
            self.eChoiceLabel.attributedString = [self getAttributedStringWithHtml:eModel.choice_staticContent fontColor:nil];
            [self.eChoiceLabel relayoutText];
           
            if (eModel.isSelected&&!isDuoXuan) {
                self.selectView = self.eTapView;
                self.eTapView.backgroundColor = ExamSelectColor;
            }else{
                self.eTapView.backgroundColor = (eModel.isSelected?ExamSelectColor:ExamUnSelectColor);
            }
        }else{
            self.eChoiceLabel.sd_layout.topSpaceToView(self.eChoiceView, 0).heightIs(0);
            [self.eChoiceLabel updateLayout];
        }
    }
    
    
    
    //查看答卷
    if (!examPaperSuitQuestionModel.isContinuerExam) {
        self.answerView.sd_layout.heightIs(40);
        self.rightContentLabel.text= [examPaperSuitQuestionModel.hintModel.answer uppercaseString];
        self.selectContentLabel.text= [examPaperSuitQuestionModel.answerModel.answer
                                       uppercaseString];
        //解析
        CGSize jieXiTextSize = [self getAttributedTextHeightHtml:examPaperSuitQuestionModel.hintModel.hint  with_viewMaxRect:CGRectMake(0, 0, kScreenWidth-40, CGFLOAT_HEIGHT_UNKNOWN)];
        self.jieXiLabel.sd_layout.heightIs(jieXiTextSize.height);
        [self.jieXiLabel updateLayout];
        self.jieXiLabel.attributedString = [self getAttributedStringWithHtml:examPaperSuitQuestionModel.hintModel.hint fontColor:ExamJieXiColor];
        [self.jieXiLabel relayoutText];
        
        self.answerView.hidden = self.jieXiView.hidden = NO;
        self.answerTipLabel.sd_layout.topSpaceToView(self.attributedTitleLabel, 20).heightIs(20);
        if (examPaperSuitQuestionModel.answerModel == nil) {//未作答
            self.answerTipLabel.textColor =COLOR_WITH_ALPHA(0xED4F4F, 1);
            self.answerTipLabel.text = @"× 您没有作答";
        }else{
            if (examPaperSuitQuestionModel.answerModel.right) {
                self.answerTipLabel.textColor = COLOR_WITH_ALPHA(0x4ED838, 1);
                self.answerTipLabel.text = @"✓ 您答对了";
            }else{
                self.answerTipLabel.textColor =COLOR_WITH_ALPHA(0xED4F4F, 1);
                self.answerTipLabel.text = @"× 您答错了";
            }
        }
    }else{
        self.answerView.sd_layout.heightIs(0);
        self.jieXiLabel.sd_layout.heightIs(0);
        [self.jieXiLabel updateLayout];
        self.answerView.hidden = self.jieXiView.hidden = YES;
        self.answerTipLabel.sd_layout.topSpaceToView(self.attributedTitleLabel, 0).heightIs(0);
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
        if ([self.examPaperSuitQuestionModel.serialNoHtmlTitle containsString:imageInfo]) {
            NSString *newHtml = [self.examPaperSuitQuestionModel.serialNoHtmlTitle stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.viewMaxRect];
            self.attributedTitleLabel.sd_layout.heightIs(textSize.height);
            [self.attributedTitleLabel updateLayout];
            self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.attributedTitleLabel relayoutText];
        }
    }else if (attributedLabel == self.aChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[0];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.aChoiceLabel.sd_layout.topSpaceToView(self.aChoiceView, 10).heightIs(textSize.height);
            [self.aChoiceLabel updateLayout];
            self.aChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.aChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.bChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[1];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.bChoiceLabel.sd_layout.topSpaceToView(self.bChoiceView, 10).heightIs(textSize.height);
            [self.bChoiceLabel updateLayout];
            self.bChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.bChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.cChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[2];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.cChoiceLabel.sd_layout.topSpaceToView(self.cChoiceView, 10).heightIs(textSize.height);
            [self.cChoiceLabel updateLayout];
            self.cChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.cChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.dChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[3];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.dChoiceLabel.sd_layout.topSpaceToView(self.dChoiceView, 10).heightIs(textSize.height);
            [self.dChoiceLabel updateLayout];
            self.dChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.dChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.eChoiceLabel) {
        HXExamQuestionChoiceModel *model = self.examPaperSuitQuestionModel.questionChoices[4];
        if ([model.choice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.choice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.eChoiceLabel.sd_layout.topSpaceToView(self.eChoiceView, 10).heightIs(textSize.height);
            [self.eChoiceLabel updateLayout];
            self.eChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.eChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.jieXiLabel) {
        if ([self.examPaperSuitQuestionModel.hintModel.hint containsString:imageInfo]) {
            NSString *newHtml = [self.examPaperSuitQuestionModel.hintModel.hint stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:CGRectMake(0, 0, kScreenWidth-40, CGFLOAT_HEIGHT_UNKNOWN)];
            self.jieXiLabel.sd_layout.heightIs(textSize.height);
            [self.jieXiLabel updateLayout];
            self.jieXiLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:ExamJieXiColor];
            [self.jieXiLabel relayoutText];
        }
    }
    
    
}

#pragma mark - private Methods
//使用HtmlString,和最大左右间距，计算视图的高度
- (CGSize)getAttributedTextHeightHtml:(NSString *)htmlString with_viewMaxRect:(CGRect)_viewMaxRect{
    //获取富文本
    NSAttributedString *attributedString =  [self getAttributedStringWithHtml:htmlString fontColor:nil];
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
- (NSAttributedString *)getAttributedStringWithHtml:(NSString *)htmlString fontColor:(UIColor *)color{
    //获取富文本
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    if (color==nil) {
        color = COLOR_WITH_ALPHA(0x333333, 1);
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 10;//字体的行间距
    paragraphStyle.minimumLineHeight = 10;//最低行高
    paragraphStyle.minimumLineHeight = 18;//最大行高
    paragraphStyle.paragraphSpacing = 10;//段与段之间的间距
    paragraphStyle.firstLineHeadIndent = 0;//首行缩进
    NSMutableAttributedString *attributedString = [[[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL] mutableCopy];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:color,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}



#pragma mark - UI布局
-(void)createUI{
    [self addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.tiXingNameLabel];
    [self.mainScrollView addSubview:self.attributedTitleLabel];
    [self.mainScrollView addSubview:self.fenShuBgImageView];
    [self.mainScrollView addSubview:self.answerTipLabel];
    
    [self.mainScrollView addSubview:self.aChoiceView];
    [self.mainScrollView addSubview:self.bChoiceView];
    [self.mainScrollView addSubview:self.cChoiceView];
    [self.mainScrollView addSubview:self.dChoiceView];
    [self.mainScrollView addSubview:self.eChoiceView];
    
    [self.mainScrollView addSubview:self.answerView];
    
    [self.mainScrollView addSubview:self.jieXiView];
    [self.jieXiView addSubview:self.jieXiLabel];
    
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
    
    self.fenShuBgImageView.sd_layout
        .topSpaceToView(self.mainScrollView, 0)
        .rightEqualToView(self.mainScrollView)
        .widthIs(32)
        .heightEqualToWidth();
    
    self.fenShuLabel.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 5, 0, 0));
    
    self.answerTipLabel.sd_layout
        .topSpaceToView(self.attributedTitleLabel, 20)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10)
        .heightIs(20);
    
    //A
    self.aChoiceView.sd_layout
        .topSpaceToView(self.answerTipLabel, 10)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10);
    
    self.aLabel.sd_layout
        .centerYEqualToView(self.aChoiceView)
        .leftSpaceToView(self.aChoiceView, 10)
        .widthIs(25)
        .heightEqualToWidth();
    
    self.aChoiceLabel.sd_layout
        .topSpaceToView(self.aChoiceView, 10)
        .leftSpaceToView(self.aLabel, 10)
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
    
    self.bLabel.sd_layout
        .centerYEqualToView(self.bChoiceView)
        .leftSpaceToView(self.bChoiceView, 10)
        .widthIs(25)
        .heightEqualToWidth();
    
    self.bChoiceLabel.sd_layout
        .topSpaceToView(self.bChoiceView, 10)
        .leftSpaceToView(self.bLabel, 10)
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
    
    self.cLabel.sd_layout
        .centerYEqualToView(self.cChoiceView)
        .leftSpaceToView(self.cChoiceView, 10)
        .widthIs(25)
        .heightEqualToWidth();
    
    self.cChoiceLabel.sd_layout
        .topSpaceToView(self.cChoiceView, 10)
        .leftSpaceToView(self.cLabel, 10)
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
    
    self.dLabel.sd_layout
        .centerYEqualToView(self.dChoiceView)
        .leftSpaceToView(self.dChoiceView, 10)
        .widthIs(25)
        .heightEqualToWidth();
    
    self.dChoiceLabel.sd_layout
        .topSpaceToView(self.dChoiceView, 10)
        .leftSpaceToView(self.dLabel, 10)
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
    
    self.eLabel.sd_layout
        .centerYEqualToView(self.eChoiceView)
        .leftSpaceToView(self.eChoiceView, 10)
        .widthIs(25)
        .heightEqualToWidth();
    
    self.eChoiceLabel.sd_layout
        .topSpaceToView(self.eChoiceView, 10)
        .leftSpaceToView(self.eLabel, 10)
        .rightSpaceToView(self.eChoiceView, 0)
        .heightIs(50);
    
    [self.eChoiceView setupAutoHeightWithBottomView:self.eChoiceLabel bottomMargin:10];
    self.eTapView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(0, 0, 0, 0));
    self.eTapView.sd_cornerRadius = @4;
    
    self.answerView.sd_layout
        .topSpaceToView(self.eChoiceView, 10)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10)
        .heightIs(40);
    
    self.rightLabel.sd_layout
        .centerYEqualToView(self.answerView)
        .leftSpaceToView(self.answerView, 10)
        .widthIs(70)
        .heightIs(20);
    
    self.rightContentLabel.sd_layout
        .centerYEqualToView(self.answerView)
        .leftSpaceToView(self.rightLabel, 0)
        .widthIs(70)
        .heightRatioToView(self.rightLabel, 1);
    
    self.selectContentLabel.sd_layout
        .centerYEqualToView(self.answerView)
        .rightSpaceToView(self.answerView, 10)
        .heightRatioToView(self.rightLabel, 1);
    [self.selectContentLabel setSingleLineAutoResizeWithMaxWidth:80];
    
    self.selectLabel.sd_layout
        .centerYEqualToView(self.answerView)
        .rightSpaceToView(self.selectContentLabel, 0)
        .widthIs(70)
        .heightRatioToView(self.rightLabel, 1);
    
    self.jieXiView.sd_layout
        .topSpaceToView(self.answerView, 10)
        .leftSpaceToView(self.mainScrollView, 10)
        .rightSpaceToView(self.mainScrollView, 10);
    
    
    self.jieXiLabel.sd_layout
        .topSpaceToView(self.jieXiView, 10)
        .leftSpaceToView(self.jieXiView, 10)
        .rightSpaceToView(self.jieXiView, 10)
        .heightIs(50);
    [self.jieXiView setupAutoHeightWithBottomView:self.jieXiLabel bottomMargin:10];
    self.jieXiView.sd_cornerRadius = @4;
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.jieXiView bottomMargin:50];
    
    
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

-(UILabel *)answerTipLabel{
    if (!_answerTipLabel) {
        _answerTipLabel = [[UILabel alloc] init];
        _answerTipLabel.numberOfLines=1;
        _answerTipLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _answerTipLabel.font = HXBoldFont(17);
    }
    return _answerTipLabel;
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


-(UIView *)aChoiceView{
    if (!_aChoiceView) {
        _aChoiceView = [[UIView alloc] init];
        [_aChoiceView addSubview:self.aLabel];
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

-(UILabel *)aLabel{
    if (!_aLabel) {
        _aLabel = [[UILabel alloc] init];
        _aLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _aLabel.font = HXFont(15);
        _aLabel.text = @"A.";
    }
    return _aLabel;
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
        [_bChoiceView addSubview:self.bLabel];
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


-(UILabel *)bLabel{
    if (!_bLabel) {
        _bLabel = [[UILabel alloc] init];
        _bLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _bLabel.font = HXFont(15);
        _bLabel.text = @"B.";
    }
    return _bLabel;
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
        [_cChoiceView addSubview:self.cLabel];
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

-(UILabel *)cLabel{
    if (!_cLabel) {
        _cLabel = [[UILabel alloc] init];
        _cLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _cLabel.font = HXFont(15);
        _cLabel.text = @"C.";
    }
    return _cLabel;
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
        [_dChoiceView addSubview:self.dLabel];
        [_dChoiceView addSubview:self.dChoiceLabel];
        [_dChoiceView addSubview:self.dTapView];
    }
    return _dChoiceView;
}

-(UIView *)dTapView{
    if (!_dTapView) {
        _dTapView = [[UIView alloc] init];
        _dTapView.tag = ExamChoiceTapViewTag;
        _dTapView.backgroundColor = ExamUnSelectColor;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectChoice:)];
        [_dTapView addGestureRecognizer:tap];
    }
    return _dTapView;
}

-(UILabel *)dLabel{
    if (!_dLabel) {
        _dLabel = [[UILabel alloc] init];
        _dLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _dLabel.font = HXFont(15);
        _dLabel.text = @"D.";
    }
    return _dLabel;
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
        [_eChoiceView addSubview:self.eLabel];
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

-(UILabel *)eLabel{
    if (!_eLabel) {
        _eLabel = [[UILabel alloc] init];
        _eLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _eLabel.font = HXFont(15);
        _eLabel.text = @"E.";
    }
    return _eLabel;
}

- (DTAttributedLabel *)eChoiceLabel{
    if (!_eChoiceLabel) {
        _eChoiceLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _eChoiceLabel.delegate = self;
        _eChoiceLabel.userInteractionEnabled = NO;
    }
    return _eChoiceLabel;
}


-(UIView *)answerView{
    if (!_answerView) {
        _answerView = [[UIView alloc] init];
        _answerView.clipsToBounds = YES;
        _answerView.backgroundColor =  UIColor.clearColor;
        [_answerView addSubview:self.rightLabel];
        [_answerView addSubview:self.rightContentLabel];
        [_answerView addSubview:self.selectLabel];
        [_answerView addSubview:self.selectContentLabel];
    }
    return _answerView;
}

-(UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _rightLabel.font = HXBoldFont(14);
        _rightLabel.text = @"正确答案：";
    }
    return _rightLabel;
}

-(UILabel *)rightContentLabel{
    if (!_rightContentLabel) {
        _rightContentLabel = [[UILabel alloc] init];
        _rightContentLabel.textColor = COLOR_WITH_ALPHA(0x4ED838, 1);
        _rightContentLabel.font = HXBoldFont(14);
    }
    return _rightContentLabel;
}

-(UILabel *)selectLabel{
    if (!_selectLabel) {
        _selectLabel = [[UILabel alloc] init];
        _selectLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _selectLabel.font = HXBoldFont(14);
        _selectLabel.text = @"已选答案：";
    }
    return _selectLabel;
}

-(UILabel *)selectContentLabel{
    if (!_selectContentLabel) {
        _selectContentLabel = [[UILabel alloc] init];
        _selectContentLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _selectContentLabel.font = HXBoldFont(14);
    }
    return _selectContentLabel;
}

-(UIView *)jieXiView{
    if (!_jieXiView) {
        _jieXiView = [[UIView alloc] init];
        _jieXiView.clipsToBounds = YES;
        _jieXiView.backgroundColor =  COLOR_WITH_ALPHA(0xF9F9F9, 1);
        _jieXiView.layer.borderColor = COLOR_WITH_ALPHA(0xC6C8D0, 1).CGColor;
        _jieXiView.layer.borderWidth = 1;
    }
    return _jieXiView;
}

-(DTAttributedLabel *)jieXiLabel{
    if (!_jieXiLabel) {
        _jieXiLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _jieXiLabel.delegate = self;
        _jieXiLabel.backgroundColor= UIColor.clearColor;
    }
    return _jieXiLabel;
}



@end
