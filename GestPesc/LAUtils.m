//
//  LAUtils.m
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 18/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import "LAUtils.h"

@implementation LAUtils


+ (void)alertStatus:(NSString *)textMsg withTitle:(NSString *)title andDelegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:textMsg
                                                       delegate:delegate
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    
    [alertView show];
}

@end
