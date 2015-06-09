//
//  lineGraphViewController.m
//  testOpenCV_3
//
//  Created by John Barr on 12/4/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "lineGraphViewController.h"

#import "EFloatBox.h"
#import "EColor.h"

#include <stdlib.h>

@interface lineGraphViewController ()
    
    @property (strong, nonatomic) NSArray *eLineChartData;

    @property (nonatomic) float eLineChartScale;
    @property (nonatomic, strong) UIColor *tempColor;

@end

@implementation lineGraphViewController

@synthesize eLineChart = _eLineChart;
@synthesize eLineChartData = _eLineChartData;
@synthesize numberTaped = _numberTaped;
@synthesize eLineChartScale = _eLineChartScale;


BOOL lineDataExists;

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Listen for oreientation chagnes
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    // eChart initialization
//     NSMutableArray *temp = [NSMutableArray array];
//    for (int i = 0; i < 50; i++)
//    {
//        int value = arc4random() % 100;
//        EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:[NSString stringWithFormat:@"%d", i] value:value index:i unit:@"pixel"];
//        [temp addObject:eColumnDataModel];
//    }
//    _data = [NSArray arrayWithArray:temp];
//    
//    
//    _eColumnChart = [[EColumnChart alloc] initWithFrame:CGRectMake(40, 100, 250, 180)];
//    //[_eColumnChart setNormalColumnColor:[UIColor purpleColor]];
//    [_eColumnChart setColumnsIndexStartFromLeft:YES];
//    [_eColumnChart setDelegate:self];
//    [_eColumnChart setDataSource:self];
//    
//    [self.view addSubview:_eColumnChart];
    
}

- (void) viewWillAppear:(BOOL)animated{
    // initialize the array that contains the circles
    if (theValues == nil || mySharedROI == nil){
        mySharedROI = [sharedROI sharedROI];
    }
    // either theValues was created or zeroed out in the mask view
    // or we saved it when we left this view
    // either way, we get theValues from the singleton
    theValues = mySharedROI.theData;
    if (!theValues || [theValues count] < 1) {
        lineDataExists = false;
    }
    else{
        lineDataExists = true;
    }
    // get the timestamp array from the singleton
    theTimeStamps = mySharedROI.theTimeStamps;
    [self initPlot];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearPlot];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    [self clearPlot];
    [self initPlot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) clearPlot{
    [_eLineChart removeFromSuperview];
    _eLineChart = nil;
}

- (void) initPlot{
    // Make the chart
    NSMutableArray *temp = [NSMutableArray array];
    NSMutableArray *pixelChanges = [NSMutableArray array];  // array holds all the pixel changes for each ROI
    int numCols;
    if (!lineDataExists) {
        numCols = 1;
    }
    else{
        // big assumption:  if dataExists then there is an item at index 0!
        numCols = (int)[[theValues objectAtIndex:0]  count];
    }
    
    // for the line chart
    _eLineChartScale = 1;
    
    //  use these variables for getting the column values
    int limit;  // limit will contain the number of timestamps
    int sum;  // sum will contain the total pixel changes for a given ROI
    NSNumber *sumObj;  // sumObj will contain the sum converted into a NSNumber
    
    // now get the total number of pixel changes for each ROI
    for (int ROIindex = 0; ROIindex < numCols; ROIindex++){
        
        limit = [theValues count];
        sum = 0;
        
        // I think I'm doing this wrong.  I'm adding all the values in all the ROI at this
        // timestamp.  I think I want to add all the values for all timestamps for the ROI at
        // index
        // check to see if we actually have some data
        if (limit == 0){
            sumObj = [NSNumber numberWithInt:1];
        }
        else{
            for (int i = 0; i < limit; i++) {
                //sum += [[ROIarray objectAtIndex:i] integerValue];
                sum += [[[theValues objectAtIndex:i] objectAtIndex:ROIindex] integerValue];
                sumObj = [NSNumber numberWithInt:sum];
            }
        }
        [pixelChanges addObject:sumObj];
    }
    
    for (int i = 0; i < numCols; i++)
    {
        //int number = arc4random() % 100;
        ELineChartDataModel *eLineChartDataModel = [[ELineChartDataModel alloc] initWithLabel:[NSString stringWithFormat:@"%d", i] value:[[pixelChanges objectAtIndex:i] floatValue] index:i unit:@"pixel"];
        [temp addObject:eLineChartDataModel];
    }
    _eLineChartData = [NSArray arrayWithArray:temp];
    
    
    /** The Actual frame for the line is half height of the frame you specified, because the bottom half is for the touch control, but it's empty */
    //_eLineChart = [[ELineChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 400)];
   // _eLineChart = [[ELineChart alloc] initWithFrame:CGRectMake(0, 150, CGRectGetWidth(self.view.frame), 300)];
    _eLineChart = [[ELineChart alloc] initWithFrame:CGRectMake(0, 125, CGRectGetWidth(self.view.frame), 300)];
    NSLog(@"screen height is %f", CGRectGetHeight(self.view.frame));
    //[_eLineChart setELineIndexStartFromRight: YES];
    [_eLineChart setDelegate:self];
    [_eLineChart setDataSource:self];
    [self.view addSubview:_eLineChart];
}

