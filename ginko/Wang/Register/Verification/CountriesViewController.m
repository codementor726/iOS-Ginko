//
//  CountriesViewController.m
//  ginko
//
//  Created by STAR on 1/3/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import "CountriesViewController.h"
#import "Countries.h"

@interface CountriesViewController () <UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@end

@implementation CountriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Your Country";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    // reset global appearance
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:COLOR_PURPLE_THEME];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    
    _majorCountryLocaleIdentifiers = [NSArray new];
    
    self.unfilteredCountries = [self partitionedArray:[Countries countries]];
    
    [self.unfilteredCountries insertObject:[Countries countriesFromCountryCodes:_majorCountryLocaleIdentifiers] atIndex:0];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.delegate = self;
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.delegate = self;
    [_searchController.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = _searchController.searchBar;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.definesPresentationContext = YES;

    [self.tableView registerNib:[UINib nibWithNibName:@"CountryCell" bundle:nil] forCellReuseIdentifier:@"CountryCell"];
    
    if (_selectedCountry) {
        for (NSArray<Country *> *countries in _unfilteredCountries) {
            NSUInteger index = [countries indexOfObject:_selectedCountry];
            if (index != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:[_unfilteredCountries indexOfObject:countries]];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
    }
}

- (void)cancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(countriesViewControllerDidCancel:)])
            [_delegate countriesViewControllerDidCancel:self];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUnfilteredCountries:(NSMutableArray<NSArray<Country *> *> *)unfilteredCountries {
    _unfilteredCountries = unfilteredCountries;
    _filteredCountries = unfilteredCountries;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _filteredCountries.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_filteredCountries[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CountryCell"];
    
    // Configure the cell...
    Country *country = _filteredCountries[indexPath.section][indexPath.row];
    cell.textLabel.text = country.name;
    cell.detailTextLabel.text = [@"+" stringByAppendingString:country.phoneExtension];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (country.countryCode == _selectedCountry.countryCode) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [cell setNeedsLayout];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray<Country *> *countries = _filteredCountries[section];
    if ([countries count] == 0)
        return nil;
    
    if (section == 0)
        return @"";
    
    return [[UILocalizedIndexedCollation currentCollation] sectionTitles][section - 1];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _searchController.active ? nil : [UILocalizedIndexedCollation currentCollation].sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index + 1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(countriesViewController:didSelectCountry:)]) {
        [_delegate countriesViewController:self didSelectCountry:_filteredCountries[indexPath.section][indexPath.row]];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)willPresentSearchController:(UISearchController *)searchController {
    [self.tableView reloadSectionIndexTitles];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [self.tableView reloadSectionIndexTitles];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

- (void)searchForText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        _filteredCountries = _unfilteredCountries;
    } else {
        NSArray<Country *> *allCountries = [[Countries countries] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", text]];
        _filteredCountries = [self partitionedArray:allCountries];
        [_filteredCountries insertObject:[NSArray new] atIndex:0]; // empty section for our favories
    }
    
    [self.tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSString *searchString = searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

- (NSMutableArray<NSArray<Country *> *> *) partitionedArray:(NSArray<Country *> *)array {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSUInteger numberOfSectionTitles = collation.sectionTitles.count;
    
    NSMutableArray<NSMutableArray<Country *> *> *unsortedSections = [NSMutableArray new];
    
    for (int i = 0; i < numberOfSectionTitles; i++)
        [unsortedSections addObject:[NSMutableArray new]];
    
    for (Country *country in array) {
        NSUInteger sectionIndex = [collation sectionForObject:country collationStringSelector:@selector(name)];
        [unsortedSections[sectionIndex] addObject:country];
    }
    
    NSMutableArray<NSArray<Country *> *> *sortedSections = [NSMutableArray new];
    for (NSMutableArray *section in unsortedSections) {
        NSArray<Country *> *sortedSection = [collation sortedArrayFromArray:section collationStringSelector:@selector(name)];
        [sortedSections addObject:sortedSection];
    }
    return sortedSections;
}

@end
