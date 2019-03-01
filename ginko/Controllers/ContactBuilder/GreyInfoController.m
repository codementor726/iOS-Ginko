//
//  GreyInfoController.m
//  GINKO
//
//  Created by mobidev on 5/20/14.
//  Copyright (c) 2014 Song Qi. All rights reserved.
//

#import "GreyInfoController.h"

@interface GreyInfoController ()
{
    NSMutableArray *arrInfoFiledNames;
    NSMutableArray *arrAvailableFields;
    
    NSMutableArray *arrSelectedTable;
    
}
@end

@implementation GreyInfoController
@synthesize navView, tblInfoItems;
@synthesize parentController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrInfoFiledNames = [[NSMutableArray alloc] initWithObjects:@"Company", @"Mobile", @"Mobile#2", @"Phone", @"Phone#2", @"Phone#3", @"Email", @"Email#2", @"Address", @"Address#2", @"Fax", @"Birthday", @"Facebook", @"Twitter", @"Website", @"Custom", @"Custom#2", @"Custom#3", nil];
    arrAvailableFields = [[NSMutableArray alloc] init];
    
    arrSelectedTable = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadInfoFields];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadInfoFields
{
    for (int i=0; i<18; i++) {
        //importer class
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if ([parentController isKindOfClass:[CISyncDetailController class]]) {
            CISyncDetailController *vc = (CISyncDetailController *)parentController;
            dict = [vc.arrDataSource objectAtIndex:i];
        }  else if ([parentController isKindOfClass:[GreyDetailController class]]) {
           GreyDetailController *vc = (GreyDetailController *)parentController;
           dict = [vc.arrDataSource objectAtIndex:i];
        }
        
        if (![dict objectForKey:@"value"]) {
            [arrAvailableFields addObject:[arrInfoFiledNames objectAtIndex:i]];
        }
    }
    for (int j=0; j<[arrAvailableFields count]; j++) {
        [arrSelectedTable addObject:@"0"];
    }
    [tblInfoItems reloadData];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrAvailableFields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tblInfoItems dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] init];
    }
    
    [cell.textLabel setText:[arrAvailableFields objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _btnDone.hidden = !(tableView.indexPathsForSelectedRows.count);
    [arrSelectedTable replaceObjectAtIndex:indexPath.row withObject:@"1"];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    _btnDone.hidden = !(tableView.indexPathsForSelectedRows.count);
    [arrSelectedTable replaceObjectAtIndex:indexPath.row withObject:@"0"];
}

#pragma mark - Actions
- (IBAction)onCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDone:(id)sender
{
    for (int i =0; i < [arrAvailableFields count]; i++) {
        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        //UITableViewCell *cell = [tblInfoItems cellForRowAtIndexPath:indexPath];
        if ([[arrSelectedTable objectAtIndex:i]  isEqual: @"1"]) {
            int k = (int)[arrInfoFiledNames indexOfObject:[arrAvailableFields objectAtIndex:i]];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSString stringWithFormat:@"%d", k] forKey:@"name_index"];
            [dict setObject:@"" forKey:@"value"];
            //importer class
            if ([parentController isKindOfClass:[CISyncDetailController class]]) {
                CISyncDetailController *vc = (CISyncDetailController *)parentController;
                [vc.arrDataSource replaceObjectAtIndex:k withObject:dict];
            } else if ([parentController isKindOfClass:[GreyDetailController class]]) {
                GreyDetailController *vc = (GreyDetailController *)parentController;
                [vc.arrDataSource replaceObjectAtIndex:k withObject:dict];
            }
        }
    }
    [self dismissViewControllerAnimated:YES  completion:^{
        //importer class
        if ([parentController isKindOfClass:[CISyncDetailController class]]) {
            [(CISyncDetailController *)parentController loaddata];
        } else if ([parentController isKindOfClass:[GreyDetailController class]]) {
            GreyDetailController *vc = (GreyDetailController *)parentController;
           // [vc.tblInfo reloadData];
        }
    }];
}

@end
