//
//  ViewController.h
//  BringAppsBack
//
//  Created by Mark Ashley on 29/08/2017.
//  Copyright © 2017 Mark Ashley. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSPopUpButton *popupButton;
@property (weak) IBOutlet NSTextField *leftField;
@property (weak) IBOutlet NSTextField *topField;

- (IBAction)bringItBack:(id)sender;

@end

