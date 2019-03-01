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

#import "ARDAppClient.h"

#import <AVFoundation/AVFoundation.h>

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
#import <libjingle_peerconnection/RTCPeerConnectionInterface.h>

#import "YYYCommunication.h"

static NSString *kARDAppClientErrorDomain = @"GinkoClient";
static NSInteger kARDAppClientErrorUnknown = -1;
static NSInteger kARDAppClientErrorRoomFull = -2;
static NSInteger kARDAppClientErrorCreateSDP = -3;
static NSInteger kARDAppClientErrorSetSDP = -4;
static NSInteger kARDAppClientErrorNetwork = -5;
static NSInteger kARDAppClientErrorInvalidClient = -6;
static NSInteger kARDAppClientErrorInvalidRoom = -7;

@interface ARDAppClient () <RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate>{
    BOOL gotSDPForInit;
    BOOL gotCandidateForInit;
    
    RTCSessionDescription *sdpGotFromServer;
    NSString *remoteSDP;
    
    NSInteger currentWeightOfUser;
    
    NSMutableArray *userIdsForCreateOffer;
    NSMutableArray *userIdsForCreateAnswer;
    
    NSTimer* internetConTimer;
    
    int count;
    
    NSString *memberId;
}

@end

@implementation ARDAppClient

@synthesize state;
@synthesize delegate;
@synthesize peerConnectionOfOneMember;
@synthesize factory ;
@synthesize conferenceId;
//@synthesize memberId;
@synthesize iceServers;
@synthesize allCandidcate;
@synthesize isInitiator,isSpeakerEnabled;
//@synthesize internetConTimer;

