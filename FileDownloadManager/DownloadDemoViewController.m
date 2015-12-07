//
//  DownloadDemoViewController.m
//  FileDownloadTool
//
//  Created by 王琦 on 15/11/23.
//  Copyright © 2015年 王琦. All rights reserved.
//

#import "DownloadDemoViewController.h"
#import "DownloadDemoCell.h"
#import "FileDemoModel.h"
#import "DownloadDemoObject.h"
#import "SCSessionDownloadManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

#define TEST_FILE_URL1   @"http://mw5.dwstatic.com/1/3/1528/133489-99-1436409822.mp4"
#define TEST_FILE_URL2   @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"

@interface DownloadDemoViewController ()<UITableViewDelegate,UITableViewDataSource,SCSessionDownloadManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) NSMutableArray *downloadArray;

//用来保存成功数据的数组
@property (strong, nonatomic) NSMutableArray *finishArray;

@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL isFirstClick;

@end

@implementation DownloadDemoViewController

- (void)addDemoData
{
    _isFirstClick = YES;
    //从网络中获取的数据类似如下
    FileDemoModel *fileModel1 = [[FileDemoModel alloc] init];
    FileDemoModel *fileModel2 = [[FileDemoModel alloc] init];
    FileDemoModel *fileModel3 = [[FileDemoModel alloc] init];
    FileDemoModel *fileModel4 = [[FileDemoModel alloc] init];
    FileDemoModel *fileModel5 = [[FileDemoModel alloc] init];
    FileDemoModel *fileModel6 = [[FileDemoModel alloc] init];
    fileModel1.fileId = @"111";
    fileModel2.fileId = @"222";
    fileModel3.fileId = @"333";
    fileModel4.fileId = @"444";
    fileModel5.fileId = @"555";
    fileModel6.fileId = @"666";
    fileModel1.fileName = @"第1个文件.mp4";
    fileModel2.fileName = @"第2个文件.mp4";
    fileModel3.fileName = @"第3个文件.mp4";
    fileModel4.fileName = @"第4个文件.mp4";
    fileModel5.fileName = @"第5个文件.mp4";
    fileModel6.fileName = @"第6个文件.mp4";
    fileModel1.fileUrl = TEST_FILE_URL1;
    fileModel2.fileUrl = TEST_FILE_URL2;
    fileModel3.fileUrl = TEST_FILE_URL1;
    fileModel4.fileUrl = TEST_FILE_URL2;
    fileModel5.fileUrl = TEST_FILE_URL1;
    fileModel6.fileUrl = TEST_FILE_URL2;
    DownloadDemoObject *demoObject1 = [[DownloadDemoObject alloc] initWithFileDemoModel:fileModel1];
    DownloadDemoObject *demoObject2 = [[DownloadDemoObject alloc] initWithFileDemoModel:fileModel2];
    DownloadDemoObject *demoObject3 = [[DownloadDemoObject alloc] initWithFileDemoModel:fileModel3];
    DownloadDemoObject *demoObject4 = [[DownloadDemoObject alloc] initWithFileDemoModel:fileModel4];
    DownloadDemoObject *demoObject5 = [[DownloadDemoObject alloc] initWithFileDemoModel:fileModel5];
    DownloadDemoObject *demoObject6 = [[DownloadDemoObject alloc] initWithFileDemoModel:fileModel6];
    NSString *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"SCDownloadFiles"];
    demoObject1.directoryPath = directoryPath;
    demoObject2.directoryPath = directoryPath;
    demoObject3.directoryPath = directoryPath;
    demoObject4.directoryPath = directoryPath;
    demoObject5.directoryPath = directoryPath;
    demoObject6.directoryPath = directoryPath;
    self.finishArray = [NSMutableArray array];
    self.downloadArray = [NSMutableArray array];
    [self.downloadArray addObject:demoObject1];
    [self.downloadArray addObject:demoObject2];
    [self.downloadArray addObject:demoObject3];
    [self.downloadArray addObject:demoObject4];
    [self.downloadArray addObject:demoObject5];
    [self.downloadArray addObject:demoObject6];
    [self.tableView reloadData];
}

