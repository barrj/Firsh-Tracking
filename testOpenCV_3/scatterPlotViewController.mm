//
//  AnalysisViewController.m
//  testOpenCV_3
//
//  Created by John Barr on 12/2/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "AnalysisViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "CPDConstants.h"
#import "CPDStockPriceStore.h"
#import "CPTGraphHostingView.h"

#import "scatterPlotViewController.h"

@interface scatterPlotViewController ()
{
    BOOL dataExists;
    float saveFreq;
}
@property (nonatomic, strong) CPTTheme *selectedTheme;


-(void)initPlot;
-(void)configureHost;
-(void)configureGraph;
//-(void)configureChart;
//-(void)configureLegend;
-(void)clearPlot;

@end

@implementation scatterPlotViewController

@synthesize hostView = hostView_;

#pragma mark - UIViewController lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Listen for oreientation chagnes
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    // initialize the array that contains the circles
    if (theValues == nil || mySharedROI == nil){
        mySharedROI = [sharedROI sharedROI]; 
    }
    // either theValues was created or zeroed out in the mask view
    // or we saved it when we left this view
    // either way, we get theValues from the singleton
    theValues = mySharedROI.theData;
    if (!theValues || [theValues count] < 1) {
        dataExists = false;
    }
    else{
        dataExists = true;
    }
    // get the timestamp array from the singleton
    theTimeStamps = mySharedROI.theTimeStamps;
    // get the time interval for setting the Y-axis
    saveFreq = [mySharedROI.captureInterval floatValue];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // The plot is initialized here, since the view bounds have not transformed for landscape until now
    [self initPlot];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self clearPlot];
}

