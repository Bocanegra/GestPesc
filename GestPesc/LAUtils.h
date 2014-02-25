//
//  LAUtils.h
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 18/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LAUtils : NSObject

+ (void)alertStatus:(NSString *)textMsg withTitle:(NSString *)title andDelegate:(id /*<UIAlertViewDelegate>*/)delegate;

+ (NSDate *)fechaDesdeHoy;


@end
