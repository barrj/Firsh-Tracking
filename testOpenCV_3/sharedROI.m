//
//  sharedROI.m
//  testOpenCV_3
//
//  Created by John Barr on 11/7/14.
//  Copyright (c) 2014 Computer Science. All rights reserved.
//

#import "sharedROI.h"

static sharedROI *theStaticROI;

@implementation sharedROI

- (id)init{
    self = [super init];
    _theROI = [[NSMutableArray alloc] initWithCapacity: 1];
    _theData = [[NSMutableArray alloc] initWithCapacity: 1];
    _theTimeStamps = [[NSMutableArray alloc] initWithCapacity: 1];
    _thresh = [[NSNumber alloc] initWithInt:50];
    _captureInterval = [[NSNumber alloc] initWithInt:150];
    return self;
}

+ (sharedROI *)sharedROI{
    if (!theStaticROI) {
        theStaticROI = [[sharedROI alloc] init];
    }
    return theStaticROI;
}

/* why not just make these properties?
- (void)setTheROI:(NSMutableArray *)newROI{
    theROI = newROI;

}

- (NSMutableArray *)getTheROI{
    return theROI;
}
 */


@end
