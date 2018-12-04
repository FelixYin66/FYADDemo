//
//  ViewController.h
//  PandaSkiing
//
//  Created by fantasy on 15/8/4.
//  Copyright (c) 2015年 fantasy. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  查看广告详情统计回调
 */
typedef void(^ADShowDetailStatistics)();
typedef void(^ADVertisementEnterDetailViewControllerCallBack)(NSString *openURLStr,NSString *title);
@interface FYADViewController : UIViewController

//广告标题
@property (nonatomic, strong) IBOutlet UILabel *skipLbl;
//完成回调
@property (nonatomic, copy) void (^skipAd)(id objc);
//是否加载广告
@property (nonatomic, assign) BOOL isLoadAd;

- (instancetype) initDefaultViweController;

- (instancetype) initWithADShowDetailStatistics:(ADShowDetailStatistics) showDetailStatistics enterDetailViewControllerCallBack:(ADVertisementEnterDetailViewControllerCallBack)enterDetailViewControllerCallBack;
@end

