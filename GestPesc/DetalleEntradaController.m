//
//  DetalleEntradaController.m
//
//  Created by Luis Ángel García Muñoz on 27/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import "DetalleEntradaController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MBProgressHUD.h"
#import "LAUtils.h"
#import <Foundation/NSCharacterSet.h>


@interface DetalleEntradaController ()

@property (weak, nonatomic) IBOutlet UITextField *nombreProductoTextField;
@property (weak, nonatomic) IBOutlet UITextField *stockTotalTextField;
@property (weak, nonatomic) IBOutlet UITextField *precioTextField;
@property (weak, nonatomic) IBOutlet UITextField *stockDisponibleTextField;
@property (weak, nonatomic) IBOutlet PFImageView *fotoProducto;
@property (weak, nonatomic) IBOutlet UITextField *formatoCajaTextField;
@property (weak, nonatomic) IBOutlet UITextField *calidadTextField;
@property (weak, nonatomic) IBOutlet UITextField *fechaEnvioTextField;
@property (weak, nonatomic) IBOutlet UITextView *comentariosTextView;
@property (strong, nonatomic) PFObject *entrada;
@property NSDateFormatter *formatoFecha;
@property BOOL nuevaEntrada;

- (IBAction)cogerFotoEntrada:(id)sender;
- (IBAction)guardarEntrada:(id)sender;
- (void)configureView;
-(void)fechaEnvioCambiada:(NSNotification *)notification;


@end

@implementation DetalleEntradaController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.formatoFecha = [[NSDateFormatter alloc] init];
    [self.formatoFecha setDateFormat:@"dd/MM/yyyy"];
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gestión del detalle de la entrada

- (void)configureView {
    NSLog(@"configureView");
    // Actualiza la página de la entrada con los datos pasados
    if (self.entrada) {
        // Título de la pantalla
        self.title = [self.entrada objectForKey:@"nombre"];
        // Nombre del producto
        self.nombreProductoTextField.text = [self.entrada objectForKey:@"nombre"];
        // Imagen del producto
        PFFile *thumbnail = [self.entrada objectForKey:@"imagen"];
        PFImageView *thumbnailImageView = (PFImageView*)[self.view viewWithTag:201];
        thumbnailImageView.image = [UIImage imageNamed:@"BgLeather.png"];
        thumbnailImageView.file = thumbnail;
        [thumbnailImageView loadInBackground];
        // Stock, precio y disponible
        self.stockTotalTextField.text = [[self.entrada objectForKey:@"stock_total"] stringValue];
        self.precioTextField.text = [[self.entrada objectForKey:@"precio"] stringValue];
        self.stockDisponibleTextField.text = [[self.entrada objectForKey:@"stock_disponible"] stringValue];
        // Formato caja, fecha envío y calidad
        self.formatoCajaTextField.text = [[self.entrada objectForKey:@"formato_caja"] stringValue];
//        self.calidadTextField.text = [self.entrada objectForKey:@"fk_categoria"];
        NSDate *fecha = [self.entrada objectForKey:@"entregado"];
        self.fechaEnvioTextField.text = [self.formatoFecha stringFromDate:fecha];
        // Comentarios
        self.comentariosTextView.text = [self.entrada objectForKey:@"descripcion"];
    }
}

- (void)setEntradaObject:(PFObject *)miEntrada nueva:(BOOL)esNueva {
    if (_entrada != miEntrada) {
        _entrada = miEntrada;
        [self configureView];
    }
    self.nuevaEntrada = esNueva;
}

- (IBAction)guardarEntrada:(id)sender {
    NSLog(@"guardarEntrada");
    // Actualizamos los datos del objeto entrada
    // TODO: Comprobar datos de entrada
    @try {
        self.entrada[@"nombre"] = _nombreProductoTextField.text;
        self.entrada[@"stock_total"] = @([_stockTotalTextField.text integerValue]);
        self.entrada[@"precio"] = @([_precioTextField.text integerValue]);
        self.entrada[@"stock_disponible"] = @([_stockDisponibleTextField.text integerValue]);
        self.entrada[@"formato_caja"] = @([_formatoCajaTextField.text integerValue]);
        self.entrada[@"descripcion"] = _fechaEnvioTextField.text;
        //    [self.entrada setObject:_calidadTextField.text forKey:@"fk_categoria"];
        //    [self.entrada setObject:_fechaEnvioTextField.text forKey:@"entregado"];
        // Imagen en JPG, con escasa compresión
        NSData *imageData = UIImageJPEGRepresentation(_fotoProducto.image, 0.8);
        PFFile *imageFile = [PFFile fileWithName:@"foto.jpg" data:imageData];
        self.entrada[@"imagen"] = imageFile;
    } @catch (NSException *exception) {
        [LAUtils alertStatus:@"Datos no válidos, revíselos" withTitle:@"Error" andDelegate:self];
    }
    
    // Barra de progreso
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Actualizando";
    [hud show:YES];
    
    // Actualizamos el backend
    [self.entrada saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [hud hide:YES];
        if (!error) {
            // Correcto, se muestra un mensaje
            [LAUtils alertStatus:@"¡Entrada actualizada!" withTitle:@"Info" andDelegate:self.navigationController];
            // Notificamos a table view para que recargue las entradas desde Parse
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refrescarEntradas" object:self];
            // Dismiss the controller
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [LAUtils alertStatus:@"Hay problemas para actualizar la entrada" withTitle:@"Error" andDelegate:self.navigationController];
        }
        // Y volvemos a la lista de Entradas
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


#pragma mark - Métodos para la captura de imagen

- (IBAction)cogerFotoEntrada:(id)sender {
    NSLog(@"cogerFotoEntrada");
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return;
    }
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerCameraCaptureModePhoto;
    
    // Displays saved pictures from the Camera Roll album.
    mediaUI.mediaTypes = @[(NSString*)kUTTypeImage];
    
    // TODO: De momento no deja editar la foto, habrá que permitirlo
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self.navigationController presentViewController:mediaUI animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"didFinishPickingMediaWithInfo");
    // TODO: Falta reducir la foto a lo que necesitemos
    UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.fotoProducto.image = originalImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)fechaEnvioCambiada:(NSNotification *)notification {
    
}

#pragma mark - TextField and TextView delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.fechaEnvioTextField) {
        // Abro la vista para elegir la fecha de envío
        UIDatePicker* picker = [[UIDatePicker alloc] init];
        picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        picker.datePickerMode = UIDatePickerModeDateAndTime;
        [picker addTarget:self
                   action:@selector(fechaEnvioCambiada:)
         forControlEvents:UIControlEventValueChanged];
        CGSize pickerSize = [picker sizeThatFits:CGSizeZero];
        picker.frame = CGRectMake(0.0, 250, pickerSize.width, 460);
        [self.view addSubview:picker];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}


@end
