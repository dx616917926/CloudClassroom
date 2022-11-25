//
//  HXMessageDetailInfoViewController.m
//  CloudClassroom
//
//  Created by mac on 2022/11/25.
//

#import "HXMessageDetailInfoViewController.h"
#import "HXMyMessageDetailModel.h"
#import "DTCoreTextToolsHeader.h"
#import "NSString+Base64.h"
#import <QuickLook/QuickLook.h>
@interface HXMessageDetailInfoViewController ()<DTAttributedTextContentViewDelegate,DTLazyImageViewDelegate,QLPreviewControllerDataSource>

@property(nonatomic,assign) CGRect viewMaxRect;


@property(nonatomic,strong) UIScrollView *mainScrollView;

@property(nonatomic,strong) UIView *whiteContanerView;
//消息标题
@property(nonatomic,strong) UILabel *messageTitleLabel;
//发送消息时间
@property(nonatomic,strong) UILabel *sendtimeLabel;
//消息内容
@property(nonatomic,strong) DTAttributedLabel *attributedMessageContentLabel;
//附件
@property(nonatomic,strong) UIView *attachmentContanerView;

@property(nonatomic,strong) HXMyMessageDetailModel *myMessageDetailModel;

@property (nonatomic, strong) QLPreviewController *QLController;
@property (nonatomic, copy) NSURL *fileURL;


@end

@implementation HXMessageDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //UI
    [self createUI];
    //查看消息详情
    [self getMessageDetailInfo];
    
    self.QLController = [[QLPreviewController alloc] init];
    self.QLController.dataSource = self;
}

