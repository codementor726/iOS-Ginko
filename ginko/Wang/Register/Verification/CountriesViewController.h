//
//  CountriesViewController.h
//  ginko
//
//  Created by STAR on 1/3/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Country.h"

@class CountriesViewController;

@protocol CountriesViewControllerDelegate <NSObject>

- (void)countriesViewControllerDidCancel:(CountriesViewController *)countriesViewController;
- (void)countriesViewController:(CountriesViewController *)countriesViewController didSelectCountry:(Country *)country;

@end

@interface CountriesViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray<NSArray<Country *> *> *unfilteredCountries;
@property (nonatomic, strong) NSMutableArray<NSArray<Country *> *> *filteredCountries;

@property (nonatomic, strong) Country *selectedCountry;
@property (nonatomic, strong) NSArray<NSString *> *majorCountryLocaleIdentifiers;

@property (nonatomic, weak) id<CountriesViewControllerDelegate> delegate;

@property (nonatomic, strong) UISearchController *searchController;
@end
