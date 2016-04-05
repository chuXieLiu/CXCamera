//
//  CXVideoEditView.m
//  CXCamera
//
//  Created by c_xie on 16/4/4.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "CXVideoEditView.h"
#import "UIView+CXExtension.h"
#import <AVFoundation/AVFoundation.h>

static const CGFloat kCXVideoEditViewToolViewHeight = 70.0f;

static const NSString * kPlayerItemStatusContex;

static NSString *kAVPlayerItemPropertyStatus = @"status";

@interface CXVideoEditView ()

@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,copy) CXCameraRecordAgainBlock recordAgainBlock;
@property (nonatomic,copy) CXCameraEmployVideoBlock employVideoBlock;

@property (nonatomic,weak) UIView *toolView;
@property (nonatomic,weak) UIButton *recordButton;
@property (nonatomic,weak) UIButton *employButton;
@property (nonatomic,weak) UIButton *playButton;

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,assign) BOOL isPrepareToPlay;



@end

@implementation CXVideoEditView

+ (instancetype)showVideoEditViewWithVideoURL:(NSURL *)videoURL
                             recordAgainBlock:(CXCameraRecordAgainBlock)recordAgainBlock
                             employVideoBlock:(CXCameraEmployVideoBlock)employVideoBlock
{
    CXVideoEditView *videoView = [[CXVideoEditView alloc] initWithFrame:CGRectZero];
    videoView.videoURL = videoURL;
    videoView.recordAgainBlock = recordAgainBlock;
    videoView.employVideoBlock = employVideoBlock;
    return videoView;
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    [self prepareToPlay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.player.rate != 0.0f) {
        [self.player pause];
        self.playButton.hidden = NO;
    }
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.toolView.origin = CGPointMake(0, self.height - kCXVideoEditViewToolViewHeight);
    self.toolView.size = CGSizeMake(self.width, kCXVideoEditViewToolViewHeight);
    
    self.recordButton.left = 15.0f;
    self.recordButton.centerY = self.toolView.height * 0.5;
    
    self.employButton.right = self.width - self.recordButton.left;
    self.employButton.centerY = self.recordButton.centerY;
    
    self.playButton.center = self.center;
    
}

#pragma mark - private method

- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
    
    UIView *toolView = [[UIView alloc] init];
    toolView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self addSubview:toolView];
    self.toolView = toolView;
    
    UIButton *recordButton = [[UIButton alloc] init];
    [recordButton setTitle:@"重拍" forState:UIControlStateNormal];
    [recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [recordButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [recordButton addTarget:self action:@selector(recordAgain:) forControlEvents:UIControlEventTouchUpInside];
    [recordButton sizeToFit];
    [self.toolView addSubview:recordButton];
    self.recordButton = recordButton;
    
    UIButton *employButton = [[UIButton alloc] init];
    [employButton setTitle:@"使用视频" forState:UIControlStateNormal];
    [employButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [employButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [employButton addTarget:self action:@selector(employVideo:) forControlEvents:UIControlEventTouchUpInside];
    [employButton sizeToFit];
    [self.toolView addSubview:employButton];
    self.employButton = employButton;
    
}

- (void)prepareToPlay
{
    AVAsset *asset = [AVAsset assetWithURL:self.videoURL];
    NSArray *assetKeys = @[
                           @"tracks",
                           @"duration"
                           ];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:assetKeys];
    [self.playerItem addObserver:self
                      forKeyPath:kAVPlayerItemPropertyStatus
                         options:NSKeyValueObservingOptionNew
                         context:&kPlayerItemStatusContex];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [(AVPlayerLayer *)[self layer] setPlayer:self.player];
}

- (void)addPlayerItemTimeEndObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemTimeEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}



- (void)playCompletion
{
    self.playButton.hidden = NO;
    
    [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
}

#pragma mark - target event

- (void)recordAgain:(UIButton *)sender
{
    [self.player setRate:0.f];
    !self.recordAgainBlock ? : self.recordAgainBlock();
}

- (void)employVideo:(UIButton *)sender
{
    [self.player setRate:0.f];
    !self.employVideoBlock ? : self.employVideoBlock();
}

- (void)play:(UIButton *)sender
{
    if (self.player.rate != 1.0f && self.isPrepareToPlay) {
        [self.player play];
        self.playButton.hidden = YES;
    }
}

- (void)playerItemTimeEnd:(NSNotification *)note
{
    if ([NSThread isMainThread]) {
        [self playCompletion];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playCompletion];
        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context == &kPlayerItemStatusContex) {
        [_playerItem removeObserver:self forKeyPath:kAVPlayerItemPropertyStatus];
        if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
            
            [self addPlayerItemTimeEndObserver];
            self.isPrepareToPlay = YES;
        }
    }
}

#pragma mark - lazy

- (UIButton *)playButton
{
    if (_playButton == nil) {
        UIButton *playButton = [[UIButton alloc] init];
        [playButton setImage:[UIImage imageNamed:@"btn_play_b"] forState:UIControlStateNormal];
        [playButton sizeToFit];
        [playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playButton];
        _playButton = playButton;
    }
    return _playButton;
}



@end
