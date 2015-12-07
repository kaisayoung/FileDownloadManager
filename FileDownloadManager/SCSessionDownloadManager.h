//
//  SCSessionDownloadManager.h
//  FileDownloadTool
//
//  Created by 王琦 on 15/12/1.
//  Copyright © 2015年 王琦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSessionDownload.h"

typedef NS_ENUM(NSInteger, FileDownloadState){
    FileDownloadStateWaiting = 0,
    FileDownloadStateDownloading = 1,
    FileDownloadStateSuspending = 2,
    FileDownloadStateFail = 3,
    FileDownloadStateFinish = 4,
};

/*
 文件下载管理类，只需引用这一个文件
 实际下载中，有可能文件名是一样的，所以用文件id作为唯一标识
 下载实现方式有NSURLConneciton和NSURLSession两种，本类实现了第二种
 比第一种方便之处在于：所有错误类型都由系统返回了，不需要自己做各种判断
 暂时未做网络变化相关逻辑；未做重启app恢复上次状态相关逻辑
 */

@protocol SCSessionDownloadManagerDelegate <NSObject>

- (void)sessionDownloadManagerStartDownload:(SCSessionDownload *)download;
- (void)sessionDownloadManagerUpdateProgress:(SCSessionDownload *)download didWriteData:(uint64_t)writeLength fileSize:(uint64_t)totalLength downloadSpeed:(NSString *)downloadSpeed;
- (void)sessionDownloadManagerFinishDownload:(SCSessionDownload *)download success:(BOOL)downloadSuccess error:(NSError *)error;

@end

@interface SCSessionDownloadManager : NSObject

+ (instancetype)sharedSessionDownloadManager;

/*
 注意若想修改同时下载多个视频，需保证下载的文件地址是非重复的
 */
@property (assign, nonatomic) NSInteger maxConDownloadCount;
@property (assign, nonatomic) id<SCSessionDownloadManagerDelegate>delegate;

//添加到下载队列
- (void)addDownloadWithFileId:(NSString *)fileId fileUrl:(NSString *)url directoryPath:(NSString *)directoryPath fileName:(NSString *)fileName;

//点击等待项（－》立即下载／暂停／do nothing）
- (void)startDownloadWithFileId:(NSString *)fileId;

//点击下载项 －》暂停
- (void)suspendDownloadWithFileId:(NSString *)fileId;

//点击暂停项（－》立刻下载／添加到下载队列）
- (void)recoverDownloadWithFileId:(NSString *)fileId;

//点击失败项 －》添加到下载队列
- (void)restartDownloadWithFileId:(NSString *)fileId;

//取消下载，且删除文件，只适用于未下载完成状态，下载完成的直接根据路径删除即可
- (void)cancelDownloadWithFileId:(NSString *)fileId;

//暂停全部：下载的，等待的
- (void)suspendAllFilesDownload;

//恢复全部：暂停的，失败的
- (void)recoverAllFilesDownload;

//取消全部：下载的，等待的，暂停的，失败的
- (void)cancelAllFilesDownload;

//获得状态
- (FileDownloadState)getFileDownloadStateWithFileId:(NSString *)fileId;

@end
















