//
//  BJLDocumentFile.m
//  BJLiveUI
//
//  Created by xijia dai on 2020/8/17.
//  Copyright © 2020 BaijiaYun. All rights reserved.
//

#import "BJLDocumentFile.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BJLDocumentFile

- (instancetype)init {
    if (self = [super init]) {
        self.state = BJLDocumentFileStateDefault;
        self.editMode = BJLDocumentFileEditModeDefault;
        self.type = BJLDocumentFileTypeDefault;
        self.progress = 0.0;
    }
    return self;
}

- (instancetype)initWithLocalDocument:(UIDocument *)localDocument {
    if (self = [super init]) {
        self.localDocument = localDocument;
        self.localID = [self getUniqueId];
        [self updateFileNameAndSuffixWithFileURL:localDocument.fileURL];
        [self updateFileTypeWithSuffix:self.suffix];
    }
    return self;
}

- (BOOL)shouldSupportUploadAndPlay {
    NSMutableArray<NSString *> *supportedSuffixArray = [@[@".ppt",
        @".pptx",
        @".doc",
        @".pdf",
        @".docx",
        @".jpg",
        @".jpeg",
        @".png",
        @".gif",
        @".bjon",
        @".zip",
        @".bds"] mutableCopy];
    [supportedSuffixArray addObjectsFromArray:[self audioSuffixArray]];
    [supportedSuffixArray addObjectsFromArray:[self videoSuffixArray]];
    return [self compareSuffix:self.suffix withSuffixArray:supportedSuffixArray];
}

- (instancetype)initWithRemoteDocument:(BJLDocument *)remoteDocument {
    if (self = [super init]) {
        self.remoteDocument = remoteDocument;
        self.remoteID = remoteDocument.documentID;
        self.isRelatedDocument = remoteDocument.isRelatedDocument;
        self.name = remoteDocument.fileName;
        self.suffix = remoteDocument.fileExtension;
        self.url = [NSURL URLWithString:remoteDocument.pageInfo.pageURLString];
        [self updateFileTypeWithSuffix:self.suffix];
        if (remoteDocument.isAnimate && self.type == BJLDocumentFileNormalPPT) {
            self.type = BJLDocumentFileAnimatedPPT;
            self.suggestImageName = @"bjl_document_animatedppt";
        }
    }
    return self;
}

- (instancetype)initWithRemoteHomework:(BJLHomework *)remoteHomework {
    if (self = [super init]) {
        self.remoteHomework = remoteHomework;
        self.remoteID = remoteHomework.homeworkID;
        self.isRelatedDocument = remoteHomework.isRelatedFile;
        self.name = remoteHomework.fileName;
        self.suffix = remoteHomework.fileExtension;
        [self updateFileTypeWithSuffix:self.suffix];
        if (remoteHomework.isAnimate && self.type == BJLDocumentFileNormalPPT) {
            self.type = BJLDocumentFileAnimatedPPT;
            self.suggestImageName = @"bjl_document_animatedppt";
        }
    }
    return self;
}

- (instancetype)initWithRemoteCloudFile:(BJLCloudFile *)remoteCloudFile {
    if (self = [super init]) {
        self.remoteCloudFile = remoteCloudFile;
        self.remoteID = remoteCloudFile.fileID;
        self.name = remoteCloudFile.fileName;
        self.suffix = remoteCloudFile.fileExtension;
        [self updateFileTypeWithSuffix:self.suffix];
        if (remoteCloudFile.format > 1 && self.type == BJLDocumentFileNormalPPT) {
            self.type = BJLDocumentFileAnimatedPPT;
            self.suggestImageName = @"bjl_document_animatedppt";
        }
        if (self.type == BJLDocumentFileAudio || self.type == BJLDocumentFileVideo) {
            self.remoteMediaFile = remoteCloudFile.mediaFile;
        }
    }
    return self;
}

- (instancetype)initWithRemoteMediaFile:(BJLMediaFile *)mediaFile {
    if (self = [super init]) {
        self.remoteMediaFile = mediaFile;
        self.remoteID = mediaFile.fileID;
        self.name = mediaFile.name;
        self.suffix = mediaFile.format;
        self.isRelatedDocument = mediaFile.isRelatedDocument;
        [self updateFileTypeWithSuffix:self.suffix];
    }
    return self;
}

#pragma mark -

