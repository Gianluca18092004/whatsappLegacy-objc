//
//  LocationViewController.h
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 03/12/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface LocationViewController : UIViewController <MKMapViewDelegate>
{
    IBOutlet MKMapView *mapView;
}

- (IBAction)btnCancel:(id)sender;
- (IBAction)btnDone:(id)sender;
- (IBAction)btnLocalize:(id)sender;
- (IBAction)typeChanged:(id)sender;

@end
