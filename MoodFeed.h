//
//  MoodFeed.h
//  MoodChanger
//
//  Created by Austin Feight on 2/6/14.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "SmileDetector.h"

@protocol MoodFeedDelegate <NSObject>

- (void)moodImproved;

@end

@interface MoodFeed : NSObject

@property (strong, nonatomic) AVCaptureSession *AVsession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (atomic) dispatch_queue_t videoDataOutputQueue;

@property (strong, nonatomic) SmileDetector *smileDetector;

- (void)startAnalysis;

@end
