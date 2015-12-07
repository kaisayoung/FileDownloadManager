//
//  SCSessionDownload.h
//  FileDownloadTool
//
//  Created by 王琦 on 15/12/1.
//  Copyright © 2015年 王琦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCSessionDownload : NSObject

@property (copy, nonatomic) NSString *fileId;           //文件的唯一标识
@property (copy, nonatomic) NSString *fileUrl;          //文件的网址
@property (copy, nonatomic) NSString *fileName;         //文件的名字
@property (copy, nonatomic, readonly) NSString *downloadSpeed;    //文件的下载速度

- (id)initWithURL:(NSString *)fileUrl directoryPath:(NSString *)directoryPath fileName:(NSString *)fileName;

- (void)startDownloadWithBackgroundSession:(NSURLSession *)session;

- (void)finishDownloadWithLocation:(NSURL *)location;

- (void)cancelDownloadIfDeleteFile:(BOOL)deleteFile;

- (void)setBytesWritten:(uint64_t)bytesWritten iFCalculateSpeed:(BOOL)ifCalculate;

@end








