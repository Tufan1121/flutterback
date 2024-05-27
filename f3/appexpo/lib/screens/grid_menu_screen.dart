import 'package:flutter/material.dart';
import 'prices_screen.dart';
import 'clienteNuevo.dart';
import 'buscarCliente.dart';
import 'inventariobodegas.dart';
import 'inventarioExpo.dart';
import 'busquedaGlobal.dart';

class GridMenuScreen extends StatelessWidget {
  const GridMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú Principal"),
      ),
      body: GridView.count(
        crossAxisCount: 3, // Número de columnas en la cuadrícula
        padding: const EdgeInsets.all(16.0),
        childAspectRatio: 8.0 / 9.0, // Relación de aspecto de los ítems
        children: List.generate(6, (index) { // Genera 4 ítems como ejemplo
          return _buildGridItem(index, context);
        }),
      ),
    );
  }

  Widget _buildGridItem(int index, BuildContext context) {
    // Iconos de ejemplo
    List<IconData> icons = [
      Icons.qr_code,
      Icons.shopping_cart_rounded,
      Icons.inventory_2_rounded,
      Icons.history,
      Icons.document_scanner_rounded,
      Icons.point_of_sale_sharp,
    ];
    // Etiquetas de ejemplo
    List<String> labels = [
      "Precios",
      "Nueva Sesion de Ventas",
      "Inventarios",
      "Historial",
      "Reportes",
      "Punto de Venta",
    ];

    return InkWell(
      onTap: () {
        if (index == 0) { // "Precios"
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PricesScreen(),
          ));
        } else if (index == 1) { // "Pedidos"
          _showOrdersSubMenu(context); // Muestra el submenú para Pedidos
        } else if (index == 2) { // "Inventarios"
          _showInventariosSubMenu(context);
        }
        // Agrega acciones para otros ítems si es necesario
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icons[index], size: 50.0),
          Text(labels[index]),
        ],
      ),
    );
  }

  void _showOrdersSubMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Cliente Nuevo'),
                onTap: () {
                  Navigator.pop(context); // Cierra la hoja modal
                  // Aquí puedes navegar a la pantalla de Cliente Nuevo
                  Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NewCustomerScreen(),
                ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Cliente Existente'),
                onTap: () {
                  Navigator.pop(context); // Cierra la hoja modal
                  // Aquí puedes navegar a la pantalla de Cliente Existente
                  Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ExistingCustomerSearchScreen(),
                ));

                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInventariosSubMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Inventario Expo'),
                onTap: () {
                  Navigator.pop(context); // Cierra la hoja modal
                  // Aquí puedes navegar a la pantalla de Cliente Nuevo
                  Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => inventarioExpo(),
                ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Inventario Bodegas'),
                onTap: () {
                  Navigator.pop(context); // Cierra la hoja modal
                  // Aquí puedes navegar a la pantalla de Cliente Existente
                  Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const InventarioBodegasScreen(),
                ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Busqueda Global'),
                onTap: () {
                  Navigator.pop(context); // Cierra la hoja modal
                  // Aquí puedes navegar a la pantalla de Cliente Existente
                  Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => busquedaGlobal(),
                ));
                },
              ),

            ],
          ),
        );
      },
    );
  }
}
