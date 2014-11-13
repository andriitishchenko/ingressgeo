//
//  ViewController.h
//  testRealLocation
//
//  Created by Andrii Tishchenko on 07.11.14.
//  Copyright (c) 2014 Andrii Tishchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet GMSMapView *viewMap;

@property (strong, nonatomic) CLLocationManager* locationAuthorizationManager;
@end

