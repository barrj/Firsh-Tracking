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

@interface ViewController : UIViewController<CvVideoCameraDelegate, UIActionSheetDelegate>
{
    
    CGFloat x1, x2, y1, y2;  // Record start and end of touch
    NSMutableArray* theAreas;
    NSMutableArray* loadFileNames;
    sharedROI *mySharedROI;  // this is the singleton that is used to pass the ROI areas from view to view
}

- (IBAction)startVideo:(id)sender;
- (IBAction)saveMask:(id)sender;
- (IBAction)clearMask:(id)sender;
- (IBAction)addRowsCols:(UIButton *)sender;
- (IBAction)noAddRowsCols:(UIButton *)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancelSaveButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *colsTextField;
@property (weak, nonatomic) IBOutlet UITextField *rowsTextField;

@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UIView *rowColView;

@property (weak, nonatomic) IBOutlet UITextField *saveTextField;
@property (weak, nonatomic) IBOutlet UIControl *saveView;

@end

