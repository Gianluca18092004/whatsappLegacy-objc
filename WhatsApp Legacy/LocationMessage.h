//
//  LocationMessage.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 20/09/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JSBubbleView.h"

@interface LocationMessage : UIView

- (id)initWithLatitude:(float)latitude andLongitude:(float)longitude;
- (void)setup;
@property (retain, nonatomic) IBOutlet UIView* view;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;

@end
