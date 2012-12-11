//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Matthew Tardiff on 11/3/12.
//  Copyright (c) 2012 Centare. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "Util.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsEnteringNumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, weak) NSDictionary *activeVariables;
- (void)submitDisplay;
- (void)displayProgram;
- (void)runProgram;
@end

@implementation CalculatorViewController

static NSDictionary *allVariables;

@synthesize display = _display;
@synthesize sentToBrain = _sentToBrain;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsEnteringNumber = _userIsEnteringNumber;
@synthesize brain = _brain;
@synthesize activeVariables = _activeVariables;

+ (void)initialize {
    if (self == [CalculatorViewController class]) {
        allVariables = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithDouble:0], @"x",
                [NSNumber numberWithDouble:10], @"y",
                [NSNumber numberWithDouble:-100], @"z",
                nil], @"TEST 1",
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithDouble:1.5], @"x",
                [NSNumber numberWithDouble:-1.5], @"z",
                nil], @"TEST 2",
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithDouble:3.14159265358979], @"y",
                nil], @"TEST 3",
            nil];
    }
}

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)submitDisplay
{
    if (self.userIsEnteringNumber) {
        [self.brain pushNumberOperand:[self.display.text doubleValue]];
        [self displayProgram];
        self.userIsEnteringNumber = NO;
    }
}

- (void)displayProgram
{
    self.sentToBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (void)runProgram
{
    // Run the program (non-destructively)
    double result = [CalculatorBrain runProgram:self.brain.program
                            usingVariableValues:self.activeVariables];
    // Display the result
    self.display.text = [[NSNumber numberWithDouble:result] stringValue];
    // Set the description
    [self displayProgram];
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    
    if (self.userIsEnteringNumber) {
        // If the displayed string already has a '.' in it, don't add another.
        if ([digit isEqualToString:@"."] && [Util doesString:self.display.text contain:@"."]) {
            return;
        } else if (![self.display.text isEqualToString:@"0"]) {
            self.display.text = [self.display.text stringByAppendingString:digit];
        } else if (![digit isEqualToString:@"0"]) {
            self.display.text = digit;
        }
    } else {
        if ([digit isEqualToString:@"."]) {
            self.display.text = @"0.";
        } else {
            self.display.text = digit;
        }
        self.userIsEnteringNumber = YES;
    }
}

- (IBAction)clearPressed:(UIButton *)sender
{
    [self.brain clearOperands];
    self.display.text = @"0";
    self.sentToBrain.text = @"";
    self.variableDisplay.text = @"";
    self.activeVariables = nil;
    self.userIsEnteringNumber = NO;
}

- (IBAction)enterPressed:(UIButton *)sender
{
    [self submitDisplay];
}

- (IBAction)backspacePressed:(UIButton *)sender {
    if (self.userIsEnteringNumber) {
        int newLength = self.display.text.length - 1;
        if (newLength == 0) {
            self.display.text = @"0";
            self.userIsEnteringNumber = NO;
        } else {
            self.display.text = [self.display.text substringToIndex:newLength];
            if ([self.display.text isEqualToString:@"0"]) {
                self.userIsEnteringNumber = NO;
            }
        }
    }
}

- (IBAction)undoPressed:(UIButton *)sender {
    if (self.userIsEnteringNumber) {
        [self backspacePressed:sender];
    } else {
        [self.brain discardLastOperand];
        [self runProgram];
    }
}

- (IBAction)operationPressed:(UIButton *)sender
{
    NSString *operation = sender.currentTitle;
    
    // If the "+/-" operation was pressed and the user is in the middle of entering a number, change the
    // sign at the beginning of the display.
    if ([operation isEqualToString:@"+/-"] && self.userIsEnteringNumber) {
        if ([self.display.text hasPrefix:@"-"]) {
            self.display.text = [self.display.text substringFromIndex:1];
        } else {
            self.display.text = [NSString stringWithFormat:@"-%@", self.display.text];
        }
    // Otherwise, treat the "+/-" operation like any other unary operator.
    } else {
        [self submitDisplay];
        @try {
            double result = [self.brain performOperation:operation];
            [self displayProgram];
            self.display.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:result]];
        }
        @catch (NSException *exception) {
            self.display.text = [NSString stringWithFormat:@"ERROR: %@", [exception debugDescription]];
            self.userIsEnteringNumber = false;
            [self.brain discardLastOperand];
            [self runProgram];
        }
    }
}

- (IBAction)variablePressed:(UIButton *)sender
{
    NSString *variable = [sender currentTitle];
    [self.brain pushVariableOperand:variable];
    [self displayProgram];
    self.display.text = variable;
    self.userIsEnteringNumber = NO;
}

- (IBAction)testPressed:(UIButton *)sender
{
    self.activeVariables = [allVariables objectForKey:sender.currentTitle];
    self.variableDisplay.text = @"";
    for (NSString *key in self.activeVariables) {
        NSString *value = [self.activeVariables objectForKey:key];
        self.variableDisplay.text = [self.variableDisplay.text
            stringByAppendingFormat:@"%@ = %@    ", key, value];
    }
    [self runProgram];
}

- (void)viewDidUnload {
    [self setVariableDisplay:nil];
    [super viewDidUnload];
}

@end
     