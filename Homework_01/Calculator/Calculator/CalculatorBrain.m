//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Matthew Tardiff on 11/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
#import "math.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *stack;
- (double)popOperand;
@end

@implementation CalculatorBrain

@synthesize stack = _stack;

- (NSMutableArray *)stack
{
    if (_stack == nil) {
        _stack = [[NSMutableArray alloc] init];   
    }
    return _stack;
}

- (void)pushOperand:(double)operand
{
    [self.stack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)popOperand
{
    if ([self.stack count] == 0) {
        return 0;
    } else {
        NSNumber *operand = self.stack.lastObject;
        if (operand) [self.stack removeLastObject];
        return operand.doubleValue;
    }
}

- (double)performOperation:(NSString *)operation
{
    double result = 0.0;
    
    if ([operation isEqualToString:@"+"]) {
        result = [self popOperand] + [self popOperand];
    } else if ([operation isEqualToString:@"-"]) {
        result = -[self popOperand] + [self popOperand];
    } else if ([operation isEqualToString:@"×"]) {
        result = [self popOperand] * [self popOperand];
    } else if ([operation isEqualToString:@"÷"]) {
        double divisor = [self popOperand];
        if (divisor == 0) {
            @throw [NSException exceptionWithName: @"DivideByZeroException"
                                           reason: @"Attempted to divide by zero"
                                         userInfo: nil];
        }
        result = [self popOperand] / divisor;
    } else if ([operation isEqualToString:@"sin"]) {
        result = sin([self popOperand]);
    } else if ([operation isEqualToString:@"cos"]) {
        result = cos([self popOperand]);
    } else if ([operation isEqualToString:@"tan"]) {
        result = tan([self popOperand]);
    } else if ([operation isEqualToString:@"π"]) {
        result = M_PI;
    } else if ([operation isEqualToString:@"√"]) {
        result = sqrt([self popOperand]);
    } else if ([operation isEqualToString:@"+/-"]) {
        result = -[self popOperand];
    }
    
    [self pushOperand:result];

    return result;
}

- (void)clearOperands
{
    [self.stack removeAllObjects];
}

@end
