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


//跟着手势滑动的view
@property(nonatomic,strong) UIView *mSplitView;
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
    
    //把移动归位
    self.mainScrollView.frame = CGRectMake(0, 0, kScreenWidth, ((kScreenHeight-kNavigationBarHeight-ExamBottomViewHeight)*0.5));
    self.mSplitView.frame = CGRectMake(0, CGRectGetMaxY(self.mainScrollView.frame), kScreenWidth, ExamSplitViewHeight);
    self.subCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.mSplitView.frame), kScreenWidth, ExamSubChoiceCellHeight);

}


#pragma mark - 复合题型子题的平移手势、轻击手势
//平移手势
- (void)handlePan:(UIPanGestureRecognizer*)recognizer{
    
    CGPoint translation = [recognizer translationInView:self];
    CGFloat y = recognizer.view.frame.origin.y + translation.y;
    CGFloat h = ExamSubChoiceCellHeight;
    //不能超出这个范围
    if (y > 0 && y < h) {
        recognizer.view.center = CGPointMake(kScreenWidth*0.5,recognizer.view.center.y + translation.y);
        self.mainScrollView.frame = CGRectMake(self.mainScrollView.frame.origin.x, self.mainScrollView.frame.origin.y, kScreenWidth, y);
        self.subCollectionView.frame = CGRectMake(self.subCollectionView.frame.origin.x, self.subCollectionView.frame.origin.y + translation.y, kScreenWidth, h);
    }
    [recognizer setTranslation:CGPointZero inView:self];
    
}


//轻击手势
- (void)handleTap:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.view.frame.origin.y != 0) {
        //不在顶部，回到顶部
        self.mainScrollView.frame =CGRectMake(0,0, kScreenWidth, 0);
        recognizer.view.frame = CGRectMake(0, 0, kScreenWidth, ExamSplitViewHeight);
        self.subCollectionView.frame = CGRectMake(0, ExamSplitViewHeight, kScreenWidth,ExamSubChoiceCellHeight);
    }else{
        //在顶部，归位
        self.mainScrollView.frame = CGRectMake(0, 0, kScreenWidth, ((kScreenHeight-kNavigationBarHeight-ExamBottomViewHeight)*0.5));
        self.mSplitView.frame = CGRectMake(0, CGRectGetMaxY(self.mainScrollView.frame), kScreenWidth, ExamSplitViewHeight);
        self.subCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.mSplitView.frame), kScreenWidth, ExamSubChoiceCellHeight);
    }
}


#pragma mark - <DTAttributedTextContentViewDelegate>
//图片占位
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    
    if([attachment isKindOfClass:[DTImageTextAttachment class]]){//超过规定宽度，等比例缩放
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


#pragma mark - <DTLazyImageViewDelegate>懒加载获取图片大小
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


#pragma mark - Private Methods
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


#pragma mark - Public Methods 点击答题卡，子题滑动到相应位置
-(void)scrollSubPosition:(NSInteger)position{
    //点击答题卡
    [self.subCollectionView setContentOffset:CGPointMake(kScreenWidth*position, 0) animated:NO];
    self.examPaperSuitQuestionModel.fuhe_position = position;
    CGPoint pInView = [self convertPoint:self.subCollectionView.center toView:self.subCollectionView];
    NSIndexPath *indexPathNow = [self.subCollectionView indexPathForItemAtPoint:pInView];
    self.subNOLabel.text = [NSString stringWithFormat:@"%ld/%lu",(indexPathNow.row+1),(unsigned long)self.examPaperSuitQuestionModel.subQuestions.count];
}


#pragma mark - <UIScrollViewDelegate>子题滑动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGPoint pInView = [self convertPoint:self.subCollectionView.center toView:self.subCollectionView];
    self.indexPathNow = [self.subCollectionView indexPathForItemAtPoint:pInView];
    self.subNOLabel.text = [NSString stringWithFormat:@"%ld/%lu",(self.indexPathNow.row+1),(unsigned long)self.examPaperSuitQuestionModel.subQuestions.count];
    
    self.examPaperSuitQuestionModel.fuhe_position = self.indexPathNow.row;
    //
    if ((self.indexPathNow.row+1<self.examPaperSuitQuestionModel.subQuestions.count-1)&&(self.indexPathNow.row+1>=0)) {
        //保存下一题答案
        HXExamPaperSubQuestionModel *nextSubQuestionModel = self.examPaperSuitQuestionModel.subQuestions[self.indexPathNow.row+1];
        [self saveQuestion:nextSubQuestionModel];
    }
    
    if ((self.indexPathNow.row-1<self.examPaperSuitQuestionModel.subQuestions.count-1)&&(self.indexPathNow.row-1>=0)) {
        //保存上一题答案
        HXExamPaperSubQuestionModel *upSubQuestionModel = self.examPaperSuitQuestionModel.subQuestions[self.indexPathNow.row-1];
        [self saveQuestion:upSubQuestionModel];
    }
    
}

