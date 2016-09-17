//
//  ViewController.h
//  TestPushDown
//
//  Created by Jindal Joshi on 02/09/16.
//  Copyright © 2016 Jindal Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestPushDown-Swift.h"

@interface TransactionsViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tblHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblHt;

@end