/*  This doesn't work.  I think the Tab Controller has to do this; orientation changes go there first
- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    //return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    return UIInterfaceOrientationMaskLandscape;
*/

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    [self clearPlot];
    [self initPlot];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    self.hostView.allowPinchScaling = YES;
    [self.view addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = @"ROI changes";
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 2 - create the plots
    int i;
    NSMutableArray *plotSet = [[NSMutableArray alloc] initWithCapacity: 1];
    CPTScatterPlot *tempPlot;
    CPTColor *tempColor;
    NSMutableArray *colorArray =[[NSMutableArray alloc] initWithCapacity: 1];
    
    if (dataExists) {
        for (i = 0; i < [[theValues objectAtIndex:0] count]; i++) {
            tempPlot = [[CPTScatterPlot alloc] init];
            tempPlot.dataSource = self;
            tempPlot.identifier = [NSString stringWithFormat:@"%d",i];
            
            if (i == 0) {
                [colorArray addObject:[CPTColor whiteColor]];
            }
            else if (i%15 == 0){
                [colorArray addObject:[CPTColor redColor]];
            }
            else if (i%14==0) {
                [colorArray addObject:[CPTColor whiteColor]];
            }
            else if (i%13==0) {
                [colorArray addObject: [CPTColor lightGrayColor]];
            }
            else if (i%12==0) {
                [colorArray addObject: [CPTColor grayColor]];
            }
            else if (i%11==0) {
                [colorArray addObject: [CPTColor darkGrayColor]];
            }
            else if (i%10==0) {
                [colorArray addObject: [CPTColor blackColor]];
            }
            else if (i%9==0) {
                [colorArray addObject:[CPTColor greenColor]];
            }
            else if (i%8==0) {
                [colorArray addObject: [CPTColor blueColor]];
            }
            else if (i%7==0) {
                [colorArray addObject: [CPTColor cyanColor]];
            }
            else if (i%6==0) {
                [colorArray addObject: [CPTColor yellowColor]];
            }
            else if (i%5==0) {
                [colorArray addObject: [CPTColor magentaColor]];
            }
            else if (i%4==0) {
                [colorArray addObject: [CPTColor orangeColor]];
            }
            else if (i%3==0) {
                [colorArray addObject: [CPTColor purpleColor]];
            }
            else if (i%2==0) {
                [colorArray addObject: [CPTColor brownColor]];
            }
            else {
                [colorArray addObject: [CPTColor redColor]];
            }
            
            
            [graph addPlot:tempPlot toPlotSpace:plotSpace];
            [plotSet addObject:tempPlot];
        }
    }
    else{
        tempPlot = [[CPTScatterPlot alloc] init];
        tempPlot.dataSource = self;
        tempPlot.identifier = [NSString stringWithFormat:@"%d",0];
        [colorArray addObject: [CPTColor redColor]];
        [graph addPlot:tempPlot toPlotSpace:plotSpace];
        [plotSet addObject:tempPlot];
    }
    //[plotSet addObject:nil];
    /*

    // 2 - Create the three plots
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = CPDTickerSymbolAAPL;
    CPTColor *aaplColor = [CPTColor redColor];
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];
    CPTScatterPlot *googPlot = [[CPTScatterPlot alloc] init];
    googPlot.dataSource = self;
    googPlot.identifier = CPDTickerSymbolGOOG;
    CPTColor *googColor = [CPTColor greenColor];
    [graph addPlot:googPlot toPlotSpace:plotSpace];
    CPTScatterPlot *msftPlot = [[CPTScatterPlot alloc] init];
    msftPlot.dataSource = self;
    msftPlot.identifier = CPDTickerSymbolMSFT;
    CPTColor *msftColor = [CPTColor blueColor];
    [graph addPlot:msftPlot toPlotSpace:plotSpace];
     */
    // 3 - Set up plot space
    //[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:aaplPlot, googPlot, msftPlot, nil]];
    [plotSpace scaleToFitPlots:plotSet];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    /************************************************************
     * if this number is 1.0 the plots will fill the screen exactly
     * so larger numbers of plots will be condensed.
     * If this number is less than 1.0 the plot will expand off the
     * screen.  The question is how to determine this number dynamically
     * so that the correct amount of space is used.  Problem when there
     * are a large number of times.
     */
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(0.5f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    // 4 - Create styles and symbols
    if (dataExists) {
        for (i = 0; i < [[theValues objectAtIndex:0] count]; i++) {
            tempPlot =((CPTScatterPlot *)[plotSet objectAtIndex: i]);
            tempColor = [colorArray objectAtIndex: i];
            CPTMutableLineStyle *aaplLineStyle = [tempPlot.dataLineStyle mutableCopy];
            aaplLineStyle.lineWidth = 2.5;
            aaplLineStyle.lineColor = tempColor;
            tempPlot.dataLineStyle = aaplLineStyle;
            CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
            aaplSymbolLineStyle.lineColor = tempColor;
            CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
            aaplSymbol.fill = [CPTFill fillWithColor:tempColor];
            aaplSymbol.lineStyle = aaplSymbolLineStyle;
            aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
            tempPlot.plotSymbol = aaplSymbol;
        }
    }
    // create a generic line if we have no data
    else {
        tempPlot =((CPTScatterPlot *)[plotSet objectAtIndex: 0]);
        tempColor = [colorArray objectAtIndex: 0];
        CPTMutableLineStyle *aaplLineStyle = [tempPlot.dataLineStyle mutableCopy];
        aaplLineStyle.lineWidth = 2.5;
        aaplLineStyle.lineColor = tempColor;
        tempPlot.dataLineStyle = aaplLineStyle;
        CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
        aaplSymbolLineStyle.lineColor = tempColor;
        CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        aaplSymbol.fill = [CPTFill fillWithColor:tempColor];
        aaplSymbol.lineStyle = aaplSymbolLineStyle;
        aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
        tempPlot.plotSymbol = aaplSymbol;
    }
    /*
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 2.5;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot.dataLineStyle = aaplLineStyle;
    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    aaplSymbolLineStyle.lineColor = aaplColor;
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
    aaplSymbol.lineStyle = aaplSymbolLineStyle;
    aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
    aaplPlot.plotSymbol = aaplSymbol;
    CPTMutableLineStyle *googLineStyle = [googPlot.dataLineStyle mutableCopy];
    googLineStyle.lineWidth = 1.0;
    googLineStyle.lineColor = googColor;
    googPlot.dataLineStyle = googLineStyle;
    CPTMutableLineStyle *googSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    googSymbolLineStyle.lineColor = googColor;
    CPTPlotSymbol *googSymbol = [CPTPlotSymbol starPlotSymbol];
    googSymbol.fill = [CPTFill fillWithColor:googColor];
    googSymbol.lineStyle = googSymbolLineStyle;
    googSymbol.size = CGSizeMake(6.0f, 6.0f);
    googPlot.plotSymbol = googSymbol;
    CPTMutableLineStyle *msftLineStyle = [msftPlot.dataLineStyle mutableCopy];
    msftLineStyle.lineWidth = 2.0;
    msftLineStyle.lineColor = msftColor;
    msftPlot.dataLineStyle = msftLineStyle;
    CPTMutableLineStyle *msftSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    msftSymbolLineStyle.lineColor = msftColor;
    CPTPlotSymbol *msftSymbol = [CPTPlotSymbol diamondPlotSymbol];
    msftSymbol.fill = [CPTFill fillWithColor:msftColor];
    msftSymbol.lineStyle = msftSymbolLineStyle;
    msftSymbol.size = CGSizeMake(6.0f, 6.0f);
    msftPlot.plotSymbol = msftSymbol;
     */
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 10.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Time";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    
    // change this to [theTimeStamps count] because each x-axis tick is one time interval
    //CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    CGFloat dateCount = [theTimeStamps count];
    //NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    //NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0, j = 0;
    NSString *date;
    for (NSNumber *num in theTimeStamps) {
        date = [NSString stringWithFormat:@"%ld", (long)[num integerValue]];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Pixels Changed";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    // this should be relative to yMax
    NSInteger majorIncrement = 500;
    NSInteger minorIncrement = 250;
    // this will be the max pixel change of any value at any time.  Need a double loop
    // to figure this out (one to go through every time, the other to go through each ROI value).
    // I set at 4,000 because that should be the max value for now
    //CGFloat yMax = 700.0f;  // should determine dynamically based on max price
    CGFloat yMax = 0.0f;
    for (i = 0; i < [theValues count]; i++) {
        for (j = 0; j < [[theValues objectAtIndex:i] count]; j++) {
            if ([[[theValues objectAtIndex:i] objectAtIndex:j] doubleValue] > yMax) {
                yMax = [[[theValues objectAtIndex:i] objectAtIndex:j]doubleValue];
            }
        }
    }
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", (int)j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

-(void)clearPlot {
    self.hostView.hostedGraph = nil;
    self.hostView = nil;
}


#pragma mark - CPTPlotDataSource methods


-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if (!dataExists) {
        return 1;
    }
    return [theValues count];
}


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    // DEBUG
    //NSLog(@"Number for Plot: index is %d number of theValues is %d", index, [theValues count]);
    
    if (dataExists) {
        // Make sure theat the requested index is in bounds
        long thePlotNumber;
        if (index < [theValues count]) {
        
            if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [theValues count])) {
                //each entry in theValues is a time (which is given by index)
                // each entry in the array at theValues[index] is an ROI
                // value at "index" time
                /*
                if ([plot.identifier isEqual:CPDTickerSymbolAAPL]) {
                    return [[theValues objectAtIndex:index] objectAtIndex:0];
                } else if ([plot.identifier isEqual:CPDTickerSymbolGOOG]) {
                    return [[theValues objectAtIndex:index] objectAtIndex:1];
                } else if ([plot.identifier isEqual:CPDTickerSymbolMSFT]) {
                    return [[theValues objectAtIndex:index] objectAtIndex:2];
                }
                 */
                thePlotNumber = [[plot.identifier description] integerValue];
                return [[theValues objectAtIndex:index] objectAtIndex:thePlotNumber];
            }
        }
    }
    return [NSDecimalNumber numberWithUnsignedInteger:index];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    
    // 1 - Define label text style
    static CPTMutableTextStyle *labelText = nil;
   // NSString *labelValue;
    
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        //labelText.color = [CPTColor grayColor];
        
        labelText.color = ((CPTScatterPlot *)plot).dataLineStyle.lineColor;
    }
    // 2 - Calculate portfolio total value
    
    // 3 - Calculate percentage value

    if (!dataExists) {
        return [[CPTTextLayer alloc] initWithText:@" " style:labelText];
    }
    // index represents a tick on the x axis which is time.
    // Each entry in theValues is a time
    
    /* uncomment this section to return a value
     
    if (index < [theValues  count]) {
        
        if (dataExists) {
            
            //NSLog(@"Data label.  index is %d Num timeStamps = %d Num Values = %d", index, [theTimeStamps count], [theValues count]);
            
                NSNumber *tempNum;
                    if ([plot.identifier isEqual:CPDTickerSymbolAAPL]) {
                        tempNum = [[theValues objectAtIndex:index] objectAtIndex:0];
                        labelValue = [NSString stringWithFormat:@"%ld", [tempNum integerValue]] ;
                    } else if ([plot.identifier isEqual:CPDTickerSymbolGOOG]) {
                        tempNum =[[theValues objectAtIndex:index] objectAtIndex:1];
                        labelValue = [NSString stringWithFormat:@"%ld", [tempNum integerValue]  ];
                    } else if ([plot.identifier isEqual:CPDTickerSymbolMSFT]) {
                        tempNum = [[theValues objectAtIndex:index] objectAtIndex:2];
                        labelValue = [NSString stringWithFormat:@"%ld",[tempNum integerValue]] ;
                    }
            
            return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
        }
    }
     
     */
    // 5 - Create and return layer with label text
    long thePlotNumber = [[plot.identifier description] integerValue];
    if ((index % [[theValues objectAtIndex:0] count]) == (thePlotNumber % [theValues count])) {
        NSString *id = [plot.identifier description];
        return [[CPTTextLayer alloc] initWithText:id style:labelText];
    }
    return [[CPTTextLayer alloc] initWithText:@" " style:labelText];
    
}

#pragma mark - UIActionSheetDelegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 1 - Get title of tapped button
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    // 2 - Get theme identifier based on user tap
    NSString *themeName = kCPTPlainWhiteTheme;
    if ([title isEqualToString:CPDThemeNameDarkGradient] == YES) {
        themeName = kCPTDarkGradientTheme;
    } else if ([title isEqualToString:CPDThemeNamePlainBlack] == YES) {
        themeName = kCPTPlainBlackTheme;
    } else if ([title isEqualToString:CPDThemeNamePlainWhite] == YES) {
        themeName = kCPTPlainWhiteTheme;
    } else if ([title isEqualToString:CPDThemeNameSlate] == YES) {
        themeName = kCPTSlateTheme;
    } else if ([title isEqualToString:CPDThemeNameStocks] == YES) {
        themeName = kCPTStocksTheme;
    }
    // 3 - Apply new theme
    [self.hostView.hostedGraph applyTheme:[CPTTheme themeNamed:themeName]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
