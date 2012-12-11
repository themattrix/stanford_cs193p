//
//  Util.h
//  Calculator
//
//  Created by Matthew Tardiff on 11/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (BOOL)doesString:(NSString *)searchSpace
           contain:(NSString *)pattern;

+ (NSString *)append:(NSString *)string
        toListString:(NSString *)list;

+ (NSString *)prepend:(NSString *)string
         toListString:(NSString *)list;

+ (id)pop:(NSMutableArray *)stack;

@end