#pragma -mark- ELineChart DataSource
- (NSInteger) numberOfPointsInELineChart:(ELineChart *) eLineChart
{
    return [_eLineChartData count];
}

- (NSInteger) numberOfPointsPresentedEveryTime:(ELineChart *) eLineChart
{
    //    NSInteger num = 20 * (1.0 / _eLineChartScale);
    //    NSLog(@"%d", num);
    return 20;
}

- (ELineChartDataModel *)     highestValueELineChart:(ELineChart *) eLineChart
{
    ELineChartDataModel *maxDataModel = nil;
    float maxValue = -FLT_MIN;
    for (ELineChartDataModel *dataModel in _eLineChartData)
    {
        if (dataModel.value > maxValue)
        {
            maxValue = dataModel.value;
            maxDataModel = dataModel;
        }
    }
    return maxDataModel;
}

- (ELineChartDataModel *)     eLineChart:(ELineChart *) eLineChart
                           valueForIndex:(NSInteger)index
{
    if (index >= [_eLineChartData count] || index < 0) return nil;
    return [_eLineChartData objectAtIndex:index];
}

#pragma -mark- ELineChart Delegate

- (void)eLineChartDidReachTheEnd:(ELineChart *)eLineChart
{
    NSLog(@"Did reach the end");
}

- (void)eLineChart:(ELineChart *)eLineChart
     didTapAtPoint:(ELineChartDataModel *)eLineChartDataModel
{
    NSLog(@"%d %f", eLineChartDataModel.index, eLineChartDataModel.value);
    [_numberTaped setText:[NSString stringWithFormat:@"%.f", eLineChartDataModel.value]];
    
}

- (void)    eLineChart:(ELineChart *)eLineChart
 didHoldAndMoveToPoint:(ELineChartDataModel *)eLineChartDataModel
{
    [_numberTaped setText:[NSString stringWithFormat:@"%.f", eLineChartDataModel.value]];
}

- (void)fingerDidLeaveELineChart:(ELineChart *)eLineChart
{
    
}

- (void)eLineChart:(ELineChart *)eLineChart
    didZoomToScale:(float)scale
{
    //    _eLineChartScale = scale;
    //    [_eLineChart removeFromSuperview];
    //    _eLineChart = nil;
    //    _eLineChart = [[ELineChart alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 300)];
    //	[_eLineChart setDelegate:self];
    //    [_eLineChart setDataSource:self];
    //    [self.view addSubview:_eLineChart];
}

#pragma -mark- Actions

- (IBAction)chartDirectionChanged:(id)sender
{
    UISwitch *mySwith = (UISwitch *)sender;
    if ([mySwith isOn])
    {
        NSLog(@"switch is on");
        [_eLineChart removeFromSuperview];
        _eLineChart = nil;
        _eLineChart = [[ELineChart alloc] initWithFrame:CGRectMake(0, 150, CGRectGetWidth(self.view.frame), 300)];
        [_eLineChart setELineIndexStartFromRight:YES];
        [_eLineChart setDelegate:self];
        [_eLineChart setDataSource:self];
        [self.view addSubview:_eLineChart];
    }
    else
    {
        NSLog(@"switch is OFF");
        [_eLineChart removeFromSuperview];
        _eLineChart = nil;
        _eLineChart = [[ELineChart alloc] initWithFrame:CGRectMake(0, 150, CGRectGetWidth(self.view.frame), 300)];
        [_eLineChart setDelegate:self];
        [_eLineChart setDataSource:self];
        [self.view addSubview:_eLineChart];
    }
}

@end
