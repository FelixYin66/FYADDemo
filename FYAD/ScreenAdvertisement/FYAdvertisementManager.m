//
//  PSAdvertisementManager.m
//  PandaSkiing
//
//  Created by Felix Yin on 2017/5/8.
//  Copyright © 2017年 Felix. All rights reserved.
//

#import "FYAdvertisementManager.h"
#import "AFNetworkReachabilityManager.h"
#import "SDWebImageManager.h"
#import "FYADViewController.h"
#include "UIImageView+WebCache.h"

@interface FYAdvertisementManager()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) BOOL isClear;
@property (nonatomic, assign) NSInteger sustain;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) FYADViewController *adViewVC;
/**
 *  广告加载完成回调
 */
@property (nonatomic, copy)   ADLoadFinishCallBack finishCallBack;
@property (nonatomic, copy)   ADShowStatistics showStatistics;

@property (nonatomic, copy)  ADVertisementEnterDetailViewControllerCallBack enterDetailViewControllerCallBack;
@property (nonatomic, copy) ADShowDetailStatistics showDetailStatistics;

@end

@implementation FYAdvertisementManager


- (void)launchAdvertisement:(UIWindow *)window finishCallBack:(ADLoadFinishCallBack)finishCallBack enterDetailViewControllerCallBack:(ADVertisementEnterDetailViewControllerCallBack)enterDetailViewControllerCallBack adShowStatistics:(ADShowStatistics)showStatistics adShowDetailStatistics:(ADShowDetailStatistics)showDetailStatistics{
    window.backgroundColor = [UIColor whiteColor];
    window.rootViewController = [[FYADViewController alloc] initDefaultViweController];
    [window makeKeyAndVisible];
    self.window = window;
    self.finishCallBack = finishCallBack;
    self.showStatistics = showStatistics;
    self.enterDetailViewControllerCallBack = enterDetailViewControllerCallBack;
    self.showDetailStatistics = showDetailStatistics;
    [self checkNetStatusAndStartDownloadADPic:window];
}


/**
 *  网络状况监测
 *
 *  @param window 显示Window
 */
- (void) checkNetStatusAndStartDownloadADPic:(UIWindow *)window{
    __weak typeof(self) weakSelf = self;
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable ) {
            NSLog(@"没有网");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf startADView:weakSelf.window];
            });
        }else{
            //发起访问
            [weakSelf checkNewAD:weakSelf.window];
        }
    }];
    //开始检测网络状态
    [manager startMonitoring];
}


/**
 *  获取广告信息
 */
static NSInteger dTime = 0;
- (void) checkNewAD:(UIWindow *)window{
    __weak typeof(self) weakSelf = self;
    if([self.delegate respondsToSelector:@selector(fyAdvertisementManager:)]){
        [self.delegate fyAdvertisementManager:^(NSDictionary *adDict,NSError *error) {
            [weakSelf dataHandle:adDict error:error];
        }];
    }
}

/**
 *  广告数据处理
 *
 *  @param adInfo 广告数据
 *  @param error  获取广告错误
 */
- (void) dataHandle:(NSDictionary *) adInfo error:(NSError *) error{
    //打开接口出错
    __weak typeof(self) weakSelf = self;
    if (error) {
        NSLog(@"🐶🐶🐶🐶🐶timeout🐶🐶🐶🐶🐶  -->%@",error.userInfo);
        weakSelf.isClear = YES;
        [self startADView:self.window];
        return;
    }
    
    NSDictionary *dict = [adInfo[@"ad"] firstObject];
    //图片地址
    NSString *imgURL = [dict objectForKey:@"img"];
    //跳转地址
    NSString *openURL = [dict objectForKey:@"url"];
    //广告标题
    NSString *title = [dict objectForKey:@"title"];
    //广告内容
    //        NSString *content = [dict objectForKey:@"content"];
    //定时秒数
    NSString *sustain = [dict objectForKey:@"sustain"];
    
    //验证是否需要下载新的图片
    NSString *oldImg = [[NSUserDefaults standardUserDefaults] objectForKey:AdvertisementPicName];
    BOOL isExist = oldImg.length > 0;
    if (isExist) {
        //一个星期后删除图片后，找不到广告图 标记需要重新下载图片  之前的bug
       isExist = [[SDImageCache sharedImageCache] diskImageExistsWithKey:oldImg];
    }
    NSLog(@"oldImg---->%@",oldImg);
    //必须有图片，时间>1
    if([sustain integerValue] >0 && imgURL != nil){
//        oldImg == nil
        if (![imgURL isEqualToString:oldImg] || !isExist) {
            NSLog(@"开始下载图片");
            //下载新的网络图片
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imgURL] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                //关闭网络检测
                [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
                //下载完成
                if(!error){
                    [[NSUserDefaults standardUserDefaults] setObject:imgURL forKey:AdvertisementPicName];
                    [[NSUserDefaults standardUserDefaults] setObject:sustain forKey:AdvertisementSustain];
                    //保存广告标题，链接
                    [[NSUserDefaults standardUserDefaults] setObject:title forKey:AdvertisementTitle];
                    [[NSUserDefaults standardUserDefaults] setObject:openURL forKey:AdvertisementURL];
                    //广告下载完成
                    if([sustain integerValue]>0){
                        
                        //有新广告并且时间不为零
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(dTime <=2){
                                //创建广告   这里无法清空定时器，通过标记...自己来清空
                                weakSelf.isClear = YES;
                                weakSelf.sustain = [sustain integerValue];
                                [weakSelf firstStartLoadADViewController:weakSelf.window];
                            }
                        });
                    }
                }else{
                    //下载图片出错
                    NSLog(@"下载广告图片出错!");
                    weakSelf.isClear = YES;
                    [weakSelf startADView:weakSelf.window];
                }
                
            }];
        }else{
            NSLog(@"没有新的广告图片");
            //关闭网络检测
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
            //没有新的照片，可能计时器秒数发生变化
            [[NSUserDefaults standardUserDefaults] setObject:sustain forKey:AdvertisementSustain];
            //保存广告标题，链接
            [[NSUserDefaults standardUserDefaults] setObject:title forKey:AdvertisementTitle];
            [[NSUserDefaults standardUserDefaults] setObject:openURL forKey:AdvertisementURL];
            //加载广告--->时时更改秒数
            self.isClear = YES;
            self.sustain = [sustain integerValue];
            [self startADView:weakSelf.window];
        }
    }else{
        //时间为0，不加载广告
        [[NSUserDefaults standardUserDefaults] setObject:sustain forKey:AdvertisementSustain];
        self.isClear = YES;
//        [self adFinish];
        [self startADView:weakSelf.window];
    }
}


