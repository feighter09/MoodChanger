//
//  CameraCapture.m
//  MoodChanger 
//
//  Created by Austin Feight on 2/2/14.
//
//

#import "SmileDetector.h"
#import "MCUtility.h"

@implementation SmileDetector

+ (id)newWithDelegate:(id)delegate {
  return [[SmileDetector alloc] initWithDelegate:delegate];
}

- (id)initWithDelegate:(id)delegate {
  if (self = [super init]) {
    _delegate = delegate;
    _square = [UIImage imageNamed:@"squarePNG"];
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                       context:nil
                                       options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
  }
  
  return self;
}

#pragma mark - API Functionality

- (void)start {
	NSError *error = nil;
	_session = [AVCaptureSession new];
	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    [_session setSessionPreset:AVCaptureSessionPresetMedium];
	} else {
    [_session setSessionPreset:AVCaptureSessionPresetPhoto];
  }
	
  // Select a video device, make an input
//  AVCaptureDevice *device = [self frontCamera];
  _isUsingFrontFacingCamera = NO;
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
  if (error) {
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"Dismiss"
                      otherButtonTitles:nil] show];
		[self stop];
    return;
	}
  
	if ( [_session canAddInput:deviceInput] ) {
		[_session addInput:deviceInput];
  }
  
  // Make a video data output
	_videoDataOutput = [AVCaptureVideoDataOutput new];
	
  // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCMPixelFormat_32BGRA]};
	[_videoDataOutput setVideoSettings:rgbOutputSettings];
	[_videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
  
  // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
  // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
  // see the header doc for setSampleBufferDelegate:queue: for more information
//	_videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[_videoDataOutput setSampleBufferDelegate:self
                                      queue:dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL)];
	
  if ( [_session canAddOutput:_videoDataOutput] ) {
		[_session addOutput:_videoDataOutput];
  }
	[[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
	
	_previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
  // start facial recognition
  [[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
	[_session startRunning];
}

- (AVCaptureDevice *)frontCamera {
  
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  for (AVCaptureDevice *device in devices) {
    if ([device position] == AVCaptureDevicePositionFront) {
      if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        CGPoint autofocusPoint = CGPointMake(0.5f, 0.5f);
        [device setFocusPointOfInterest:autofocusPoint];
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
          [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
      }
      return device;
    }
  }
  return nil;
}

// clean up capture setup
- (void)stop {
  [_session stopRunning];
}

#pragma mark - API Session Management

- (void)setDetectionAccuracy:(NSString *)accuracy {
  if (![accuracy isEqualToString:CIDetectorAccuracyHigh] && ![accuracy isEqualToString:CIDetectorAccuracyLow]) {
    return;
  }
  
  _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                     context:nil
                                     options:@{CIDetectorAccuracy: accuracy}];
}

#pragma mark - Output Buffer Handling

// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
// to detect features and for each draw the red square in a layer and set appropriate orientation
-(void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments) {
		CFRelease(attachments);
  }
	
  int exifOrientation = [MCUtility exifOrientation:_isUsingFrontFacingCamera];
	NSArray *features = [_faceDetector featuresInImage:ciImage options:@{ CIDetectorSmile: @YES,
                                                                        CIDetectorEyeBlink: @YES,
                                                                        CIDetectorImageOrientation: [NSNumber numberWithInt:exifOrientation] }];
  for (CIFaceFeature *feat in features) {
    if ([feat hasSmile]) {
      NSLog(@"Smiling");
    } else {
      NSLog(@"Face is there, not detecting smiles");
    }
  }
}

@end

