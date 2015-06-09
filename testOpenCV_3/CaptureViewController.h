//
//  CaptureViewController.h
//  testOpenCV_3
//
//  Created by John Barr on 10/25/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//


#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#import <opencv2/highgui/cap_ios.h>

#import <UIKit/UIKit.h>

#import "sharedROI.h"

@interface CaptureViewController : UIViewController<CvVideoCameraDelegate, UIActionSheetDelegate>
{
    NSMutableArray* theROIAreas;  // This array contains the ROI
    // theValues Contains the observed differences; each entry is itself an array
    // every  element is an int of the number of pixels
    // that changed in the corresponding ROI (element 0 corresponds to ROI 0, etc.)
    NSMutableArray* theValues;
    // this array is a parallel array for theValues.  Each element is the timestamp for the corresponding row of theValues
    NSMutableArray* theTimeStamps;
    sharedROI *mySharedROI;  // this is the singleton that is used to pass the ROI areas from view to view

}

- (IBAction)startCapture:(id)sender;
- (IBAction)stopCapture:(id)sender;
- (IBAction)saveCapture:(UIButton *)sender;

- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancelSaveButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *videoImage;

@property (weak, nonatomic) IBOutlet UITextField *saveTextField;
@property (weak, nonatomic) IBOutlet UIControl *saveView;

@end
