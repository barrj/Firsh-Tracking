//
//  ViewController.m
//  testOpenCV_3
//
//  Created by John Barr on 10/3/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "ViewController.h"

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/core/core_c.h>
#endif

#import <opencv2/highgui/cap_ios.h>

#import "sharedROI.h"

using namespace cv;

@interface ViewController ()
{
    BOOL videoIsOn;
    Mat staticImage;
    int videoFrameOffset_X;
    int videoFrameOffset_Y;
}

@property (nonatomic, retain) CvVideoCamera* videoCamera;

@end

@implementation ViewController

#pragma mark - view controllers

- (void)viewDidLoad {
    [super viewDidLoad];
    // set up the gesture recognizer
    //UIPanGestureRecognizer *panImage = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
   // [self.videoImage addGestureRecognizer:panImage];
    
    //didCapture = false;
    videoIsOn = false;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if (!_videoCamera) {
        [self createVideoCamera];
    }
    if (videoIsOn) {
        [self.videoCamera start];
    }
    else {
        [self.videoCamera stop];
        }
    // initialize the array that contains the circles
    // We get the array from the singleton.
    // If the array does not yet exist, the singleton will create it
    if (theAreas == nil){
        mySharedROI = [sharedROI sharedROI];
        theAreas = mySharedROI.theROI;
    }
    
    // Debug:  find dimensions
    CGFloat thisViewWidth = self.view.frame.size.width;
    CGFloat thisViewHeight = self.view.frame.size.height;
    NSLog(@"The container's width = %f and height = %f",thisViewWidth, thisViewHeight);
    NSLog(@"The video's x = %f and y = %f", _videoImage.frame.origin.x, _videoImage.frame.origin.y);
    NSLog(@"The video's width = %f and height = %f", _videoImage.frame.size.width, _videoImage.frame.size.height);
    
    videoFrameOffset_X = _videoImage.frame.origin.x;
    videoFrameOffset_Y = _videoImage.frame.origin.y;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    // make sure that we're in portrait mode
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_videoCamera stop];
    _videoCamera = nil;
    
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
    NSLog(@"received memory waring in Mask view");
}

- (void) createVideoCamera{
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_videoImage];
    //self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    [self.videoCamera adjustLayoutToInterfaceOrientation: UIInterfaceOrientationPortrait];
    
    self.videoCamera.delegate = self;
}


#pragma mark - action methods

- (IBAction)startVideo:(id)sender {
    [self.videoCamera start];
    videoIsOn = true;
}

- (IBAction)saveMask:(id)sender {
    if (!theAreas || [theAreas count] == 0) {
        NSString *msg = @"No Mask to Save!";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Save Error!"
                              message:msg
                              delegate:nil
                              cancelButtonTitle:@"ok!"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /* no longer need to set this variable since we're not creating a grayscale mask
    if (!didCapture) {
       //UIImage* theMask = [self UIImageFromCVMat:staticImage];
        //_videoImage.image = theMask;
       //  [_videoImage setImage:theMask];
        didCapture = true;
    }
     */
    
    if (mySharedROI == nil) {
        mySharedROI = [sharedROI sharedROI];
    }
    [mySharedROI setTheROI: theAreas];
    // initialize the array containing the changes in the ROI
    // set the capacity to 1 because each entry is a different time of capture of differences
    // Each entry will be an array of [theAreas count] + 1 size.
    [mySharedROI setTheData:[[NSMutableArray alloc] initWithCapacity: 1]];
    //  Also initialize the array that contains the timestamps of each entry in the array
    // containing the chnages in the ROI
    [mySharedROI setTheTimeStamps:[[NSMutableArray alloc] initWithCapacity: 1]];
    
    if ([theAreas count] == 1) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Do you want to select rows and colunns?" delegate:self cancelButtonTitle:@"No use one ROI" destructiveButtonTitle:@"Yes set rows and cols" otherButtonTitles:nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
    }
    else{
        _saveView.hidden = NO;
    }
    
}

