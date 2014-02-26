//
//  DetalleEntradaController.h
//
//  Created by Luis Ángel García Muñoz on 27/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DetalleEntradaController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

- (void)refrescaEntrada:(NSNotification *)notification;
- (void)setEntradaObject:(PFObject *)miEntrada nueva:(BOOL)esNueva;

@end
