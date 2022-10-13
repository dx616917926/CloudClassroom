//
//  HXCommonUtil.m
//  HXMinedu
//
//  Created by mac on 2021/3/30.
//

#import "HXCommonUtil.h"

@implementation HXCommonUtil

/**
 *  判断对象是否为空，包括 nil、空字符串、NSNull
 *  @param obj 需要进行判断的对象
 *  @return 对象为空返回YES，否则返回NO
 */
+ (BOOL)isNull:(id)obj {
    if ([obj isKindOfClass:[NSNull class]] || !obj) {
        return YES;
    } else if ([obj isKindOfClass:[NSString class]] && [[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

/**
 字符串编码
 */
+ (NSString *)stringEncoding:(NSString *)str{
    if ([HXCommonUtil isNull:str]) {
        return @"";
    }
    return  [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
}



/**
 字符串解码
 */
+ (NSString*)strDecodedString:(NSString*)str{
    if ([HXCommonUtil isNull:str]) {
        return @"";
    }
    NSString *decodedString=[str stringByRemovingPercentEncoding];
    return decodedString;
}

//生成指定长度的字符串
+ (NSString *)generateTradeNO:(NSInteger)len{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform(letters.length)]];
    }
    return randomString;
    
}
/**
 属性化文字
 @param needString             需要属性化的文字
 @param needAttributedDic      添加的属性
 @param content                所有文本
 @param defaultAttributedDic   默认的属性
 @return 属性化文字
 */
+ (NSMutableAttributedString *)getAttributedStringWith:(NSString *)needString needAttributed:(NSDictionary *)needAttributedDic content:(NSString *)content defaultAttributed:(NSDictionary *)defaultAttributedDic{
    if ([HXCommonUtil isNull:content]||[HXCommonUtil isNull:needString]) {
        return nil;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    ///添加默认属性
    if (defaultAttributedDic!=nil&&![HXCommonUtil isNull:content]) {
        [attributedString addAttributes:defaultAttributedDic range:NSMakeRange(0, content.length)];
    }
    if (needAttributedDic!=nil&&![HXCommonUtil isNull:needString]) {
        ///需要属性化的范围
        NSRange range =  [content rangeOfString:needString];
        ///添加属性
        [attributedString addAttributes:needAttributedDic range:range];
    }
    
    return attributedString;
}

/**
 属性化文字
 @param needStringArray             需要属性化的文字数组
 @param needAttributedDic      添加的属性
 @param content                所有文本
 @param defaultAttributedDic   默认的属性
 @return 属性化文字
 */
+ (NSMutableAttributedString *)getAttributedStringWithArray:(NSArray<NSString *> *)needStringArray needAttributed:(NSDictionary *)needAttributedDic content:(NSString *)content defaultAttributed:(NSDictionary *)defaultAttributedDic{
    if ([HXCommonUtil isNull:content]||needStringArray.count==0) {
        return nil;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    ///添加默认属性
    if (defaultAttributedDic!=nil&&![HXCommonUtil isNull:content]) {
        [attributedString addAttributes:defaultAttributedDic range:NSMakeRange(0, content.length)];
    }
    
    for (NSString *needString in needStringArray) {
        if (needAttributedDic!=nil&&![HXCommonUtil isNull:needString]) {
            ///需要属性化的范围
            NSRange range =  [content rangeOfString:needString];
            ///添加属性
            [attributedString addAttributes:needAttributedDic range:range];
        }
    }
    return attributedString;
}

/**
 图片质量压缩到某一范围内，如果后面用到多，可以抽成分类或者工具类,这里压缩递减比二分的运行时间长，二分可以限制下限。
 */
+ (UIImage *)compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength{
    //首先判断原图大小是否在要求内，如果满足要求则不进行压缩，over
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    NSLog(@"原图大小：%.2f M",(float)data.length/(1024*1024.0f));
    if (data.length < maxLength) return image;
    //原图大小超过范围，先进行“压处理”，这里 压缩比 采用二分法进行处理，6次二分后的最小压缩比是0.015625，已经够小了
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    //判断“压处理”的结果是否符合要求，符合要求就over
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    //缩处理，直接用大小的比例作为缩处理的比例进行处理，因为有取整处理，所以一般是需要两次处理
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        //获取处理后的尺寸
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
        //通过图片上下文进行处理图片
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //获取处理后图片的大小
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}


//限制UITextField输入的长度，包括汉字  一个汉字算2个字符
+(void)limitIncludeChineseTextField:(UITextField *)textField Length:(NSUInteger)kMaxLength
{
    NSString *toBeString = textField.text;
    NSUInteger length = [self unicodeLengthOfString:toBeString];
    
    NSString *lang = [textField.textInputMode primaryLanguage];
    
    //    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            
            if (length > kMaxLength) {
                
                textField.text = [self subStringIncludeChinese:toBeString ToLength:kMaxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        
        if (length > kMaxLength) {
            textField.text = [self subStringIncludeChinese:toBeString ToLength:kMaxLength];
        }
    }
}

///判断输入的字符长度 一个汉字算2个字符
+ (NSUInteger)unicodeLengthOfString:(NSString *)text {
    NSUInteger asciiLength = 0;
    for(NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    return asciiLength;
}

//字符串截到对应的长度包括中文 一个汉字算2个字符
+ (NSString *)subStringIncludeChinese:(NSString *)text ToLength:(NSUInteger)length{
    
    if (text==nil) {
        return text;
    }
    
    NSUInteger asciiLength = 0;
    NSUInteger location = 0;
    for(NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
        
        if (asciiLength==length) {
            location=i;
            break;
        }else if (asciiLength>length){
            location=i-1;
            break;
        }
        
    }
    
    if (asciiLength<length) { //文字长度小于限制长度
        return text;
        
    } else {
        
        __block NSMutableString * finalStr = [NSMutableString stringWithString:text];
        
        [text enumerateSubstringsInRange:NSMakeRange(0, [text length]) options:NSStringEnumerationByComposedCharacterSequences|NSStringEnumerationReverse usingBlock:
         ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            
            //             DLog(@"substring:%@ substringRange:%@  enclosingRange:%@",substring,NSStringFromRange(substringRange),NSStringFromRange(enclosingRange));
            
            if (substringRange.location<=location+1) {
                NSString *temp=[text substringToIndex:substringRange.location];
                finalStr=[NSMutableString stringWithString:temp];
                *stop=YES;
            }
            
        }];
        
        return finalStr;
    }
}



//限制UITextView输入的长度，包括汉字  一个汉字算2个字符
+(void)limitIncludeChineseTextView:(UITextView *)textview Length:(NSUInteger)kMaxLength
{
    NSString *toBeString = textview.text;
    NSUInteger length = [self unicodeLengthOfString:toBeString];
    
    NSString *lang = [textview.textInputMode primaryLanguage];
    //    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，简体五笔，简体手写
        UITextRange *selectedRange = [textview markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textview positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            
            if (length > kMaxLength) {
                NSString *msg = [NSString stringWithFormat:@"内容最多只能%zi字",[self deptNumInputShouldNumber:textview.text]?kMaxLength: kMaxLength/2];
                //                showMessageInWindow(msg);
                textview.text = [self subStringIncludeChinese:toBeString ToLength:kMaxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        
        if (length > kMaxLength) {
            
            NSString *msg = [NSString stringWithFormat:@"内容最多只能%zi字",[self deptNumInputShouldNumber:textview.text]?kMaxLength: kMaxLength/2];
            //            showMessageInWindow(msg);
            textview.text = [self subStringIncludeChinese:toBeString ToLength:kMaxLength];
        }
    }
}

+ (BOOL) deptNumInputShouldNumber:(NSString *)str
{
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

/*
 18位身份证验证要求
 */
+(bool)checkIDCardIsOrNotLegalWithIDCard:(NSString*)cardNo
{
    if (cardNo.length != 18) {
        return  NO;
    }
    NSArray* codeArray = [NSArray arrayWithObjects:@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2", nil];
    NSDictionary* checkCodeDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2", nil]  forKeys:[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil]];
    
    NSScanner* scan = [NSScanner scannerWithString:[cardNo substringToIndex:17]];
    
    int val;
    BOOL isNum = [scan scanInt:&val] && [scan isAtEnd];
    if (!isNum) {
        return NO;
    }
    int sumValue = 0;
    
    for (int i =0; i<17; i++) {
        sumValue+=[[cardNo substringWithRange:NSMakeRange(i , 1) ] intValue]* [[codeArray objectAtIndex:i] intValue];
    }
    
    NSString* strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d",sumValue%11]];
    
    if ([strlast isEqualToString: [[cardNo substringWithRange:NSMakeRange(17, 1)]uppercaseString]]) {
        return YES;
    }
    return  NO;
}
//根据身份证号获取生日
+(NSString *)birthdayStrFromIdentityCard:(NSString *)numberStr
{
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    NSString *year = nil;
    NSString *month = nil;
    
    BOOL isAllNumber = YES;
    NSString *day = nil;
    if([numberStr length]<14)
        return result;
    
    //**截取前14位
    NSString *fontNumer = [numberStr substringWithRange:NSMakeRange(0, 13)];
    
    //**检测前14位否全都是数字;
    const char *str = [fontNumer UTF8String];
    const char *p = str;
    while (*p!='\0') {
        if(!(*p>='0'&&*p<='9'))
            isAllNumber = NO;
        p++;
    }
    if(!isAllNumber)
        return result;
    
    year = [numberStr substringWithRange:NSMakeRange(6, 4)];
    month = [numberStr substringWithRange:NSMakeRange(10, 2)];
    day = [numberStr substringWithRange:NSMakeRange(12,2)];
    
    [result appendString:year];
    [result appendString:@"-"];
    [result appendString:month];
    [result appendString:@"-"];
    [result appendString:day];
    return result;
}



//根据身份证号性别
+(NSString *)getIdentityCardSex:(NSString *)numberStr{
    NSString *sex = @"";
    //获取18位 二代身份证  性别
    if (numberStr.length==18){
        int sexInt=[[numberStr substringWithRange:NSMakeRange(16,1)] intValue];
        if(sexInt%2!=0){
            sex = @"男";
        }else{
            sex = @"女";
        }
    }
    //    //  获取15位 一代身份证  性别
    //    if (numberStr.length==15){
    //        int sexInt=[[numberStr substringWithRange:NSMakeRange(14,1)] intValue];
    //        if(sexInt%2!=0){
    //            sex = @"男";
    //        }else{
    //            sex = @"女";
    //        }
    //    }
    return sex;
}

#pragma mark - 根据view生成image
+ (UIImage *)getMakeImageWithView:(UIView *)view{
    //下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数 。
    UIGraphicsBeginImageContextWithOptions(view.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 获取当前的日期
 默认日期格式为:yyyy-MM-dd HH-mm
 */
+ (NSString *)getCurrentDateWithFormatterStr:(NSString *)formatterStr{
    // 设置 日期的格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([HXCommonUtil isNull:formatterStr]) {
        [formatter setDateFormat:@"yyyy-MM-dd HH-mm"];
    }else{
        [formatter setDateFormat:formatterStr];
    }
    // 获取 当前系统时间
    NSString *dataTime = [formatter stringFromDate:[NSDate date]];
    return dataTime;
}

/**
 将某个时间戳转化成 时间
 默认日期格式为:yyyy.MM.dd  HH:mm
 */
+(NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(format){
        [formatter setDateFormat:format];
    }else{
        [formatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    }
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;

}

@end
