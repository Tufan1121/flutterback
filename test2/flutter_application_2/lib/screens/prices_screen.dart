import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';


bool _isLoadingRelatedProducts = true; // Añade esto al inicio de tu clase _PricesScreenState
int _currentImageIndex = 0;


class PricesScreen extends StatefulWidget {
  @override
  _PricesScreenState createState() => _PricesScreenState();
}




class _PricesScreenState extends State<PricesScreen> {
  final TextEditingController _productKeyController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  // Variables para almacenar la información del producto
  String _nombreProducto = '';
  String _codigoProducto = '';
  int _existencias = 0;
  String _medidas = '';
  double _precioLista = 0.0;
  double _precioExpo = 0.0;
  double _precioMayoreo = 0.0;
  List<String> _imagenes = []; // URLs de las imágenes
  List<Map<String, dynamic>> _productosRelacionados = []; // Productos relacionados
  String _descripcio = '';
  String _diseno = '';
  String _composicion = '';
  
  get relatedProductsData => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consulta de Precios"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _productKeyController,
              decoration: InputDecoration(
                labelText: 'Clave del producto',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => fetchProductInfo(_productKeyController.text),
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text("Escanear"),
              onPressed: () => scanBarcode(),
            ),
              buildProductDetails(),
              buildRelatedProducts(),
            
          ],
        ),
      ),
    );
  }

   Widget buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_nombreProducto, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text("Clave: $_codigoProducto"),
        Text("Existencia en Bodegas: $_existencias"),
        Text("Medidas: $_medidas"),
        Text("Precio Lista: \$$_precioLista"),
        Text("Precio Expo: \$$_precioExpo"),
        Text("Precio Mayoreo: \$$_precioMayoreo"),
        Text("Composicion: $_composicion"),
        if (_imagenes.isNotEmpty) ...[
          SizedBox(height: 10),
          //////////////////////
          CarouselSlider(
            options: CarouselOptions(
              initialPage: _currentImageIndex,
              autoPlay: false,
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              onPageChanged: (index, reason) {
                setState(() {
                _currentImageIndex = index;
                });
              },
            ),
            items: _imagenes.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return Image.network(imageUrl, fit: BoxFit.cover);
                },
              );
            }).toList(),
          ),
        ],
      ],
      
    );
  }


Widget buildRelatedProducts() {
  if (_isLoadingRelatedProducts) {
    // No muestres nada (o podrías mostrar un indicador de carga si lo prefieres)
    return Container();
  } else if (_productosRelacionados.isNotEmpty) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Artículos Relacionados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _productosRelacionados.length,
          itemBuilder: (context, index) {
            final producto = _productosRelacionados[index];
            return ListTile(
              title: Text(producto['producto'], textAlign: TextAlign.center),
              onTap: () {
                final claveProducto = producto['producto'];
                fetchProductInfo(claveProducto);
              },
            );
          },
          separatorBuilder: (context, index) => Divider(), // Agrega una línea divisoria
        ),
      ],
    );
  } else {
    // No hay artículos relacionados disponibles
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: Text("No hay artículos relacionados disponibles")),
    );
  }
}




  // Las funciones scanBarcode y fetchProductInfo se mantienen igual que en el ejemplo anterior.
  Future<void> scanBarcode() async {
  String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
    "#ff6666", "Cancelar", true, ScanMode.BARCODE);
  if (barcodeScanRes != "-1") {
    fetchProductInfo(barcodeScanRes);
    _productKeyController.clear();
    }
  }

 Future<void> fetchProductInfo(String productKey) async {
  String? token = await _storage.read(key: 'jwtToken');
  final response = await http.get(
    Uri.parse('https://tapetestufan.mx:6002/productScan/?producto=$productKey'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    if (responseData.isNotEmpty) {
      final data = responseData.first; // Asumiendo que queremos el primer producto
      List<String> imagenesTemp = [];
      for (int i = 1; i <= 6; i++) {
        String key = 'pathima$i';
        if (data[key] != null && data[key].isNotEmpty) {
          imagenesTemp.add("https://tapetestufan.mx:446/imagen/${Uri.encodeFull(data[key])}");
          //_imagenes = imagenesTemp;
          setState(() {
            _imagenes = imagenesTemp;
            _currentImageIndex = 0; // Restablece al primer índice para mostrar la primera imagen
            // Otros estados que necesitas actualizar...
          });
        }
      }

      int existencias = (data['bodega1'] ?? 0) +
                        (data['bodega2'] ?? 0) +
                        (data['bodega3'] ?? 0) +
                        (data['bodega4'] ?? 0);

        setState(() {
          _nombreProducto = data['producto'] ?? '';
          _codigoProducto = data['producto1'] ?? '';
          _existencias = existencias;
          _medidas = data['medidas']?.trim() ?? '';
          _precioLista = data['precio1']?.toDouble() ?? 0.0;
          _precioExpo = data['precio2']?.toDouble() ?? 0.0;
          _precioMayoreo = data['precio3']?.toDouble() ?? 0.0;
          _imagenes = imagenesTemp;
          _descripcio = data['descripcio'] ?? '';
          _diseno = data['diseno'] ?? '';
          _composicion = data['compo1']+data['compo2'] ?? '';
        
        // Aquí podrías añadir el manejo de los demás campos según lo necesites
      });
      _productKeyController.clear();
      fetchRelatedProducts(_descripcio, _diseno, _nombreProducto);
    }
  } else {
    // Manejo de errores...
    resetProductDetails();
    print('Error al buscar información del producto: ${response.statusCode}');
  }
}

Future<void> fetchRelatedProducts(String descripcion, String diseno, String producto) async {
    
    setState(() {
      _isLoadingRelatedProducts = true;
    });

    String? token = await _storage.read(key: 'jwtToken');
    final response = await http.get(
      Uri.parse('https://tapetestufan.mx:6002/restoScan/?descripcio=$descripcion&diseno=$diseno&producto=$producto'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      if (responseBody['data'] != null) {
        final List<dynamic> relatedProductsData = responseBody['data'];
        setState(() {
          _productosRelacionados = relatedProductsData.map<Map<String, dynamic>>((product) => product as Map<String, dynamic>).toList();
          _isLoadingRelatedProducts = false; // La carga ha concluido
        });
      } else {
        setState(() {
          _isLoadingRelatedProducts = false; // Asegúrate de manejar también el estado de error
        });
        // Maneja el caso donde 'data' es nulo o no está presente.
        //print("La respuesta de la API no contiene el campo 'data'.");
      }
    } else {
      // Manejo de errores...
      print('Error al buscar artículos relacionados: ${response.statusCode}');
    }
  }

  void resetProductDetails() {
    setState(() {
      // Restablece los campos de texto y las variables de estado a sus valores por defecto
      _productKeyController.clear(); // Ya lo haces para el código de barras
      _nombreProducto = '';
      _codigoProducto = '';
      _existencias = 0;
      _medidas = '';
      _precioLista = 0.0;
      _precioExpo = 0.0;
      _precioMayoreo = 0.0;
      _imagenes = []; // Limpia la lista de imágenes
      _productosRelacionados = []; // Limpia la lista de productos relacionados
      _descripcio = '';
      _diseno = '';
      _composicion = '';
      _currentImageIndex = 0; // Restablece el índice de la imagen actual a 0
      _isLoadingRelatedProducts = true; // O false, dependiendo de lo que quieras mostrar inicialmente
    });
  }


  // Asegúrate de que las claves usadas en estos métodos coincidan con tu estructura JSON real.
}


