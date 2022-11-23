//
//  HXExamFuHeCell.m
//  CloudClassroom
//
//  Created by mac on 2022/11/18.
//

#import "HXExamFuHeCell.h"
#import "HXExamSubChoiceCell.h"

@interface HXExamFuHeCell ()<DTAttributedTextContentViewDelegate,DTLazyImageViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,assign) CGRect viewMaxRect;


@property(nonatomic,strong) UIScrollView *mainScrollView;
//题型（单选提，判断题，简答题.....）
@property(nonatomic,strong) UILabel *tiXingNameLabel;
//问题标题
@property(nonatomic,strong) DTAttributedLabel *attributedTitleLabel;

//分数
@property(nonatomic,strong) UIImageView *fenShuBgImageView;
@property(nonatomic,strong) UILabel *fenShuLabel;

//子问题的容器
@property(nonatomic,strong) UIView *subContainerView;

//跟着手势滑动的view
@property(nonatomic,strong) UIView *topTapContainerView;
@property(nonatomic,strong) UILabel *checkSubLabel;//查看小题
@property(nonatomic,strong) UILabel *subNOLabel;//小题序号

@property(nonatomic,strong) UICollectionView *subCollectionView;

///子问题当前的位置
@property (nonatomic, strong) NSIndexPath *indexPathNow;

@end

@implementation HXExamFuHeCell

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

-(void)dealloc{
    [HXNotificationCenter removeObserver:self];
}

#pragma mark - Event

//平移手势
- (void)handlePan:(UIPanGestureRecognizer*)recognizer{
    
    CGPoint translation = [recognizer translationInView:self];
    
    int y = self.subContainerView.frame.origin.y+ translation.y-44;
    int h = kScreenHeight-kNavigationBarHeight-44;
    //不能超出这个范围
    if (y >(kNavigationBarHeight) && y < h) {
        self.subContainerView.center = CGPointMake(self.subContainerView.center.x,
                                                   self.subContainerView.center.y + translation.y);
        
    }
    [recognizer setTranslation:CGPointZero inView:self];
    
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
    
    [self.subCollectionView reloadData];
    //复归原位
    [self scrollSubPosition:0];
    

}


#pragma mark - 滑动复合题型子题到相应位置
-(void)scrollSubPosition:(NSInteger)position{
    [self.subCollectionView setContentOffset:CGPointMake(kScreenWidth*position, 0) animated:NO];
    
    CGPoint pInView = [self.subContainerView convertPoint:self.subCollectionView.center toView:self.subCollectionView];
    NSIndexPath *indexPathNow = [self.subCollectionView indexPathForItemAtPoint:pInView];
    self.subNOLabel.text = [NSString stringWithFormat:@"%ld/%lu",(indexPathNow.row+1),(unsigned long)self.examPaperSuitQuestionModel.subQuestions.count];
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


#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGPoint pInView = [self.subContainerView convertPoint:self.subCollectionView.center toView:self.subCollectionView];
    self.indexPathNow = [self.subCollectionView indexPathForItemAtPoint:pInView];
    self.subNOLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.indexPathNow.row+1),(unsigned long)self.examPaperSuitQuestionModel.subQuestions.count];
    
}

#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.examPaperSuitQuestionModel.subQuestions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    HXExamSubChoiceCell *choiceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXExamSubChoiceCell" forIndexPath:indexPath];
    return choiceCell;

}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    HXExamPaperSubQuestionModel *examPaperSubQuestionModel = self.examPaperSuitQuestionModel.subQuestions[indexPath.row];
    HXExamSubChoiceCell *choiceCell = (HXExamSubChoiceCell *)cell;
    choiceCell.examPaperSubQuestionModel = examPaperSubQuestionModel;

}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

