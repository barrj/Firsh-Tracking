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

#import "LoadViewController.h"

#import "sharedROI.h"

@interface LoadViewController ()
{
    int timeStamp;
}

@end

@implementation LoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self loadMasks];
}

- (void)viewWillAppear:(BOOL)animated
{
    // initialize the array that contains the circles
    if (theROIAreas == nil || mySharedROI == nil){
        mySharedROI = [sharedROI sharedROI];
    }
    // update the ROI
    theROIAreas = mySharedROI.theROI;
    // either theValues was created or zeroed out in the mask view
    // or we saved it when we left this view
    // either way, we get theValues from the singleton
    theValues = mySharedROI.theData;
    // get the timestamp array from the singleton
    theTimeStamps = mySharedROI.theTimeStamps;
    // get the ROI from the singleton
    theROIAreas = mySharedROI.theROI;
    
    // empty out the selected value
    selectedFile = @"";
    
    // load the file names of the masks
    [self loadMasks];
    
    // make sure that we're in portrait mode
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
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

#pragma mark - action methods
- (IBAction)textFieldDoneEditing:(id)sender {
    [_emailTextField resignFirstResponder];
}

#pragma mark - datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [theMaskFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSString* fileName = [theMaskFiles objectAtIndex:indexPath.row];
    cell.textLabel.text = fileName;
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowValue = [theMaskFiles objectAtIndex:indexPath.row];
    NSString *message = [[NSString alloc] initWithFormat:
                         @"You selected %@", rowValue];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Row Selected!"
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Yes I Did"
                          otherButtonTitles:nil];
    [alert show];
    
    selectedFile = [theMaskFiles objectAtIndex:indexPath.row];
}

#pragma mark - local methods

-(void) loadMasks
{
    BOOL isDirectory;
    // get the path to all of the directories used by this app
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // the first directory is always the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // check to see if the file already exists
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"CAP"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    
    if (![manager fileExistsAtPath:folderPath isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
        [manager createDirectoryAtPath:folderPath
           withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
        if (error)
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
    }
    
    theMaskFiles = [manager contentsOfDirectoryAtPath:folderPath error:Nil];
    
    [_tableView reloadData];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)sendButtonPressed:(UIButton *)sender {
    NSString *msg;
    if ([selectedFile  isEqual: @""]) {
        msg = @"Select a file before sending";
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Send Problem!"
                              message:msg
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];

    }
    else {
        // see if the file exists
        NSString *msg; // the message for the action sheet/alert box
        BOOL isDirectory;
        // get the path to all of the directories used by this app
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        // the first directory is always the document directory
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        // check to see if the file already exists
        NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"CAP"];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:folderPath isDirectory:&isDirectory] || !isDirectory) {
            msg = @"Cannot find capture directory!";
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Send Problem!"
                                  message:msg
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        else{
        
            // check to see if the file already exists
            NSString* saveFilePath = [folderPath stringByAppendingPathComponent:selectedFile];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:saveFilePath];
            
            
            NSLog(@"saveButtonPressed:  filename stored at %@", saveFilePath);
            
            if (!fileExists) {
                msg = [NSString stringWithFormat:@"File %@ does not exist!", selectedFile];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Send Problem!"
                                      message:msg
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
            }
            else{
                // open the file
                NSError* myError = nil;
                //NSString* body = [NSString stringWithContentsOfFile:saveFilePath encoding:NSUTF8StringEncoding error:&myError];
                
                NSString* body = [NSString stringWithContentsOfFile:saveFilePath
                                                           encoding:NSUTF32StringEncoding
                                                              error:&myError];
                
                NSLog(@"body of email is %@  with error %@", body, myError);
                NSString *theAddress = _emailTextField.text;
                
                NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
                                        [theAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                        [@"Capture" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                        [body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
            }
        }
    }
}
@end
