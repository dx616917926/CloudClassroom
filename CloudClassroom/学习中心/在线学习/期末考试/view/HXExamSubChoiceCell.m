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

@property(nonatomic,strong) UIView *grayView;
@property(nonatomic,strong) IQTextView *textView;

@property(nonatomic,strong) UIView *selectView;


//照片容器试图
@property(nonatomic,strong) UIView *photosContainerView;
//添加照片
@property(nonatomic,strong) UIButton *addPhotoBtn;
@property(nonatomic,strong) UILabel *photoTipLabel;
@property(nonatomic,strong) UIButton *deletePhotoBtn;

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
    
    
    if (self.examPaperSubQuestionModel.isDuoXuan) {
        UIView *sender = ges.view;
        
        
        __block NSMutableArray *choices = [NSMutableArray array];
        
        [self.examPaperSubQuestionModel.subQuestionChoices enumerateObjectsUsingBlock:^(HXExamSubQuestionChoicesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HXExamSubQuestionChoicesModel *examSubQuestionChoicesModel = obj;
            if (examSubQuestionChoicesModel.isSelected) {
                [choices addObject:examSubQuestionChoicesModel.subChoice_order];
            }
        }];
        
        if (sender==self.aTapView) {
            HXExamSubQuestionChoicesModel *choiceModel = self.examPaperSubQuestionModel.subQuestionChoices[0];
            choiceModel.isSelected = !choiceModel.isSelected;
            self.aTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.subChoice_order];
            }else{
                [choices removeObject:choiceModel.subChoice_order];
            }
        }else if (sender==self.bTapView) {
            HXExamSubQuestionChoicesModel *choiceModel = self.examPaperSubQuestionModel.subQuestionChoices[1];
            choiceModel.isSelected = !choiceModel.isSelected;
            self.bTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.subChoice_order];
            }else{
                [choices removeObject:choiceModel.subChoice_order];
            }
        }else if (sender==self.cTapView) {
            HXExamSubQuestionChoicesModel *choiceModel = self.examPaperSubQuestionModel.subQuestionChoices[2];
            choiceModel.isSelected = !choiceModel.isSelected;
            self.cTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.subChoice_order];
            }else{
                [choices removeObject:choiceModel.subChoice_order];
            }
        }else if (sender==self.dTapView) {
            HXExamSubQuestionChoicesModel *choiceModel = self.examPaperSubQuestionModel.subQuestionChoices[3];
            choiceModel.isSelected = !choiceModel.isSelected;
            self.dTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.subChoice_order];
            }else{
                [choices removeObject:choiceModel.subChoice_order];
            }
        }else {
            HXExamSubQuestionChoicesModel *choiceModel = self.examPaperSubQuestionModel.subQuestionChoices[4];
            choiceModel.isSelected = !choiceModel.isSelected;
            self.eTapView.backgroundColor = choiceModel.isSelected?ExamSelectColor:ExamUnSelectColor;
            if (choiceModel.isSelected) {
                [choices addObject:choiceModel.subChoice_order];
            }else{
                [choices removeObject:choiceModel.subChoice_order];
            }
        }
        if (choices.count>0) {
            //数组按字母升序排序
            NSArray*result = [choices sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1 ,id _Nonnull obj2){
                return [obj1 compare:obj2 options:NSLiteralSearch]; //升序
            }];
            self.examPaperSubQuestionModel.answer = [result componentsJoinedByString:@""];
        }else{
            self.examPaperSubQuestionModel.answer = @"";
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
        
        [self.examPaperSubQuestionModel.subQuestionChoices enumerateObjectsUsingBlock:^(HXExamSubQuestionChoicesModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx==selectIndex) {
                obj.isSelected = YES;
                self.examPaperSubQuestionModel.answer = obj.subChoice_order;
            }else{
                obj.isSelected = NO;
            }
        }];
    }
    
    
    
    
}

