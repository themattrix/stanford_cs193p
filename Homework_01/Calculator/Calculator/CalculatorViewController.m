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
- (void)submitDisplay;
- (void)displayEvent:(NSString *)event;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize sentToBrain = _sentToBrain;
@synthesize userIsEnteringNumber = _userIsEnteringNumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (void)submitDisplay
{
    if (self.userIsEnteringNumber) {
        [self.brain pushOperand:[self.display.text doubleValue]];
        [self displayEvent:self.display.text];
        self.userIsEnteringNumber = NO;
    }
}

- (void)displayEvent:(NSString *)event
{
    if (self.sentToBrain.text.length == 0) {
        self.sentToBrain.text = event;
    } else {
        self.sentToBrain.text = [self.sentToBrain.text stringByAppendingFormat:@" %@", event];
    }
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    
    if (self.userIsEnteringNumber) {
        // If the displayed string already has a '.' in it, don't add another.
        if ([digit isEqualToString:@"."] && [Util doesString:self.display.text contain:@"."]) {
            return;
        }
        // If the digit is '0' and the displayed string is not '0', append this digit to the display.
        if ([digit isEqualToString:@"0"] || ![self.display.text isEqualToString:@"0"]) {
            self.display.text = [self.display.text stringByAppendingString:digit];
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
    self.userIsEnteringNumber = NO;
}

- (IBAction)enterPressed:(UIButton *)sender
{
    [self submitDisplay];
}

- (IBAction)backspacePressed:(UIButton *)sender {
    int newLength = self.display.text.length - 1;
    if (newLength == 0) {
        self.display.text = @"0";
        self.userIsEnteringNumber = NO;
    } else {
        self.display.text = [self.display.text substringToIndex:newLength];
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
            [self displayEvent:operation];
            [self displayEvent:@"="];
            double result = [self.brain performOperation:operation];
            self.display.text = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:result]];
        }
        @catch (NSException *exception) {
            self.display.text = @"Error: Divide by 0";
        }
    }
}

@end
