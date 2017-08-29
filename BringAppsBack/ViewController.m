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
    
    [self.popupButton setAction:@selector(popupButtonChanged:)];
    [self.popupButton setTarget:self];
    
    [self populateAppsList:nil];
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
                        ", appName, [[NSProcessInfo processInfo] processName]];
    
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:source];
    [appleScript executeAndReturnError:nil];
}
@end
