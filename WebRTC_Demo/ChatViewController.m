//
//  ChatViewController.m
//  WebRTC_Demo
//
//  Created by 杨宇航 on 20/7/22.
//  Copyright © 2020年 杨宇航. All rights reserved.
//

#import "ChatViewController.h"
#import "WebRTCHelper.h"

#import "UIViewExt.h"
#import "UIButton+Edge.h"

//获取屏幕的宽高
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// 状态栏
#define statusBar_Height [[UIApplication sharedApplication] statusBarFrame].size.height
// 系统安全距离,x以上
#define tabBar_Safety_Height ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 34 : 0)

#define KVedioWidth SCREEN_WIDTH/3.0
#define KVedioHeight KVedioWidth*16/9

@interface ChatViewController ()<WebRTCHelperChatDelegate>

@property (strong, nonatomic) UIButton *hornButton;   // 话筒
@property (strong, nonatomic) UIButton *closeButton;  // 关闭按钮
@property (strong, nonatomic) UIButton *cameraButton; // 前后摄像头

// 本地视频追踪
@property (nonatomic, strong) AVCaptureSession *captureSession;
// 远程的视频追踪
@property (nonatomic, strong) RTCVideoTrack *remoteVideoTrack;

@property (nonatomic, strong) RTCEAGLVideoView *videoView; // 大窗口，远端视频
@property (nonatomic, strong) RTCCameraPreviewView *localVideoView; // 小窗口，本地视频

@property (nonatomic) BOOL isLocalOrRemote; // 用于判断 大窗口显示远端还是本地视频流，NO本地，YES远端，默认远端

@end

@implementation ChatViewController

- (void)dealloc {
    [WebRTCHelper sharedInstance].chatdelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [WebRTCHelper sharedInstance].chatdelegate = self;
    
    _isLocalOrRemote = YES;
    
    [self creatSubViews];
    [self connect];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

//在页面消失的时候就让navigationbar还原样式
- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)creatSubViews {
    // 大视频图层
    _videoView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [self.view addSubview:_videoView];
    
    // 小视频图层
    _localVideoView = [[RTCCameraPreviewView alloc] initWithFrame:CGRectMake(self.view.width - KVedioWidth - 10, statusBar_Height, KVedioWidth, KVedioHeight)];
    [self.view addSubview:_localVideoView];
    // 添加拖拽手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    [_localVideoView addGestureRecognizer:pan];

    _hornButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.height-tabBar_Safety_Height-120, self.view.width/3, 100)];
    [_hornButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_hornButton setTitle:@"免提" forState:UIControlStateNormal];
    [_hornButton setImage:[UIImage imageNamed:@"rtc_horn_default"] forState:UIControlStateNormal];
    [_hornButton setImage:[UIImage imageNamed:@"rtc_horn_select"] forState:UIControlStateSelected];
    [_hornButton setImagePositionWithType:QMImagePositionTypeTop spacing:5];
    _hornButton.exclusiveTouch = YES;
    [_hornButton addTarget:self action:@selector(hornButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_hornButton];

    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(_hornButton.right, _hornButton.y, self.view.width/3, 100)];
    [_closeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_closeButton setTitle:@"挂断" forState:UIControlStateNormal];
    [_closeButton setImage:[UIImage imageNamed:@"rtc_close"] forState:UIControlStateNormal];
    [_closeButton setImagePositionWithType:QMImagePositionTypeTop spacing:5];
    _closeButton.exclusiveTouch = YES;
    [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];

    _cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(_closeButton.right, _hornButton.y, self.view.width/3, 100)];
    [_cameraButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_cameraButton setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [_cameraButton setImage:[UIImage imageNamed:@"rtc_switch_default"] forState:UIControlStateNormal];
    [_cameraButton setImage:[UIImage imageNamed:@"rtc_switch"] forState:UIControlStateSelected];
    [_cameraButton setImagePositionWithType:QMImagePositionTypeTop spacing:5];
    _cameraButton.exclusiveTouch = YES;
    [_cameraButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraButton];
}

#pragma mark - 拖拽手势
- (void)handlePanAction:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"FlyElephant---视图拖动开始");
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [recognizer locationInView:self.view];
        
        if (location.y < 0 || location.y > self.view.height) {
            return;
        }
        CGPoint translation = [recognizer translationInView:self.view];
        
        NSLog(@"当前视图在View的位置:%@----平移位置:%@",NSStringFromCGPoint(location),NSStringFromCGPoint(translation));
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:self.view];
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"FlyElephant---视图拖动结束");
    }
}

#pragma mark - 外放
- (void)hornButtonAction:(UIButton *)button {
    self.hornButton.selected = !self.hornButton.selected;
    if (self.hornButton.selected) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        // 扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
    } else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        // 听筒播放
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
}

#pragma mark - 挂断
- (void)closeButtonAction:(UIButton *)button {
    [[WebRTCHelper sharedInstance] exitRoom];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 翻转摄像头
- (void)cameraButtonAction:(UIButton *)button {
    [[WebRTCHelper sharedInstance] swichCamera];
}

#pragma mark - 连接服务器
- (void)connect {
    [[WebRTCHelper sharedInstance] connectServer:@"192.168.4.151" port:@"3000" room:@"100"];
}

#pragma mark -- WebRTCHelperChatDelegate
//接收到消息
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper receiveMessage:(NSString *)message {
    NSLog(@"接收到消息：%@",message);
}

/**
 * 新版获取本地视频流的方法
 * captureSession RTCCameraPreviewView类的参数，通过设置这个，就可以达到显示本地视频的功能
 */
- (void)webRTCHelper:(WebRTCHelper *)webRTCHelper capturerSession:(AVCaptureSession *)captureSession {
    _captureSession = captureSession;
    _localVideoView.captureSession = _captureSession;
}

- (void)webRTCHelper:(WebRTCHelper *)webRTCHelper addRemoteStream:(RTCMediaStream *)stream {
    NSLog(@"setRemoteStream");
    
    _remoteVideoTrack = [stream.videoTracks lastObject];
    // 添加渲染器
    [_remoteVideoTrack addRenderer:_videoView];
}

// 连接断开
- (void)webRTCHelper:(WebRTCHelper *)webRTChelper closeWithUserId:(NSString *)userId {
    [[WebRTCHelper sharedInstance] exitRoom];
    [self.navigationController popViewControllerAnimated:YES];
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

@end
