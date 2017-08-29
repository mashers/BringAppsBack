//
//  ViewController.m
//  BringAppsBack
//
//  Created by Mark Ashley on 29/08/2017.
//  Copyright © 2017 Mark Ashley. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (IBAction)bringItBack:(id)sender {
    NSString *source = [NSString stringWithFormat:@"\
                        tell application \"%@\" \n \
                            reopen \n \
                            \
                            set xOffset to 50 \n \
                            set yOffset to 50 \n \
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
                        tell application \"%@\" to activate \
                        ", self.textField.stringValue, [[NSProcessInfo processInfo] processName]];
    
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:source];
    [appleScript executeAndReturnError:nil];
}
@end
