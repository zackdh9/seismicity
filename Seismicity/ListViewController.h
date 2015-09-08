//
//  ListViewController.h
//  
//
//  Created by zack on 4/25/15.
//
//

#import <UIKit/UIKit.h>
#import "mainMapViewController.h"

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) UIImage *previousContextImage;
@property (strong, nonatomic) NSArray *sortedArray;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backButtonPressed:(UIButton *)sender;
@property (strong, nonatomic) mainMapViewController *parent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backConstraint;


@end