#pragma mark - 查看消息详情
-(void)getMessageDetailInfo{
    
    NSString *studentId = [HXPublicParamTool sharedInstance].student_id;
    
    NSDictionary *dic =@{
        @"message_id":HXSafeString(self.myMessageInfoModel.message_Id),
        @"detail_id":HXSafeString(self.myMessageInfoModel.messageDetail_Id),
        @"studentid":HXSafeString(studentId)
    };
    [HXBaseURLSessionManager postDataWithNSString:HXPOST_GetMessageDetailInfo needMd5:YES  withDictionary:dic success:^(NSDictionary * _Nonnull dictionary) {
        
        BOOL success = [dictionary boolValueForKey:@"success"];
        if (success) {
            self.myMessageDetailModel = [HXMyMessageDetailModel mj_objectWithKeyValues:[dictionary dictionaryValueForKey:@"data"]];
            //
            [self refreshUI];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
    
}

-(void)refreshUI{
    
    HXMyMessageInfoModel *messageInfoModel = self.myMessageDetailModel.respMyMessageInfo;

    self.messageTitleLabel.text = messageInfoModel.messagetitle;
    self.sendtimeLabel.text = messageInfoModel.sendtime;
    
    CGSize textSize = [self getAttributedTextHeightHtml:[messageInfoModel.messagecontent base64DecodedString]  with_viewMaxRect:self.viewMaxRect];
    self.attributedMessageContentLabel.sd_layout.heightIs(textSize.height);
    [self.attributedMessageContentLabel updateLayout];
    self.attributedMessageContentLabel.attributedString = [self getAttributedStringWithHtml:[messageInfoModel.messagecontent base64DecodedString]];
    
    
    [self.attachmentContanerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    
    if (self.myMessageDetailModel.respMessageAttaches.count==0) {
        self.attachmentContanerView.sd_layout.heightIs(50);
    }else{
        NSMutableArray *btns = [NSMutableArray array];
        for (int i=0; i<self.myMessageDetailModel.respMessageAttaches.count; i++) {
            HXMessageAttachmentModel *model =self.myMessageDetailModel.respMessageAttaches[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 5000+i;
            btn.backgroundColor = HXThemeBlue;
            btn.titleLabel.font = HXBoldFont(14);
            [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [btn setTitle:[@"📎" stringByAppendingString:model.fileName] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickAttachment:) forControlEvents:UIControlEventTouchUpInside];
            [self.attachmentContanerView addSubview:btn];
            [btns addObject:btn];
            btn.sd_layout.heightIs(30);
            btn.sd_cornerRadiusFromHeightRatio=@0.5;
            [self.attachmentContanerView setupAutoMarginFlowItems:btns withPerRowItemsCount:2 itemWidth:(self.viewMaxRect.size.width-20)*0.5 verticalMargin:0 verticalEdgeInset:0 horizontalEdgeInset:0];
        }
    }
   
    
}

#pragma mark - 点击附件📎
-(void)clickAttachment:(UIButton *)sender{
    
    NSInteger index = sender.tag-5000;
    HXMessageAttachmentModel *model =self.myMessageDetailModel.respMessageAttaches[index];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.directory]];
    
    NSString *downLoadUrl = [HXCommonUtil stringEncoding:model.directory];
    
    if ([HXCommonUtil isNull:downLoadUrl]) {
        [self.view showTostWithMessage:@"资源无效"];
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 1. 创建会话管理者
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // 2. 创建下载路径和请求对象
    NSURL *URL = [NSURL URLWithString:downLoadUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSString *generateStr = [HXCommonUtil generateTradeNO:5];//生成指定长度的字符串
    NSString *fileName = [generateStr stringByAppendingString:[model.fileName lastPathComponent]]; //获取文件名称

    [self.view showLoadingWithMessage:@"正在下载..."];
    //下载文件
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress){
        
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *url = [documentsDirectoryURL URLByAppendingPathComponent:fileName];
        return url;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [self.view hideLoading];
        self.fileURL = filePath;
        [self presentViewController:self.QLController animated:YES completion:nil];
        //刷新界面,如果不刷新的话，不重新走一遍代理方法，返回的url还是上一次的url
        [self.QLController refreshCurrentPreviewItem];
    }];
    [downloadTask resume];
}

#pragma mark - QLPreviewControllerDataSource
/// 文件路径
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.fileURL;
}
/// 文件数
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

#pragma mark - <DTAttributedTextContentViewDelegate>
//图片占位
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
    
    if([attachment isKindOfClass:[DTImageTextAttachment class]]){
        NSString *imageURL = [NSString stringWithFormat:@"%@", attachment.contentURL];
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
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
    for (DTTextAttachment *oneAttachment in [self.attributedMessageContentLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize attributedLabel:self.attributedMessageContentLabel];
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
    
    if (attributedLabel == self.attributedMessageContentLabel) {
        HXMyMessageInfoModel *messageInfoModel = self.myMessageDetailModel.respMyMessageInfo;
        if ([[messageInfoModel.messagecontent base64DecodedString] containsString:imageInfo]) {
            NSString *newHtml = [messageInfoModel.messagecontent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.viewMaxRect];
            self.attributedMessageContentLabel.sd_layout.heightIs(textSize.height);
            [self.attributedMessageContentLabel updateLayout];
            self.attributedMessageContentLabel.attributedString = [self getAttributedStringWithHtml:newHtml];
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
    paragraphStyle.lineSpacing = 8;//字体的行间距
    paragraphStyle.minimumLineHeight = 8;//最低行高
    paragraphStyle.minimumLineHeight = 16;//最大行高
    paragraphStyle.paragraphSpacing = 8;//段与段之间的间距
    paragraphStyle.firstLineHeadIndent = 0;//首行缩进
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSMutableAttributedString *attributedString = [[[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL] mutableCopy];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:COLOR_WITH_ALPHA(0x999999, 1)} range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

#pragma mark - UI布局
-(void)createUI{
    
    self.sc_navigationBar.title = @"消息详情";
    self.viewMaxRect = CGRectMake(0, 0, kScreenWidth-56, CGFLOAT_HEIGHT_UNKNOWN);
    
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.whiteContanerView];
    [self.whiteContanerView addSubview:self.messageTitleLabel];
    [self.whiteContanerView addSubview:self.sendtimeLabel];
    [self.whiteContanerView addSubview:self.attributedMessageContentLabel];
    [self.whiteContanerView addSubview:self.attachmentContanerView];
    
    self.mainScrollView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(kNavigationBarHeight, 0, 0, 0));
    
    self.whiteContanerView.sd_layout
    .topSpaceToView(self.mainScrollView, 16)
    .leftSpaceToView(self.mainScrollView, 12)
    .rightSpaceToView(self.mainScrollView, 12);
    
    self.whiteContanerView.sd_cornerRadius=@8;
    
    
    self.sendtimeLabel.sd_layout
    .topSpaceToView(self.whiteContanerView, 16)
    .rightSpaceToView(self.whiteContanerView, 16)
    .heightIs(17);
    [self.sendtimeLabel setSingleLineAutoResizeWithMaxWidth:150];
    
    self.messageTitleLabel.sd_layout
    .topSpaceToView(self.whiteContanerView, 16)
    .leftSpaceToView(self.whiteContanerView, 16)
    .rightSpaceToView(self.sendtimeLabel, 10)
    .heightIs(21);
    
    self.attributedMessageContentLabel.sd_layout
    .topSpaceToView(self.messageTitleLabel, 13)
    .leftSpaceToView(self.whiteContanerView, 16)
    .rightSpaceToView(self.whiteContanerView, 16)
    .heightIs(50);
    
    self.attachmentContanerView.sd_layout
    .topSpaceToView(self.attributedMessageContentLabel, 50)
    .leftSpaceToView(self.whiteContanerView, 16)
    .rightSpaceToView(self.whiteContanerView, 16);
    
    [self.whiteContanerView setupAutoHeightWithBottomView:self.attachmentContanerView bottomMargin:50];
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.whiteContanerView bottomMargin:50];
    
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


-(UIView *)whiteContanerView{
    if (!_whiteContanerView) {
        _whiteContanerView = [[UIView alloc] init];
        _whiteContanerView.backgroundColor = UIColor.whiteColor;
        _whiteContanerView.clipsToBounds = YES;
    }
    return _whiteContanerView;
}

-(UILabel *)messageTitleLabel{
    if (!_messageTitleLabel) {
        _messageTitleLabel = [[UILabel alloc] init];
        _messageTitleLabel.textAlignment = NSTextAlignmentLeft;
        _messageTitleLabel.numberOfLines=1;
        _messageTitleLabel.textColor = COLOR_WITH_ALPHA(0x2E5BFD, 1);
        _messageTitleLabel.font = HXBoldFont(15);
    }
    return _messageTitleLabel;
}

-(UILabel *)sendtimeLabel{
    if (!_sendtimeLabel) {
        _sendtimeLabel = [[UILabel alloc] init];
        _sendtimeLabel.numberOfLines=1;
        _sendtimeLabel.textAlignment = NSTextAlignmentRight;
        _sendtimeLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _sendtimeLabel.font = HXFont(12);
    }
    return _sendtimeLabel;
}

- (DTAttributedLabel *)attributedMessageContentLabel{
    if (!_attributedMessageContentLabel) {
        _attributedMessageContentLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectZero];
        _attributedMessageContentLabel.delegate = self;
        _attributedMessageContentLabel.clipsToBounds = YES;
    }
    return _attributedMessageContentLabel;
}


-(UIView *)attachmentContanerView{
    if (!_attachmentContanerView) {
        _attachmentContanerView = [[UIView alloc] init];
        _attachmentContanerView.backgroundColor = UIColor.clearColor;
        _attachmentContanerView.clipsToBounds = YES;
    }
    return _attachmentContanerView;
}



@end
