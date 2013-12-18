//
//  LAViewController.m
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 18/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize usuarioTextField;
@synthesize claveTextField;
@synthesize entrarButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Login Actions
- (IBAction)backgroundClick:(id)sender {
    [usuarioTextField resignFirstResponder];
    [claveTextField resignFirstResponder];
}

- (void)alertStatus:(NSString *)textMsg withTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:textMsg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (IBAction)loginAction:(id)sender {
    NSLog(@"loginAction");
    if ([[usuarioTextField text] isEqualToString:@""] || [[claveTextField text] isEqualToString:@""] ) {
        [self alertStatus:@"Faltan campos" withTitle:@"Error"];
    } else {
        
    }
}


@end
