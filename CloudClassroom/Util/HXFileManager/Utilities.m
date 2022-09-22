#import <sys/xattr.h>
#import "UIKit/UIKit.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CommonCrypto/CommonDigest.h>
#import "Utilities.h"

@implementation Utilities

+(NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    
    NSMutableArray *results = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, [str length]);
    NSRange range;
    while ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        
        [results addObject:[NSString stringWithFormat:@"%ld",range.location]];
        
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
    
    return results;
}

+(BOOL)fileIsExist:(NSString*)file
{
    return [[NSFileManager defaultManager] fileExistsAtPath:file];
}

+(BOOL)deleteFileAtPath:(NSString*)filePath
{
    NSError * error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    return success;
}

+(BOOL)deleteDirAtPath:(NSString*)DirPath
{
    return [[NSFileManager defaultManager] removeItemAtPath:DirPath error:nil];
}

+(NSString *)getDirPathCreateIfNeed:(NSString*)dirPath
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ( ![fileManager fileExistsAtPath:dirPath] ) {
        [fileManager createDirectoryAtPath:dirPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }
    return dirPath;
}

+(NSString *)getFilePathCreateIfNeed:(NSString*)dirPath file:(NSString*)fileName
{
    return [[Utilities getDirPathCreateIfNeed:dirPath]
            stringByAppendingPathComponent:fileName];
}

+(NSString *)getMD5FilePathCreateIfNeed:(NSString*)dirPath file:(NSString*)fileName
{
    return [self getFilePathCreateIfNeed:dirPath
                                    file:[self MD5StringWithKey:fileName]];
}

+(NSString *)MD5StringWithKey:(NSString*)key
{
    if (key == nil || key.length ==0) {
        return @"";
    }
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *md5str = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"
                        "%02x%02x%02x%02x%02x%02x",
                        r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9],
                        r[10], r[11], r[12], r[13], r[14], r[15]];
    return md5str;
}


+(NSString *)diskSizeToHumanString:(unsigned long long)bytes
{
    char buff[128] = { 0 };
    NSString *nsRet = nil;

    long G = bytes / kBytesPerG;
    long M = (bytes - G * kBytesPerG) / kBytesPerM;
    long K = (bytes - G * kBytesPerG - M * kBytesPerM) / kBytesPerK;
    long B = bytes - G * kBytesPerG - M * kBytesPerM - K * kBytesPerK;

    if ( G > 0 )
        snprintf(buff, sizeof(buff), "%.2fGB", (double)bytes / kBytesPerG);
    else if ( M > 0 )
        snprintf(buff, sizeof(buff), "%ldMB", M + 1);
    else if ( K > 0 )
        snprintf(buff, sizeof(buff), "%ldKB", K + 1);
    else
        snprintf(buff, sizeof(buff), "%ldB", B);

    nsRet = [[NSString alloc] initWithCString:buff
                                      encoding:NSUTF8StringEncoding];

    return nsRet;
}

+(long long)folderSizeAtPath:(NSString*)folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
    }
    return folderSize;
}

+(long long)fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath]) return 0;
    long long folderSize = 0;
    folderSize += [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    return folderSize;
}

+(NSString *)timeToHumanString:(NSInteger)seconds
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    NSString *format = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m ,s];
    
    return format;
}

+(NSString *)timeToHumanString2:(NSInteger)seconds
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    //NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    NSString *format = [NSString stringWithFormat:@"%02d:%02d",m,s];
    
    return format;
}


+(NSMutableDictionary *)getDictionaryFromUrlQuery:(NSString *)query
{
    if (query == nil || [query isEqualToString:@""]) {
        return nil;
    }
    NSArray * ary = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    for (NSString * str in ary) {
        NSRange range = [str rangeOfString:@"="];
        if (range.location != NSNotFound) {
            NSString * key  = [str substringToIndex:range.location];
            NSString * value = [str substringFromIndex:range.location+1];
            [dic setObject:value forKey:key];
        }
    }
    return dic;
}


//将特殊字符串赋值给特殊char*
+(void)setCharsWithString:(NSString *)str withChar:(char*)cr withSize:(int)size
{
    if (str == nil || [str isEqualToString:@""] || [str isEqual:[NSNull null]]) {
        return;
    }
    
    NSArray * strings = [str componentsSeparatedByString:@"/"];
    for (NSString * s in strings) {
        
        if ([s isEqualToString:@""]) {
            break;
        }
        NSArray * sub = [s componentsSeparatedByString:@"-"];
        if (sub.count==2) {
            int start = [[sub objectAtIndex:0] intValue];
            int end = [[sub objectAtIndex:1] intValue];
            
            if (start<=size && end <=size) {
                for (int i = start; i<end; i++) {
                    cr[i] = 1;
                }
            }
        }
        
    }
}

