//
//  CaptureViewController.m
//  testOpenCV_3
//
//  Created by John Barr on 10/25/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/core/core_c.h>
#endif

#import <opencv2/highgui/cap_ios.h>
using namespace cv;

#import "CaptureViewController.h"

#import "sharedROI.h"

@interface CaptureViewController ()
{
    BOOL videoIsOn;
    BOOL haveStoredImage;
    Mat storedFrame;
    int saveFreq;  // how long between saving frames
    int Threshold;  // threshold for amount of pixels that must change before recording
    int timeStamp;
    NSMutableArray *flashTime;
}

@property (nonatomic, retain) CvVideoCamera* videoCamera;

-(void) createCamera;

@end

@implementation CaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // set up the gesture recognizer
    //UIPanGestureRecognizer *panImage = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    // [self.videoImage addGestureRecognizer:panImage];
    
    [self createCamera];
    
    haveStoredImage = false;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_videoCamera == nil) {
        [self createCamera];
    }
    if (videoIsOn) {
        [self.videoCamera start];
    }
    else {
        if (_videoCamera != nil) {
            [self.videoCamera stop];
        }
    }
    
    // initialize the array that contains the circles
    if (theROIAreas == nil || mySharedROI == nil){
        mySharedROI = [sharedROI sharedROI];
    }
    // update the ROI
    theROIAreas = mySharedROI.theROI;
    flashTime = [[NSMutableArray alloc] initWithCapacity:[theROIAreas count]];
    for (int i = 0; i < [theROIAreas count]; i++)
    {
        [flashTime insertObject:[[NSNumber alloc]initWithInt: 0] atIndex:i];
    }
    // either theValues was created or zeroed out in the mask view
    // or we saved it when we left this view
    // either way, we get theValues from the singleton
    theValues = mySharedROI.theData;
    // get the timestamp array from the singleton
    theTimeStamps = mySharedROI.theTimeStamps;
    // get the ROI from the singleton
    theROIAreas = mySharedROI.theROI;
    // get the threshold from the Singleton
    Threshold = [mySharedROI.thresh integerValue];
    // initial save frequency is always 60 frames or 2 seconds
    saveFreq = 60;  // initial wait is 60 frames or 2 seconds
    
    // if the mask was discarded and created again then theTimeStamps should have been reset
    //  if this happened, we must reset our internal variables.
    if (theTimeStamps == nil || [theTimeStamps count] == 0 || [theTimeStamps objectAtIndex:0] == nil) {
        haveStoredImage = false;
        timeStamp = 0;
        
    }
    
    // make sure that we're in portrait mode
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_videoCamera stop];
    _videoCamera = nil;
    // save the differences that we've created in the singleton
    mySharedROI.theData = theValues;
    mySharedROI.theTimeStamps = theTimeStamps;
    
}

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - local methods

- (void) createCamera
{
    
    NSLog(@"Create new video camera instance");
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_videoImage];
    //self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    self.videoCamera.delegate = self;
    
    videoIsOn = false;
}

#pragma mark - action methods

- (IBAction)startCapture:(id)sender {
    if (theROIAreas == nil || [theROIAreas count] == 0  || [theROIAreas objectAtIndex: 0] == nil) {
        UIAlertView *noMask = [[UIAlertView alloc] initWithTitle:@"No Mask" message:@"You must create a mask before detecting differences" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noMask show];
        return;
    }
    [self.videoCamera start];
    videoIsOn = true;
}

- (IBAction)stopCapture:(id)sender
{
    [self.videoCamera stop];
    videoIsOn = false;
}

- (IBAction)saveCapture:(UIButton *)sender {
    _saveView.hidden = false;
}

-(IBAction)textFieldDoneEditing:(id)sender{
    [self.saveTextField resignFirstResponder];
}

- (IBAction)saveButtonPressed:(id)sender {
    
    NSString *msg; // the message for the action sheet/alert box
    BOOL isDirectory;
    // get the path to all of the directories used by this app
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // the first directory is always the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // ok, now we can get the file name
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",_saveTextField.text];
    
    // check to see if the file already exists
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"CAP"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
        [manager createDirectoryAtPath:folderPath
           withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
        if (error)
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
    }
    
    // check to see if the file already exists
    NSString* saveFilePath = [folderPath stringByAppendingPathComponent:fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:saveFilePath];
    
    
    NSLog(@"saveButtonPressed:  filename stored at %@", saveFilePath);
    
    msg = [NSString stringWithFormat:@"Do you want to replace %@", fileName];
    if (fileExists) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:msg delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
        actionSheet.tag = 2;
        [actionSheet showInView:self.view];
    }
    else{
        [self writeCaptureToFile];
    }
    
}

