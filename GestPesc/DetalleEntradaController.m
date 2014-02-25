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
@property (assign, nonatomic) id currentResponder;
@property NSArray *articulos;

- (IBAction)cogerFotoEntrada:(id)sender;
- (IBAction)guardarEntrada:(id)sender;
- (void)configureView;
- (void)fechaEnvioCambiada:(NSNotification *)notification;

@end

@implementation DetalleEntradaController {
    NSArray *resultadosBusqueda;
}

@synthesize articulos;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatoFecha = [[NSDateFormatter alloc] init];
    [self.formatoFecha setDateFormat:@"dd/MM/yyyy"];
    [self configureView];
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
    // Si es una entrada nueva, se cargan los artículos en caché (si no están aún)
    PFQuery *query = [PFQuery queryWithClassName:@"Articulo"];
    [query includeKey:@"fk_categoria"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60 * 60 * 24 * 1;  // 1 día, en segundos
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Cargada lista de %d Artículos", objects.count);
            articulos = objects;
        } else {
            NSLog(@"Error al cargar la lista de Artículos: %@ %@", error, [error userInfo]);
        }
    }];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0 && !self.nuevaEntrada) {
        return 0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.currentResponder resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)guardarEntrada:(id)sender {
    NSLog(@"guardarEntrada");
    // Actualizamos los datos del objeto entrada
    // TODO: Comprobar datos de entrada
    @try {
        /*
        self.entrada[@"nombre"] = _nombreProductoTextField.text;
        self.entrada[@"stock_total"] = @([_stockTotalTextField.text integerValue]);
        self.entrada[@"precio"] = @([_precioTextField.text integerValue]);
        self.entrada[@"stock_disponible"] = @([_stockDisponibleTextField.text integerValue]);
        self.entrada[@"formato_caja"] = @([_formatoCajaTextField.text integerValue]);
        self.entrada[@"descripcion"] = _fechaEnvioTextField.text;
        //    [self.entrada setObject:_fechaEnvioTextField.text forKey:@"entregado"];
        // Imagen en JPG, con escasa compresión
        NSData *imageData = UIImageJPEGRepresentation(_fotoProducto.image, 0.8);
        PFFile *imageFile = [PFFile fileWithName:@"foto.jpg" data:imageData];
        self.entrada[@"imagen"] = imageFile;
         */
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

-(void)fechaEnvioCambiada:(NSNotification *)notification {
    
}

#pragma mark - TextField and TextView delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.currentResponder = textView;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Métodos de filtrado predictivo

- (void)filtrarContenidoBusqueda:(NSString*)textoBuscar scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.nombre contains[cd] %@", textoBuscar];
    resultadosBusqueda = [self.articulos filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filtrarContenidoBusqueda:searchString
                             scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                    objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

// Este método es para cambiar el botón de "Cancelar" por "Ok" en la predictiva
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.searchDisplayController.searchBar.showsCancelButton = YES;
    UIButton *cancelButton;
    UIView *topView = self.searchDisplayController.searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        [cancelButton setTitle:@"Ok" forState:UIControlStateNormal];
    }
}

@end