- (IBAction)clearMask:(id)sender {
    // clear all the ROI from theAreas
    if (!theAreas) {
        NSLog(@"in clearMask, theAreas does not exist!");
    }
    else{
        [theAreas removeAllObjects];
    }
    
    if (mySharedROI == nil) {
        mySharedROI = [sharedROI sharedROI];
    }
    // set the saved mask in the singleton to the cleared array
    [mySharedROI setTheROI: theAreas];
    // initialize the array containing the changes in the ROI to empty
    NSMutableArray *tempValues = mySharedROI.theData;
    [tempValues removeAllObjects];
    [mySharedROI setTheData:tempValues];
    // reinitialize the timeStamp array also
    tempValues = mySharedROI.theTimeStamps;
    [tempValues removeAllObjects];
    [mySharedROI setTheTimeStamps:tempValues];
     
    if (!videoIsOn) {
        videoIsOn = true;
    }
    if (_videoCamera){
        [_videoCamera stop];
        [_videoCamera start];
    }
    else{
        [self createVideoCamera];
        [_videoCamera start];
    }
    
   // NSLog(@"Singleton.  theValues count = %lu theROI count = %lu the timeStamps count = %lu", (unsigned long)[mySharedROI.theROI count], (unsigned long)[mySharedROI.theData count], (unsigned long)[mySharedROI.theTimeStamps count]);
    
}

// called when the user wants to save the mask
- (IBAction)saveButtonPressed:(id)sender {
    
    NSString *msg; // the message for the action sheet/alert box
    BOOL isDirectory;
    // get the path to all of the directories used by this app
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // the first directory is always the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // ok, now we can get the file name
    NSString *fileName = _saveTextField.text;
    
    // check to see if the file already exists
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"ROI"];
    
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
        [self writeMaskToFile];
    }
    
}

- (IBAction)cancelSaveButtonPressed:(id)sender {
    _saveView.hidden = true;
}

// This function actually saves the file
- (void) writeMaskToFile{
    NSArray *nextROI;
    NSString *currentRow;
    
    // get the path to all of the directories used by this app
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // the first directory is always the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // We save all files in the directory Documents/ROI so add the ROI part
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"ROI"];
    
    // ok, now we can get the file name
    NSString *fileName = _saveTextField.text;
    // we can assume that the folder ROI exists because we created it in saveButtonPressed
    NSString* saveFilePath = [folderPath stringByAppendingPathComponent:fileName];
    
    
    NSLog(@"in writeMaskToFile: filename is %@", saveFilePath);
    
    
    // Turn the mask ROI into a string
    currentRow = @"";
    for (int i = 0; i < [theAreas count]; i++) {
        nextROI = [theAreas objectAtIndex:i];
        for (int j = 0; j < [nextROI count]; j++) {
            currentRow = [NSString stringWithFormat:@"%@ %ld", currentRow, (long)[[nextROI objectAtIndex:j] integerValue]];
        }
        currentRow = [NSString stringWithFormat:@"%@\n", currentRow];
    }
    [currentRow writeToFile: saveFilePath atomically: YES encoding: NSUTF32StringEncoding error: nil];
    
    _saveView.hidden = true;
}


