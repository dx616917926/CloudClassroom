//
//  HXFileManager.m
//  eplatform-edu
//
//  Created by iMac on 16/8/24.
//  Copyright © 2016年 华夏大地教育网. All rights reserved.
//

#import "HXFileManager.h"
#import "Utilities.h"

@implementation HXFileManager

+ (NSString *)appDocumentsPath
{
    NSString* documentRoot = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"];
    
    return documentRoot;
}

+ (NSString *)appDocumentsFilePath:(NSString *)fileName
{
    NSString* documentRoot = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents"];
    
    return [documentRoot stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
}

+ (BOOL)isFileExsit:(NSString *)aPath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:aPath];
}

+ (BOOL)isFileExsitInDocuments:(NSString *)aPath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [self appDocumentsPath];
    [path stringByAppendingPathComponent:aPath];
    return [manager fileExistsAtPath:path];
}

+(NSString*)userNamePath
{
    NSFileManager *filemgr = [NSFileManager new];
    static NSString *Folder;
    
    NSString *Dir = [self appDocumentsPath];
    NSString *path = [Utilities MD5StringWithKey:@"HX"];
    Folder = [Dir stringByAppendingPathComponent:path];
    
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:Folder];
    if (exist) {
        return Folder;
    }
    
    NSError *error = nil;
    if(![filemgr createDirectoryAtPath:Folder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", Folder);
        Folder = nil;
    }else
    {
        [self addSkipBackupAttributeToItemAtPath:Folder];
    }
    
    return Folder;
}

+(NSString*)userNameRelativePath
{
    NSFileManager *filemgr = [NSFileManager new];
    static NSString *Folder;
    
    NSString *Dir = [self appDocumentsPath];
    NSString *path = [Utilities MD5StringWithKey:@"HX"];
    Folder = [Dir stringByAppendingPathComponent:path];
    
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:Folder];
    if (exist) {
        return path;
    }
    
    NSError *error = nil;
    if(![filemgr createDirectoryAtPath:Folder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", Folder);
    }else
    {
        [self addSkipBackupAttributeToItemAtPath:Folder];
    }
    
    return path;
}


+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[URL path]];
    if (!exist) {
        NSLog(@"file not exist: %@",filePathString);
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (void)calculateSizeWithCompletionBlock:(HXFileManagerCalculateSizeBlock)completionBlock {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSURL *diskCacheURL = [NSURL fileURLWithPath:[paths firstObject] isDirectory:YES];
    
    dispatch_queue_t ioQueue = dispatch_queue_create("com.edu.HXFileManager", DISPATCH_QUEUE_SERIAL);
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    dispatch_async(ioQueue, ^{
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        
        NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                                  includingPropertiesForKeys:@[NSFileSize]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                errorHandler:NULL];
        
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += [fileSize unsignedIntegerValue];
            fileCount += 1;
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize);
            });
        }
    });
}
@end