- (instancetype)initWithDelegate:(id<ARDAppClientDelegate>)dgate boardId:(NSString *)_boardId arrIceServers:(NSMutableArray *)_arrIceServers memberId:(NSString *)_memberId{
    if (self = [super init]) {
        delegate = dgate;
        //factory = [[RTCPeerConnectionFactory alloc] init];
        conferenceId = _boardId;
        iceServers = [NSMutableArray array];
        iceServers = _arrIceServers;
        memberId = _memberId;
        allCandidcate = [[NSMutableArray alloc] init];
        isSpeakerEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    [self disconnect];
}

- (void)setState:(ARDAppClientState)statetoGet {
    
    if (state == statetoGet) {
        return;
    }
    state = statetoGet;
    [delegate appClient:self didChangeState:state memberId:memberId];
}


- (void)disconnect {
    
    if (state == kARDAppClientStateDisconnected) {
        return;
    }
    memberId = nil;
    peerConnectionOfOneMember = nil;
    factory = [[RTCPeerConnectionFactory alloc] init];
    self.state = kARDAppClientStateDisconnected;
    if(internetConTimer != nil)
    {
        [internetConTimer invalidate];
        count = 0;
    }
}

//
- (void)connectToRoomWithId:(RTCMediaStream *)localStream{
    self.state = kARDAppClientStateConnecting;
    [self startSignalingIfReady:localStream];
}

#pragma mark - Private

- (void)startSignalingIfReady:(RTCMediaStream *)localStream {
    
    self.state = kARDAppClientStateConnected;
    
    // Create peer connection.
    RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
    RTCConfiguration *configura = [[RTCConfiguration alloc] init];
    configura.iceServers = [iceServers copy];
    configura.tcpCandidatePolicy = kRTCTcpCandidatePolicyDisabled;
    configura.bundlePolicy = kRTCBundlePolicyMaxBundle;
    configura.rtcpMuxPolicy = kRTCRtcpMuxPolicyRequire;
    peerConnectionOfOneMember = [factory peerConnectionWithConfiguration:configura constraints:constraints delegate:self];
    
    [peerConnectionOfOneMember addStream:localStream];
}
- (void)sendOffer {
    [peerConnectionOfOneMember createOfferWithDelegate:self  constraints:[self defaultOfferConstraints]];
}

- (void)setStreamPeerConnection:(RTCMediaStream *)stream{
    [peerConnectionOfOneMember removeStream:stream];
    [peerConnectionOfOneMember addStream:stream];
}

- (void)getRemoteSDP:(NSString *)userId{
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            for (NSDictionary *dict in _responseObject[@"data"]) {
                if ([dict objectForKey:@"sdp"]) {
                    for (int i = 0; i < [APPDELEGATE.userIdsForSenddingSDP count]; i ++) {
                        NSString *uId = [APPDELEGATE.userIdsForSenddingSDP objectAtIndex:i];
                        if ([uId integerValue] == [userId integerValue]) {
                            [APPDELEGATE.userIdsForSenddingSDP removeObjectAtIndex:i];
                        }
                    }
                    NSDictionary *values = [NSDictionary dictionaryWithJSONString:[dict objectForKey:@"sdp"]];
                    RTCSessionDescription *sdpDesc = [RTCSessionDescription descriptionFromJSONDictionary:values];
                    [peerConnectionOfOneMember setRemoteDescriptionWithDelegate:self sessionDescription:sdpDesc];
                    
                    if ([sdpDesc.type isEqualToString:@"offer"]) {
                        
                        //                    RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
                        //                    [peerConnectionOfOneMember createAnswerWithDelegate:self  constraints:constraints];
                    }else if ([sdpDesc.type isEqualToString:@"answer"]){
                        
                    }
                }
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        //[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    [[YYYCommunication sharedManager] GetVideoDataConference:APPDELEGATE.sessionId boardId:conferenceId dataType:@"sdp" userId:userId?userId:@"" successed:successed failure:failure];
}

- (void)getRemoteCandidate:(NSString *)userId{
    
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            //dispatch_async(dispatch_get_main_queue(), ^{
            
            for (NSDictionary *dict in _responseObject[@"data"]) {
                
                if ([dict objectForKey:@"candidates"]) {
                    
                    for (int i = 0; i < [APPDELEGATE.userIdsForSendingCandidate count]; i ++) {
                        NSString *uId = [APPDELEGATE.userIdsForSendingCandidate objectAtIndex:i];
                        if ([uId integerValue] == [userId integerValue]) {
                            [APPDELEGATE.userIdsForSendingCandidate removeObjectAtIndex:i];
                        }
                    }
                    
                    NSMutableArray *candidates = [[NSDictionary dictionaryWithJSONString:[dict objectForKey:@"candidates"]] mutableCopy];
                    
                    for (NSDictionary *oneCand in candidates) {
                        //NSLog(@"Receiving candidate 1 -> %@", oneCand);
                        RTCICECandidate *candidate =  [RTCICECandidate candidateFromJSONDictionary:oneCand];
                        //NSLog(@"Receiving candidate -> %@", candidate);
                        [peerConnectionOfOneMember addICECandidate:candidate];
                    }
                }
            }
            //});
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        //[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    [[YYYCommunication sharedManager] GetVideoDataConference:APPDELEGATE.sessionId boardId:conferenceId dataType:@"candidates" userId:userId?userId:@"" successed:successed failure:failure];
}

- (void) DetectPeerInternetConnectionFailed
{
    count += 3;
#ifdef DEVENV
    NSLog(@"ICE gathering state changed: %d to %@", count, memberId);
#endif
    
    if (count > 50)
    {
        [delegate appClient:self disconnectInternet:memberId];
        count = 0;
        [internetConTimer invalidate];
        internetConTimer = nil;
    }
}


#pragma mark - RTCPeerConnectionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged {
    NSLog(@"Signaling state changed: %d", stateChanged);
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Received %lu video tracks and %lu audio tracks from %@",
              (unsigned long)stream.videoTracks.count,
              (unsigned long)stream.audioTracks.count, memberId);
        
        if (stream.videoTracks.count) {
            RTCVideoTrack *videoTrack = stream.videoTracks[0];
            [delegate appClient:self didReceiveRemoteVideoTrack:videoTrack memberId:memberId];
            if ([self isHeadsetPluggedIn]){
                AVAudioSession* session = [AVAudioSession sharedInstance];
                NSError* error;
                [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
                UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
                AudioSessionSetProperty (
                                         kAudioSessionProperty_OverrideAudioRoute,
                                         sizeof (audioRouteOverride),
                                         &audioRouteOverride
                                         );
                [session setActive:YES error:&error];
            }
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream {
    NSLog(@"Stream was removed.");
}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection {
    NSLog(@"WARNING: Renegotiation needed but unimplemented.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection  iceConnectionChanged:(RTCICEConnectionState)newState {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ICE state changed: %d", newState);
        if(newState == RTCICEConnectionDisconnected || newState == RTCICEConnectionFailed)
        {
            if (internetConTimer == nil)
                internetConTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target: self selector: @selector(DetectPeerInternetConnectionFailed) userInfo: nil repeats: YES];
        }else{
            if (internetConTimer != nil)
            {
                [internetConTimer invalidate];
                internetConTimer = nil;
            }
            count = 0;
            if (newState == 2) {
                [delegate appClient:self didConnectedOnConference:memberId];
            }
        }
    });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState {
    NSLog(@"ICE gathering state changed: %d to %@", newState, memberId);
    if (newState == 2) {
        [self sendSignalingCandidateToIceServer:allCandidcate toUser:memberId];
        [allCandidcate removeAllObjects];
    }
    
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"sending candidate -> %@", candidate);
        NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
        [message setObject:candidate.sdp forKey:@"candidate"];
        [message setObject:[NSString stringWithFormat:@"%ld", (long)candidate.sdpMLineIndex] forKey:@"sdpMLineIndex"];
        [message setObject:candidate.sdpMid forKey:@"sdpMid"];
        [allCandidcate addObject:message];
    });
}