#pragma mark - UI布局
-(void)createUI{
    [self addSubview:self.mainScrollView];
    [self addSubview:self.subContainerView];
    
    
    [self.mainScrollView addSubview:self.tiXingNameLabel];
    [self.mainScrollView addSubview:self.attributedTitleLabel];
    [self.mainScrollView addSubview:self.fenShuBgImageView];
    
    [self.subContainerView addSubview:self.topTapContainerView];
    [self.subContainerView addSubview:self.subCollectionView];
    
    
    self.mainScrollView.sd_layout
    .topSpaceToView(self, 0)
    .leftSpaceToView(self, 0)
    .rightSpaceToView(self, 0)
    .heightIs((kScreenHeight-kNavigationBarHeight-72)*0.5);
    [self.mainScrollView updateLayout];
    
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
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.attributedTitleLabel bottomMargin:50];
    
    
    self.subContainerView.sd_layout
    .topSpaceToView(self.mainScrollView, 0)
    .leftSpaceToView(self, 0)
    .rightSpaceToView(self, 0)
    .bottomEqualToView(self);

    self.topTapContainerView.sd_layout
    .topSpaceToView(self.subContainerView, 0)
    .leftSpaceToView(self.subContainerView, 0)
    .rightSpaceToView(self.subContainerView, 0)
    .heightIs(44);
    
    self.subCollectionView.sd_layout
    .topSpaceToView(self.topTapContainerView, 0)
    .leftSpaceToView(self.subContainerView, 0)
    .rightSpaceToView(self.subContainerView, 0)
    .bottomEqualToView(self.subContainerView);
    
    self.checkSubLabel.sd_layout
    .centerYEqualToView(self.topTapContainerView)
    .centerXEqualToView(self.topTapContainerView).offset(-10)
    .heightIs(20);
    [self.checkSubLabel setSingleLineAutoResizeWithMaxWidth:100];
   
    self.subNOLabel.sd_layout
    .centerYEqualToView(self.topTapContainerView)
    .leftSpaceToView(self.checkSubLabel, 10)
    .widthIs(60)
    .heightIs(20);
   
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


-(UIView *)subContainerView{
    if (!_subContainerView) {
        _subContainerView = [[UIView alloc] init];
        _subContainerView.backgroundColor = UIColor.whiteColor;
    }
    return _subContainerView;
}


-(UIView *)topTapContainerView{
    if (!_topTapContainerView) {
        _topTapContainerView = [[UIView alloc] init];
        _topTapContainerView.backgroundColor = COLOR_WITH_ALPHA(0xF2F2F2, 1);
        [_topTapContainerView addSubview:self.checkSubLabel];
        [_topTapContainerView addSubview:self.subNOLabel];
//        //平移手势
//        UIPanGestureRecognizer *panGestureRecognizer =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
//        [_topTapContainerView addGestureRecognizer:panGestureRecognizer];
    }
    return _topTapContainerView;
}

-(UILabel *)checkSubLabel{
    if (!_checkSubLabel) {
        _checkSubLabel = [[UILabel alloc] init];
        _checkSubLabel.font = HXBoldFont(16);
        _checkSubLabel.textAlignment = NSTextAlignmentCenter;
        _checkSubLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        _checkSubLabel.text = @"查看小题";
    }
    return _checkSubLabel;
}

-(UILabel *)subNOLabel{
    if (!_subNOLabel) {
        _subNOLabel = [[UILabel alloc] init];
        _subNOLabel.font = HXFont(16);
        _subNOLabel.textAlignment = NSTextAlignmentLeft;
        _subNOLabel.textColor = COLOR_WITH_ALPHA(0x999999, 1);
        
    }
    return _subNOLabel;
}

-(UICollectionView *)subCollectionView{
    if (!_subCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(kScreenWidth, kScreenHeight-kNavigationBarHeight-(kScreenHeight-kNavigationBarHeight-72)*0.5-44-72);
        _subCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _subCollectionView.backgroundColor = [UIColor whiteColor];
        _subCollectionView.showsVerticalScrollIndicator = NO;
        _subCollectionView.showsHorizontalScrollIndicator = NO;
        _subCollectionView.delegate = self;
        _subCollectionView.dataSource = self;
        _subCollectionView.pagingEnabled = YES;
        _subCollectionView.scrollEnabled = YES;
        [_subCollectionView registerClass:[HXExamSubChoiceCell class] forCellWithReuseIdentifier:@"HXExamSubChoiceCell"];
    }
    return _subCollectionView;
}

@end