//将特殊char*转化为特殊字符串
+(NSString *)getSpecialStringWithCharArry:(char*)cr size:(int)size;
{
    NSLog(@"size:%d ",size);
    
    if (cr == NULL) {
        return @"";
    }
    
    NSMutableString * string = [[NSMutableString alloc]init];
    int start = 0;
    int end = 0;
    short begin = 0;
    for (int i = 0; i<size; i++) {
        
        if (cr[i] == 1) {
            if (begin == 0) {
                begin = 1;
                start = i;
            }
            if (i == size-1) { //最后一个数字要结尾
                end = i;
                [string appendString:[NSString stringWithFormat:@"%d-%d/",start,end]];
            }
        }else
        {
            if (begin == 1) {
                begin = 0;
                end = i;
                [string appendString:[NSString stringWithFormat:@"%d-%d/",start,end]];
            }
        }
    }
    return string;
}

+(BOOL)isCompletetWithChar:(char*)cr withSize:(int)size
{
    if (cr == NULL) {
        return NO;
    }
    float num = 0;
    for (int i = 0; i<size; i++) {
        if (cr[i] == 1) {
            num++;
        }
    }
    if (num/size >= 0.7 ) {
        return YES;
    }
    return NO;
}

+(BOOL)isCompletetWithChar:(char*)cr withStart:(int)start withEnd:(int)end
{
    if (cr == NULL || end<start) {
        return NO;
    }
    float num = 0;
    for (int i = start; i<end; i++) {
        if (cr[i] == 1) {
            num++;
        }
    }
    if (num/(end-start) >= 0.7 ) {
        return YES;
    }
    return NO;
}

+(BOOL)isCompletetWithChar:(char*)cr withSize:(int)size andTotal:(int)total
{
    if (cr == NULL) {
        return NO;
    }
    float num = 0;
    for (int i = 0; i<size; i++) {
        if (cr[i] == 1) {
            num++;
        }
    }
    if (num/total >= 0.7 ) {
        return YES;
    }
    return NO;
}

+(NSString *)getNowTimeForHumanString
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
	[formatter setDateFormat:@"HH:mm"];
    NSString *nsNow = [formatter stringFromDate:now];

    return nsNow;
}

+(NSString *)dateTimeToHumanString:(NSDate*)date
{
    if ( date == nil ) return nil;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *ns = [formatter stringFromDate:date];

    return ns;
}

+(NSString *)dateTimeToHumanString:(NSDate*)date WithFormat:(NSString *)formatStr
{
    if ( date == nil ) return nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:formatStr];
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *ns = [formatter stringFromDate:date];
    
    return ns;
}

+(NSString *)getBatteryLevelForHumanString
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    float battLvl = [[UIDevice currentDevice] batteryLevel];
    char buff[32] = { 0 };
    NSString *nsRet = nil;

    snprintf(buff, sizeof(buff), "%d%%", (int)(battLvl * 100));
    nsRet = [[NSString alloc] initWithCString:buff
                                      encoding:NSUTF8StringEncoding];

    return nsRet;
}

+(NSString *)percentageToHumanString:(float)percentage
{
    char buff[16] = { 0 };
    NSString *nsRet = nil;

    snprintf(buff, sizeof(buff), "%d%%", (int)(percentage * 100));
    nsRet = [[NSString alloc] initWithCString:buff
                                      encoding:NSUTF8StringEncoding];

    return nsRet;
}

+(BOOL)isLocalMedia:(NSURL*)url
{
    static NSString * const local = @"/";
    static NSString * const local2 = @"file://";
    static NSString * const iPod = @"ipod-library://";
    static NSString * const camera = @"assets-library://";

    NSString * urlStr = [url absoluteString];
    if ( [urlStr hasPrefix:local] ) return YES;
    if ( [urlStr hasPrefix:local2] ) return YES;
    if ( [urlStr hasPrefix:iPod] ) return YES;
    if ( [urlStr hasPrefix:camera] ) return YES;

    return NO;
}

+(BOOL)isIPodOrCameraFile:(NSURL*)url
{
    static NSString * const iPod = @"ipod-library://";
    static NSString * const camera = @"assets-library://";

    NSString * urlStr = [url absoluteString];
    if ( [urlStr hasPrefix:iPod] ) return YES;
    if ( [urlStr hasPrefix:camera] ) return YES;

    return NO;
}

+(void)removeFileInSharingLibrary:(NSURL*)fileURL
{
    if ( ![fileURL isFileURL] ) {
        return;
    }
    NSFileManager *fileMg = [[NSFileManager alloc] init];
    [fileMg removeItemAtPath:[fileURL path] error:nil];
}

+(BOOL)file:(NSString *)file isExpirationWithSeconds:(int)secs
{
    if (!file || ![[NSFileManager defaultManager] fileExistsAtPath:file])
		return YES;
    NSDate *exp = [NSDate dateWithTimeIntervalSinceNow:-secs];
	NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
	if ([[[attrs fileModificationDate] laterDate:exp] isEqualToDate:exp]) {
		return YES;
    }
	return NO;
}

+(BOOL)systemVersionIsHighOrEqualToIt:(NSString*)minSystemVersion
{
	NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
	if ( [systemVersion compare:minSystemVersion options:NSNumericSearch] != NSOrderedAscending ) {
        return YES;
    }
    return NO;
}

