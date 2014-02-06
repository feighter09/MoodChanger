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

@interface SmileDetector : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureVideoDataOutput *videoDataOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (atomic) dispatch_queue_t videoDataOutputQueue;
@property (strong, nonatomic) UIImage *square;
@property (atomic) BOOL isUsingFrontFacingCamera;
@property (strong, nonatomic) CIDetector *faceDetector;

+ (id)new;

- (void)start;
- (void)stop;

- (void)setDetectionAccuracy:(NSString *)accuracy;

@end
