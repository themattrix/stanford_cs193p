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

+ (NSString *)append:(NSString *)string
        toListString:(NSString *)list
{
    if (list == nil || list.length == 0) {
        return string;
    }
    
    return [list stringByAppendingFormat:@", %@", string];
}

+ (NSString *)prepend:(NSString *)string
         toListString:(NSString *)list
{
    if (list == nil || list.length == 0) {
        return string;
    }
    return [NSString stringWithFormat:@"%@, %@", string, list];
}

+ (id)pop:(NSMutableArray *)stack
{
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    return topOfStack;
}

@end
