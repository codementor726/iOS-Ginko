/*
 * libjingle
 * Copyright 2014, Google Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

#import "ARDMessageResponse.h"
#import "ARDRegisterResponse.h"
#import "ARDSignalingMessage.h"
#import "ARDUtilities.h"
#import "ARDWebSocketChannel.h"
#import "RTCICECandidate+JSON.h"
#import "RTCICEServer+JSON.h"
#import "RTCMediaConstraints.h"
#import "RTCMediaStream.h"
#import "RTCPair.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription+JSON.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCVideoCapturer.h"
#import "RTCVideoTrack.h"

#import <libjingle_peerconnection/RTCVideoSource.h>

#import "YYYCommunication.h"

typedef NS_ENUM(NSInteger, ARDAppClientState) {
  // Disconnected from servers.
  kARDAppClientStateDisconnected,
  // Connecting to servers.
  kARDAppClientStateConnecting,
  // Connected to servers.
  kARDAppClientStateConnected,
};

@class ARDAppClient;
@protocol ARDAppClientDelegate <NSObject>

- (void)appClient:(ARDAppClient *)client didChangeState:(ARDAppClientState)state memberId:(NSString *)_memberId;

//- (void)appClient:(ARDAppClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

- (void)appClient:(ARDAppClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack memberId:(NSString *)_memberId;

- (void)appClient:(ARDAppClient *)client didError:(NSError *)error memberId:(NSString *)_memberId;

- (void)appClient:(ARDAppClient *)client didConnectedOnConference:(NSString *)_memberId;
- (void)appClient:(ARDAppClient *)client disconnectInternet:(NSString *)_memberId;

@end

// Handles connections to the AppRTC server for a given room.
@interface ARDAppClient : NSObject

@property(nonatomic, readonly) ARDAppClientState state;
@property(nonatomic, weak) id<ARDAppClientDelegate> delegate;

@property(nonatomic, strong) RTCPeerConnection *peerConnectionOfOneMember;
@property(nonatomic, strong) RTCPeerConnectionFactory *factory;

@property(nonatomic, strong) NSString *conferenceId;
//@property(nonatomic, strong) NSString *memberId;
@property(nonatomic, strong) NSMutableArray *iceServers;

@property(nonatomic, strong) NSMutableArray *allCandidcate;
@property(nonatomic, assign) BOOL isInitiator;
@property(nonatomic, assign) BOOL isSpeakerEnabled;
//@property(nonatomic, weak) NSTimer* internetConTimer;

- (instancetype)initWithDelegate:(id<ARDAppClientDelegate>)dgate boardId:(NSString *)_boardId arrIceServers:(NSMutableArray *)_arrIceServers memberId:(NSString *)_memberId;

//init peerconnection and factory, connecting to a conference
- (void)connectToRoomWithId:(RTCMediaStream *)localStream;
- (void)sendOffer;
- (void)getRemoteSDP:(NSString *)userId;
- (void)getRemoteCandidate:(NSString *)userId;

- (void)setStreamPeerConnection:(RTCMediaStream *)stream;

// Disconnects from the AppRTC servers and any connected clients.
- (void)disconnect;

@end