+(BOOL)systemVersionIsEqualToIt:(NSString*)version
{
	NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
	if ( [systemVersion compare:version options:NSNumericSearch] == NSOrderedSame ) {
        return YES;
    }
    return NO;
}

+(BOOL)isFirstTimeTouchHere:(NSString *)str
{
	assert(str != nil && ![str isEqualToString:@""]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:str] == nil) {
		[defaults setObject:str forKey:str];
		[defaults synchronize];
        return YES;
    }
    return NO;
}

+(UIColor*)colorR:(int)r G:(int)g B:(int)b A:(int)a
{
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
}

+(UIColor*)colorWithRed:(int)r withGreen:(int)g withBlue:(int)b
{
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}

+(UIColor*)colorWithHexNumber:(unsigned long)colorHex
{
    return [UIColor colorWithRed:((colorHex & 0xFF000000) >> 24)/255.0
                           green:((colorHex & 0x00FF0000) >> 16)/255.0
                            blue:((colorHex & 0x0000FF00) >> 8) /255.0
                           alpha:((colorHex & 0x000000FF))      /255.0];
}

+(unsigned long)colorHexNumberWithUIColor:(UIColor *)color
{
	CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 1.0;
	const CGFloat *components = CGColorGetComponents(color.CGColor);
	size_t num = CGColorGetNumberOfComponents(color.CGColor);
	if (num == 4) {
		red = components[0];
		green = components[1];
		blue = components[2];
		alpha = components[3];
	} else if (num == 3) {
		red = components[0];
		green = components[1];
		blue = components[2];
	}

	int r = (int)(red * 255)   & 0xFF;
	int g = (int)(green * 255) & 0xFF;
	int b = (int)(blue * 255)  & 0xFF;
	int a = (int)(alpha * 255) & 0xFF;
	unsigned long rgba = r<<24 | g<<16 | b<< 8 | a;

	return rgba;
}

+(float)getCurSystemBright
{
    if ( [[UIScreen mainScreen] respondsToSelector:@selector(brightness)] ) {
        return [UIScreen mainScreen].brightness;
    }
    return 1.0;
}

+(void)setCurSystemBright:(float)bright
{
    if ( [[UIScreen mainScreen] respondsToSelector:@selector(brightness)] ) {
        [[UIScreen mainScreen] setBrightness:bright];
    }
}


+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:[URL path]] ) return YES;

    BOOL success = YES;
    if ( [self systemVersionIsHighOrEqualToIt:@"5.1"] ) {
        NSError *error = nil;
        success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                 forKey:NSURLIsExcludedFromBackupKey
                                  error:&error];
    } else if ( [self systemVersionIsEqualToIt:@"5.0.1"] ) {
        const char *filePath = [[URL path] fileSystemRepresentation];
        const char *attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        success = (result == 0);
    }

    return success;
}

+(void)showErrorView:(NSString *)sError withReason:(NSString *)sReason
{
	if (!sError) sError = @"Unknown Error";
	if (!sReason) sReason = @"Unknown Reason!";

	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
							   sError, NSLocalizedDescriptionKey,
							   sReason, NSLocalizedFailureReasonErrorKey,
							   nil];
	NSError *error = [NSError errorWithDomain:@"VPlayer" code:0 userInfo:errorDict];

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
														message:[error localizedFailureReason]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}


//支持查看课件目录的类型
+(BOOL)isSystemSupportType:(NSString *)type
{
    //只支持1(flash)、2(网页)、3(大视频，包括cc) 、4(移动设备兼容类型)类型课件
    if (type == nil || [type isKindOfClass:[NSNull class]] || [type isEqualToString:@""] || [type isEqualToString:@"<null>"]) {
        return NO;
    }
    if ([type isEqualToString:@"1"] || [type isEqualToString:@"2"] || [type isEqualToString:@"3"]) {
        return YES;
    }
    return NO;
}

//移动端支持播放的类型
+(BOOL)isSystemSupportPlayType:(NSString *)type
{
    //只支持1(flash)、2(网页)、3(大视频，包括cc) 、4(移动设备兼容类型)类型课件
    if (type == nil || [type isKindOfClass:[NSNull class]] || [type isEqualToString:@""] || [type isEqualToString:@"<null>"]) {
        return NO;
    }
    if ([type isEqualToString:@"1"] || [type isEqualToString:@"2"] || [type isEqualToString:@"3"]|| [type isEqualToString:@"4"]) {
        return YES;
    }
    return NO;
}

//是否是有效的正则表达式
+(BOOL)isValidateRegularExpression:(NSString *)strDestination byExpression:(NSString *)strExpression
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strExpression];
    
    return [predicate evaluateWithObject:strDestination];
    
}

//验证email
+(BOOL)isValidateEmail:(NSString *)email {
    
    NSString *strRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,5}";
    
    BOOL rt = [self isValidateRegularExpression:email byExpression:strRegex];
    
    return rt;
    
}

//验证电话号码
+(BOOL)isValidateTelNumber:(NSString *)number {
    
    NSString *strRegex = @"[0-9]{1,20}";
    
    BOOL rt = [self isValidateRegularExpression:number byExpression:strRegex];
    
    return rt;
    
}

@end
