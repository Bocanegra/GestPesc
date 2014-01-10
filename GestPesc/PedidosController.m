//
//  PedidosController.m
//  GestPesc
//
//  Created by Luis Angel on 10/01/14.
//  Copyright (c) 2014 Luis Ángel García Muñoz. All rights reserved.
//

#import "PedidosController.h"
#import "ConfirmarPedidoController.h"


@interface PedidosController ()

@end

@implementation PedidosController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Parse methods
// Configurar Parse para acceder a objetos Pedido
- (id)initWithCoder:(NSCoder *)aCoder {
    NSLog(@"initWithCoder");
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Pedido";
        // The key of the PFObject to display in the label of the default cell style
        //self.textKey = @"nombre";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
    }
    return self;
}

- (PFQuery *)queryForTable {
    NSLog(@"queryForTable");
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query orderByAscending:@"createdAt"];
    return query;
}


#pragma mark - Métodos de Table View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    NSLog(@"cellForRowAtIndexPath");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pedidoCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pedidoCell"];
    }
    // Configurar la celda con datos del backend
    /*
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
     */
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ConfirmarPedidoController *destViewController = segue.destinationViewController;
    if ([[segue identifier] isEqualToString:@"confirmarPedido"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [destViewController setPedidoObject:object];
    }
}

@end
