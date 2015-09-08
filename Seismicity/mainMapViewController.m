//
//  mainMapViewController.m
//  
//
//  Created by zack on 4/7/15.
//
//
#import "DACircularProgressView.h"
#import "mainMapViewController.h"
#import <QuartzCore/QuartzCore.h> 
#import "ListViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface mainMapViewController ()

@end

@implementation mainMapViewController {
    GMSMapView *mapView;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"listSegue"]) {
        ListViewController *vc = (ListViewController*)segue.destinationViewController;
        
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        UIImage *currentContextImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        vc.previousContextImage = currentContextImage;
        vc.sortedArray = _sortedArray;
        vc.parent = self;
        
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    if (_goToLongitude && _goToLatitude) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[_goToLatitude floatValue]  longitude:[_goToLongitude floatValue] zoom:6];
        [mapView setCamera:camera];
        _goToLongitude = nil;
        _goToLatitude = nil;
    }
}
-(void)firstLaunch
{

    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    
    if (![defaults objectForKey:@"FirstLaunch"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        
        _firstLaunchView.layer.cornerRadius = 20;
        _firstLaunchView.clipsToBounds = YES;
        _firstLaunchView.hidden = NO;
   
        
        
        
        
        
        [defaults setObject:@"NO" forKey:@"FirstLaunch"];
        
        
        
        
        
        
    }
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self firstLaunch];
    
    
    
    _progressView.trackTintColor = [UIColor clearColor];
    _progressView.backgroundColor = [UIColor clearColor];
    //_progressView.roundedCorners = YES;
    _progressView.thicknessRatio = 0.1;
    UIImage *lines = [[UIImage imageNamed:@"linesButton@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_listViewButton setImage:lines forState:UIControlStateNormal];
    _listViewButton.tintColor = [UIColor whiteColor];
    _listViewButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    
    
    _progressView.hidden = YES;
    _quakesDictionary = [[NSMutableDictionary alloc] init];
    _dictionariesArray = [[NSMutableArray alloc ]init];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:13 longitude:85 zoom:0];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.frame = [UIScreen mainScreen].bounds;
   [self.view insertSubview:mapView belowSubview:_oneXButton];
    
    
    
    _timerButtons = @[_oneXButton, _twoXButton, _threeXButton];
    for (UIButton *button in _timerButtons) {
        button.hidden = YES;
        [self roundAndShadowButton:button];
        button.layer.shadowOpacity = 0.0f;
    }
    [self roundAndShadowButton:_viewToggleButton];
    [self roundAndShadowButton:_listViewButton];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTap:) ];
    [_viewToggleButton addGestureRecognizer:longPress];
    _oneXConstraint.constant = 20;
    _twoXConstraint.constant = 20;
    _threeXConstraint.constant = 20;
    
    [self urlCall];
    
   
  
    
}
-(void)viewDidAppear:(BOOL)animated
{
    if (!_listIsSender) {
       [self shakeViewVertical:_viewToggleButton withConstraint:_timerButtonConstraint];
    }
    
    
    
}
-(void)shakeViewVertical:(id)view withConstraint:(NSLayoutConstraint*)constraint{
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        constraint.constant = constraint.constant +8;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            constraint.constant = constraint.constant -16;
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                constraint.constant = constraint.constant +8;
                [self.view layoutIfNeeded];
                
            } completion:^(BOOL finished) {
                
                
            }];
            
        }];
    }];
    
}
-(void)pulseMarkerWithCoordinates:(CLLocationCoordinate2D)coordinates title:(NSString*)title locationDescription:(NSString*)location withMag:(NSNumber*)mag withDelay:(float)delay
{

    if (_progressEnabled ==NO) {
        _progressEnabled = YES;
        _progressView.hidden = NO;
        float timeInterval = 0.01;
        if (_twoXActive) {
            timeInterval = timeInterval/(float)2;
        }
        else if (_threeXActive)
        {
            timeInterval = timeInterval/(float)3;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
        });
        
        
    }
    
    GMSMarker * marker = [[GMSMarker alloc] init];
    marker.position = coordinates;
    marker.title = title;
    marker.snippet =  location;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    
    if ([mag doubleValue] < 2.5) {
     UIImage *flagIcon =[[UIImage imageNamed:@"seismarker2@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        marker.icon = flagIcon;
    }
    else if ([mag doubleValue] <5) {
      UIImage *flagIcon =[[UIImage imageNamed:@"seismarkerYellow@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        marker.icon = flagIcon;
    }
    else
    {
       UIImage *flagIcon =[[UIImage imageNamed:@"seismarkerRed@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        marker.icon = flagIcon;
    }
    
    
    
    
   // marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:delay
                                     target:self
                                   selector:@selector(deployMarker:)
                                   userInfo:marker repeats:NO]; 
    });
   
    
    //marker.map = mapView;
    
  /*  CGPoint markerPoint = [mapView.projection pointForCoordinate:marker.position];
  
    UIView *pulseView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    pulseView.layer.borderWidth = 2;
    pulseView.layer.borderColor = [UIColor redColor].CGColor;
    
    pulseView.backgroundColor = [UIColor redColor];
    [self.view addSubview:pulseView];*/
    /*[UIView animateWithDuration:0.5 animations:^{
        pulseView.transform = CGAffineTransformMakeScale(3, 3);
    } completion:^(BOOL finished) {
        [pulseView removeFromSuperview];
    }];
    */
     
   
}
-(void)updateProgress:(NSTimer*)timer{
    if (_progressView.progress == 1) {
        [timer invalidate];
        
        [UIView animateWithDuration:0.3 animations:^{
            _progressView.alpha = 0;
        } completion:^(BOOL finished) {
           _progressView.hidden = YES;
            _progressView.alpha = 1.0;
            _progressEnabled = NO;
            _progressView.progress = 0;
        }];
        
        return;
    }
    _progressView.progress = _progressView.progress +0.001f;
    

    
}
-(void)deployMarker:(NSTimer*)timer
{
    
    GMSMarker *marker = [timer userInfo];
    marker.map = mapView;
}
-(void)longPressTap:(UILongPressGestureRecognizer*)sender
{
   
    
    
    
    if (sender.state ==UIGestureRecognizerStateBegan) {
       [self animateTimerButtonsWithDelay:0 andConstraintFloat:98 forView:_threeXButton andConstraint:_threeXConstraint];
    [self animateTimerButtonsWithDelay:0.1 andConstraintFloat:176 forView:_twoXButton andConstraint:_twoXConstraint];
    [self animateTimerButtonsWithDelay:0.2 andConstraintFloat:254 forView:_oneXButton andConstraint:_oneXConstraint];
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
-(void)animateTimerButtonsWithDelay:(float)delay andConstraintFloat:(float)constraintFloat forView:(UIButton*)button andConstraint:(NSLayoutConstraint*)constraint
{
    
    [(UIButton*)button setHidden:NO];
    [self.view layoutIfNeeded];
    
    if (constraint.constant == 98 | constraint.constant == 176 | constraint.constant == 254) {
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            constraint.constant = 20;
            button.layer.shadowOpacity = 0.0f;
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            [(UIButton*)button setHidden:YES];
            
        }];
    }
    
    else {
    
    [UIView animateWithDuration:0.3 delay:delay usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        constraint.constant = constraintFloat;
        button.layer.shadowOpacity = 0.45f;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
    }
}
-(float)calculateDurationForArray:(NSArray*)array
{
    id firstObject = [array firstObject];
    id lastObject = [array lastObject];
    NSNumber *earliestTime= [[firstObject objectForKey:@"properties"] objectForKey:@"time"];
    NSNumber *latestTime = [[lastObject objectForKey:@"properties"] objectForKey:@"time"];
    long range = [earliestTime longValue] - [latestTime longValue];
    float timeUnit = (float)10/(float)range;
    if (_twoXActive) {
        timeUnit = timeUnit/(float)2;
    }
    if (_threeXActive) {
        timeUnit = timeUnit/(float)3;
    }
    return timeUnit;
    
    
    
    
}
#pragma mark - NSURLSession
-(void)urlCall
{
    //NSURLSession
    [mapView clear];
    [_dictionariesArray removeAllObjects];
    [_quakesDictionary removeAllObjects];
    
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *method = @"query";
    NSString *parameters= @"format=geojson&starttime=2014-01-01&endtime=2014-01-02";
    NSString *USGSUrlString = [NSString stringWithFormat: @"http://comcat.cr.usgs.gov/fdsnws/event/1/%@?%@",method ,parameters];
    
    [[session dataTaskWithURL:[NSURL URLWithString:USGSUrlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        _quakesDictionary = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error]];
       // _quakesDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        
        NSArray *quakesFeaturesArray = [_quakesDictionary objectForKey:@"features"];
       
        
        
        
        for (NSDictionary *object in quakesFeaturesArray) {
            NSDictionary *objectDictionary = object;
            [_dictionariesArray addObject:  objectDictionary];
        
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        _sortedArray = [quakesFeaturesArray sortedArrayUsingDescriptors:sortDescriptors];
       float timeUnit =  [self calculateDurationForArray:_sortedArray];
        NSNumber *earliestTime = [[[_sortedArray firstObject] objectForKey:@"properties"] objectForKey:@"time"];
        
        
        
        for (id object in _dictionariesArray) {
            
            
            NSNumber *time = [[object objectForKey:@"properties"] objectForKey:@"time"];
            long difference = [earliestTime longValue] - [time longValue];
            float delay = difference * timeUnit;
            
            
            NSString *titleString = [[object objectForKey:@"properties"] objectForKey:@"title"];
            NSArray *array = [[object  objectForKey:@"geometry"] objectForKey:@"coordinates"];
            NSNumber *longitude = [array objectAtIndex:0];
            NSNumber *latitude = [array objectAtIndex:1];
            NSNumber *depth = [array objectAtIndex:2];
            NSNumber *magnitude =[[object objectForKey:@"properties"] objectForKey:@"mag"];
            NSArray *stringArray = [titleString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *title = [NSString stringWithFormat:@"%@ %@", stringArray[0], stringArray[1]];
            NSString *locationString = @"";
            for (id object in stringArray) {
                if (object == [stringArray objectAtIndex:0] || object == [stringArray objectAtIndex:2] || object == [stringArray objectAtIndex:1] ) {
                    
                }
                else
                {
                   locationString =  [[locationString stringByAppendingString:object] stringByAppendingString:@" "];
                }
            }
            
        
                                                                                             
          
            
            
            [self pulseMarkerWithCoordinates:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]) title:title locationDescription:locationString withMag:magnitude withDelay:delay];
            
        }
        
        
        
       
    }] resume];
}
-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
}


