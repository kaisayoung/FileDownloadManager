//
//  SCSessionDownload.m
//  FileDownloadTool
//
//  Created by 王琦 on 15/12/1.
//  Copyright © 2015年 王琦. All rights reserved.
//

#import "SCSessionDownload.h"

@interface SCSessionDownload ()

@property (strong, nonatomic) NSURL *downloadURL;
@property (strong, nonatomic) NSData *resumeData;
@property (strong, nonatomic) NSString *directoryPath;    
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (assign, nonatomic) uint64_t timerReceivedDataLength;

@end

@implementation SCSessionDownload

- (id)initWithURL:(NSString *)fileUrl directoryPath:(NSString *)directoryPath fileName:(NSString *)fileName
{
    if(self = [super init]){
        self.fileUrl = fileUrl;
        self.fileName = fileName;
        self.directoryPath = directoryPath;
        self.downloadURL = [NSURL URLWithString:[fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return self;
}

#pragma mark --- Public Method ---

- (void)startDownloadWithBackgroundSession:(NSURLSession *)session
{
    //首先判断本地是否存在了？
    if(self.resumeData){
        _downloadTask = [session downloadTaskWithResumeData:self.resumeData];
    }
    else{
        NSMutableURLRequest *sessionRequest = [[NSMutableURLRequest alloc] initWithURL:_downloadURL];
        _downloadTask = [session downloadTaskWithRequest:sessionRequest];
    }
    [_downloadTask resume];
}

- (void)cancelDownloadIfDeleteFile:(BOOL)deleteFile
{
    if(deleteFile){
        [self.downloadTask cancel];
        self.downloadTask = nil;
        self.resumeData = nil;
    }
    else{
        [self.downloadTask cancelByProducingResumeData:^(NSData * resumeData) {
            self.resumeData = resumeData;
            self.downloadTask = nil;
        }];
    }
}

- (void)finishDownloadWithLocation:(NSURL *)location
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:self.directoryPath]){
        [fileManager createDirectoryAtPath:self.directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if([fileManager fileExistsAtPath:[self finishFilePath] isDirectory:NULL]){
        [fileManager removeItemAtPath:[self finishFilePath] error:NULL];
    }
    if([fileManager moveItemAtPath:[location path] toPath:[self finishFilePath] error:NULL]){
        self.downloadTask = nil;
        self.resumeData = nil;
    }
}

- (void)setBytesWritten:(uint64_t)bytesWritten iFCalculateSpeed:(BOOL)ifCalculate
{
    _timerReceivedDataLength += bytesWritten;
    if(ifCalculate){
        float downloadData = (float)_timerReceivedDataLength/1024.0;
        if(downloadData>=1024.0){
            downloadData /= 1024.0;
            _downloadSpeed = [NSString stringWithFormat:@"%.1fMB/s",downloadData];
        }
        else{
            _downloadSpeed = [NSString stringWithFormat:@"%.1fKB/s",downloadData];
        }
        _timerReceivedDataLength = 0;
    }
}

#pragma mark --- Private Method ---

//文件夹和文件拼接后的路径
- (NSString *)finishFilePath
{
    return [self.directoryPath stringByAppendingPathComponent:self.fileName];
}

@end














