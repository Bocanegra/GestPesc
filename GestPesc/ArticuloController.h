//
//  ArticuloController.h
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 26/02/14.
//  Copyright (c) 2014 Luis Ángel García Muñoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ArticuloController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property PFObject *entrada;

@end
