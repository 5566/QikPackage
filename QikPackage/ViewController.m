//
//  ViewController.m
//  QikPackage
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "ViewController.h"
#import "QPPackageService.h"
#import "QPBuilder.h"

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate, QPPackageServiceDelegate>

@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSTextField *progressInfoLabel;

@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (weak) IBOutlet NSTextField *projectPathField;

@property (weak) IBOutlet NSTextField *savePathField;

@property (nonatomic, strong) QPPackageService *packageService;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _packageService = [QPPackageService serviceWithDelegate:self];
        
    [self setup];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)setup {
    if (_packageService.projectPath) {
        [_projectPathField setStringValue:_packageService.projectPath];
    }
    
    if (_packageService.targetPath) {
        [_savePathField setStringValue:_packageService.targetPath];
    }
}

- (IBAction)previewResult:(id)sender {
    if (!_packageService.targetPath) return;
    
    [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:_packageService.targetPath];
}

- (IBAction)run:(id)sender {
    [_packageService run];
}

- (IBAction)browse:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];

    [openPanel setCanChooseFiles:NO];
    
    [openPanel setAllowsMultipleSelection:NO];
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        NSURL *url = [[openPanel URLs] objectAtIndex:0];
        
        if (((NSButton *)sender).tag == 0) {
            [_packageService setupProjectPath:url.relativePath];
            
            [_projectPathField setStringValue:url.relativePath];
        } else if (((NSButton *)sender).tag == 1) {
            [_packageService setupTargetPath:url.relativePath];
            
            [_savePathField setStringValue:url.relativePath];
        }
    }];
}

- (void)checkBoxDidClicked:(id)aSender {
    NSButtonCell *cell=(NSButtonCell *)[(NSTableView *)aSender selectedCell];

    if (cell.state == NSOnState) {
        [_packageService addBuidingScheme:cell.title];
    } else if (cell.state == NSOffState) {
        [_packageService removeBuildingScheme:cell.title];
    }
}

#pragma mark -
#pragma mark ----------- NSTableView DataSource -----------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_packageService numberOfProjectSchemes];
}

- (nullable id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(nullable NSTableColumn *)tableColumn
                     row:(NSInteger)row {
    NSString *scheme = [_packageService titleOfSchemeAtIndex:row];
    
    BOOL flag = [_packageService containtBuildingScheme:scheme];
    
    NSButtonCell* cell = [tableColumn dataCellForRow:row];
    
    [cell setTag:row];
    
    [cell setAction:@selector(checkBoxDidClicked:)];
    
    [cell setTarget:self];
    
    [cell setState:flag];
    
    [cell setTitle:scheme];
    
    return cell;
}

#pragma mark -
#pragma mark ----------- QPPackageService Delegate -----------

- (void)serviceWillStartPackage {
    [_progressInfoLabel setStringValue:@""];

    [_progressIndicator startAnimation:nil];
}

- (void)service:(QPPackageService *)aService packageDidFinished:(NSString *)aTarget {
    [_progressIndicator stopAnimation:nil];

    [[NSWorkspace sharedWorkspace] selectFile:nil
                     inFileViewerRootedAtPath:aTarget];
}

- (void)service:(QPPackageService *)aService updateProgressInfo:(NSString *)aInfo {
    
    if (_progressInfoLabel.stringValue.length) {
        aInfo = [@"\n" stringByAppendingString:aInfo];
    }
    
    aInfo = [_progressInfoLabel.stringValue stringByAppendingString:aInfo];
    
    [_progressInfoLabel setStringValue:aInfo];
}

- (void)serviceWillParseProjectSchemes {
    [_progressInfoLabel setStringValue:@""];

    [_progressIndicator startAnimation:nil];
}

- (void)parseProjectSchemesDidFinished {
    [_progressInfoLabel setStringValue:@""];

    [_progressIndicator stopAnimation:nil];

    [_tableView reloadData];
}

@end
