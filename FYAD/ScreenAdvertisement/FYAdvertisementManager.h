//
//  PSAdvertisementManager.h
//  PandaSkiing
//
//  Created by Felix Yin on 2017/5/8.
//  Copyright © 2017年 Felix. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AdvertisementSustain @"AdvertisementSustain" //广告显示时间
#define AdvertisementPicName @"AdvertisementPicName"
#define AdvertisementTitle @"AdvertisementTitle"
#define AdvertisementURL @"AdvertisementURL"

typedef void(^ADVertisementGetInfoCallBack)(NSDictionary *adDict,NSError *error);
typedef void(^ADVertisementEnterDetailViewControllerCallBack)(NSString *openURLStr,NSString *title);


@class FYAdvertisementManager;
@protocol  FYAdvertisementManagerDelegate<NSObject>

/**
 *  网络获取广告信息
 *
 *  @param getADVertisementGetInfoCallBack 信息处理
 */
- (void)fyAdvertisementManager:(ADVertisementGetInfoCallBack) getADVertisementGetInfoCallBack;

/**
 *  进入广告页
 *
 *  @param advertisementManager            广告管理Object
 *  @param enterDetailViewControllerCallBack 进入广告详情页
 */
//- (void)fyAdvertisementManager:(FYAdvertisementManager *) advertisementManager  enterDetailViewController:(ADVertisementEnterDetailViewControllerCallBack) enterDetailViewControllerCallBack;



@end


/**
 *  广告完成回调
 */
typedef void(^ADLoadFinishCallBack)();
/**
 *  广告显示统计
 */
typedef void(^ADShowStatistics)();
/**
 *  查看广告详情统计回调
 */
typedef void(^ADShowDetailStatistics)();

@interface FYAdvertisementManager : NSObject

@property (nonatomic, assign) id<FYAdvertisementManagerDelegate> delegate;

+ (instancetype) shareInstance;

/**
 *  加载开屏广告
 *
 *  @param window         程序窗口
 *  @param finishCallBack 广告完成后执行操作
 *  enterDetailViewControllerCallBack  进入广告详情页
 *  @param showStatistics 广告显示统计
 *  @param showStatistics 查看广告统计
 */
- (void) launchAdvertisement:(UIWindow *)window finishCallBack:(ADLoadFinishCallBack) finishCallBack enterDetailViewControllerCallBack:(ADVertisementEnterDetailViewControllerCallBack)enterDetailViewControllerCallBack adShowStatistics:(ADShowStatistics) showStatistics adShowDetailStatistics:(ADShowDetailStatistics) showDetailStatistics;

@end
