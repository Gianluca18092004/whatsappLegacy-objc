//
//  LocationViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 03/12/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "LocationViewController.h"

#define METERS_PER_MILE 1609.344

@interface LocationViewController ()

@end

@implementation LocationViewController

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
    // Do any additional setup after loading the view from its nib.
    
    // Crear y configurar el MapView
    mapView.delegate = self;
    
    // Agregar el UITapGestureRecognizer al MapView
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
    [mapView addGestureRecognizer:tapGesture];
    [tapGesture release]; // Si no usas ARC
}

- (void)mapTapped:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        // Obtener el punto donde el usuario tocó
        CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
        
        // Convertir el punto a coordenadas geográficas
        CLLocationCoordinate2D coordinate = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
        
        // Mostrar un marcador o manejar la ubicación
        [self addAnnotationAtCoordinate:coordinate];
    }
}

- (void)addAnnotationAtCoordinate:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 1.5*METERS_PER_MILE, 1.5*METERS_PER_MILE);
    
    // Crear una anotación
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = @"Ubicación seleccionada";
    
    // Agregar la anotación al mapa
    [mapView removeAnnotations:mapView.annotations];
    [mapView addAnnotation:annotation];
    [mapView setRegion:viewRegion animated:YES];
    [annotation release]; // Si no usas ARC
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnDone:(id)sender {
    
}

- (IBAction)btnLocalize:(id)sender {
    mapView.showsUserLocation = YES;
}

- (IBAction)typeChanged:(id)sender {
    switch(((UISegmentedControl *) sender).selectedSegmentIndex){
        case 0:
            mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            mapView.mapType = MKMapTypeHybrid;
            break;
    }
}
@end