- (void)peerConnection:(RTCPeerConnection*)peerConnection didOpenDataChannel:(RTCDataChannel*)dataChannel {
    
}

#pragma mark - RTCSessionDescriptionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSLog(@"Failed to create session description. Error: %@", error);
            [self disconnect];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: @"Failed to create session description.",
                                       };
            NSError *sdpError =
            [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                       code:kARDAppClientErrorCreateSDP
                                   userInfo:userInfo];
            [delegate appClient:self didError:sdpError memberId:memberId];
            return;
        }
        
        [peerConnectionOfOneMember setLocalDescriptionWithDelegate:self   sessionDescription:sdp];
        
        NSDictionary *dic;
        if ([sdp.type isEqualToString:@"offer"]) {
            dic = @{@"type":@"offer", @"sdp":[NSString stringWithFormat:@"%@", sdp]};
        }else if([sdp.type isEqualToString:@"answer"]){
            dic = @{@"type":@"answer", @"sdp":[NSString stringWithFormat:@"%@", sdp]};
            
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
        NSString *stringSDP = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [self sendSignalingSDPToIceServer:stringSDP toUser:memberId];
    });
}


- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSLog(@"Failed to set session description. Error: %@", error);
            [self disconnect];
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: @"Failed to set session description.",
                                       };
            NSError *sdpError =
            [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                       code:kARDAppClientErrorSetSDP
                                   userInfo:userInfo];
            [delegate appClient:self didError:sdpError memberId:memberId];
            return;
        }
        
        if (!isInitiator && !peerConnectionOfOneMember.localDescription) {
            RTCMediaConstraints *constraints = [self defaultAnswerConstraints];
            [peerConnectionOfOneMember createAnswerWithDelegate:self
                                                    constraints:constraints];
            
        }
    });
}

- (void)sendSignalingSDPToIceServer:(NSString *)sdp toUser:(NSString *)_toUser{
    //NSData *data = [message JSONData];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            if ([[_responseObject objectForKey:@"data"] integerValue] == 1) {
                
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        [CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    
    [[YYYCommunication sharedManager] SendVideoDataForSDPConference:APPDELEGATE.sessionId boardId:conferenceId sdp:sdp toUser:_toUser successed:successed failure:failure];
}

- (void)sendSignalingCandidateToIceServer:(NSMutableArray *)candidate toUser:(NSString *)_toUser{
    //NSData *data = [message JSONData];
    void ( ^successed )( id _responseObject ) = ^( id _responseObject )
    {
        if ([[_responseObject objectForKey:@"success"] boolValue]) {
            if ([[_responseObject objectForKey:@"data"] integerValue] == 1) {
                
            }
        }
    };
    
    void ( ^failure )( NSError* _error ) = ^( NSError* _error )
    {
        //[CommonMethods showAlertUsingTitle:@"GINKO" andMessage:@"Internet Connection Error!"];
    };
    [[YYYCommunication sharedManager] SendVideoDataForCandidateConference:APPDELEGATE.sessionId boardId:conferenceId candidate:candidate toUser:_toUser successed:successed failure:failure];
}





#pragma mark - Defaults

- (RTCMediaConstraints *)defaultMediaStreamConstraints {
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultAnswerConstraints {
    return [self defaultOfferConstraints];
}

- (RTCMediaConstraints *)defaultOfferConstraints {
    NSArray *mandatoryConstraints = @[
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"],
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]
                                      ];
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
    NSArray *optionalConstraints = @[
                                     [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]
                                     ];
    RTCMediaConstraints* constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:optionalConstraints];
    return constraints;
}


#pragma mark - enable/disable speaker

- (void)enableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    isSpeakerEnabled = YES;
}

- (void)disableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    isSpeakerEnabled = NO;
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        NSLog(@"Porttype : %@", [desc portType]);
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return NO;
    }
    return YES;
}
@end
