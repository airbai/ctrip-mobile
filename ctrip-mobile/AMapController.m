//
//  AMapController.m
//  ctrip-mobile
//
//  Created by caoguangyao on 8/14/13.
//  Copyright (c) 2013 caoguangyao. All rights reserved.
//

#import "AMapController.h"

@interface AMapController ()

@end

@implementation AMapController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = self.name;
    
    //MKMapView *mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)] autorelease];
    /*CGFloat height = [[UIScreen mainScreen] bounds].size.height;//-64;
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    
    NSLog(@"height == %f",height);
    
    CGRect frame = CGRectMake(0, 0, width, height);*/
    
    MAMapView *mapView = [[[MAMapView alloc] initWithFrame:self.view.frame] autorelease];
    mapView.delegate = self;
    
    MACoordinateRegion region;
    
    region.span.latitudeDelta = 0.05;
    region.span.longitudeDelta = 0.05;
    region.center = self.coordinate;
    
    [mapView setRegion:region];
    [mapView setCameraDegree:22.0 animated:YES duration:1.0];
    [mapView setRotationDegree:45 animated:YES duration:1.0];
    
    [self.view addSubview:mapView];
    
    MAPointAnnotation *annotation = [[[MAPointAnnotation alloc] init] autorelease];
	annotation.coordinate = self.coordinate;
    annotation.title = self.address;
    annotation.subtitle =self.name;
    
    [mapView addAnnotation:annotation];
}

-(MAAnnotationView *) mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    MAPinAnnotationView *pinView = nil;
    
    static NSString *pinIdentify = @"pinindetify";
    
    pinView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentify];
    
    if (pinView == nil) {
        pinView = [[[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentify]autorelease];
        
        pinView.pinColor = MAPinAnnotationColorRed;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
        
    }
    
    return pinView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
