//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Matthew Tardiff on 11/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushNumberOperand:(double)operand;
- (void)pushVariableOperand:(NSString *)operand;
- (void)discardLastOperand;
- (double)performOperation:(NSString *)operation;
- (void)clearOperands;

@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;

@end
