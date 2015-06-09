//
//  sharedROI.h
//  testOpenCV_3
//
//  Created by John Barr on 11/7/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sharedROI : NSObject{

}

@property (strong, nonatomic) IBOutlet NSMutableArray* theROI;
@property (strong, nonatomic) IBOutlet NSMutableArray* theData;
@property (strong, nonatomic) IBOutlet NSMutableArray* theTimeStamps;
@property (strong, nonatomic) IBOutlet NSNumber* thresh;
@property (strong, nonatomic) IBOutlet NSNumber* captureInterval;

+ (sharedROI *)sharedROI;
//- (void)setTheROI:(NSMutableArray *)newROI;
//- (NSMutableArray *)getTheROI;


@end
