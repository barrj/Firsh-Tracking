//
//  AnalysisViewController.h
//  testOpenCV_3
//
//  Created by John Barr on 12/2/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#import <opencv2/highgui/cap_ios.h>

#import "CPDConstants.h"
#import "CPDStockPriceStore.h"

#import <UIKit/UIKit.h>

#import "sharedROI.h"

#import "CorePlot-CocoaTouch.h"
#import "CPDConstants.h"
#import "CPDStockPriceStore.h"

using namespace cv;

#import <UIKit/UIKit.h>

@interface AnalysisViewController : UIViewController <CPTPlotDataSource, UIActionSheetDelegate>
{
    // theValues Contains the observed differences; each entry is itself an array
    // every  element is an int of the number of pixels
    // that changed in the corresponding ROI (element 0 corresponds to ROI 0, etc.)
    NSMutableArray* theValues;
    // this array is a parallel array for theValues.  Each element is the timestamp for the corresponding row of theValues
    NSMutableArray* theTimeStamps;
    sharedROI *mySharedROI;  // this is the singleton that is used to pass the ROI areas from view to view
}

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *themeButton;

-(IBAction)themeTapped:(id)sender;

@end