#pragma mark --- life cycles ---

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addDemoData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SCSessionDownloadManager sharedSessionDownloadManager].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SCSessionDownloadManager sharedSessionDownloadManager].delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark --- UITableViewDataSource ---

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_downloadArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DownloadDemoCell";
    DownloadDemoCell *cell = (DownloadDemoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    [cell displayCellFromDownloadObject:[_downloadArray objectAtIndex:indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCSessionDownloadManager *downloadManager = [SCSessionDownloadManager sharedSessionDownloadManager];
    DownloadDemoObject *demoModel = [_downloadArray objectAtIndex:indexPath.row];
    BOOL success = [self ifCurrentFileDownloadSuccess:demoModel.fileId];
    if(success){
        NSString *filePath = [demoModel.directoryPath stringByAppendingPathComponent:demoModel.fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:filePath]){
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
    else{
        [downloadManager cancelDownloadWithFileId:demoModel.fileId];
    }
    [_downloadArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark --- UITableViewDelegate ---

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCSessionDownloadManager *downloadManager = [SCSessionDownloadManager sharedSessionDownloadManager];
    DownloadDemoObject *demoModel = [_downloadArray objectAtIndex:indexPath.row];
    switch (demoModel.downloadState) {
        case FileDownloadStateWaiting: {
            [downloadManager startDownloadWithFileId:demoModel.fileId];
            break;
        }
        case FileDownloadStateDownloading: {
            [downloadManager suspendDownloadWithFileId:demoModel.fileId];
            break;
        }
        case FileDownloadStateSuspending: {
            [downloadManager recoverDownloadWithFileId:demoModel.fileId];
            break;
        }
        case FileDownloadStateFail: {
            [downloadManager restartDownloadWithFileId:demoModel.fileId];
            break;
        }
        case FileDownloadStateFinish: {
            NSString *filePath = [demoModel.directoryPath stringByAppendingPathComponent:demoModel.fileName];
            NSURL *URL = [NSURL fileURLWithPath:filePath];
//            MPMoviePlayerViewController *viewController = [[MPMoviePlayerViewController alloc] initWithContentURL:URL];
//            MPMoviePlayerController *player = viewController.moviePlayer;
//            player.controlStyle = MPMovieControlStyleFullscreen;
//            player.allowsAirPlay = YES;
//            [self presentMoviePlayerViewControllerAnimated:viewController];
            
            AVPlayer *player = [[AVPlayer alloc] initWithURL:URL];
            AVPlayerViewController *avplayerController = [[AVPlayerViewController alloc] init];
            avplayerController.player = player;
            [self presentViewController:avplayerController animated:YES completion:^{
                [player play];
            }];
            return;
        }
        default: {
            break;
        }
    }
    NSInteger totalCount = [_downloadArray count];
    for(int i=0;i<totalCount;i++){
        DownloadDemoObject *demoModel = [_downloadArray objectAtIndex:i];
        BOOL success = [self ifCurrentFileDownloadSuccess:demoModel.fileId];
        if(success){
            demoModel.downloadState = FileDownloadStateFinish;
        }
        else{
            demoModel.downloadState = [downloadManager getFileDownloadStateWithFileId:demoModel.fileId];
        }
    }
    [_tableView reloadData];
}

#pragma mark --- SCSessionDownloadManagerDelegate ---

- (void)sessionDownloadManagerStartDownload:(SCSessionDownload *)download
{
    DownloadDemoCell *downloadCell = [self getTargetCellWithFileId:download.fileId];
    downloadCell.downloadObject.downloadState = FileDownloadStateDownloading;
    [downloadCell displayCellFromDownloadObject:downloadCell.downloadObject];
}

- (void)sessionDownloadManagerUpdateProgress:(SCSessionDownload *)download didWriteData:(uint64_t)writeLength fileSize:(uint64_t)totalLength downloadSpeed:(NSString *)downloadSpeed
{
    DownloadDemoCell *downloadCell = [self getTargetCellWithFileId:download.fileId];
    NSString *totalSize = @"";
    if(totalLength==-1){
        totalSize = @"未知大小";
    }
    else{
        totalSize = [NSString stringWithFormat:@"%.1fMB",(CGFloat)totalLength/1024.0/1024.0];
    }
    downloadCell.downloadObject.totalSize = totalSize;
    downloadCell.downloadObject.totalLength = totalLength;
    NSString *downloadSize = [NSString stringWithFormat:@"%.1fMB",(CGFloat)writeLength/1024.0/1024.0];
    if(downloadCell.downloadObject.totalLength>0){
        CGFloat progress = (CGFloat)writeLength/(CGFloat)downloadCell.downloadObject.totalLength;
        downloadCell.downloadObject.progress = progress;
    }
    downloadCell.downloadObject.downloadSize = downloadSize;
    downloadCell.downloadObject.downloadSpeed = downloadSpeed;
    //只是刷新界面时需要用主线程，计算什么的也可以用子线程
    [downloadCell displayCellFromDownloadObject:downloadCell.downloadObject];
}

- (void)sessionDownloadManagerFinishDownload:(SCSessionDownload *)download success:(BOOL)downloadSuccess error:(NSError *)error
{
    SCSessionDownloadManager *downloadManager = [SCSessionDownloadManager sharedSessionDownloadManager];
    DownloadDemoCell *downloadCell = [self getTargetCellWithFileId:download.fileId];
    if(downloadSuccess){
        downloadCell.downloadObject.progress = 1;
        downloadCell.downloadObject.downloadSpeed = @"";
        downloadCell.downloadObject.downloadState = FileDownloadStateFinish;
        [_finishArray addObject:download.fileId];
    }
    else{
        //可以根据不同的错误类型给出不同的提示
        NSLog(@"error happen is %@",error);
        downloadCell.downloadObject.downloadSpeed = @"";
        downloadCell.downloadObject.downloadState = FileDownloadStateFail;
    }
    NSInteger totalCount = [_downloadArray count];
    for(int i=0;i<totalCount;i++){
        DownloadDemoObject *demoModel = [_downloadArray objectAtIndex:i];
        if(![demoModel.fileId isEqualToString:download.fileId]){
            BOOL success = [self ifCurrentFileDownloadSuccess:demoModel.fileId];
            if(success){
                demoModel.downloadState = FileDownloadStateFinish;
            }
            else{
                demoModel.downloadState = [downloadManager getFileDownloadStateWithFileId:demoModel.fileId];
            }
        }
    }
    [_tableView reloadData];
}

#pragma mark --- private method ---

- (BOOL)ifCurrentFileDownloadSuccess:(NSString *)fileId
{
    for(NSString *succFileId in _finishArray){
        if([succFileId isEqualToString:fileId]){
            return YES;
        }
    }
    return NO;
}

- (DownloadDemoCell *)getTargetCellWithFileId:(NSString *)fileId
{
    NSArray *cellArr = _tableView.visibleCells;
    for(id obj in cellArr){
        if([obj isKindOfClass:[DownloadDemoCell class]]){
            DownloadDemoCell *downloadCell = (DownloadDemoCell *)obj;
            if([downloadCell.downloadObject.fileId isEqualToString:fileId]){
                return downloadCell;
            }
        }
    }
    return nil;
}

#pragma mark --- event method ---

- (IBAction)onLeftButtonClicked:(id)sender
{
    //首次点击依次添加到下载队列，以后就是全部暂停/全部开始切换
    SCSessionDownloadManager *downloadManager = [SCSessionDownloadManager sharedSessionDownloadManager];
    NSInteger totalCount = [_downloadArray count];
    if(_isFirstClick){
        _isLoading = YES;
        _isFirstClick = NO;
        for(int i=0;i<totalCount;i++){
            DownloadDemoObject *demoModel = [_downloadArray objectAtIndex:i];
            [downloadManager addDownloadWithFileId:demoModel.fileId fileUrl:demoModel.fileUrl directoryPath:demoModel.directoryPath fileName:demoModel.fileName];
            demoModel.downloadState = [downloadManager getFileDownloadStateWithFileId:demoModel.fileId];
        }
        [_leftButton setTitle:@"全部暂停" forState:UIControlStateNormal];
    }
    else{
        //此时已经全部存在于下载队列中
        if(_isLoading){
            [downloadManager suspendAllFilesDownload];
            for(int i=0;i<totalCount;i++){
                DownloadDemoObject *demoModel = [_downloadArray objectAtIndex:i];
                BOOL success = [self ifCurrentFileDownloadSuccess:demoModel.fileId];
                if(success){
                    demoModel.downloadState = FileDownloadStateFinish;
                }
                else{
                    demoModel.downloadState = [downloadManager getFileDownloadStateWithFileId:demoModel.fileId];
                }
            }
            [_leftButton setTitle:@"全部开始" forState:UIControlStateNormal];
        }
        else{
            [downloadManager recoverAllFilesDownload];
            for(int i=0;i<totalCount;i++){
                DownloadDemoObject *demoModel = [_downloadArray objectAtIndex:i];
                BOOL success = [self ifCurrentFileDownloadSuccess:demoModel.fileId];
                if(success){
                    demoModel.downloadState = FileDownloadStateFinish;
                }
                else{
                    demoModel.downloadState = [downloadManager getFileDownloadStateWithFileId:demoModel.fileId];
                }
            }
            [_leftButton setTitle:@"全部暂停" forState:UIControlStateNormal];
        }
        _isLoading=!_isLoading;
    }
    [_tableView reloadData];
}

- (IBAction)onRightButtonClicked:(id)sender
{
    SCSessionDownloadManager *downloadManager = [SCSessionDownloadManager sharedSessionDownloadManager];
    [downloadManager cancelAllFilesDownload];
    [self addDemoData];
    _isFirstClick = YES;
    [_finishArray removeAllObjects];
    [_leftButton setTitle:@"全部开始" forState:UIControlStateNormal];
}

@end








