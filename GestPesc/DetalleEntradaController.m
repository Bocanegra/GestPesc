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
#import "ArticuloController.h"


@interface DetalleEntradaController ()

@property (weak, nonatomic) IBOutlet UILabel *nombreProductoLabel;
@property (weak, nonatomic) IBOutlet UITextField *stockTotalTextField;
@property (weak, nonatomic) IBOutlet UITextField *precioTextField;
@property (weak, nonatomic) IBOutlet UITextField *stockDisponibleTextField;
@property (weak, nonatomic) IBOutlet PFImageView *fotoProductoImage;
@property (weak, nonatomic) IBOutlet UITextField *formatoCajaTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *fechaEnvioDatePicker;
@property (weak, nonatomic) IBOutlet UITextView *comentariosTextView;
@property (strong, nonatomic) PFObject *entrada;
@property NSDateFormatter *formatoFecha;
@property BOOL nuevaEntrada;
@property (assign, nonatomic) UITextField *currentResponder;
@property (assign, nonatomic) UITextView *currentResponderTV;

- (IBAction)cogerFotoEntrada:(id)sender;
- (IBAction)guardarEntrada:(id)sender;
- (void)configureView;

@end

@implementation DetalleEntradaController {
    NSArray *resultadosBusqueda;
    NSString *kTituloArticulo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatoFecha = [[NSDateFormatter alloc] init];
    [self.formatoFecha setDateFormat:@"dd/MM/yyyy"];
    [self configureView];
    // Se pone el título por defecto al nombre del Artículo
    kTituloArticulo = @"Introduce aquí el artículo...";
    _nombreProductoLabel.text = kTituloArticulo;
    // Creamos un nuevo notificador para refrescar los datos de la tabla
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refrescaEntrada:)
                                                 name:@"refrescaEntrada"
                                               object:nil];
    // Esto sirve para añadir botones de "Ok" y "Cancelar" a los teclados numéricos, que no tienen
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 32)];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancelar" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelarNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Ok" style:UIBarButtonItemStyleDone target:self action:@selector(okNumberPad)],
                           nil];
    _stockTotalTextField.inputAccessoryView = numberToolbar;
    _precioTextField.inputAccessoryView = numberToolbar;
    _stockDisponibleTextField.inputAccessoryView = numberToolbar;
    _formatoCajaTextField.inputAccessoryView = numberToolbar;
    _comentariosTextView.inputAccessoryView = numberToolbar;
}

- (void)cancelarNumberPad {
    [self.currentResponder resignFirstResponder];
    [self.currentResponderTV resignFirstResponder];
}

- (void)okNumberPad {
    if (self.currentResponder == _stockTotalTextField) {
        [_precioTextField becomeFirstResponder];
    } else if (self.currentResponder == _precioTextField) {
        [_stockDisponibleTextField becomeFirstResponder];
    } else if (self.currentResponder == _stockDisponibleTextField) {
        [_formatoCajaTextField becomeFirstResponder];
    } else {
        [self.currentResponder resignFirstResponder];
    }
    [self.currentResponderTV resignFirstResponder];
}