/**
 *  加载缓存广告
 */
- (void) startADView:(UIWindow *)window{
    
    __weak typeof(self) weakSelf = self;
    FYADViewController *vc = [[FYADViewController alloc] initWithADShowDetailStatistics:self.showDetailStatistics enterDetailViewControllerCallBack:self.enterDetailViewControllerCallBack];
    vc.skipAd = ^void (id param){
        [weakSelf invalidateTimer];
        [weakSelf adFinish];
    };
    self.adViewVC = vc;
    
    NSString *second = [[NSUserDefaults standardUserDefaults] objectForKey:AdvertisementSustain];
    if (vc.isLoadAd && [second intValue] > 0) {
        
        //需要加载广告页
        if (second == nil) {
            weakSelf.sustain = 5-1;
        }else{
            weakSelf.sustain = [second integerValue];
        }
        weakSelf.finishCallBack();
        
        //统计广告被展示
        if(self.showStatistics){
            self.showStatistics();
        }
        //设置广告视图
        [window.rootViewController.view addSubview:self.adViewVC.view];
        [window.rootViewController.view bringSubviewToFront:self.adViewVC.view];
        //启动定时器
        [weakSelf startTimer:nil];
    }else{
        weakSelf.finishCallBack();
    }
    
}



//第一次启动广告
- (void) firstStartLoadADViewController:(UIWindow *) window{
    //做一个标记
    self.finishCallBack();
    __weak typeof(self) weakSelf = self;
    FYADViewController *vc = [[FYADViewController alloc] initWithADShowDetailStatistics:self.showDetailStatistics enterDetailViewControllerCallBack:self.enterDetailViewControllerCallBack];
    vc.skipAd = ^void (id param){
        [weakSelf invalidateTimer];
        [weakSelf adFinish];
    };
    self.adViewVC = vc;
    //设置广告视图
    [window.rootViewController.view addSubview:self.adViewVC.view];
    [window.rootViewController.view bringSubviewToFront:self.adViewVC.view];
    //展示广告统计
    if (self.showStatistics) {
        self.showStatistics();
    }
    //启动定时器
    [self startTimer:nil];
}



/**
 *  移除广告
 */
- (void) adFinish{
    [UIView animateWithDuration:1 animations:^{
        self.adViewVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.adViewVC.view removeFromSuperview];
        self.adViewVC = nil;
        self.showDetailStatistics = nil;
        self.enterDetailViewControllerCallBack = nil;
        self.window = nil;
    }];
}




/**
 *  启动定时器
 *
 *  @param launchOptions 加载选项
 */
- (void) startTimer:(NSDictionary *)launchOptions{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(skipAdertisement:) userInfo:launchOptions repeats:YES];
}

/**
 *  废弃定时器
 */
- (void) invalidateTimer{
    [self.timer invalidate];
    self.timer = nil;
}


/**
 *  定时跳过广告
 *
 *  @param timer 定时器
 */
- (void) skipAdertisement:(NSTimer *)timer{
    self.sustain = self.sustain-1;
    if (self.sustain>=1) {
        self.adViewVC.skipLbl.text = [NSString stringWithFormat:@"跳过 %ld",(long)self.sustain];
        return;
    }
    //当到达self.sustain秒，退出广告
    [self adFinish];
    [self invalidateTimer];
}


#pragma mark Initionalize

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static FYAdvertisementManager *advertisement = nil;
    dispatch_once(&onceToken, ^{
        advertisement = [[FYAdvertisementManager alloc] init];
    });
    return advertisement;
}


@end
