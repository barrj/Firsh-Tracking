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

@interface LoadViewController : UIViewController
{
    NSArray* theMaskFiles; // contains the names of the files that hold masks
    NSMutableArray* theCaptureFiles; // contians the names of the files that hold a capture session
    NSMutableArray* theROIAreas;  // This array contains the ROI for the mask that is loaded
    // theValues Contains the observed differences in the loaded file; each entry is itself an array
    // every  element is an int of the number of pixels
    // that changed in the corresponding ROI (element 0 corresponds to ROI 0, etc.)
    NSMutableArray* theValues;
    // this array is a parallel array for theValues.  Each element is the timestamp for the corresponding row of theValues
    NSMutableArray* theTimeStamps;
    sharedROI *mySharedROI;  // this is the singleton that is used to pass the ROI areas from view to view
    NSString *selectedFile; // file to email

}

// pointer to the tableView so that we can force reloading 
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
- (IBAction)sendButtonPressed:(UIButton *)sender;
- (IBAction)textFieldDoneEditing:(id)sender;

@end