#pragma mark - 提交试题答案
-(void)saveQuestion:(HXExamPaperSubQuestionModel *)examPaperSubQuestionModel{
    //开始考试或继续考试才提交答案
    if (!examPaperSubQuestionModel.isContinuerExam) {
        return;
    }
    //答案非空才保存
    if ([HXCommonUtil isNull:examPaperSubQuestionModel.answer]) {
        return;
    }
    
    //问答题保存当前子题答案
    if (examPaperSubQuestionModel.isWenDa) {//问答题非空才保存
        if (examPaperSubQuestionModel.attach.count==0&&[HXCommonUtil isNull:examPaperSubQuestionModel.answer]) {
            return;
        }
    }else{//非空才保存
        if ([HXCommonUtil isNull:examPaperSubQuestionModel.answer]) {
            return;
        }
    }
    
    //问题id截掉"q_"
    NSString *psqId = HXSafeString([examPaperSubQuestionModel.sub_id substringFromIndex:2]);
    
    NSString *url = [NSString stringWithFormat:HXEXAM_SubmitAnswer,examPaperSubQuestionModel.domain,examPaperSubQuestionModel.userExamId,psqId];
   
    NSString *keyStr =[NSString stringWithFormat:@"%@%@",psqId,examPaperSubQuestionModel.userExamId];
    
    
    NSString *answer = HXSafeString(examPaperSubQuestionModel.answer);
    //获取当前时间戳
    NSString *stime = [HXCommonUtil getNowTimeTimestamp];
    //用于加密的参数,生成m
    NSDictionary *md5Dic;
    if (examPaperSubQuestionModel.attach.count>0) {
        if ([HXCommonUtil isNull:answer]) {
            md5Dic =@{
                @"psqId":psqId,
                @"stime":stime,
                @"attach":HXSafeString([examPaperSubQuestionModel.attach componentsJoinedByString:@","])
            };
        }else{
            md5Dic =@{
                @"answer":answer,
                @"psqId":psqId,
                @"stime":stime,
                @"attach":HXSafeString([examPaperSubQuestionModel.attach componentsJoinedByString:@","])
            };
        }
        
    }else{
        md5Dic =@{
            @"answer":answer,
            @"psqId":psqId,
            @"stime":stime
        };
    }
    NSString *md5Str = [HXCommonUtil getMd5String:md5Dic pingKey:[NSString stringWithFormat:@"key=%@",keyStr]];
    //拼接请求地址
    NSString *pingDicUrl;
    if (examPaperSubQuestionModel.attach.count!=0) {
        NSString *attachStr = [examPaperSubQuestionModel.attach componentsJoinedByString:@","];
        pingDicUrl = [HXCommonUtil  stringEncoding:[NSString stringWithFormat:@"%@?answer=%@&psqId=%@&stime=%@&m=%@&attach=%@",url,answer,psqId,stime,md5Str,attachStr]];
    }else{
        pingDicUrl = [HXCommonUtil  stringEncoding:[NSString stringWithFormat:@"%@?answer=%@&psqId=%@&stime=%@&m=%@",url,answer,psqId,stime,md5Str]];
    }
    
    AFHTTPSessionManager *manager =[AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//json请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//json返回
    
    [manager POST:pingDicUrl parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dictionary = responseObject;
        if ([dictionary boolValueForKey:@"success"]) {
            NSLog(@"答案已保存");
        }else{
            [self showErrorWithMessage:[dictionary stringValueForKey:@"errMsg"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showErrorWithMessage:error.description.lowercaseString];
    }];
}


#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.examPaperSuitQuestionModel.subQuestions.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    HXExamSubChoiceCell *choiceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HXExamSubChoiceCell" forIndexPath:indexPath];
    choiceCell.examVc = self.examVc;
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
    [self addSubview:self.mSplitView];
    [self addSubview:self.subCollectionView];
    
    
    [self.mainScrollView addSubview:self.tiXingNameLabel];
    [self.mainScrollView addSubview:self.attributedTitleLabel];
    [self.mainScrollView addSubview:self.fenShuBgImageView];
    

    
    self.mainScrollView.frame = CGRectMake(0, 0, kScreenWidth, ((kScreenHeight-kNavigationBarHeight-ExamBottomViewHeight)*0.5));
    self.mSplitView.frame = CGRectMake(0, CGRectGetMaxY(self.mainScrollView.frame), kScreenWidth, ExamSplitViewHeight);
    self.subCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.mSplitView.frame), kScreenWidth, ExamSubChoiceCellHeight);
    
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
    
    
    //查看小题
    self.checkSubLabel.sd_layout
    .centerYEqualToView(self.mSplitView)
    .centerXEqualToView(self.mSplitView).offset(-10)
    .heightIs(20);
    [self.checkSubLabel setSingleLineAutoResizeWithMaxWidth:100];
   
    self.subNOLabel.sd_layout
    .centerYEqualToView(self.mSplitView)
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


-(UIView *)mSplitView{
    if (!_mSplitView) {
        _mSplitView = [[UIView alloc] init];
        _mSplitView.backgroundColor = COLOR_WITH_ALPHA(0xF2F2F2, 1);
        [_mSplitView addSubview:self.checkSubLabel];
        [_mSplitView addSubview:self.subNOLabel];
        //平移手势
        UIPanGestureRecognizer *panGestureRecognizer =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [_mSplitView addGestureRecognizer:panGestureRecognizer];
        
        //轻击手势
        UITapGestureRecognizer *tapGestureRecognizer =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [_mSplitView addGestureRecognizer:tapGestureRecognizer];
    }
    return _mSplitView;
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
        layout.itemSize = CGSizeMake(kScreenWidth, ExamSubChoiceCellHeight);
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


