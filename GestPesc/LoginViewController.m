//
//  LAViewController.m
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 18/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import "LoginViewController.h"
#import "LAUtils.h"


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

- (IBAction)loginAction:(id)sender {
    @try {
        NSLog(@"loginAction");
        if ([self isLoggedWith:usuarioTextField.text andPassword:claveTextField.text]) {
            NSLog(@"Login del usuario %@", usuarioTextField.text);
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UITabBarController *tabController = [storyboard instantiateViewControllerWithIdentifier:@"tabMenu"];
            [self presentViewController:tabController animated:YES completion:nil];
        } else {
            [LAUtils alertStatus:@"Usuario/clave erróneos" withTitle:@"Error" andDelegate:self];
        }
    } @catch (NSException * e) {
        NSLog(@"loginAction Exception: %@", e);
        [LAUtils alertStatus:@"Error al entrar" withTitle:@"Error" andDelegate:self];
    }
}

- (BOOL)isLoggedWith:(NSString *)user andPassword:(NSString *)password {
    if ([user isEqualToString:@"luis"] && [password isEqualToString:@"luis"] ) {
        return YES;
    }
    return NO;
}



@end
