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

- (id)init {
  if (self = [super init]) {
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                       context:nil
                                       options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
  }
  
  return self;
}

#pragma mark - API Functionality

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

