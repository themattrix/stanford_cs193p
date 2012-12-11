//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Matthew Tardiff on 11/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"
#import "Util.h"
#import "math.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSSet *unaryOperations;
@property (nonatomic, strong) NSSet *binaryOperations;
+ (double)popOperand:(NSMutableArray *)stack
 usingVariableValues:(NSDictionary *)variableValues;
+ (int)precedenceOfOperator:(NSString *)operator;
+ (NSString *)buildDescriptionOfProgram:(NSMutableArray *)stack
               parentOperatorPrecedence:(int)parentPrecedence;
// Duplicated from the interface: Added here because Xcode complains about
// runProgram being called from performOperation (which is implemented
// before runProgram).
+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;
@end

@implementation CalculatorBrain

static NSSet *unaryOperations;
static NSSet *binaryOperations;

@synthesize programStack = _programStack;
@synthesize unaryOperations = _unaryOperations;
@synthesize binaryOperations = _binaryOperations;

+ (void)initialize {
    if (self == [CalculatorBrain class]) {
        unaryOperations  = [NSSet setWithObjects:@"sin", @"cos", @"tan", @"√", nil];
        binaryOperations = [NSSet setWithObjects:@"+", @"-", @"×", @"÷", nil];
    }
}

- (NSMutableArray *)programStack
{
    if (_programStack == nil) {
        _programStack = [[NSMutableArray alloc] init];   
    }
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

- (void)pushNumberOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (void)pushVariableOperand:(NSString *)operand
{
    [self.programStack addObject:operand];
}

- (void)discardLastOperand
{
    if ([self.programStack count] > 0) {
        [self.programStack removeLastObject];
    }
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (void)clearOperands
{
    [self.programStack removeAllObjects];
}

+ (double)popOperand:(NSMutableArray *)stack
 usingVariableValues:(NSDictionary *)variableValues
{
    double result = 0.0;
    
    id topOfStack = [Util pop:stack];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]) {
            result =  [self popOperand:stack usingVariableValues:variableValues] +
                      [self popOperand:stack usingVariableValues:variableValues];
        } else if ([operation isEqualToString:@"-"]) {
            result = -[self popOperand:stack usingVariableValues:variableValues] +
                      [self popOperand:stack usingVariableValues:variableValues];
        } else if ([operation isEqualToString:@"×"]) {
            result =  [self popOperand:stack usingVariableValues:variableValues] *
                      [self popOperand:stack usingVariableValues:variableValues];
        } else if ([operation isEqualToString:@"÷"]) {
            double divisor = [self popOperand:stack usingVariableValues:variableValues];
            if (divisor == 0) {
                @throw [NSException
                    exceptionWithName: @"DivideByZeroException"
                               reason: @"Divide by zero"
                             userInfo: nil];
            }
            result = [self popOperand:stack usingVariableValues:variableValues] / divisor;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperand:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperand:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"tan"]) {
            result = tan([self popOperand:stack usingVariableValues:variableValues]);
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else if ([operation isEqualToString:@"√"]) {
            double resultSquared = [self popOperand:stack usingVariableValues:variableValues];
            if (resultSquared < 0) {
                @throw [NSException
                    exceptionWithName: @"NegativeRootException"
                               reason: @"Negative root"
                             userInfo: nil];
            }
            result = sqrt(resultSquared);
        } else if ([operation isEqualToString:@"+/-"]) {
            result = -[self popOperand:stack usingVariableValues:variableValues];
        } else {
            result = [[variableValues objectForKey:topOfStack] doubleValue];
        }
    }
    
    return result;
}

+ (int)precedenceOfOperator:(NSString *)operator
{
    if ([operator isEqualToString:@"×"] || [operator isEqualToString:@"÷"]) {
        return 1;
    }
    return 0;
}

+ (NSString *)buildDescriptionOfProgram:(NSMutableArray *)stack
               parentOperatorPrecedence:(int)parentPrecedence
{
    NSString *description = @"";
    
    id topOfStack = [Util pop:stack];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        description = [topOfStack stringValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        
        if ([binaryOperations containsObject:operation]) {
            int precedence = [CalculatorBrain precedenceOfOperator:operation];
            NSString *right = [CalculatorBrain buildDescriptionOfProgram:stack
                                                parentOperatorPrecedence:precedence];
            NSString *left  = [CalculatorBrain buildDescriptionOfProgram:stack
                                                parentOperatorPrecedence:precedence];
            if (parentPrecedence > precedence) {
                description = [NSString stringWithFormat:@"(%@ %@ %@)", left, operation, right];
            } else {
                description = [NSString stringWithFormat:@"%@ %@ %@", left, operation, right];
            }
        } else if ([unaryOperations containsObject:operation]) {
            NSString *operand = [CalculatorBrain buildDescriptionOfProgram:stack
                                                  parentOperatorPrecedence:0];
            description = [NSString stringWithFormat:@"%@(%@)", operation, operand];
        }
        else {
            description = operation;
        }
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack = [(NSArray *)program mutableCopy];
    NSString *description = @"";
    
    while (stack.count != 0) {
        NSString *topFormat = [CalculatorBrain buildDescriptionOfProgram:stack
                                                parentOperatorPrecedence:0];
        description = [Util prepend:topFormat toListString:description];
    }
    
    return description;
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}

+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperand:stack usingVariableValues:variableValues];
}

@end
