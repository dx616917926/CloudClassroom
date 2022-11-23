//
//  HXExamAnswerCell.m
//  CloudClassroom
//
//  Created by mac on 2022/11/17.
//

#import "HXExamAnswerCell.h"
#import "IQTextView.h"

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

@end

@implementation HXExamAnswerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.viewMaxRect = CGRectMake(0, 0, kScreenWidth-20, CGFLOAT_HEIGHT_UNKNOWN);
        [self createUI];
    }
    return self;
}

#pragma mark - Event


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
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.grayView bottomMargin:50];
    
   
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


@end