- (IBAction)clockButtonPressed:(id)sender {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

    
    [self urlCall];
    
}

- (IBAction)threeXPressed:(UIButton *)sender {
    _threeXActive = YES;
    [_viewToggleButton setTitle:@"3x" forState:UIControlStateNormal];
    [self animateTimerButtonsWithDelay:0 andConstraintFloat:98 forView:_threeXButton andConstraint:_threeXConstraint];
    [self animateTimerButtonsWithDelay:0.1 andConstraintFloat:176 forView:_twoXButton andConstraint:_twoXConstraint];
    [self animateTimerButtonsWithDelay:0.2 andConstraintFloat:254 forView:_oneXButton andConstraint:_oneXConstraint];
}

- (IBAction)twoXPressed:(UIButton *)sender {
    _twoXActive = YES;
    [_viewToggleButton setTitle:@"2x" forState:UIControlStateNormal];
    [self animateTimerButtonsWithDelay:0 andConstraintFloat:98 forView:_threeXButton andConstraint:_threeXConstraint];
    [self animateTimerButtonsWithDelay:0.1 andConstraintFloat:176 forView:_twoXButton andConstraint:_twoXConstraint];
    [self animateTimerButtonsWithDelay:0.2 andConstraintFloat:254 forView:_oneXButton andConstraint:_oneXConstraint];
}

- (IBAction)oneXPressed:(UIButton *)sender {_twoXActive= NO;
    _threeXActive= NO;
    [_viewToggleButton setTitle:@"1x" forState:UIControlStateNormal];
    [self animateTimerButtonsWithDelay:0 andConstraintFloat:98 forView:_threeXButton andConstraint:_threeXConstraint];
    [self animateTimerButtonsWithDelay:0.1 andConstraintFloat:176 forView:_twoXButton andConstraint:_twoXConstraint];
    [self animateTimerButtonsWithDelay:0.2 andConstraintFloat:254 forView:_oneXButton andConstraint:_oneXConstraint];
    
}
- (IBAction)xButtonPressed:(id)sender {
    _firstLaunchView.hidden = YES;
}
@end
