#import <Foundation/Foundation.h>

#define kBytesPerG  1073741824    // 1024 * 1024 * 1024
#define kBytesPerM  1048576       // 1024 * 1024
#define kBytesPerK  1024          // 1024

@interface Utilities : NSObject {

}
+(NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str;
+(BOOL)fileIsExist:(NSString*)file;
+(BOOL)deleteFileAtPath:(NSString*)filePath;
+(BOOL)deleteDirAtPath:(NSString*)DirPath;
+(NSString *)getDirPathCreateIfNeed:(NSString*)dirPath;
+(NSString *)getFilePathCreateIfNeed:(NSString*)dirPath file:(NSString*)fileName;
+(NSString *)getMD5FilePathCreateIfNeed:(NSString*)dirPath file:(NSString*)fileName;
+(NSString *)MD5StringWithKey:(NSString*)key;

+(NSString *)diskSizeToHumanString:(unsigned long long)bytes;
+(long long)folderSizeAtPath:(NSString*)folderPath;
+(long long)fileSizeAtPath:(NSString*)filePath;
+(NSString *)timeToHumanString:(NSInteger)ms;
+(NSString *)timeToHumanString2:(NSInteger)seconds;

+(NSMutableDictionary *)getDictionaryFromUrlQuery:(NSString *)query;

+(void)setCharsWithString:(NSString *)str withChar:(char*)cr withSize:(int)size;
+(NSString *)getSpecialStringWithCharArry:(char*)cr size:(int)size;
+(BOOL)isCompletetWithChar:(char*)cr withSize:(int)size;
+(BOOL)isCompletetWithChar:(char*)cr withStart:(int)start withEnd:(int)end;
+(BOOL)isCompletetWithChar:(char*)cr withSize:(int)size andTotal:(int)total;  //no

+(NSString *)getNowTimeForHumanString;
+(NSString *)dateTimeToHumanString:(NSDate*)date;
+(NSString *)dateTimeToHumanString:(NSDate*)date WithFormat:(NSString *)formatStr;
+(NSString *)getBatteryLevelForHumanString;
+(NSString *)percentageToHumanString:(float)percentage;

+(BOOL)isLocalMedia:(NSURL*)url;
+(BOOL)isIPodOrCameraFile:(NSURL*)url;
+(void)removeFileInSharingLibrary:(NSURL*)fileURL;
+(BOOL)file:(NSString *)file isExpirationWithSeconds:(int)secs;

+(BOOL)systemVersionIsHighOrEqualToIt:(NSString*)minSystemVersion;
+(BOOL)systemVersionIsEqualToIt:(NSString*)version;
+(BOOL)isFirstTimeTouchHere:(NSString *)str;


+(UIColor*)colorR:(int)r G:(int)g B:(int)b A:(int)a;
+(UIColor*)colorWithRed:(int)r withGreen:(int)g withBlue:(int)b;
+(UIColor*)colorWithHexNumber:(unsigned long)colorHex;
+(unsigned long)colorHexNumberWithUIColor:(UIColor *)color;

+(float)getCurSystemBright;
+(void)setCurSystemBright:(float)bright;

+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+(void)showErrorView:(NSString *)sError withReason:(NSString *)sReason;

//支持查看课件目录的类型
+(BOOL)isSystemSupportType:(NSString *)type;

//移动端支持播放的类型
+(BOOL)isSystemSupportPlayType:(NSString *)type;

//验证电话号码
+(BOOL)isValidateTelNumber:(NSString *)number;
//验证email
+(BOOL)isValidateEmail:(NSString *)email;
//是否是有效的正则表达式
+(BOOL)isValidateRegularExpression:(NSString *)strDestination byExpression:(NSString *)strExpression;

@end

