//
//  AppDelegate.m
//  MenubarTicker
//
//  Created by Serban Giuroiu on 6/3/12.
//  Copyright (c) 2012 Serban Giuroiu. All rights reserved.
//

#import "AppDelegate.h"

#import "iTunes.h"
#import "Rdio.h"
#import "Spotify.h"

const NSTimeInterval kPollingInterval = 10.0;


@interface AppDelegate ()

@property (nonatomic, retain) iTunesApplication *iTunes;
@property (nonatomic, retain) RdioApplication *rdio;
@property (nonatomic, retain) SpotifyApplication *spotify;

@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) NSTimer *timer;

@end


@implementation AppDelegate

@synthesize iTunes;
@synthesize rdio;
@synthesize spotify;

@synthesize statusItem;
@synthesize statusMenu;
@synthesize timer;

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];

    self.iTunes = nil;
    self.rdio = nil;
    self.spotify = nil;
    
    self.statusItem = nil;
    self.statusMenu = nil;
    
    [self.timer invalidate];
    self.timer = nil;
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kPollingInterval
                                                  target:self
                                                selector:@selector(timerDidFire:)
                                                userInfo:nil
                                                 repeats:YES];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(didReceivePlayerNotification:)
                                                            name:@"com.apple.iTunes.playerInfo"
                                                          object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(didReceivePlayerNotification:)
                                                            name:@"com.rdio.desktop.playStateChanged"
                                                          object:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(didReceivePlayerNotification:)
                                                            name:@"com.spotify.client.PlaybackStateChanged"
                                                          object:nil];
}

- (void)awakeFromNib
{
    self.iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    self.rdio = [SBApplication applicationWithBundleIdentifier:@"com.rdio.desktop"];
    self.spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.menu = self.statusMenu;
    self.statusItem.highlightMode = YES;
    self.statusItem.toolTip = @"Menu Bar Ticker";
    
    [self updateTrackInfo];
}


- (void)updateTrackInfo
{
    NSString *displayString = @"🎶"; // 🎵 or 🎶
    
    if ([self.iTunes isRunning] && [self.iTunes playerState] == iTunesEPlSPlaying) {
        iTunesTrack *currentTrack = [self.iTunes currentTrack];
        displayString = [NSString stringWithFormat:@"%@ - %@",
                         [currentTrack artist], [currentTrack name]];
    } else if ([self.rdio isRunning] && [self.rdio playerState] == RdioEPSSPlaying) {
        RdioTrack *currentTrack = [self.rdio currentTrack];
        displayString = [NSString stringWithFormat:@"%@ - %@",
                         [currentTrack artist], [currentTrack name]];
    } else if ([self.spotify isRunning] && [self.spotify playerState] == SpotifyEPlSPlaying) {
        SpotifyTrack *currentTrack = [self.spotify currentTrack];
        displayString = [NSString stringWithFormat:@"%@ - %@",
                         [currentTrack artist], [currentTrack name]];
    }
    
    statusItem.title = displayString;
}

- (void)timerDidFire:(NSTimer *)theTimer
{
    [self updateTrackInfo];
}

- (void)didReceivePlayerNotification:(NSNotification *)notification
{
    [self updateTrackInfo];
}

@end
