//
//  ViewController.m
//  PandaSkiing
//
//  Created by fantasy on 15/8/4.
//  Copyright (c) 2015年 fantasy. All rights reserved.
//

#import "FYADViewController.h"
#include "UIImageView+WebCache.h"
#import "AFNetworkReachabilityManager.h"


/*
 
 适配iPhone 刘海屏
 
 */

//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792),[[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436),[[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688),[[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhoneXs Max
#define Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436),[[UIScreen mainScreen] currentMode].size) : NO)

#define iPhoneStatusBarHeight (iPhoneIsAllX ? 88 : 64)
#define iPhoneTabBarHeight (iPhoneIsAllX ? 83 : 49)
#define iPhoneIsAllX (Is_iPhoneX==YES || IS_IPHONE_Xr==YES || IS_IPHONE_Xs==YES || IS_IPHONE_Xs_Max==YES)
#define iPhoneAllXBottomSpace 34


#define AdvertisementPicName @"AdvertisementPicName"

@interface FYADViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic,weak) IBOutlet UIImageView *logoView;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewLogo;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewText;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, copy) ADShowDetailStatistics showDetailStatistics;
@property (nonatomic, copy)  ADVertisementEnterDetailViewControllerCallBack enterDetailViewControllerCallBack;

@end

@implementation FYADViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //修改按钮的样式
    self.skipLbl.layer.borderColor = [[UIColor redColor] CGColor];
    self.skipLbl.layer.cornerRadius = 3.0;
    self.skipLbl.layer.masksToBounds = YES;
    self.isFirst = YES;
}


//1.0.6 修改 添加占位图
- (instancetype) initDefaultViweController{
    NSArray *xibs = [[NSBundle mainBundle] loadNibNamed:@"Launch" owner:nil options:nil];
    self = [xibs objectAtIndex:0];
    self.view.frame = [UIScreen mainScreen].bounds;
//    defoult_X 1    default
    [self.imageView sd_setImageWithURL:nil placeholderImage:[UIImage new]];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    return self;
}


//方案二   65 * 30
//With:(ADShowDetailStatistics)showDetailStatistics enterDetailViewControllerCallBack:(ADVertisementEnterDetailViewControllerCallBack)enterDetailViewControllerCallBack
- (instancetype)initWithADShowDetailStatistics:(ADShowDetailStatistics) showDetailStatistics enterDetailViewControllerCallBack:(ADVertisementEnterDetailViewControllerCallBack)enterDetailViewControllerCallBack{
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"AdvertisementPicName"];
    NSArray *xibs = [[NSBundle mainBundle] loadNibNamed:@"Launch" owner:nil options:nil];
    self = [xibs objectAtIndex:0];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.showDetailStatistics = showDetailStatistics;
    self.enterDetailViewControllerCallBack = enterDetailViewControllerCallBack;
    //添加跳过
    self.skipLbl = [[UILabel alloc] init];
    [self.view addSubview:self.skipLbl];
    CGFloat width = 65;
    CGFloat height = 30;
    CGFloat x = CGRectGetWidth([UIScreen mainScreen].bounds) - 65 -10;
    self.skipLbl.textColor = [UIColor whiteColor];
    self.skipLbl.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];//[UIColor lightGrayColor];
    self.skipLbl.font = [UIFont systemFontOfSize:15];
    self.skipLbl.textAlignment = NSTextAlignmentCenter;
    CGFloat y = iPhoneIsAllX ? 32 : 22;
    self.skipLbl.frame = CGRectMake(x, y,width , height);
    self.skipLbl.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.skipLbl.userInteractionEnabled = YES;
    self.skipLbl.layer.masksToBounds = YES;
    self.skipLbl.layer.cornerRadius = 15;
    self.skipLbl.layer.borderWidth = 1;
    if (str == nil || [str isEqualToString:@""]) {
        self.isLoadAd = NO;
        return self;
    }
    
    if ([[SDImageCache sharedImageCache] diskImageExistsWithKey:str]) {
        
        NSLog(@"本地存在图片");
        NSString *second = [[NSUserDefaults standardUserDefaults] objectForKey:@"AdvertisementSustain"];
        if (second) {
            self.skipLbl.text = [NSString stringWithFormat:@"跳过 %@",second];
        }else{
            //默认设置5秒
            self.skipLbl.text = [NSString stringWithFormat:@"跳过 %ld",(long)5];
        }
//        __weak typeof(self) weakSelf = self;
//        [self.skipLbl bk_whenTapped:^{
//            [weakSelf skipAdvertisement:nil];
//        }];
        UITapGestureRecognizer *skipTapGet = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(skipLblTapGes:)];
        self.skipLbl.userInteractionEnabled = YES;
        [self.skipLbl addGestureRecognizer:skipTapGet];
        
    }else{
    
        NSLog(@"本地不存在图片");
        self.isLoadAd = NO;
        return self;
    }
    
//    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:str]];
    self.imageViewLogo.hidden = YES;
    self.imageViewText.hidden = YES;
    UITapGestureRecognizer *imageTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapGes:)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:imageTapGes];
//    [self.imageView bk_whenTapped:^{
//        
//        //跳转到
//        if (weakSelf.isFirst) {
//            [weakSelf enterDetail];
//            weakSelf.isFirst = NO;
//            weakSelf.skipAd(@"haha");
//        }
//        
//    }];
    self.isLoadAd = YES;
    return self;
}


///  跳转链接
- (void)enterDetail{
    
    //在此处统计用户进入了广告详情
    if(self.showDetailStatistics){
        self.showDetailStatistics();
    }
    NSString *_url = [[NSUserDefaults standardUserDefaults] objectForKey:@"AdvertisementURL"];
    NSString *_title = [[NSUserDefaults standardUserDefaults] objectForKey:@"AdvertisementTitle"];
    if (_url && _url.length > 0) {
        if(self.enterDetailViewControllerCallBack){
            self.enterDetailViewControllerCallBack(_url,_title);
        }
    }
    
}


#pragma mark 状态栏

//隐藏状态栏
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

//隐藏状态栏
- (BOOL) prefersStatusBarHidden{
    return YES;
}


#pragma mark ViewEventAction

- (void) skipLblTapGes:(UIGestureRecognizer *) ges{
    [self skipAdvertisement:nil];
}


- (void) imageTapGes:(UIGestureRecognizer *) ges{
    //跳转到
    if (self.isFirst) {
        [self enterDetail];
        self.isFirst = NO;
        self.skipAd(@"haha");
    }
}


#pragma mark   广告

//跳过广告
- (IBAction)skipAdvertisement:(UITapGestureRecognizer *)sender {
    self.skipAd(@"没有参数");
}


- (void)dealloc{
    NSLog(@"❤️❤️❤️❤️❤️❤️");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