- (void)setErrorCode:(NSInteger)errorCode {
    _errorCode = errorCode;
    self.errorMessage = [self errorMessageWithCode:errorCode];
}

#pragma mark -

- (void)updateFileNameAndSuffixWithFileURL:(NSURL *)url {
    NSString *urlString = url.absoluteString;
    NSString *name = [urlString.lastPathComponent stringByRemovingPercentEncoding];
    NSString *suffix = name.pathExtension;
    self.url = url;
    self.localPathURL = url;
    self.name = name;
    self.suffix = [@"." stringByAppendingString:suffix];
    // 处理 HEIC 和 HEIF 格式的图片
    NSArray *imageSuffixArray = @[@".heic",
        @".heif"];
    if ([self compareSuffix:self.suffix withSuffixArray:imageSuffixArray]) {
        CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)self.localDocument.fileURL, nil);
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, nil);
        NSString *cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *fileName = [name.stringByDeletingPathExtension stringByAppendingString:@".jpg"];
        NSString *filePath = [cachesDir stringByAppendingPathComponent:fileName];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        CGImageDestinationRef fileURLRef = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeJPEG, 1, nil);
        if (!fileURLRef) {
            CGImageRelease(imageRef);
            CFRelease(source);
            NSLog(@"unable to create CGImageDestination");
            return;
        }
        CGImageDestinationAddImage(fileURLRef, imageRef, nil);
        CGImageDestinationFinalize(fileURLRef);
        // 重新赋值
        self.url = fileURL;
        self.name = fileName;
        self.suffix = @".jpg";

        CGImageRelease(imageRef);
        CFRelease(fileURLRef);
        CFRelease(source);
    }
}

- (NSString *)getUniqueId {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return [NSString stringWithFormat:@"documentFile%@", (__bridge_transfer NSString *)uuidStringRef];
}

- (void)updateFileTypeWithSuffix:(NSString *)suffix {
    // txt
    NSArray *txtSuffixArray = @[@".txt"];
    // image
    NSArray *imageSuffixArray = @[@".jpg",
        @".png",
        @".jpeg",
        @".webp",
        @".bmp",
        @".ico",
        @".gif",
        @".heic",
        @".heif"];
    // doc
    NSArray *docSuffixArray = @[@".doc",
        @".docx"];

    // web doc
    NSArray *webDocSuffixArray = @[@".zip"];

    // pdf
    NSArray *pdfSuffixArray = @[@".pdf"];
    // xls
    NSArray *xlsSuffixArray = @[@".xls",
        @".xlsx"];
    // ppt
    NSArray *pptSuffixArray = @[@".ppt",
        @".pptx"];
    // audio mp3、wma、wav、mid、midd、kar、ogg、m4a、ra、ram、mod、oga、opus 等
    NSArray *audioSuffixArray = [self audioSuffixArray];
    // video wmv、avi、dat、asf、rm、rmvb、ram、mpg、mpeg、3gp、mov、mp4、m4v、dvix、dv、mkv、flv、vob、qt、divx、cpk、fli、flc、mod 等
    NSArray *videoSuffixArray = [self videoSuffixArray];
    // web link
    NSArray *webLinkSuffixArray = @[@".html"];
    // bds
    NSArray *bdsSuffixArray = @[@".bds"];

    if ([self compareSuffix:suffix withSuffixArray:txtSuffixArray]) {
        self.type = BJLDocumentFileTXT;
        self.suggestImageName = @"bjl_document_txt";
    }
    else if ([self compareSuffix:suffix withSuffixArray:imageSuffixArray]) {
        self.type = BJLDocumentFileImage;
        self.suggestImageName = @"bjl_document_img";
    }
    else if ([self compareSuffix:suffix withSuffixArray:docSuffixArray]) {
        self.type = BJLDocumentFileDOC;
        self.suggestImageName = @"bjl_document_doc";
    }
    else if ([self compareSuffix:suffix withSuffixArray:pdfSuffixArray]) {
        self.type = BJLDocumentFilePDF;
        self.suggestImageName = @"bjl_document_pdf";
    }
    else if ([self compareSuffix:suffix withSuffixArray:xlsSuffixArray]) {
        self.type = BJLDocumentFileXLS;
        self.suggestImageName = @"bjl_document_xls";
    }
    else if ([self compareSuffix:suffix withSuffixArray:pptSuffixArray]) {
        self.type = BJLDocumentFileNormalPPT;
        self.suggestImageName = @"bjl_document_ppt";
    }
    else if ([self compareSuffix:suffix withSuffixArray:webDocSuffixArray]) {
        self.type = BJLDocumentFileWebPPT;
        self.suggestImageName = @"bjl_document_webppt";
    }
    else if ([self compareSuffix:suffix withSuffixArray:audioSuffixArray]) {
        self.type = BJLDocumentFileAudio;
        self.suggestImageName = @"bjl_document_audio";
    }
    else if ([self compareSuffix:suffix withSuffixArray:videoSuffixArray]) {
        self.type = BJLDocumentFileVideo;
        self.suggestImageName = @"bjl_document_video";
    }
    else if ([self compareSuffix:suffix withSuffixArray:webLinkSuffixArray]) {
        self.type = BJLDocumentFileWebLink;
        self.suggestImageName = @"bjl_document_html5";
    }
    else if ([self compareSuffix:suffix withSuffixArray:bdsSuffixArray]) {
        self.type = BJLDocumentFileBDS;
        self.suggestImageName = @"bjl_document_bds";
    }
    // default
    else {
        self.type = BJLDocumentFileTypeDefault;
        self.suggestImageName = @"bjl_document_error";
    }
    self.mimeType = BJLMimeTypeForPathExtension(self.url.absoluteString.pathExtension);
}

