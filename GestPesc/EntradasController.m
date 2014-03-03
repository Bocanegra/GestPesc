//
//  EntradasController.m
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 27/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import "EntradasController.h"
#import "DetalleEntradaController.h"
#import "MBProgressHUD.h"

@interface EntradasController () {
    NSDate *hoy;
}
@end

@implementation EntradasController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Crear botones de arriba
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    // Creamos un nuevo notificador para refrescar los datos de la tabla
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refrescarEntradas:)
                                                 name:@"refrescarEntradas"
                                               object:nil];
}

- (void)refrescarEntradas:(NSNotification *)notification {
    // Recarga los objetos de la query de Parse
    [self loadObjects];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Parse methods

// Configure Parse access to backend
- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Entrada";
        // The key of the PFObject to display in the label of the default cell style
        // self.textKey = @"nombre";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
    }
    return self;
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    // Filtro de entradas del usuario actual
    [query whereKey:@"fk_proveedor" equalTo:[PFUser currentUser]];
    // Filtro de eventos del día
# warning - Poner esto
//    [query whereKey:@"createdAt" greaterThan:[LAUtils fechaDesdeHoy]];
    // Ordenados los items por fecha de creación de la entrada
    [query orderByAscending:@"createdAt"];
    // Esto se hace para que también cargue la información del objeto Artículo
    [query includeKey:@"fk_articulo"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    return query;
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"entradaCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"entradaCell"];
    }
    // Configurar la celda con datos del backend
    PFFile *thumbnail = object[@"imagen"];
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:103];
    thumbnailImageView.image = [UIImage imageNamed:@"photo-frame.png"];
    if (![thumbnail isKindOfClass:[NSNull class]]) {
        thumbnailImageView.file = thumbnail;
        [thumbnailImageView loadInBackground];
    }
    UILabel *nombreLabel = (UILabel*) [cell viewWithTag:100];
    nombreLabel.text = object[@"fk_articulo"][@"nombre"];
    UILabel *stockLabel = (UILabel*) [cell viewWithTag:101];
    stockLabel.text = [NSString stringWithFormat:@"%@ kgs. de %@", [object[@"stock_disponible"] stringValue], [object[@"stock_total"] stringValue]];
    UILabel *precioLabel = (UILabel*) [cell viewWithTag:102];
    precioLabel.text = [NSString stringWithFormat:@"%@ €", [object[@"precio"] stringValue]];
    UIImageView *comprobadoImage = (UIImageView *) [cell viewWithTag:104];
    if ([object[@"comprobado"] boolValue]) {
//        [comprobadoImage setImage:[UIImage imageNamed:@"Light_Bulb.png"]];
    } else {
        [comprobadoImage setImage:[UIImage imageNamed:@"Red_Bulb.png"]];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Devolver NO si alguna fila en concreto no queremos que se pueda editar (borrar)
    PFObject *entrada = [self.objects objectAtIndex:indexPath.row];
    return ![entrada[@"comprobado"] boolValue];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Eliminamos la entrada del backend, sólo si no está comprobada ya
        PFObject *entrada = [self.objects objectAtIndex:indexPath.row];
        if (![entrada[@"comprobado"] boolValue]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"Eliminando";
            [hud show:YES];
            [entrada deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [hud hide:YES];
                [self refrescarEntradas:nil];
            }];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetalleEntradaController *destViewController = segue.destinationViewController;
    if ([[segue identifier] isEqualToString:@"muestraEntrada"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [destViewController setEntradaObject:object nueva:NO];
    } else if ([[segue identifier] isEqualToString:@"creaEntrada"]) {
        // Creamos el objeto y lo pasamos al controller del detalle
        PFObject *entrada = [PFObject objectWithClassName:@"Entrada"];
        [destViewController setEntradaObject:entrada nueva:YES];
    }
}

 
/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/
/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
