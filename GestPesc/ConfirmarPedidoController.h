//
//  ConfirmarPedidoController.h
//  GestPesc
//
//  Created by Luis Angel on 10/01/14.
//  Copyright (c) 2014 Luis Ángel García Muñoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface ConfirmarPedidoController : UITableViewController <UINavigationControllerDelegate>

- (void)setPedidoObject:(PFObject *)miPedido;

@end
