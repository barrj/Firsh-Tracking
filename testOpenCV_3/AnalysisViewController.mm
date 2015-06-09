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

@interface AnalysisViewController ()
{
    BOOL dataExists;
}
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;


-(void)initPlot;
-(void)configureHost;
-(void)configureGraph;
-(void)configureChart;
-(void)configureLegend;
-(void)clearPlot;

@end

@implementation AnalysisViewController

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
-(IBAction)themeTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Apply a Theme" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:CPDThemeNameDarkGradient, CPDThemeNamePlainBlack, CPDThemeNamePlainWhite, CPDThemeNameSlate, CPDThemeNameStocks, nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configureChart];
    [self configureLegend];
}

-(void)clearPlot {
    self.hostView.hostedGraph = nil;
    self.hostView = nil;
}

-(void)configureHost {
    // 1 - Set up view frame
    CGRect parentRect = self.view.bounds;
    CGSize toolbarSize = self.toolbar.bounds.size;
    parentRect = CGRectMake(parentRect.origin.x,
                            (parentRect.origin.y + toolbarSize.height),
                            parentRect.size.width,
                            (parentRect.size.height - toolbarSize.height));
    // 2 - Create host view
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = NO;
    [self.view addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create and initialize graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    self.hostView.hostedGraph = graph;
    graph.paddingLeft = 0.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingBottom = 0.0f;
    graph.axisSet = nil;
    // 2 - Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 16.0f;
    // 3 - Configure title
    //NSString *title = @"Portfolio Prices: May 1, 2012";
    NSString *title = @"Differences";
    graph.title = title;
    graph.titleTextStyle = textStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
    // 4 - Set theme
    self.selectedTheme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph applyTheme:self.selectedTheme];
}

-(void)configureChart {
    // 1 - Get reference to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    // 2 - Create chart
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.delegate = self;
    pieChart.pieRadius = (self.hostView.bounds.size.height * 0.7) / 2;
    pieChart.identifier = graph.title;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    // 3 - Create gradient
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
    pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
    // 4 - Add chart to graph    
    [graph addPlot:pieChart];
}

-(void)configureLegend {
    // 1 - Get graph instance
    CPTGraph *graph = self.hostView.hostedGraph;
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    // 3 - Configure legend
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    // 4 - Add legend to graph
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.view.bounds.size.width / 8);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

#pragma mark - CPTPlotDataSource methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if (!dataExists) {
        return 1;
    }
    //return [theValues count];
    return [[theValues objectAtIndex:0]  count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    // DEBUG
    //NSLog(@"Number for Plot: index is %d number of theValues is %d", index, [theValues count]);
    
    if (dataExists) {
        // Make sure theat the requested index is in bounds
        //if (index < [theValues count]) {
        if (index < [[theValues objectAtIndex:0]  count]) {

            //NSMutableArray *ROIarray = [theValues objectAtIndex:index];
            //int limit = [ROIarray count];
            int limit = [theValues count];
            int sum = 0;
            
            // I think I'm doing this wrong.  I'm adding all the values in all the ROI at this
            // timestamp.  I think I want to add all the values for all timestamps for the ROI at
            // index
            for (int i = 0; i < limit; i++) {
                //sum += [[ROIarray objectAtIndex:i] integerValue];
                sum += [[[theValues objectAtIndex:i] objectAtIndex:index] integerValue];
            }
            return [[NSNumber alloc] initWithInt:sum];
        }
    }
    return [NSDecimalNumber zero];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    // 1 - Define label text style
    static CPTMutableTextStyle *labelText = nil;
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        labelText.color = [CPTColor grayColor];
    }
    // 2 - Calculate portfolio total value
    /*
    NSDecimalNumber *portfolioSum = [NSDecimalNumber zero];
    for (NSDecimalNumber *price in [[CPDStockPriceStore sharedInstance] dailyPortfolioPrices]) {
        portfolioSum = [portfolioSum decimalNumberByAdding:price];
    } 
     */
    // 3 - Calculate percentage value
    /*
    NSDecimalNumber *price = [[[CPDStockPriceStore sharedInstance] dailyPortfolioPrices] objectAtIndex:index];
    NSDecimalNumber *percent = [price decimalNumberByDividingBy:portfolioSum];
    // 4 - Set up display label
    NSString *labelValue = [NSString stringWithFormat:@"$%0.2f USD (%0.1f %%)", [price floatValue], ([percent floatValue] * 100.0f)];
     */
    if (!dataExists) {
        return [[CPTTextLayer alloc] initWithText:@"none" style:labelText];
    }
    if (index < [[theValues objectAtIndex:0] count]) {
        
        if (dataExists) {
            
            //NSLog(@"Data label.  index is %d Num timeStamps = %d Num Values = %d", index, [theTimeStamps count], [theValues count]);
            
            //NSMutableArray *ROIarray = [theValues objectAtIndex:index];
            //int limit = [ROIarray count];
            int limit = [theValues count];
            int sum = 0;
            
            for (int i = 0; i < limit; i++) {
                sum += [[[theValues objectAtIndex:i] objectAtIndex:index] integerValue];
            }
            
            //NSString *labelValue = [NSString stringWithFormat:@"ROI:%d Diff: %d", index,sum];
            NSString *labelValue = [NSString stringWithFormat:@"Diff: %d",sum];
            return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
        }
    }
    // 5 - Create and return layer with label text
    
    return [[CPTTextLayer alloc] initWithText:@"None" style:labelText];
    
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
/*
    if (index < [theTimeStamps count]) {
        
        if (dataExists) {
            return [NSString stringWithFormat:@"%ld", (long)[[theTimeStamps objectAtIndex:index] integerValue]];
        }
        
    }
    return @"None";
 */
    return [NSString stringWithFormat:@"ROI %d",index];
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
