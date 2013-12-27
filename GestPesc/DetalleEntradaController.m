//
//  DetalleEntradaController.m
//
//  Created by Luis Ángel García Muñoz on 27/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import "DetalleEntradaController.h"

@interface DetalleEntradaController ()

- (void)configureView;

@end

@implementation DetalleEntradaController

#pragma mark - Gestión del detalle de la entrada

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Actualiza la página de la entrada con los datos pasados
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