- (BOOL)compareSuffix:(NSString *)suffix withSuffixArray:(NSArray<NSString *> *)suffixArray {
    BOOL flag = NO;
    for (NSString *targetSuffix in suffixArray) {
        if ([suffix compare:targetSuffix options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            flag = YES;
            break;
        }
    }
    return flag;
}

- (NSString *)errorMessageWithCode:(NSInteger)errorCode {
    NSString *errorMessage = BJLLocalizedString(@"未知错误");
    switch (errorCode) {
        case 10001:
            errorMessage = BJLLocalizedString(@"下载文件失败");
            break;
        case 10002:
            errorMessage = BJLLocalizedString(@"office转PDF失败");
            break;
        case 10003:
            errorMessage = BJLLocalizedString(@"pdf转png失败");
            break;
        case 10004:
            errorMessage = BJLLocalizedString(@"上传静态文件失败");
            break;
        case 10005:
            errorMessage = BJLLocalizedString(@"动画转html失败");
            break;
        case 10006:
            errorMessage = BJLLocalizedString(@"打包动画文件失败");
            break;
        case 10007:
            errorMessage = BJLLocalizedString(@"压缩动画文件失败");
            break;
        case 10008:
            errorMessage = BJLLocalizedString(@"上传动画压缩文件失");
            break;
        case 10009:
            errorMessage = BJLLocalizedString(@"上传动画html失败");
            break;
        case 10010:
            errorMessage = BJLLocalizedString(@"转码失败");
            break;
        case 10011:
            errorMessage = BJLLocalizedString(@"文件被加密，请上传非加密文件");
            break;
        case 10012:
            errorMessage = BJLLocalizedString(@"删除隐藏页或另存为pptx格式文件");
            break;

        default:
            errorMessage = BJLLocalizedString(@"未知错误");
            break;
    }
    return errorMessage;
}

- (NSArray<NSString *> *)audioSuffixArray {
    return @[@".mp3",
        @".wma",
        @".wav",
        @".mid",
        @".midd",
        @".kar",
        @".m4a",
        @".ra",
        @".ram",
        @".flac",
        @".au",
        @".ogg",
        @".aac",
        @".pcm",
        @".arm",
        @".mod",
        @".oga",
        @".opus"];
}

- (NSArray<NSString *> *)videoSuffixArray {
    return @[@".wmv",
        @".avi",
        @".dat",
        @".asf",
        @".rm",
        @".rmvb",
        @".ram",
        @".mpg",
        @".mpeg",
        @".3gp",
        @".mov",
        @".mp4",
        @".m4v",
        @".dvix",
        @".dv",
        @".mkv",
        @".flv",
        @".vob",
        @".qt",
        @".divx",
        @".cpk",
        @".fli",
        @".flc",
        @".webm",
        @".3g2",
        @".h264",
        @".ogv",
        @".mj2"];
}

@end

NS_ASSUME_NONNULL_END
