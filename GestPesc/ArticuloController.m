//
//  ArticuloController.m
//  GestPesc
//
//  Created by Luis Ángel García Muñoz on 26/02/14.
//  Copyright (c) 2014 Luis Ángel García Muñoz. All rights reserved.
//

#import "ArticuloController.h"

@interface ArticuloController ()

@property NSArray *articulos;

@end

@implementation ArticuloController {
    NSArray *resultadosBusqueda;
}

@synthesize entrada;
@synthesize articulos;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Si es una entrada nueva, se cargan los artículos en caché (si no están aún)
    PFQuery *query = [PFQuery queryWithClassName:@"Articulo"];
    [query includeKey:@"fk_categoria"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60 * 60 * 24 * 1;  // 1 día, en segundos
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Cargada lista de %d Artículos", objects.count);
            articulos = objects;
            [self.tableView reloadData];
        } else {
            NSLog(@"Error al cargar la lista de Artículos: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [resultadosBusqueda count];
    } else {
        return [articulos count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"articulosCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    PFObject *articulo;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        articulo = [resultadosBusqueda objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        cell.textLabel.text = articulo[@"nombre"];
    } else {
        articulo = [articulos objectAtIndex:indexPath.row];
        UILabel *nombreArticulo = (UILabel*)[cell viewWithTag:302];
        nombreArticulo.text = articulo[@"nombre"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *articulo;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        articulo = [resultadosBusqueda objectAtIndex:indexPath.row];
    } else {
        articulo = [articulos objectAtIndex:indexPath.row];
    }
    entrada[@"fk_articulo"] = articulo;
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refrescaEntrada" object:self];
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
