//
//  ContactIImgViewController.m
//  WhatsApp Legacy
//
//  Created by Gian Luca Russo on 31/07/24.
//  Copyright (c) 2024 Gian Luca Russo. All rights reserved.
//

#import "ContactIImgViewController.h"

@interface ContactIImgViewController ()

@end

@implementation ContactIImgViewController
@synthesize imgView, viewNav;
#define MINIMUM_SCALE 1.0
#define MAXIMUM_SCALE 2.0

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
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.imgView addGestureRecognizer:pinchGestureRecognizer];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.imgView addGestureRecognizer:panGestureRecognizer];
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [doubleTapGestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    [self.imgView addGestureRecognizer:doubleTapGestureRecognizer];
    self.imgView.userInteractionEnabled = YES;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    UIView *view = pinchGestureRecognizer.view;
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat currentScale = view.frame.size.width / view.bounds.size.width;
        CGFloat newScale = currentScale * pinchGestureRecognizer.scale;
        
        if (newScale > MINIMUM_SCALE && newScale < MAXIMUM_SCALE) {
            view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        }
        
        pinchGestureRecognizer.scale = 1.0;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *view = panGestureRecognizer.view;
    CGPoint translation = [panGestureRecognizer translationInView:view.superview];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat currentScale = view.frame.size.width / view.bounds.size.width;
        
        if (currentScale > 1.0) {
            CGPoint newCenter = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
            
            // Limitar el movimiento para que la imagen no salga del borde de la pantalla
            CGFloat maxX = view.superview.bounds.size.width / 2 + (view.frame.size.width - view.superview.bounds.size.width) / 2;
            CGFloat minX = view.superview.bounds.size.width / 2 - (view.frame.size.width - view.superview.bounds.size.width) / 2;
            CGFloat maxY = view.superview.bounds.size.height / 2 + (view.frame.size.height - view.superview.bounds.size.height) / 2;
            CGFloat minY = view.superview.bounds.size.height / 2 - (view.frame.size.height - view.superview.bounds.size.height) / 2;
            
            newCenter.x = MAX(MIN(newCenter.x, maxX), minX);
            newCenter.y = MAX(MIN(newCenter.y, maxY), minY);
            
            view.center = newCenter;
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTapGestureRecognizer {
    UIView *view = doubleTapGestureRecognizer.view;
    CGFloat currentScale = view.frame.size.width / view.bounds.size.width;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (currentScale > MINIMUM_SCALE) {
            // Restablecer la transformación a la identidad con animación
            view.transform = CGAffineTransformIdentity;
            // Restablecer la posición al centro de la superview con animación
            view.center = CGPointMake(view.superview.bounds.size.width / 2, view.superview.bounds.size.height / 2);
        } else {
            // Aplicar el zoom máximo con animación
            view.transform = CGAffineTransformMakeScale(MAXIMUM_SCALE, MAXIMUM_SCALE);
            // Ajustar la posición para que la imagen esté centrada
            view.center = CGPointMake(view.superview.bounds.size.width / 2, view.superview.bounds.size.height / 2);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}

/*-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}*/

- (void)dealloc {
    [self setViewNav:nil];
    [super dealloc];
}
- (IBAction)viewDone:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
