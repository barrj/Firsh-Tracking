		//
//  ViewController.m
//  testOpenCV_3
//
//  Created by John Barr on 10/3/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "SettingsViewController.h"

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/core/core_c.h>
#endif

#import <opencv2/highgui/cap_ios.h>

#import "sharedROI.h"

using namespace cv;

@interface SettingsViewController ()
{
    BOOL didCapture;
    BOOL videoIsOn;
}

@property (nonatomic, retain) CvVideoCamera* videoCamera;

@end

@implementation SettingsViewController

#pragma mark - view controllers

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initialize the array that contains the circles
    // We get the arry from the singleton.
    // If the array does not yet exist, the singleton will create it
    if (theAreas == nil){
        mySharedROI = [sharedROI sharedROI];
        theAreas = mySharedROI.theROI;
    }
    
    didCapture = false;
    videoIsOn = false;
}

- (void)viewDidAppear:(BOOL)animated
{
    _threshold.text = [NSString stringWithFormat:@"%@", mySharedROI.thresh];
    _interval.text = [NSString stringWithFormat:@"%@", mySharedROI.captureInterval];

}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - action methods

- (IBAction)textFieldDoneEditing:(id)sender {
    [_interval resignFirstResponder];
    [_threshold resignFirstResponder];
}

- (IBAction)updateSettings:(id)sender {
    NSString *newThresh = _threshold.text;
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([newThresh rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        // newString consists only of the digits 0 through 9
         mySharedROI.thresh = [[NSNumber alloc] initWithInteger:[newThresh integerValue]];
    }
    else{
        UIAlertView *invalidNumber = [[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Threshold value must contain only digits" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [invalidNumber show];
    }
    
    NSString *newInterval = _interval.text;
    if ([newInterval rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        // newString consists only of the digits 0 through 9
        mySharedROI.captureInterval = [[NSNumber alloc] initWithInteger:[newInterval integerValue]];
    }
    else{
        UIAlertView *invalidNumber = [[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Interval value must contain only digits" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [invalidNumber show];
    }
    NSString *msg = [NSString stringWithFormat:@"thresh set to %@ and interval to %@", mySharedROI.thresh, mySharedROI.captureInterval];
    UIAlertView *changedSettings = [[UIAlertView alloc] initWithTitle:@"Changed" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [changedSettings show];
    
    NSLog(@"set threshold to be %d and interval to be %d", [mySharedROI.thresh integerValue], [mySharedROI.captureInterval integerValue]);
}
@end
