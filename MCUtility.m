//
//  Utility.m
//  MoodChanger
//
//  Created by Austin Feight on 2/6/14.
//
//

#import "MCUtility.h"

@implementation MCUtility

// utility routine to display error aleart if takePicture fails
+ (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
                                message:[error localizedDescription]
														   delegate:nil
                      cancelButtonTitle:@"Dismiss"
                      otherButtonTitles:nil] show];
	});
}

+ (int)exifOrientation:(BOOL)isUsingFrontFacingCamera {

  /* kCGImagePropertyOrientation values
   The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
   by the TIFF and EXIF specifications -- see enumeration of integer constants.
   The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
   
   used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
   If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */

  enum {
    PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
    PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
    PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
    PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
    PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
    PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
    PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
    PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
  };

  UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
  switch (curDeviceOrientation) {
    case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
      return PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
      break;
    case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
      if (isUsingFrontFacingCamera)
        return PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
      else
        return PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
      break;
    case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
      if (isUsingFrontFacingCamera)
        return PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
      else
        return PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
      break;
    case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
    default:
      return PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
      break;
  }
}
@end
