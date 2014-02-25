//
//  EntradasController.m
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 27/12/13.
//  Copyright (c) 2013 Luis Ángel García Muñoz. All rights reserved.
//

#import "EntradasController.h"
#import "DetalleEntradaController.h"


@interface EntradasController () {
    
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
    NSLog(@"initWithCoder");
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
    PFUser *david = [PFUser logInWithUsername:@"David" password:@"12345"];
    [query whereKey:@"fk_proveedor" equalTo:david];
    // Filtro de eventos "comprobados"
    [query whereKey:@"comprobado" equalTo:@YES];
    // Ordenados los items por fecha de creación de la entrada
    [query orderByAscending:@"createdAt"];
    // Esto se hace para que también cargue la información del objeto Artículo
    [query includeKey:@"Articulo"];
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
    PFFile *thumbnail = [object objectForKey:@"imagen"];
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:103];
    thumbnailImageView.image = [UIImage imageNamed:@"BgLeather.png"];
    thumbnailImageView.file = thumbnail;
    [thumbnailImageView loadInBackground];
    UILabel *nombreLabel = (UILabel*) [cell viewWithTag:100];
    nombreLabel.text = [object objectForKey:@"nombre"];
    UILabel *stockLabel = (UILabel*) [cell viewWithTag:101];
    stockLabel.text = [[object objectForKey:@"stock_total"] stringValue];
    UILabel *precioLabel = (UILabel*) [cell viewWithTag:102];
    precioLabel.text = [NSString stringWithFormat:@"%@ €", [[object objectForKey:@"precio"] stringValue]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Devolver NO si alguna fila en concreto no queremos que se pueda editar (borrar)
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Eliminamos la entrada del backend
        PFObject *entrada = [self.objects objectAtIndex:indexPath.row];
        [entrada deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self refrescarEntradas:nil];
        }];
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
        PFObject *entrada = [PFObject objectWithClassName:@"Articulo"];
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
