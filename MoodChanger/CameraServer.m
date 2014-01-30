//
//  CameraServer.m
//  Encoder Demo
//
//  Created by Geraint Davies on 19/02/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "CameraServer.h"
#import "AVEncoder.h"
#import "RTSPServer.h"

static CameraServer* theServer;

@interface CameraServer  () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession* _captureSession;
    AVCaptureVideoPreviewLayer* _preview;
    AVCaptureVideoDataOutput* _output;
    dispatch_queue_t _captureQueue;
    
    AVEncoder* _encoder;
    
    RTSPServer* _rtsp;
}
@end


@implementation CameraServer

+ (void) initialize
{
    // test recommended to avoid duplicate init via subclass
    if (self == [CameraServer class])
    {
        theServer = [[CameraServer alloc] init];
    }
}

+ (CameraServer*) server
{
    return theServer;
}

- (void) startup
{
    if (_captureSession != nil) {
      return;
    }
  
    NSLog(@"Starting up server");
    NSError *error;
    AVCaptureDeviceInput *captureInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
    
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    _captureQueue = dispatch_queue_create("uk.co.gdcl.avencoder.capture", DISPATCH_QUEUE_SERIAL);
    [captureOutput setSampleBufferDelegate:self queue:_captureQueue];
    [captureOutput setVideoSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}]; // that looks bad
    
    _encoder = [AVEncoder encoderForHeight:480 andWidth:720];
    [_encoder encodeWithBlock:^int(NSArray* data, double pts) {
      if (_rtsp != nil)
      {
        _rtsp.bitrate = _encoder.bitspersecond;
        [_rtsp onVideoData:data time:pts];
      }
      return 0;
    } onParams:^int(NSData *data) {
      _rtsp = [RTSPServer setupListener:data];
      return 0;
    }];
    
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canAddInput:captureInput] && [_captureSession canAddOutput:captureOutput]) {
      [_captureSession addInput:captureInput];
      [_captureSession addOutput:captureOutput];
    } else {
      [[[UIAlertView alloc] initWithTitle:@"Well Shit"
                                  message:nil
                                 delegate:nil
                        cancelButtonTitle:@"Damn man."
                        otherButtonTitles:nil] show];
    }
    
    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [_captureSession startRunning];
    
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    [_preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
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

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // pass frame to encoder
    [_encoder encodeFrame:sampleBuffer];
}

- (void) shutdown
{
    NSLog(@"shutting down server");
    if (_captureSession)
    {
        [_captureSession stopRunning];
        _captureSession = nil;
    }
    if (_rtsp)
    {
        [_rtsp shutdownServer];
    }
    if (_encoder)
    {
        [_encoder shutdown];
    }
}

- (NSString*) getURL
{
    NSString* ipaddr = [RTSPServer getIPAddress];
    NSString* url = [NSString stringWithFormat:@"rtsp://%@/", ipaddr];
    return url;
}

- (AVCaptureVideoPreviewLayer*) getPreviewLayer
{
    return _preview;
}

@end
