//
//  ListViewController.m
//  
//
//  Created by zack on 4/25/15.
//
//

#import "ListViewController.h"
#import "mainMapViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _backgroundImageView.image = _previousContextImage;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    
    UIImage *back = [[UIImage imageNamed:@"backArrow@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_backButton setImage:back forState:UIControlStateNormal];
    _backButton.tintColor = [UIColor whiteColor];
    _backButton.imageEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 13);
    [self roundAndShadowButton:_backButton];
    
    
    
    
    
    
    
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{   [self.view layoutIfNeeded];
     [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _backConstraint.constant = 80;
            
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            
        }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"quakeCell" forIndexPath:indexPath];
    
    UILabel *magLabel = (UILabel*)[cell viewWithTag:1];
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
    UILabel *depthLabel = (UILabel*)[cell viewWithTag:3];
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:4];
    
    
    
    
    id object = _sortedArray[indexPath.row];
    
    //magnitude
    NSNumber *magnitudeRough =[[object objectForKey:@"properties"] objectForKey:@"mag"];
    NSNumberFormatter *f = [NSNumberFormatter new];
    [f setMaximumFractionDigits:1];
    [f setMinimumFractionDigits:1];
    [f setMinimumIntegerDigits:1];
    [f setMinimum:0];
    if (magnitudeRough.floatValue <0) {
        magnitudeRough = [NSNumber numberWithDouble:fabs([magnitudeRough doubleValue])];
    }
    NSString *magnitude = [f stringFromNumber:magnitudeRough];
    
    
    if (magnitude.floatValue <2.5) {
        magLabel.textColor = [UIColor colorWithRed:76.0/255.0f green:149/255.0f blue:197/255.0f alpha:1];
    }
    else if (magnitude.floatValue < 5)
    {
        magLabel.textColor = [UIColor colorWithRed:254.0/255.0f green:213/255.0f blue:24/255.0f alpha:1];
    }
    else
    {
        magLabel.textColor = [UIColor colorWithRed:255.0/255.0f green:71/255.0f blue:10/255.0f alpha:1];
    }
    
    
    
    
    magLabel.text = magnitude ;
    
    //title
     NSString *titleString = [[object objectForKey:@"properties"] objectForKey:@"title"];
    NSArray *stringArray = [titleString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *locationString = @"";
    for (id object in stringArray) {
        if (object == [stringArray objectAtIndex:0] || object == [stringArray objectAtIndex:2] || object == [stringArray objectAtIndex:1] ) {
            
        }
        else
        {
            locationString =  [[locationString stringByAppendingString:object] stringByAppendingString:@" "];
        }
    }
    titleLabel.text = locationString;
    
    //depth
    NSArray *array = [[object  objectForKey:@"geometry"] objectForKey:@"coordinates"];
    NSNumber *depth = [array objectAtIndex:2];
    depthLabel.text = [[depth stringValue] stringByAppendingString:@"km deep"];
    
    //date
    NSNumber *time = [[object objectForKey:@"properties"] objectForKey:@"time"];
    NSDate *Qdate = [NSDate dateWithTimeIntervalSince1970:[time longValue]];
    NSDateFormatter *dF = [[NSDateFormatter alloc] init];
    [dF setDateFormat:@"HH:mm"];
    [dF setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString *formattedTime = [dF stringFromDate:Qdate];
    
    dateLabel.text = formattedTime;
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _sortedArray.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    id object = [_sortedArray objectAtIndex:indexPath.row];
    NSArray *array = [[object  objectForKey:@"geometry"] objectForKey:@"coordinates"];
    _parent.goToLongitude =[array objectAtIndex:0];
    _parent.goToLatitude = [array objectAtIndex:1];
    _parent.listIsSender = YES;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)roundAndShadowButton:(UIButton*)button
{
    button.layer.cornerRadius = 35.0f;
    button.layer.masksToBounds = NO;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(5.0f , 5.0f);
    button.layer.shadowRadius = 5.0f;
    button.layer.shadowOpacity = 0.45f;
    
    
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


- (IBAction)backButtonPressed:(UIButton *)sender {
    _parent.listIsSender = YES;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
@end
