//
//  mainMapViewController.h
//  
//
//  Created by zack on 4/7/15.
//
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"

@interface mainMapViewController : UIViewController <NSURLSessionDelegate>
{
    NSMutableData *_responseData;
}
@property (weak, nonatomic) IBOutlet UIButton *viewToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *oneXButton;
@property (weak, nonatomic) IBOutlet UIButton *twoXButton;
@property (weak, nonatomic) IBOutlet UIButton *threeXButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *threeXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twoXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerButtonConstraint;
@property (strong, nonatomic) NSArray *timerButtons;
@property (strong, nonatomic) NSMutableDictionary *quakesDictionary;
@property (strong, nonatomic) NSMutableArray *dictionariesArray;

@property (nonatomic, assign) BOOL progressEnabled;
- (IBAction)clockButtonPressed:(id)sender;
- (IBAction)threeXPressed:(UIButton *)sender;
- (IBAction)twoXPressed:(UIButton *)sender;
- (IBAction)oneXPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet DACircularProgressView *progressView;
@property (nonatomic, assign) BOOL twoXActive;
@property (nonatomic, assign) BOOL threeXActive;
@property (weak, nonatomic) IBOutlet UIButton *listViewButton;
@property (strong, nonatomic) NSArray *sortedArray;
@property (strong, nonatomic) NSNumber *goToLongitude;
@property (strong, nonatomic) NSNumber *goToLatitude;
@property (nonatomic, assign) BOOL listIsSender;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *firstLaunchView;
- (IBAction)xButtonPressed:(id)sender;

@end
