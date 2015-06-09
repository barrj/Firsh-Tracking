//
//  ViewController.h
//  testOpenCV_3
//
//  Created by John Barr on 10/3/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#import <opencv2/highgui/cap_ios.h>

#import <UIKit/UIKit.h>

#import "sharedROI.h"

using namespace cv;

@interface SettingsViewController : UIViewController
{
    
    CGFloat x1, x2, y1, y2;  // Record start and end of touch
    NSMutableArray* theAreas;
    NSMutableArray* theData;
    sharedROI *mySharedROI;  // this is the singleton that is used to pass the ROI areas from view to view
}
@property (weak, nonatomic) IBOutlet UITextField *threshold;

@property (weak, nonatomic) IBOutlet UITextField *interval;

- (IBAction)updateSettings:(id)sender;

- (IBAction)textFieldDoneEditing:(id)sender;

@end