// this method is called by the "set" button on the actionsheet that
// appears to ask if the user wants to enter a number of rows and columns
// The user has entered a number of rows and columns, we have to create the
// appropriate mask.
- (IBAction)addRowsCols:(UIButton *)sender {
    
    
    int i,j;
    int horizPadding = 3;  // number of pixels around the sides of an ROI
    int vertPadding = 3;  // number of pixels around the sides of an ROI
    int startX = 0; // starting x and y for the new masks
    int startY = 0;
    
    // get rid of the number pad
    [self.rowsTextField resignFirstResponder];
    [self.colsTextField resignFirstResponder];
    
    /* don't want the screen dimensions but the view dimensions
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
     */
    
//    CGFloat viewWidth = self.view.frame.size.width;
//    CGFloat viewHeight = self.view.frame.size.height;
    // This would have the ROI fill the video

    
    int pt1x = [[[theAreas objectAtIndex:0] objectAtIndex:0] integerValue];
    int pt2x = [[[theAreas objectAtIndex:0]objectAtIndex:2] integerValue];
    int pt1y = [[[theAreas objectAtIndex:0] objectAtIndex:1] integerValue];
    int pt2y =[[[theAreas objectAtIndex:0]objectAtIndex:3] integerValue];
    
    int viewWidth = pt1x - pt2x;
    int viewHeight = pt1y - pt2y;
    if (viewWidth < 0) {
        viewWidth = -viewWidth;
    }
    if (viewHeight < 0) {
        viewHeight = -viewHeight;
    }
    
    if (pt1x > pt2x) {
        startX = pt2x;
        startY = pt2y;
    }
    else{
        startX = pt1x;
        startY = pt1y;
    }
    
    
    
    [self clearMask:self];
    
    int rows = [_rowsTextField.text integerValue];
    int cols = [_colsTextField.text integerValue];
    if (rows == 0 || cols == 0) {
        NSString *msg = @"Non numeric value in field!";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Entry Error!"
                              message:msg
                              delegate:nil
                              cancelButtonTitle:@"ok!"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Create the appropriate ROI and store in the array "theArrays".
    // Then can save theArrays by calling saveMask
    // Note that x1, y1, x2, y2 are class properties
    // We subtract 20 from the view width because the camera doesn't seem to use all of the parent image
    int horizWidth = (viewWidth - 20) / cols - 2 * horizPadding;
    int vertHeight = (viewHeight) / rows - 2 * vertPadding;
    
    
    //fprintf(stderr, "view width = %f view height = %f\n\n", viewWidth, viewHeight);
    //fprintf(stderr, "horizWidth = %d vertHeight = %d \n\n", horizWidth, vertHeight);
    
    if (horizWidth <= 0 || vertHeight <= 0) {
        NSString *msg = @"Too many rows or columns!";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Entry Error!"
                              message:msg
                              delegate:nil
                              cancelButtonTitle:@"ok!"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    x1 = startX + horizPadding;
    y1 = startY + vertPadding;
    x2 = x1 + horizWidth;
    y2 = y1 + vertHeight;
    
    for (i = 0; i < rows; i++) {
        for (j = 0; j < cols; j++) {
            
            printf("x1 = %.4f y1 = %.4f \n x2 = %.4f y2 = %.4f \n\n", x1, y1, x2, y2);
            
            NSNumber* NSx1 = [NSNumber numberWithFloat:x1];
            NSNumber* NSy1 = [NSNumber numberWithFloat:y1];
            NSNumber* NSx2 = [NSNumber numberWithFloat:x2];
            NSNumber* NSy2 = [NSNumber numberWithFloat:y2];
            NSArray* newArray = @[NSx1,NSy1,NSx2,NSy2];
            
            [theAreas addObject:newArray];
            
            x1 = x2 + horizPadding;
            x2 = x1 + horizWidth;
        }
        y1 = y2 + vertPadding;
        y2 = y1 + vertHeight;
        x1 = startX + horizPadding;
        x2 = x1 + horizWidth;
    }
    
    [self saveMask:self];
    
    
    // get the rows and columns, create the ROI, let the user know that the rows and cols are set
        NSString *msg = [ @"You entered " stringByAppendingFormat:
                     @" %@ rows and %@ columns", _rowsTextField.text, _colsTextField.text];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Set Rows and Cols"
                          message:msg
                          delegate:nil
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil];
    [alert show];
    
   
    
    _rowColView.hidden = YES;
    //_saveView.hidden = NO;
    
}

// this method is called by the cancel button on the actionsheet that
// appears to ask if the user wants to enter a number of rows and columns
// The user has canceled, so let her know that the mask will be left with
// just the one ROI.
- (IBAction)noAddRowsCols:(UIButton *)sender {
    
    // get rid of the number pad
    [self.rowsTextField resignFirstResponder];
    [self.colsTextField resignFirstResponder];
    
    // let the user know that we're only keeping the one ROI
    // Note that the one ROI was set before this dialog box was shown
    // so we don't have to create it now.
    NSString *msg = nil;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Left Mask with one ROI"
                          message:msg
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
    _rowColView.hidden = YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex])
    {
        if (actionSheet.tag == 1) {
            _rowColView.hidden = NO;
        }
        else{
            [self writeMaskToFile];
        }
        
    }
}

