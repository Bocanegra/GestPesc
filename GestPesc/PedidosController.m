//
//  PedidosController.m
//  GestPesc
//
//  Created by Luis Angel on 10/01/14.
//  Copyright (c) 2014 Luis Ángel García Muñoz. All rights reserved.
//

#import "PedidosController.h"
#import "ConfirmarPedidoController.h"
#import "LAUtils.h"


@interface PedidosController ()

@end

@implementation PedidosController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Creamos un nuevo notificador para refrescar los datos de la tabla
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refrescarPedidos:)
                                                 name:@"refrescarPedidos"
                                               object:nil];
}

- (void)refrescarPedidos:(NSNotification *)notification {
    // Recarga los objetos de la query de Parse
    [self loadObjects];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Parse methods
// Configurar Parse para acceder a objetos Pedido
- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Entrada";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
    }
    return self;
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    // Filtro de entradas del usuario actual
    [query whereKey:@"fk_proveedor" equalTo:[PFUser currentUser]];
    // Filtro de eventos del día
    [query whereKey:@"createdAt" greaterThan:[LAUtils fechaDesdeHoy]];
    // Ordenados los items por fecha de creación de la entrada
    [query orderByAscending:@"createdAt"];
    // Y que estén comprobados
    [query whereKey:@"comprobado" equalTo:@YES];
    // Esto se hace para que también cargue la información del objeto Artículo
    [query includeKey:@"fk_articulo"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    return query;
}


#pragma mark - Métodos de Table View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pedidoCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pedidoCell"];
    }
    // Configurar la celda con datos del backend
    cell.detailTextLabel.text = object[@"fk_articulo"][@"nombre"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ kgs.", [[self calculaStockPedir:object] stringValue]];
    return cell;
}

// Calcula lo que hay que pedir en función del stock de la entrada y el factor de corrección
- (NSInteger *)calculaStockPedir:(PFObject *)entrada {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*
    ConfirmarPedidoController *destViewController = segue.destinationViewController;
    if ([[segue identifier] isEqualToString:@"confirmarPedido"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [destViewController setPedidoObject:object];
    }
    */
}

@end
