//
//  MoodFeed.m
//  MoodChanger
//
//  Created by Austin Feight on 2/6/14.
//
//

#import "MoodFeed.h"

@implementation MoodFeed

- (void)startAnalysis {
  [self startAudioVideoCapture];
//  _smileDetector = [SmileDetector new];
//  [_smileDetector start];
}

- (void)startAudioVideoCapture {
  _smileDetector = [SmileDetector new];
  
	NSError *error = nil;
	_AVsession = [AVCaptureSession new];
	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    [_AVsession setSessionPreset:AVCaptureSessionPresetMedium];
	} else {
    [_AVsession setSessionPreset:AVCaptureSessionPresetPhoto];
  }
	
  // Select a video device, make an input
  //  AVCaptureDevice *device = [self frontCamera];
  [_smileDetector setIsUsingFrontFacingCamera:NO];
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
  if (error) {
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"Dismiss"
                      otherButtonTitles:nil] show];
//		[self stop];
    return;
	}
  
	if ( [_AVsession canAddInput:deviceInput] ) {
		[_AVsession addInput:deviceInput];
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
	[_videoDataOutput setSampleBufferDelegate:_smileDetector
                                      queue:dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL)];
	
  if ( [_AVsession canAddOutput:_videoDataOutput] ) {
		[_AVsession addOutput:_videoDataOutput];
  }
	[[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
	
	_previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_AVsession];
  // start facial recognition
  [[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
	[_AVsession startRunning];
}

@end
