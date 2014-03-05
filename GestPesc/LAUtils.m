//
//  LAUtils.m
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 18/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import "LAUtils.h"
#import "MBProgressHUD.h"

@implementation LAUtils


+ (void)alertStatus:(NSString *)textMsg withTitle:(NSString *)title andDelegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:textMsg
                                                       delegate:delegate
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    
    [alertView show];
}

+ (void)alertOkCancel:(NSString *)textMsg withTitle:(NSString *)title andDelegate:(id)delegate {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:textMsg
                                                       delegate:delegate
                                              cancelButtonTitle:@"Cancelar"
                                              otherButtonTitles:@"Ok", nil];
    
    [alertView show];
}

+ (NSDate *)fechaDesdeHoy {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComponents = [calendar components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    [nowComponents setHour:0];
    [nowComponents setMinute:0];
    [nowComponents setSecond:0];
    NSDate *hoy = [calendar dateFromComponents:nowComponents];
    return hoy;
}

@end
