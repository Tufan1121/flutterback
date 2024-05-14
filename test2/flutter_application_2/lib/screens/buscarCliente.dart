import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExistingCustomerSearchScreen extends StatefulWidget {
  @override
  _ExistingCustomerSearchScreenState createState() => _ExistingCustomerSearchScreenState();
}

class _ExistingCustomerSearchScreenState extends State<ExistingCustomerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  List<dynamic> _searchResults = [];

  Future<void> _searchCustomer() async {
    final String searchTerm = _searchController.text;
    final String token = await _storage.read(key: 'jwtToken') ?? '';

    if (searchTerm.isEmpty) {
      return;
    }

    void _selectClient(String idCliente) async {
      await _storage.write(key: 'selected_client_id', value: idCliente);
      // Opcional: Mostrar un mensaje de confirmación o realizar alguna acción después de guardar el ID
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cliente seleccionado guardado')));
  }
    final Uri url = Uri.parse('https://tapetestufan.mx:6002/buscacliente?nombre=$searchTerm');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
          _searchCustomer(); // Vuelve a buscar para actualizar la lista con los datos más recientes
        });
      } else {
        print('Error en la búsqueda: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al buscar el cliente: $e');
    }
  }

  void _showEditMenu(BuildContext context, Map<String, dynamic> client) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Editar Cliente'),
              onTap: () {
                Navigator.pop(context);
                _showEditForm(context, client);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditForm(BuildContext context, Map<String, dynamic> client) {
    TextEditingController nameController = TextEditingController(text: client['nombre']);
    TextEditingController lastNameController = TextEditingController(text: client['apellido']);
    TextEditingController phoneController = TextEditingController(text: client['telefono']);
    TextEditingController emailController = TextEditingController(text: client['correo']);
    // Asume que `factura` es un bool en tu cliente y lo convierte a String para el Switch
    bool factura = client['factura'] == 1;

    showDialog(
      
      context: context,
      builder: (context) {
        bool localFactura = factura;

        return AlertDialog(
          title: Text('Editar Cliente'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(controller: nameController, decoration: InputDecoration(labelText: 'Nombre')),
                TextFormField(controller: lastNameController, decoration: InputDecoration(labelText: 'Apellido')),
                TextFormField(controller: phoneController, decoration: InputDecoration(labelText: 'Teléfono')),
                TextFormField(controller: emailController, decoration: InputDecoration(labelText: 'Correo')),
                
                SwitchListTile(
                  title: Text('Factura'),
                  value: localFactura,
                  onChanged: (bool value) {
                    // Actualiza el estado del Switch
                    setState(() {
                      localFactura = value;
                    });
                  },
                ),

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                _confirmUpdate(context, client['id_cliente'].toString(), nameController.text, lastNameController.text, phoneController.text, emailController.text, factura ? '1' : '0');
               
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmUpdate(BuildContext context, String idCliente, String nombre, String apellido, String telefono, String correo, String factura) {
    _updateCustomer(idCliente, nombre, apellido, telefono, correo, factura);

    //showDialog(
    //  context: context,
    //  builder: (context) {
    //    return AlertDialog(
    //      title: Text('Confirmar'),
    //      content: Text('¿Estás seguro de que quieres guardar los cambios?'),
    //      actions: <Widget>[
    //        TextButton(
    //          child: Text('No'),
    //          onPressed: () => Navigator.of(context).pop(),
    //        ),
    //        TextButton(
    //          child: Text('Sí'),
    //          onPressed: () {
    //            Navigator.of(context).pop(); // Cierra el diálogo de confirmación
    //            _updateCustomer(idCliente, nombre, apellido, telefono, correo, factura);
    //          },
    //        ),
    //      ],
    //    );
    //  },
    //);
  }

  void _updateCustomer(String idCliente, String nombre, String apellido, String telefono, String correo, String factura) async {
    final String token = await _storage.read(key: 'jwtToken') ?? '';
    final Uri url = Uri.parse('https://tapetestufan.mx:6002/updateClientesExpo?id_cliente=$idCliente&nombre=$nombre&apellido=$apellido&telefono=$telefono&correo=$correo&factura=$factura');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cliente actualizado con éxito')));
        Navigator.of(context).pop(); // Cierra el diálogo de edición
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar el cliente')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error durante la actualización')));
    }
  }

  void _selectClient(String idCliente) async {
    await _storage.write(key: 'selected_client_id', value: idCliente);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cliente seleccionado guardado')));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Cliente Existente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar cliente',
                hintText: 'Ingresa el nombre, apellido, correo',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchCustomer,
                ),
              ),
              onSubmitted: (value) => _searchCustomer(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var client = _searchResults[index];
                  return ListTile(
                    title: Text(client['nombre'] ?? 'Sin nombre'),
                    subtitle: Text('${client['apellido'] ?? ''} - ${client['telefono'] ?? ''}'),
                    onTap: () => _selectClient(client['id_cliente'].toString()),
                    onLongPress: () => _showEditMenu(context, client),

                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
