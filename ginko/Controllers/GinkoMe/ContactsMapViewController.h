//
//  ContactsMapViewController.h
//  ginko
//
//  Created by ccom on 1/8/16.
//  Copyright © 2016 com.xchangewithme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GinkoMeTabController.h"
#import "ExchangedInfoCell.h"
#import "NotExchangedInfoCell.h"
#import "EntityCell.h"
#import "QTree.h"

@interface ContactsMapViewController : UIViewController<GinkoMeTabDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, ExchangedInfoCellDelegate, NotExchangedInfoCellDelegate, EntityCellDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) QTree *qTree;
//@property(nonatomic, strong) QTree *purpleTree;
//@property(nonatomic, strong) QTree *greyTree;
//@property(nonatomic, strong) QTree *entityTree;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

- (void)reloadEntitiesForMap;
@end
