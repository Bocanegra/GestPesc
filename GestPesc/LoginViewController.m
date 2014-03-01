//
//  LAViewController.m
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 18/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import "LoginViewController.h"
#import "LAUtils.h"
#import "MBProgressHUD.h"

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
}

# pragma mark Login Actions

- (IBAction)backgroundClick:(id)sender {
    [usuarioTextField resignFirstResponder];
    [claveTextField resignFirstResponder];
}

- (IBAction)loginAction:(id)sender {
    @try {
        [usuarioTextField resignFirstResponder];
        [claveTextField resignFirstResponder];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Comprobando...";
        [hud show:YES];
        [PFUser logInWithUsernameInBackground:usuarioTextField.text
                                     password:claveTextField.text
                                        block:^(PFUser *user, NSError *error) {
            [hud hide:YES];
            if (user) {
                // Login correcto
                NSLog(@"Login del usuario %@", usuarioTextField.text);
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UITabBarController *tabController = [storyboard instantiateViewControllerWithIdentifier:@"tabMenu"];
                [self presentViewController:tabController animated:YES completion:nil];
            } else {
                [LAUtils alertStatus:@"Usuario/clave erróneos" withTitle:@"Error" andDelegate:self];
            }
        }];
    } @catch (NSException * e) {
        NSLog(@"loginAction Exception: %@", e);
        [LAUtils alertStatus:@"Error al entrar" withTitle:@"Error" andDelegate:self];
    }
}

@end
