// ignore: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';


// ignore: camel_case_types
class busquedaGlobal extends StatefulWidget {
  const busquedaGlobal({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _busquedaGlobalState createState() => _busquedaGlobalState();
}


class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency();
    List<String> imageUrls = [];
    for (int i = 1; i <= 6; i++) {
      String? imageUrl = item['pathima$i'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageUrls.add('https://tapetestufan.mx:446/imagen/$imageUrl');
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(item['producto']),
      ),
      body: Column(
        children: <Widget>[
          if (imageUrls.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
                autoPlay: false,
              ),
              items: imageUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.network(imageUrl),
                    );
                  },
                );
              }).toList(),
            ),
          //Text('Total de Existencias en Bodegas: ${item['bodega1'] + item['bodega2'] + item['bodega3'] + item['bodega4']}'),
          //Text('Bodega 1: ${item['bodega1']}'),
          //Text('Bodega 2: ${item['bodega2']}'),
          //Text('Bodega 3: ${item['bodega3']}'),
          //Text('Bodega 4: ${item['bodega4']}'),
          Text('Precio Normal: ${formatCurrency.format(item['precio1'])}'),
          Text('Precio Expo: ${formatCurrency.format(item['precio2'])}'),
          Text('Precio Mayoreo: ${formatCurrency.format(item['precio3'])}'),

          //Text('Composiciom: ${item['compos']}'),
          //Text('Lavado: ${item['lava1']} ${item['lava2']}'),
          

          Text('Existencia: ${item['hm']}'),
          Text('${item['desalmacen']}'),

        ],
      ),
    );
  }
}
// ignore: camel_case_types
class _busquedaGlobalState extends State<busquedaGlobal> {
  final TextEditingController _calidadController = TextEditingController();
  final TextEditingController _colorDisenoController = TextEditingController();
  final TextEditingController _medidasLargoDesdeController = TextEditingController();
  final TextEditingController _medidasLargoHastaController = TextEditingController();
  final TextEditingController _medidasAnchoDesdeController = TextEditingController();
  final TextEditingController _medidasAnchoHastaController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<dynamic> _searchResults = [];

  Future<void> _buscarInventario() async {
    // Aquí asumimos que tienes controladores de texto para descripcio y diseno, y variables para mlargo1, mlargo2, etc.
    final String descripcio = _calidadController.text; // Asumiendo que usas 'calidad' como 'descripcio'
    final String diseno = _colorDisenoController.text;
    final double? mlargo1 = double.tryParse(_medidasLargoDesdeController.text);
    final double? mlargo2 = double.tryParse(_medidasLargoHastaController.text);
    final double? mancho1 = double.tryParse(_medidasAnchoDesdeController.text);
    final double? mancho2 = double.tryParse(_medidasAnchoHastaController.text);

    // Verificación de las condiciones requeridas para la búsqueda
    if (descripcio.isEmpty && diseno.isEmpty) {
      // Mostrar error
      if (kDebugMode) {
        print("Al menos una de las condiciones (descripcio o diseno) debe ser obligatoria");
      }
      return;
    }

    // Comenzar a construir la URL para la solicitud GET
    String baseUrl = 'https://tapetestufan.mx:6002/busquedaGlobal/';
    List<String> queryParameters = [];

    if (descripcio.isNotEmpty) {
      queryParameters.add('descripcio=$descripcio');
    }
    if (diseno.isNotEmpty) {
      queryParameters.add('diseno=$diseno');
    }
    if (mlargo1 != null && mlargo2 != null) {
      queryParameters.add('mlargo1=${mlargo1 - 0.01}');
      queryParameters.add('mlargo2=${mlargo2 + 0.01}');
    }
    if (mancho1 != null && mancho2 != null) {
      queryParameters.add('mancho1=${mancho1 - 0.01}');
      queryParameters.add('mancho2=${mancho2 + 0.01}');
    }

    // Unir todos los parámetros en la URL final
    String finalUrl = '$baseUrl?${queryParameters.join("&")}';

    // Realizar la llamada a la API
    final String token = await _storage.read(key: 'jwtToken') ?? '';
    final Uri url = Uri.parse(finalUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        // Procesar los resultados
        
        setState(() {
           _searchResults = jsonDecode(response.body);
         });
        
        if (kDebugMode) {
          print('Resultados de la búsqueda: ${response.body}');
        }
      } else {
        // Manejar los errores
        if (kDebugMode) {
          print('Error en la búsqueda: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      // Manejar las excepciones
      if (kDebugMode) {
        print('Error al buscar en el inventario: $e');
      }
    }
}


 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Busqueda Global'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _calidadController,
            decoration: const InputDecoration(labelText: 'Calidad'),
          ),
          TextField(
            controller: _colorDisenoController,
            decoration: const InputDecoration(labelText: 'Color/Diseño'),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _medidasLargoDesdeController,
                  decoration: const InputDecoration(labelText: 'Medidas Largo Desde'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 10), // Espacio entre los dos campos de texto
              Expanded(
                child: TextField(
                  controller: _medidasLargoHastaController,
                  decoration: const InputDecoration(labelText: 'Medidas Largo Hasta'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _medidasAnchoDesdeController,
                  decoration: const InputDecoration(labelText: 'Medidas Ancho Desde'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 10), // Espacio entre los dos campos de texto
              Expanded(
                child: TextField(
                  controller: _medidasAnchoHastaController,
                  decoration: const InputDecoration(labelText: 'Medidas Ancho Hasta'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _buscarInventario,
            child: const Text('Buscar en Bodegas'),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _searchResults.isNotEmpty ? _buildSearchResultsList() : const Text(''),
          ),
        ],
      ),
    ),
  );
}
Widget _buildSearchResultsList() {
  final formatCurrency = NumberFormat.simpleCurrency();
  return ListView.builder(
    itemCount: _searchResults.length,
    itemBuilder: (context, index) {
      final item = _searchResults[index];
      //int total = item['bodega1'] + item['bodega2'] + item['bodega3'] + item['bodega4'];
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(item: item),
            ),
          );
        },
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 100, // Ancho de la imagen
              height: 200, // Altura de la imagen
              child: InteractiveViewer(
                minScale: 0.1,
                maxScale: 2.0,
                // ignore: prefer_interpolation_to_compose_strings
                child: Image.network('https://tapetestufan.mx:446/imagen/' + item['pathima1']),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Text(item['producto']), // Muestra el producto
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Text('Total de Existencias en Bodegas: $total'), // Muestra las bodegas
                    //Text('Bodega 1: ${item['bodega1']}'), // Muestra las bodegas
                    //Text('Bodega 2: ${item['bodega2']}'), // Muestra las bodegas
                    //Text('Bodega 3: ${item['bodega3']}'), // Muestra las bodegas
                    //Text('Bodega 4: ${item['bodega4']}'), // Muestra las bodegas
                    Text('Precio Normal: ${formatCurrency.format(item['precio1'])}'), // Muestra los precios
                    Text('Precio Expo: ${formatCurrency.format(item['precio2'])}'), // Muestra los precios
                    Text('Precio Mayoreo: ${formatCurrency.format(item['precio3'])}'), // Muestra los precios
                    Text('Existencia: ${item['hm']}'),
                    Text('${item['desalmacen']}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  
}
