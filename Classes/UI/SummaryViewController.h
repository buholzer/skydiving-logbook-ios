//
//  SummaryViewController.h
//  skydiveapp-4-iphone
//
//  Created by Tom Cain on 2/19/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "TableModel.h"

@interface SummaryViewController : UITableViewController<UITableViewDelegate,
														UITableViewDataSource>
{
	IBOutlet UITableViewCell *totalJumpsCell;
	IBOutlet UITableViewCell *totalFreefallTimeCell;
	IBOutlet UITableViewCell *totalFreefallDistanceCell;
	IBOutlet UITableViewCell *maxFreefallTimeCell;
	IBOutlet UITableViewCell *maxExitAltitudeCell;
	IBOutlet UITableViewCell *minDeploymentAltitudeCell;
	IBOutlet UITableViewCell *totalCutawaysCell;
	IBOutlet UITableViewCell *lastJumpCell;
	IBOutlet UITableViewCell *jumpsInYearCell;
	IBOutlet UITableViewCell *jumpsInMonthCell;
	
	IBOutlet UILabel *totalJumpsField;
	IBOutlet UILabel *totalFreefallTimeField;
	IBOutlet UILabel *totalFreefallDistanceField;
	IBOutlet UILabel *maxFreefallTimeField;
	IBOutlet UILabel *maxExitAltitudeField;
	IBOutlet UILabel *minDeploymentAltitudeField;
	IBOutlet UILabel *totalCutawaysField;
	IBOutlet UILabel *lastJumpField;
	IBOutlet UILabel *jumpsInYearField;
	IBOutlet UILabel *jumpsInMonthField;
	
	TableModel *tableModel;
}

@end
