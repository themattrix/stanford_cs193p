//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Matthew Tardiff on 11/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
- (void)clearOperands;

@end
