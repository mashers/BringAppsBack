//
//  ViewController.m
//  BringAppsBack
//
//  Created by Mark Ashley on 29/08/2017.
//  Copyright © 2017 Mark Ashley. All rights reserved.
//

#import "ViewController.h"

@interface OnlyIntegerValueFormatter : NSNumberFormatter

@end

@implementation OnlyIntegerValueFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    if([partialString length] == 0) {
        return YES;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        NSBeep();
        return NO;
    }
    
    return YES;
}

@end

@interface ViewController () <NSTextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    OnlyIntegerValueFormatter *formatter = [[OnlyIntegerValueFormatter alloc] init];
    [self.leftField setFormatter:formatter];
    [self.topField setFormatter:formatter];
    
    self.leftField.delegate = self;
    self.topField.delegate = self;
    
    NSInteger topOffset = [[NSUserDefaults standardUserDefaults] integerForKey:@"topOffset"];
    if (topOffset > 0) {
        [self.topField setIntegerValue:topOffset];
    }
    
    NSInteger leftOffset = [[NSUserDefaults standardUserDefaults] integerForKey:@"leftOffset"];
    if (leftOffset > 0) {
        [self.leftField setIntegerValue:leftOffset];
    }
    
    [self.popupButton setAction:@selector(popupButtonChanged:)];
    [self.popupButton setTarget:self];
    
    [self populateAppsList:nil];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self.view.window setLevel:NSFloatingWindowLevel];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSInteger val = [textField integerValue];
    
    if (textField == self.leftField) {
        [[NSUserDefaults standardUserDefaults] setInteger:val forKey:@"leftOffset"];
    }
    else if (textField == self.topField) {
        [[NSUserDefaults standardUserDefaults] setInteger:val forKey:@"topOffset"];
    }
}

- (IBAction)popupButtonChanged:(NSPopUpButton*)sender {
    [[NSUserDefaults standardUserDefaults] setValue:sender.titleOfSelectedItem forKey:@"lastSelectedApp"];
}

- (IBAction)populateAppsList:(id)sender {
    [self.popupButton removeAllItems];
    
    NSString *lastSelectedApp = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastSelectedApp"];
    NSInteger selectedIndex = 0;
    
    NSMutableArray *apps = [NSMutableArray array];
    NSString *currentAppName = [[NSProcessInfo processInfo] processName];
    
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if (app.activationPolicy == NSApplicationActivationPolicyRegular && ![app.localizedName isEqualToString:currentAppName]) {
            [apps addObject:app];
        }
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localizedName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [apps sortUsingDescriptors:@[sortDescriptor]];
    
    for (NSRunningApplication *app in apps) {
        [self.popupButton addItemWithTitle:app.localizedName];
        [self.popupButton.itemArray.lastObject setImage:app.icon];
        if ([app.localizedName isEqualToString:lastSelectedApp]) {
            selectedIndex = self.popupButton.itemArray.count-1;
        }
    }
    
    [self.popupButton selectItemAtIndex:selectedIndex];
    [self popupButtonChanged:self.popupButton];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)bringItBack:(id)sender {
    NSString *appName = self.popupButton.selectedItem.title;
    
    NSInteger topOffset = [[NSUserDefaults standardUserDefaults] integerForKey:@"topOffset"];
    NSInteger leftOffset = [[NSUserDefaults standardUserDefaults] integerForKey:@"leftOffset"];
    
    NSString *source = [NSString stringWithFormat:@"\
                        tell application \"%@\" \n \
                            reopen \n \
                            \
                            set xOffset to %ld \n \
                            set yOffset to %ld \n \
                            \n \
                            repeat with win in windows \n \
                                set theBounds to (bounds of win) \n \
                                \n \
                                set originX to item 1 of theBounds \n \
                                set originY to item 2 of theBounds \n \
                                \n \
                                set endX to item 3 of theBounds \n \
                                set endY to item 4 of theBounds \n \
                                \n \
                                set width to endX - originX \n \
                                set height to endY - originY \n \
                                \n \
                                set originX to xOffset \n \
                                set originY to yOffset \n \
                                \n \
                                set endX to originX + width \n \
                                set endY to originY + height \n \
                                \n \
                                set bounds of win to {originX, originY, endX, endY} \n \
                            end repeat \n \
                            activate \n \
                        end tell \n \
                        \
                        ", appName, (long)leftOffset, (long)topOffset, [[NSProcessInfo processInfo] processName]];
    
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:source];
    [appleScript executeAndReturnError:nil];
}

@end
