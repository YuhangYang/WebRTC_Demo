//
//  WebRTCHelper.h
//  WebRTC_Demo
//
//  Created by 杨宇航 on 20/7/22.
//  Copyright © 2020年 杨宇航. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>
#import <WebRTC/WebRTC.h>

@protocol WebRTCHelperFriendListDelegate;
@protocol WebRTCHelperChatDelegate;

@interface WebRTCHelper : NSObject<SRWebSocketDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic, weak)id<WebRTCHelperFriendListDelegate> friendListDelegate;
@property (nonatomic, weak)id<WebRTCHelperChatDelegate> chatdelegate;

/**
 *  与服务器建立连接
 *
 *  @param server 服务器地址
 @pram  port   端口号
 *  @param room   房间号
 */
- (void)connectServer:(NSString *)server port:(NSString *)port room:(NSString *)room;

/**
 *  退出房间
 */
- (void)exitRoom;

/*
 *  断开连接
 */
- (void)closePeerConnection;
/*
 *建立与好友的WebRTC连接
 */
- (void)connectWithUserId:(NSString *)userId;

/**
 * 切换摄像头
 */
- (void)swichCamera;

@end

/*
 *  好友列表协议
 */
@protocol WebRTCHelperFriendListDelegate <NSObject>

@optional

- (void)webRTCHelper:(WebRTCHelper *)webRTCHelper gotFriendList:(NSArray *)friendList;
- (void)webRTCHelper:(WebRTCHelper *)webRTCHelper gotNewFriend:(NSString *)userId;
- (void)webRTCHelper:(WebRTCHelper *)webRTCHelper removeFriend:(NSString *)userId;
- (void)requestConnectWithUserId:(NSString *)userId;

@end

/*
 *  聊天消息协议
 */
@protocol WebRTCHelperChatDelegate <NSObject>

@optional

/**
 * 获取到发送信令消息
 * @param webRTCHelper 本类
 * @param message 消息内容
 */
-(void)webRTCHelper:(WebRTCHelper *)webRTCHelper receiveMessage:(NSString *)message;

/**
 * 获取socket连接状态
 * @param webRTCHelper 本类
 * @param captureSession 连接状态，分为
 */
-(void)webRTCHelper:(WebRTCHelper *)webRTCHelper capturerSession:(AVCaptureSession *)captureSession;

/**
 * 获取远程的remoteVideoStream数据
 * @param webRTCHelper 本类
 * @param stream 视频流
 */
-(void)webRTCHelper:(WebRTCHelper *)webRTCHelper addRemoteStream:(RTCMediaStream *)stream;

/**
 * 某个用户退出后，关闭用户的连接
 * @param webRTCHelper 本类
 * @param userId 用户标识
 */
- (void)webRTCHelper:(WebRTCHelper *)webRTCHelper closeWithUserId:(NSString *)userId;

@end
