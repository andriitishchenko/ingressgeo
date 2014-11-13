//
//  ViewController.m
//  testRealLocation
//
//  Created by Andrii Tishchenko on 07.11.14.
//  Copyright (c) 2014 Andrii Tishchenko. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<CLLocationManagerDelegate>
@end

@implementation ViewController{
    BOOL firstLocationUpdate_;
    
}
@synthesize locationAuthorizationManager=_locationAuthorizationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableMyLocation];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.viewMap.myLocationEnabled = YES;
    self.viewMap.settings.compassButton = YES;
    self.viewMap.settings.myLocationButton = YES;
    self.viewMap.mapType = kGMSTypeNormal;
    
    
//    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:30.868
//                                                            longitude:50.2086
//                                                                 zoom:12];
//    self.viewMap.camera = camera;
    [self.viewMap addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewMap.myLocationEnabled = YES;
    });
}

- (void)dealloc {
    [self.viewMap removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        self.viewMap.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:18];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)ckuck:(id)sender {

    NSLog(@"Ok");
    
}

- (void)enableMyLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined)
        [self requestLocationAuthorization];
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
        return; // we weren't allowed to show the user's location so don't enable
    else
        [self.viewMap setMyLocationEnabled:YES];
}

// Ask the CLLocationManager for location authorization,
// and be sure to retain the manager somewhere on the class

- (void)requestLocationAuthorization
{
    _locationAuthorizationManager = [[CLLocationManager alloc] init];
    _locationAuthorizationManager.delegate = self;
    [_locationAuthorizationManager requestWhenInUseAuthorization];
    
}

// Handle the authorization callback. This is usually
// called on a background thread so go back to main.

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        [self performSelectorOnMainThread:@selector(enableMyLocation) withObject:nil waitUntilDone:[NSThread isMainThread]];
        
        _locationAuthorizationManager.delegate = nil;
        _locationAuthorizationManager = nil;
    }
}

@end