- (IBAction)cancelSaveButtonPressed:(id)sender {
    _saveView.hidden = true;
}

// This function actually saves the file
- (void) writeCaptureToFile{
    NSArray *nextValue;
    NSNumber *nextTime;
    NSString *currentRow;
    
    // get the path to all of the directories used by this app
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // the first directory is always the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // We save all files in the directory Documents/ROI so add the ROI part
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"CAP"];
    
    // ok, now we can get the file name
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",_saveTextField.text];
    // we can assume that the folder ROI exists because we created it in saveButtonPressed
    NSString* saveFilePath = [folderPath stringByAppendingPathComponent:fileName];
    
    
    NSLog(@"in writeMaskToFile: filename is %@", saveFilePath);
    
    
    // Turn the mask ROI into a string
    currentRow = @"";
    for (int i = 0; i < [theValues count]; i++) {
        nextValue = [theValues objectAtIndex:i];
        nextTime = [theTimeStamps objectAtIndex:i];
        currentRow = [NSString stringWithFormat:@"%@ %ld", currentRow, (long)[nextTime integerValue]];
        for (int j = 0; j < [nextValue count]; j++) {
            currentRow = [NSString stringWithFormat:@"%@ %ld", currentRow, (long)[[nextValue objectAtIndex:j] integerValue]];
        }
        currentRow = [NSString stringWithFormat:@"%@\n", currentRow];
    }
    [currentRow writeToFile: saveFilePath atomically: YES encoding: NSUTF32StringEncoding error: nil];
    
    _saveView.hidden = true;
}

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex])
    {
            [self writeCaptureToFile];
    }
    else{
        _saveView.hidden = true;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    // Do some OpenCV stuff with the image
    Mat newFrame;

    // amount of blur
    cv::Size ksize;
    ksize.height = 7;
    ksize.width = 7;
    
    saveFreq--;
    
    if ([flashTime count] > 0) {
        // Do some OpenCV stuff with the image
        Mat image_copy;
        cvtColor(image, image_copy, CV_BGRA2BGR);
        CvPoint pt1;
        CvPoint pt2;
        CvScalar color;
        color.val[0] = 200;
        color.val[1] = 200;
        color.val[2] = 0;
        //color.val[3] = 100;
        
        // use this to store the points of a ROI
        NSArray* thePoint;
        
        // check to see whether there are any circles defined
        int numCircles = [theROIAreas count];
        while (numCircles > 0) {
            // note a race condition here.  If we're in this while loop and
            // the user clicks "clear", then suddenly theArray will be empty!
            if ([theROIAreas count] <= 0) {
                break;
            }
            
            int frameTime = [[flashTime objectAtIndex:numCircles-1] integerValue];
            if (frameTime > 0) {
                [flashTime insertObject:[[NSNumber alloc]initWithInt: frameTime - 1] atIndex:numCircles-1];
                thePoint = [theROIAreas objectAtIndex:numCircles-1];
                // make sure we got a point from the array
                // theAreas is initialized to 1 element, but this will be nil
                if (thePoint != nil || [thePoint count] >= 4) {
                    
                    
                    pt2.x = [thePoint[0] intValue];
                    pt2.y = [thePoint[1] intValue];
                    
                    pt1.x = [thePoint[2] intValue];
                    pt1.y = [thePoint[3] intValue];
                    
                    
                    
                    //NSLog(@"image processing ");
                    //NSLog(@"pt1.x = %d, pt1.y = %d", pt1.x, pt1.y);
                    //NSLog(@"pt2.x = %d, pt2.y = %d", pt2.x, pt2.y);
                    
                    //Mat image2 = Mat::zeros(400, 400, CV_8UC3);
                    IplImage newImage = image_copy;
                    cvRectangle(&newImage, pt1, pt2, color, CV_FILLED, 0, 0);
                    //cvCircle( &newImage, pt2, 100, color, CV_FILLED, 0, 0);
                } // end if thePoint is not nil
            }  // end if this ROI has frames left to be flashed
            
            
            
            numCircles--;
        }
        cvtColor(image_copy, image, CV_BGR2BGRA);

    }
    
    
    
    if (saveFreq <= 0) {
        // get the save frequence from the singleton; this value
        // is set in the settings view
        saveFreq = [mySharedROI.captureInterval integerValue];
        
        if (!haveStoredImage) {
            // turn current frame gray
            cvtColor(image, newFrame, CV_BGRA2GRAY);
            //pixThreshold = 3.0;
            //threshold(rsltMatrix,rsltMatrixThresh, pixThreshold,255,THRESH_BINARY);
            
            // blur the current frame
            //GaussianBlur(newFrame, newFrameGray, ksize, 0);
            newFrame.copyTo(storedFrame);
            haveStoredImage = true;
            timeStamp = 0;
            NSLog(@"number of channels = %d", newFrame.channels());
            NSLog(@"depth: %d", newFrame.depth());
        }
        else {
            
            // turn current frame gray
            cvtColor(image, newFrame, CV_BGRA2GRAY);
            
            // blur the current frame
            //GaussianBlur(newFrame, newFrameGray, ksize, 0);
            
            // find the differences between this frame and last frame
            //absdiff(storedFrame,newFrame, rsltMatrix);
            
            // for now set threshold at 3 pixels, but we'll calculate this later
            //pixThreshold = 3.0;
            //threshold(rsltMatrix,rsltMatrixThresh, pixThreshold,255,THRESH_BINARY);
            // print the resulting matrix
            
            /*  Idea:  can't look at the int represented by the pixel; this number could change drastically
             based on a small change in color.  Instead look at the rgb values independently.  How do I extract the
             individual colors from a pixel?
             */
            
            // set the timestamp.  The time is the number of frames since the last time we checked differences
            timeStamp += saveFreq;
            
            // put the timestamp into the correct position of the timestamp array
            if (theTimeStamps)
                [theTimeStamps addObject:[[NSNumber alloc] initWithInt:timeStamp] ];
            else
            {
                theTimeStamps = [[NSMutableArray alloc] initWithCapacity:1];
                [theTimeStamps addObject:[[NSNumber alloc] initWithInt:timeStamp]];
            }
            
            int j, k;
            Vec3b storedIntensity, newIntensity;
            // the actual difference in the value of a pixel between this frame and the stored frame
            int diff;
            // the accumulated number of pixels with differences in this ROI
            int recordedDiff;
            int numOfROI = [theROIAreas count];
            NSMutableArray *diffArray = [[NSMutableArray alloc] initWithCapacity: numOfROI];
            
            // store differences for each ROI
            for (int ROIindex = 0; ROIindex < numOfROI; ROIindex++) {
                
                // set the boundaries of this ROI
                // values are stored as: [NSx1,NSy1,NSx2,NSy2];
                int x1 = [[[theROIAreas objectAtIndex:ROIindex] objectAtIndex:0] integerValue];
                int y1 = [[[theROIAreas objectAtIndex:ROIindex] objectAtIndex:1] integerValue];
                int x2 = [[[theROIAreas objectAtIndex:ROIindex] objectAtIndex:2] integerValue];
                int y2 = [[[theROIAreas objectAtIndex:ROIindex] objectAtIndex:3] integerValue];
                
                printf("ROI at x1 = %d y1 = %d and x2 = %d y2 = %d\n", x1,y1, x2, y2);
                
                // reset the number of recorded differences for this ROI 
                recordedDiff = 0;
                int temp;
                if (x1 > x2){
                    temp = x1;
                    x1 = x2;
                    x2 = temp;
                }
                if (y1 > y2){
                    temp = y1;
                    y1 = y2;
                    y2 = temp;
                }
                printf("going into for loops, x1 = %d and x2 = %d\n", x1, x2);
                //for(i = 0; i < rsltMatrix.size().width; i++)
                for (k = x1; k <= x2; k++)
                //for (k = x1; k <= 10; k++)
                {
                    //for (j = 0; j < rsltMatrix.size().height; j++) {
                    for (j = y1; j <= y2; j++) {
                    //for (j = y1; j <= 10; j++) {
                        newIntensity = newFrame.at<int>(k,j);
                        //printf("newFrame:\t\t");
                        //printf("%d \t\t", nIntensity.val[0]);
                        //printf("%d \t\t", nIntensity.val[1]);
                        //printf("%d \n", nIntensity.val[2]);
                        storedIntensity = storedFrame.at<int>(k,j);
                        //printf("storedFrame:\t");
                        //printf("%d \t\t", sIntensity.val[0]);
                        //printf("%d \t\t", sIntensity.val[1]);
                        //printf("%d \n", sIntensity.val[2]);
                        /*
                         rIntensity = rsltMatrixThresh.at<int>(i,j);
                         printf("rsltMatrixThresh:\t");
                         printf("%d \t", rIntensity[0]);
                         printf("%d \t", rIntensity[1]);
                         printf("%d \n", rIntensity[2]);
                         */
                        diff = newIntensity.val[0] - storedIntensity.val[0];
                        if (diff < 0) diff = -diff;
                        if (diff >= Threshold) {
                            recordedDiff++;
                        }  // end for (j = y1....
                        printf("%d ", diff );
                    } // end for (k = x1...
                    printf("\n");
                }
                // now save the number of pixels that are different
                // ROIindex represents the number of the current ROI
                [diffArray insertObject:[[NSNumber alloc]initWithInt: recordedDiff] atIndex:ROIindex];
                // initialize the falshTime array so that this ROI will flash if there was differences
                if (recordedDiff > 0) {
                    [flashTime insertObject:[[NSNumber alloc]initWithInt: 10] atIndex:ROIindex];
                }
                else{
                    [flashTime insertObject:[[NSNumber alloc]initWithInt: 0] atIndex:ROIindex];
                }
                printf("At time %d Recorded number of differences: %d\n", timeStamp, recordedDiff);
                printf("************************************************************************\n");
                
            }  // end for(i = 0; i < numOfROI; i++)
            
            printf("************************************************************************\n");
            
            // Save the array of differences for this time stamp
            if (theValues)
                [theValues addObject:diffArray];
            else
            {
                theValues = [[NSMutableArray alloc] initWithCapacity:1];
                [theValues addObject:diffArray];}
            
            // Current frame becomes the old frame
            newFrame.copyTo(storedFrame);
        }
    
    }

    // convert the image to grayscale
    //cvtColor(image, image_copy, CV_BGRA2GRAY);

    // invert image
    //bitwise_not(image_copy, image_copy);

    /*
    
    CvPoint pt1;
    CvPoint pt2;
    CvScalar color;
    color.val[0] = 200;
    color.val[1] = 200;
    color.val[2] = 0;
    //color.val[3] = 100;
    IplImage newImage;
    //int imageWidth = _videoImage.frame.size.width;
    int imageHeight = _videoImage.frame.size.height;
    
    // check to see whether there are any circles defined

    int numCircles = [theAreas count];
    while (numCircles > 0) {
        
        NSArray* thePoint = [theAreas objectAtIndex:numCircles-1];
        // make sure we got a point from the array
        if (thePoint != nil || [thePoint count] >= 4) {
            
            
            pt2.y = [thePoint[0] intValue] * 2;
            pt2.x = (imageHeight - [thePoint[1] intValue]) * 2;
            
            pt1.y = [thePoint[2] intValue] * 2;
            pt1.x = (imageHeight - [thePoint[3] intValue]) * 2;
            
            //NSLog(@"image processing ");
            NSLog(@"pt1.x = %d, pt1.y = %d", pt1.x, pt1.y);
            //NSLog(@"pt2.x = %d, pt2.y = %d", pt2.x, pt2.y);
            
            //Mat image2 = Mat::zeros(400, 400, CV_8UC3);
            newImage = image_copy;
            cvRectangle(&newImage, pt1, pt2, color, CV_FILLED, 0, 0);
            //cvCircle( &newImage, pt2, 100, color, CV_FILLED, 0, 0);
        }
        numCircles--;
    }
     */
    
    //cvtColor(image_copy, image, CV_BGR2BGRA);
}


#pragma mark - image manipulation methods

#endif

@end
