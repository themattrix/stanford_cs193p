//
//  Util.m
//  Calculator
//
//  Created by Matthew Tardiff on 11/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (BOOL)doesString:(NSString *)searchSpace
           contain:(NSString *)pattern
{
    return [searchSpace rangeOfString:pattern].location != NSNotFound;
}

@end
