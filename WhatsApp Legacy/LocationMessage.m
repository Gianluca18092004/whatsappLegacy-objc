//
//  LocationMessage.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 20/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "LocationMessage.h"

#define IS_IOS4orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)

@implementation LocationMessage
@synthesize view;
@synthesize mapView;

- (id)initWithLatitude:(float)latitude andLongitude:(float)longitude
{
    self = [super init];
    if (self) {
        [self setup];
        
        CLLocationCoordinate2D coords;
        coords.latitude = latitude;
        coords.longitude = longitude;
        
        MKCoordinateSpan span;
        span.latitudeDelta = 0.005f;
        span.longitudeDelta = 0.005f;
        
        MKCoordinateRegion myRegion = MKCoordinateRegionMake(coords, span);
        [mapView setRegion:myRegion animated:YES];
        
        if(IS_IOS4orHIGHER){
            MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
            point.coordinate = coords;
            [mapView addAnnotation:point];
        }
        
        self.mapView.clipsToBounds = YES;
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"LocationMessage" owner:self options:nil];
    self.frame = CGRectMake(0, 0, 220, 220);
    self.tag = (NSInteger)@"LocationMessage";
    [self addSubview:self.view];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)dealloc {
    [mapView release];
    [super dealloc];
}

@end
