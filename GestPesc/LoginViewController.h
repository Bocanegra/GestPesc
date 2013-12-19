//
//  LAViewController.h
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 18/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface LoginViewController : UIViewController <PFLogInViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usuarioTextField;
@property (weak, nonatomic) IBOutlet UITextField *claveTextField;
@property (weak, nonatomic) IBOutlet UIButton *entrarButton;
- (IBAction)loginAction:(id)sender;
- (IBAction)backgroundClick:(id)sender;
- (BOOL)isLoggedWith:(NSString *)user andPassword:(NSString *)password;

@end