#pragma mark - Setter
-(void)setExamPaperSubQuestionModel:(HXExamPaperSubQuestionModel *)examPaperSubQuestionModel{
    
    _examPaperSubQuestionModel = examPaperSubQuestionModel;
    
    
    //设置偏移归位
    [self.mainScrollView setContentOffset:CGPointZero];
    
    CGSize textSize = [self getAttributedTextHeightHtml:examPaperSubQuestionModel.serialNoHtmlTitle  with_viewMaxRect:self.viewMaxRect];
    self.attributedTitleLabel.sd_layout.heightIs(textSize.height);
    [self.attributedTitleLabel updateLayout];
    self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:examPaperSubQuestionModel.serialNoHtmlTitle fontColor:nil];
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
    
    if (examPaperSubQuestionModel.isWenDa) {//问答题
        
        self.answerTipLabel.sd_layout.topSpaceToView(self.attributedTitleLabel, 0).heightIs(0);
        
        //正确答案
        self.answerView.sd_layout.topSpaceToView(self.photosContainerView, 0).heightIs(0);
        
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
        
        
        if (examPaperSubQuestionModel.isContinuerExam) {
            self.textView.placeholder = @"请填写答案";

            //解析
            self.jieXiLabel.sd_layout.heightIs(0);
            [self.jieXiLabel updateLayout];
            
            self.addPhotoBtn.hidden = self.photoTipLabel.hidden = NO;
            self.jieXiView.hidden  = YES;
            self.addPhotoBtn.userInteractionEnabled = self.textView.editable = YES;
            [self.mainScrollView setupAutoContentSizeWithBottomView:self.photoTipLabel bottomMargin:ExamSubChoiceCellHeight];
        }else{
            self.textView.placeholder = @"";
            
            //解析
            NSString *answerStr = [NSString stringWithFormat:@"答案:%@",examPaperSubQuestionModel.hintModel.answer];
            CGSize jieXiTextSize = [self getAttributedTextHeightHtml:answerStr  with_viewMaxRect:CGRectMake(0, 0, kScreenWidth-40, CGFLOAT_HEIGHT_UNKNOWN)];
            self.jieXiLabel.sd_layout.heightIs(jieXiTextSize.height);
            [self.jieXiLabel updateLayout];
            self.jieXiLabel.attributedString = [self getAttributedStringWithHtml:answerStr  fontColor:ExamJieXiColor];
            [self.jieXiLabel relayoutText];
            
            self.addPhotoBtn.hidden = self.photoTipLabel.hidden = YES;
            self.jieXiView.hidden  = NO;
            self.addPhotoBtn.userInteractionEnabled = self.textView.editable = NO;
            [self.mainScrollView setupAutoContentSizeWithBottomView:self.jieXiView bottomMargin:ExamSubChoiceCellHeight];
        }
        
        
    }else{//选择题(单选和多选)
        
        BOOL isDuoXuan= examPaperSubQuestionModel.isDuoXuan;
        
        self.answerTipLabel.sd_layout.topSpaceToView(self.attributedTitleLabel, 20).heightIs(20);
        self.grayView.hidden = YES;
        
        
        
        
        
        if (examPaperSubQuestionModel.subQuestionChoices.count>0) {
            //A
            self.aChoiceView.hidden = NO;
            HXExamSubQuestionChoicesModel *aModel = examPaperSubQuestionModel.subQuestionChoices[0];
            CGSize AtextSize = [self getAttributedTextHeightHtml:aModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
            self.aChoiceLabel.sd_layout.heightIs(AtextSize.height);
            [self.aChoiceLabel updateLayout];
            self.aChoiceLabel.attributedString = [self getAttributedStringWithHtml:aModel.subChoice_staticContent  fontColor:nil];
            [self.aChoiceLabel relayoutText];
            
            if (aModel.isSelected&&!isDuoXuan) {
                self.selectView = self.aTapView;
                self.aTapView.backgroundColor =  ExamSelectColor;
            }else{
                self.aTapView.backgroundColor = (aModel.isSelected?ExamSelectColor:ExamUnSelectColor);
            }
            
            //B
            if (examPaperSubQuestionModel.subQuestionChoices.count>=2) {
                self.bChoiceView.hidden = NO;
                HXExamSubQuestionChoicesModel *bModel = examPaperSubQuestionModel.subQuestionChoices[1];
                CGSize BtextSize = [self getAttributedTextHeightHtml:bModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
                self.bChoiceLabel.sd_layout.topSpaceToView(self.bChoiceView, 10).heightIs(BtextSize.height);
                [self.bChoiceLabel updateLayout];
                self.bChoiceLabel.attributedString = [self getAttributedStringWithHtml:bModel.subChoice_staticContent  fontColor:nil];
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
            if (examPaperSubQuestionModel.subQuestionChoices.count>=3) {
                self.cChoiceView.hidden = NO;
                HXExamSubQuestionChoicesModel *cModel = examPaperSubQuestionModel.subQuestionChoices[2];
                CGSize CtextSize = [self getAttributedTextHeightHtml:cModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
                self.cChoiceLabel.sd_layout.topSpaceToView(self.cChoiceView, 10).heightIs(CtextSize.height);
                [self.cChoiceLabel updateLayout];
                self.cChoiceLabel.attributedString = [self getAttributedStringWithHtml:cModel.subChoice_staticContent fontColor:nil];
                [self.cChoiceLabel relayoutText];
               
                if (cModel.isSelected&&!isDuoXuan) {//单选
                    self.selectView = self.cTapView;
                    self.cTapView.backgroundColor =  ExamSelectColor;
                }else{//多选
                    self.cTapView.backgroundColor = (cModel.isSelected?ExamSelectColor:ExamUnSelectColor);
                }
            }else{
                self.cChoiceLabel.sd_layout.topSpaceToView(self.cChoiceView, 0).heightIs(0);
                [self.cChoiceLabel updateLayout];
            }
            
            //D
            if (examPaperSubQuestionModel.subQuestionChoices.count>=4) {
                self.dChoiceView.hidden = NO;
                HXExamSubQuestionChoicesModel *dModel = examPaperSubQuestionModel.subQuestionChoices[3];
                CGSize DtextSize = [self getAttributedTextHeightHtml:dModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
                self.dChoiceLabel.sd_layout.topSpaceToView(self.dChoiceView, 10).heightIs(DtextSize.height);
                [self.dChoiceLabel updateLayout];
                self.dChoiceLabel.attributedString = [self getAttributedStringWithHtml:dModel.subChoice_staticContent fontColor:nil];
                [self.dChoiceLabel relayoutText];
                
                if (dModel.isSelected&&!isDuoXuan) {//单选
                    self.selectView = self.dTapView;
                    self.dTapView.backgroundColor =  ExamSelectColor;
                }else{
                    self.dTapView.backgroundColor = (dModel.isSelected?ExamSelectColor:ExamUnSelectColor);
                }
            }else{//多选
                self.dChoiceLabel.sd_layout.topSpaceToView(self.dChoiceView, 0).heightIs(0);
                [self.dChoiceLabel updateLayout];
            }
            
            //E
            if (examPaperSubQuestionModel.subQuestionChoices.count>=5) {
                self.eChoiceView.hidden = NO;
                HXExamSubQuestionChoicesModel *eModel = examPaperSubQuestionModel.subQuestionChoices[4];
                CGSize EtextSize = [self getAttributedTextHeightHtml:eModel.subChoice_staticContent  with_viewMaxRect:self.choiceMaxRect];
                self.eChoiceLabel.sd_layout.topSpaceToView(self.eChoiceView, 10).heightIs(EtextSize.height);
                [self.eChoiceLabel updateLayout];
                self.eChoiceLabel.attributedString = [self getAttributedStringWithHtml:eModel.subChoice_staticContent fontColor:nil];
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
        
        //查看答卷，不能作答，禁用选择
        self.aTapView.userInteractionEnabled = self.bTapView.userInteractionEnabled = self.cTapView.userInteractionEnabled = self.dTapView.userInteractionEnabled = self.eTapView.userInteractionEnabled = examPaperSubQuestionModel.isContinuerExam;
    
    
        //查看答卷
        if (!examPaperSubQuestionModel.isContinuerExam) {
            //正确答案
            self.answerView.sd_layout.topSpaceToView(self.eChoiceView, 10).heightIs(40);
            self.rightContentLabel.text= [examPaperSubQuestionModel.hintModel.answer uppercaseString];
            self.selectContentLabel.text= [examPaperSubQuestionModel.answerModel.answer
                                           uppercaseString];
            //解析
            CGSize jieXiTextSize = [self getAttributedTextHeightHtml:examPaperSubQuestionModel.hintModel.hint  with_viewMaxRect:CGRectMake(0, 0, kScreenWidth-40, CGFLOAT_HEIGHT_UNKNOWN)];
            self.jieXiLabel.sd_layout.heightIs(jieXiTextSize.height);
            [self.jieXiLabel updateLayout];
            self.jieXiLabel.attributedString = [self getAttributedStringWithHtml:examPaperSubQuestionModel.hintModel.hint fontColor:ExamJieXiColor];
            [self.jieXiLabel relayoutText];
            
            self.answerView.hidden = self.jieXiView.hidden = NO;
            self.answerTipLabel.sd_layout.topSpaceToView(self.attributedTitleLabel, 20).heightIs(20);
            
            if (examPaperSubQuestionModel.answerModel == nil) {//未作答
                self.answerTipLabel.textColor =COLOR_WITH_ALPHA(0xED4F4F, 1);
                self.answerTipLabel.text = @"× 您没有作答";
            }else{
                if (examPaperSubQuestionModel.answerModel.right) {
                    self.answerTipLabel.textColor = COLOR_WITH_ALPHA(0x4ED838, 1);
                    self.answerTipLabel.text = @"✓ 您答对了";
                }else{
                    self.answerTipLabel.textColor =COLOR_WITH_ALPHA(0xED4F4F, 1);
                    self.answerTipLabel.text = @"× 您答错了";
                }
            }
        }else{
            //正确答案
            self.answerView.sd_layout.topSpaceToView(self.eChoiceView, 0).heightIs(0);
            self.jieXiLabel.sd_layout.heightIs(0);
            [self.jieXiLabel updateLayout];
            self.answerView.hidden = self.jieXiView.hidden = YES;
            self.answerTipLabel.sd_layout.topSpaceToView(self.attributedTitleLabel, 0).heightIs(0);
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
    
    for (DTTextAttachment *oneAttachment in [self.jieXiLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize attributedLabel:self.jieXiLabel];
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
            self.attributedTitleLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.attributedTitleLabel relayoutText];
        }
    }else if (attributedLabel == self.aChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[0];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.aChoiceLabel.sd_layout.topSpaceToView(self.aChoiceView, 10).heightIs(textSize.height);
            [self.aChoiceLabel updateLayout];
            self.aChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.aChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.bChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[1];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.bChoiceLabel.sd_layout.topSpaceToView(self.bChoiceView, 10).heightIs(textSize.height);
            [self.bChoiceLabel updateLayout];
            self.bChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.bChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.cChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[2];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.cChoiceLabel.sd_layout.topSpaceToView(self.cChoiceView, 10).heightIs(textSize.height);
            [self.cChoiceLabel updateLayout];
            self.cChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.cChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.dChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[3];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.dChoiceLabel.sd_layout.topSpaceToView(self.dChoiceView, 10).heightIs(textSize.height);
            [self.dChoiceLabel updateLayout];
            self.dChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.dChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.eChoiceLabel) {
        HXExamSubQuestionChoicesModel *model = self.examPaperSubQuestionModel.subQuestionChoices[4];
        if ([model.subChoice_staticContent containsString:imageInfo]) {
            NSString *newHtml = [model.subChoice_staticContent stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
            // reload newHtml
            CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:self.choiceMaxRect];
            self.eChoiceLabel.sd_layout.topSpaceToView(self.eChoiceView, 10).heightIs(textSize.height);
            [self.eChoiceLabel updateLayout];
            self.eChoiceLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:nil];
            [self.eChoiceLabel relayoutText];
        }
    }else if (attributedLabel == self.jieXiLabel) {
        
        if (self.examPaperSubQuestionModel.subQuestionChoices==0) {//问答题
            if ([self.examPaperSubQuestionModel.hintModel.answer containsString:imageInfo]) {
                NSString *answerStr = [NSString stringWithFormat:@"答案:%@",self.examPaperSubQuestionModel.hintModel.answer];
                NSString *newHtml = [answerStr stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
                // reload newHtml
                CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:CGRectMake(0, 0, kScreenWidth-40, CGFLOAT_HEIGHT_UNKNOWN)];
                self.jieXiLabel.sd_layout.heightIs(textSize.height);
                [self.jieXiLabel updateLayout];
                self.jieXiLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:ExamJieXiColor];
            }
        }else{
            if ([self.examPaperSubQuestionModel.hintModel.hint containsString:imageInfo]) {
                NSString *newHtml = [self.examPaperSubQuestionModel.hintModel.hint stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
                // reload newHtml
                CGSize textSize = [self getAttributedTextHeightHtml:newHtml with_viewMaxRect:CGRectMake(0, 0, kScreenWidth-40, CGFLOAT_HEIGHT_UNKNOWN)];
                self.jieXiLabel.sd_layout.heightIs(textSize.height);
                [self.jieXiLabel updateLayout];
                self.jieXiLabel.attributedString = [self getAttributedStringWithHtml:newHtml fontColor:ExamJieXiColor];
            }
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
   
    [self.mainScrollView addSubview:self.attributedTitleLabel];
    [self.mainScrollView addSubview:self.fenShuBgImageView];
    
    [self.mainScrollView addSubview:self.answerTipLabel];
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
    
    [self.mainScrollView addSubview:self.answerView];
    
    [self.mainScrollView addSubview:self.jieXiView];
    [self.jieXiView addSubview:self.jieXiLabel];
    
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
    
    //正确答案
    self.answerView.sd_layout
        .topSpaceToView(self.photosContainerView, 10)
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
    
    //解析
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
    
    
    [self.mainScrollView setupAutoContentSizeWithBottomView:self.jieXiView bottomMargin:ExamSubChoiceCellHeight];
    

   
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

-(UILabel *)answerTipLabel{
    if (!_answerTipLabel) {
        _answerTipLabel = [[UILabel alloc] init];
        _answerTipLabel.numberOfLines=1;
        _answerTipLabel.textColor = COLOR_WITH_ALPHA(0x333333, 1);
        _answerTipLabel.font = HXBoldFont(17);
    }
    return _answerTipLabel;
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
        _dTapView.backgroundColor =  ExamUnSelectColor;
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