-(IBAction)textFieldDoneEditing:(id)sender{
    [self.rowsTextField resignFirstResponder];
    [self.colsTextField resignFirstResponder];
    [self.saveTextField resignFirstResponder];
}


#pragma mark - touch recognizors



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([touch view] == _videoImage) {
        
        // this might need to be self.view
        CGPoint location = [touch locationInView: _videoImage];
        
        x1 = location.x; // - videoFrameOffset_X;
        y1 = location.y; // - videoFrameOffset_Y;
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Triggered when touch is released
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([touch view] == _videoImage) {
        
        // this might need to be self.view
        CGPoint location = [touch locationInView: _videoImage];
        
        x2 = location.x; // - videoFrameOffset_X;
        y2 = location.y; // - videoFrameOffset_Y;
        
        NSLog(@"original: \n x1 = %f y1 = %f \n x2 = %f y2 = %f", x1, y1, x2, y2);
        
        // convert the CGFloat numbers to NSNumbers so that we can store them in an NSArray
        // CGFloat is not considered an object and cannot be stored in an NSArray
        NSNumber* NSx1 = [NSNumber numberWithFloat:x1];
        NSNumber* NSy1 = [NSNumber numberWithFloat:y1];
        NSNumber* NSx2 = [NSNumber numberWithFloat:x2];
        NSNumber* NSy2 = [NSNumber numberWithFloat:y2];
        NSArray* newArray;
        // translate the points so that they represent the upper left hand corner and the lower right hand corner
        if (NSx1 >= NSx2 && NSy1 >= NSy2)
        {
            newArray = @[NSx2,NSy2,NSx1,NSy1];
        }
        else if (NSx1 >= NSx2 && NSy1 <= NSy2){
                newArray = @[NSx2,NSy1,NSx1,NSy2];
        }
        else if (NSx1 <= NSx2 && NSy1 >= NSy2){
                newArray = @[NSx1,NSy2,NSx2,NSy1];
        }
        else{
            newArray = @[NSx1,NSy1,NSx2,NSy2];
        }
        
        [theAreas addObject:newArray];
        
        //NSLog(@"x1 = %f y1 = %f x2 = %f y2 = %f", x1, y1, x2, y2);
        NSLog(@"New: \n NSx1 = %d NSy1 = %d \n NSx2 = %d NSy2 = %d", [NSx1 intValue], [NSy1 intValue], [NSx2 intValue], [NSy2 intValue]);
        
    }

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Triggered if touch leaves view
    // Need to get rid of inital touch down values
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Triggered when touch moves within a view
    // Need to get rid of inital touch down values
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    // Do some OpenCV stuff with the image
    Mat image_copy;
    IplImage newImage;
    
    cvtColor(image, image_copy, CV_BGRA2BGR);
    // convert the image to grayscale
    //cvtColor(image, image_copy, CV_BGRA2GRAY);
    
    // invert image
    //bitwise_not(image_copy, image_copy);
    
    CvPoint pt1;
    CvPoint pt2;
    CvScalar color;
    color.val[0] = 200;
    color.val[1] = 200;
    color.val[2] = 0;
    //color.val[3] = 100;
    //int imageWidth = _videoImage.frame.size.width;
    //int imageHeight = _videoImage.frame.size.height;
    
    // check to see whether there are any circles defined
    int numCircles = (int)[theAreas count];
    while (numCircles > 0) {
        // note a race condition here.  If we're in this while loop and
        // the user clicks "clear", then suddenly theArray will be empty!
        if ([theAreas count] <= 0) {
            break;
        }
        NSArray* thePoint = [theAreas objectAtIndex:numCircles-1];
        // make sure we got a point from the array
        // theAreas is initialized to 1 element, but this will be nil
        if (thePoint != nil || [thePoint count] >= 4) {

            
            pt1.x = [thePoint[0] intValue];
            pt1.y = [thePoint[1] intValue];
            
            pt2.x = [thePoint[2] intValue];
            pt2.y = [thePoint[3] intValue];
            
        
            
            NSLog(@"image processing: ");
            NSLog(@"pt1.x = %d, pt1.y = %d", pt1.x, pt1.y);
            NSLog(@"pt2.x = %d, pt2.y = %d", pt2.x, pt2.y);
            
            /* draw transparent rectangles */
            /* opencv hack.  To draw the rectangle on an image, the
             * type of the image must be IplImage so we create a copy
             * of the current image and make newImage, a IplImage, point
             * to it.  But to use addWeighted, we must have two Mats
             * so we pass tempImage which is of type Mat.  But tempImage
             * was changed when newImage had rectangles added to it.
             */
            Mat tempImage;
            image_copy.copyTo(tempImage);
            newImage = tempImage;
            cvRectangle(&newImage, pt1, pt2, color, CV_FILLED, 0, 0);
            /* addWeighted adds two images together.  The first 0.5 is
             * the weight of the first melded image, teh second 0.5 is
             * the weight of the second melded image.  The 0.0 is a
             * constant added to both.  The last image is the destination.
             */
            addWeighted(tempImage, 0.4,image_copy, 0.6, 0.0, image_copy);
            // use this line to make circles.  Eventually can give user a choice
            //cvCircle( &newImage, pt2, 100, color, CV_FILLED, 0, 0);
            
        }
        
        /* make squares that are transparent */
        
        
        /* can't get this to work; I suspect that image_copy is null in some situation but can't
           figure out how to test for this.  */
         
        //if (pt1.x > 0 && pt1.y > 0 && pt2.x > 0 && pt2.y > 0 && countNonZero(image_copy) > 1) {
        
        /*
         double alpha = 0.5;
        if (pt1.x > 0 && pt1.y > 0 && pt2.x > 0 && pt2.y > 0) {
            cv::Mat image = image_copy;
            if (image.rows <= 0 || image.cols <= 0)
                break;
            NSLog(@"creating ROI");
            cv::Mat roi = image(cv::Rect(pt1, pt2));
            //color: colored rectangle
            cv::Mat color(roi.size(), CV_8UC3, cv::Scalar(0, 125, 125));
            //blend colored rectangle with roi
            cv::addWeighted(color, alpha, roi, 1.0 - alpha , 0.0, roi);
            
        }
         */
        
        /* end add transparent squares */
        
        numCircles--;
    }
    
    /*
     The variable didCapture is set to True when the "save" button is clicked.
     When set, we capture the current frame with the ROI drawn on it, stop the
     video from running, and set the mask as the image.  Note that we have to rotate the mask.
     
     TODO:  if we make the static image a class variable can we keep from re-copying it?  Might save time.
     */
    /*  This code will create a grayscale mask; very slow!!
    if (didCapture) {
        cvtColor(image_copy, staticImage, CV_BGRA2GRAY);
        didCapture = false;
        UIImage* theMask = [self UIImageFromCVMat:staticImage];
       // _videoImage.image = theMask;
        
        // must rotate the image before putting it in the imageview
        // UIImage* rotatedMask = [UIImage imageWithCGImage:theMask.CGImage scale:theMask.scale orientation UIImageOrientationLeft];
        // stop video and set image to mask
         [self.videoCamera stop];
        videoIsOn = false;
        [_videoImage setImage:theMask];
    }
     */
    
    cvtColor(image_copy, image, CV_BGR2BGRA);
}

#pragma mark - image manipulation methods



-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
#endif

@end
