//
//  CameraCapture.h
//  MoodChanger 
//
//  Created by Austin Feight on 2/2/14.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

#import "ImageProcessing.h"

@protocol SmileDetectorDelegate <NSObject>

- (void)smileDetected;

@end

@interface SmileDetector : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) id delegate;

@property (strong, nonatomic) AVCaptureSession *AVsession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (atomic) dispatch_queue_t videoDataOutputQueue;
@property (strong, nonatomic) CIDetector *faceDetector;
@property (atomic) BOOL isUsingFrontFacingCamera;

@property (strong, nonatomic) UIImage *square;

+ (id)newWithDelegate:(id)delegate;
- (id)initWithDelegate:(id)delegate;

- (void)setDetectionAccuracy:(NSString *)accuracy;

@end