- (void)refrescaEntrada:(NSNotification *)notification {
    // Recarga la entrada, de momento sólo cambio el nombre
    self.nombreProductoLabel.text = _entrada[@"fk_articulo"][@"nombre"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Gestión del detalle de la entrada

- (void)setEntradaObject:(PFObject *)miEntrada nueva:(BOOL)esNueva {
    self.nuevaEntrada = esNueva;
    if (_entrada != miEntrada) {
        _entrada = miEntrada;
        [self configureView];
    }
}

- (void)configureView {
    // Actualiza la página de la entrada con los datos pasados
    if (self.entrada && !self.nuevaEntrada) {
        // Título de la pantalla
        self.title = @"Detalle entrada";
        // Nombre del producto
        self.nombreProductoLabel.text = _entrada[@"fk_articulo"][@"nombre"];
        // Imagen del producto
        PFFile *foto = _entrada[@"imagen"];
        self.fotoProductoImage.image = [UIImage imageNamed:@"photo-frame.png"];
        if (![foto isKindOfClass:[NSNull class]]) {
            self.fotoProductoImage.file = foto;
            [self.fotoProductoImage loadInBackground];
        }
        // Stock, precio y disponible
        self.stockTotalTextField.text = [_entrada[@"stock_total"] stringValue];
        self.precioTextField.text = [_entrada[@"precio"] stringValue];
        self.stockDisponibleTextField.text = [_entrada[@"stock_disponible"] stringValue];
        // Formato caja y fecha envío
        self.formatoCajaTextField.text = [_entrada[@"formato_caja"] stringValue];
        self.fechaEnvioDatePicker.date = _entrada[@"entregado"];
        // Comentarios
        self.comentariosTextView.text = _entrada[@"observacion"];
    }
}

#pragma mark - Tableview delegate

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 && !self.nuevaEntrada) {
        return 0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.currentResponder resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
*/

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (IBAction)guardarEntrada:(id)sender {
    NSLog(@"guardarEntrada");
    // Se crea una entrada nueva
    @try {
        // Datos obligatorios
        if (!_entrada[@"fk_articulo"]) {
            [LAUtils alertStatus:@"Tienes que elegir un Artículo" withTitle:@"Nueva entrada" andDelegate:self];
            return;
        }
        if ([_stockTotalTextField.text isEqualToString:@""]) {
            [LAUtils alertStatus:@"Tienes que introducir el stock total" withTitle:@"Nueva entrada" andDelegate:self];
            return;
        }
        self.entrada[@"stock_total"] = @([_stockTotalTextField.text integerValue]);
        if ([_precioTextField.text isEqualToString:@""]) {
            [LAUtils alertStatus:@"Tienes que introducir el precio unitario" withTitle:@"Nueva entrada" andDelegate:self];
            return;
        }
        self.entrada[@"precio"] = @([_precioTextField.text integerValue]);
        if ([_stockDisponibleTextField.text isEqualToString:@""]) {
            [LAUtils alertStatus:@"Tienes que introducir el stock disponible" withTitle:@"Nueva entrada" andDelegate:self];
            return;
        }
        self.entrada[@"stock_disponible"] = @([_stockDisponibleTextField.text integerValue]);
        if ([_formatoCajaTextField.text isEqualToString:@""]) {
            [LAUtils alertStatus:@"Tienes que introducir el formato de caja" withTitle:@"Nueva entrada" andDelegate:self];
            return;
        }
        self.entrada[@"formato_caja"] = @([_formatoCajaTextField.text integerValue]);
        if (!_fechaEnvioDatePicker.date) {
            [LAUtils alertStatus:@"Tienes que introducir fecha de envío" withTitle:@"Nueva entrada" andDelegate:self];
            return;
        }
        self.entrada[@"entregado"] = _fechaEnvioDatePicker.date;
        
        // Datos no obligatorios
        self.entrada[@"observacion"] = _comentariosTextView.text;
        // Imagen en JPG, con escasa compresión
        if (_fotoProductoImage.image) {
            NSData *imageData = UIImageJPEGRepresentation(_fotoProductoImage.image, 0.8);
            PFFile *imageFile = [PFFile fileWithName:@"foto.jpg" data:imageData];
            self.entrada[@"imagen"] = imageFile;
        }
        // El proveedor es el usuario actual logueado
        self.entrada[@"fk_proveedor"] = [PFUser currentUser];
        // Flag de comprobado a False
        self.entrada[@"comprobado"] = @NO;
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
    if (self.nuevaEntrada) {
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
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"didFinishPickingMediaWithInfo");
    // TODO: Falta reducir la foto a lo que necesitemos
    UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.fotoProductoImage.image = originalImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"buscaArticulo"]) {
        ArticuloController *viewController = segue.destinationViewController;
        viewController.entrada = _entrada;
    }
}

#pragma mark - TextField and TextView delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.currentResponderTV = textView;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}


@end

