import 'package:DenizEkosistemi/util.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
export 'package:flutter_animate/flutter_animate.dart';

class App1 extends StatefulWidget {
  @override
  _App1State createState() => _App1State();
}

class _App1State extends State<App1> {
  double temperature = 0; // Başlangıç sıcaklığı
  double glacierSize = 1.0; // Buzul büyüklüğü (1.0 normalde)
  double kordinatx =0,kordinaty =0;

  final List<LatLng> glacierLocations = [
    LatLng(90.0, 0.0), // Kuzey Kutbu
    LatLng(-90.0, 0.0), // Güney Kutbu
  ];
  final List<LatLng> arcticPolygon = [
    LatLng(85.0, -180.0),  // Kuzey kutbunun batı noktası
    LatLng(85.0, -90.0),   // Kuzey kutbunun batı 90 derece noktası
    LatLng(85.0, 0.0),     // Kuzey kutbunun sıfır boylamı noktası
    LatLng(85.0, 90.0),    // Kuzey kutbunun doğu 90 derece noktası
    LatLng(85.0, 180.0),   // Kuzey kutbunun doğu 180 derece noktası
    LatLng(85.0, -180.0),  // İlk noktaya geri dönüş
  ];


  @override
  void initState() {
    super.initState();
    readFromFile((update) => setState(update));
  }

  void increaseTemperature() {
    setState(() {
      temperature += 1.0; // 1 derece artır
    });
  }
  void decreaseTemperature() {
    setState(() {
      temperature -= 1.0; // 1 derece azalt
    });
  }
  void copykordinat() {
    String kordinatString = 'LatLng($kordinatx, $kordinaty)';
    postMessage(kordinatString);
    Clipboard.setData(ClipboardData(text: kordinatString)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Koordinatlar kopyalandı: $kordinatString'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
  double calculateGlacierSize(double temperature) {
    return (1.0 - (temperature * 0.05));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deniz Ekosistemi'),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(0.0, 0.0),
                initialZoom: 2.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    // Harita üzerine tıklanmış olan noktanın koordinatları
                    print("Tıklanan Nokta: ${point.latitude}, ${point.longitude}");
                    kordinatx = point.latitude;
                    kordinaty = point.longitude;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                MarkerLayer(
                  markers: glacierLocations.map((location) {
                    // Buzul boyutunu sıcaklık değerine göre güncelle
                    double updatedGlacierSize = calculateGlacierSize(temperature);
                    return Marker(
                      point: location,
                      width: updatedGlacierSize * 100,
                      height: updatedGlacierSize * 100,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        width: updatedGlacierSize * 100,
                        height: updatedGlacierSize * 100,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Positioned(
                  bottom: 10,  // Ekranın alt kısmına yerleştirir
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // + ve - butonları
                          GestureDetector(
                            onTap: decreaseTemperature,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.remove, color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10), // Aradaki boşluk
                          // Sıcaklık değeri
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Sıcaklık:\n${temperature.toStringAsFixed(1)}°C',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          SizedBox(width: 10), // Aradaki boşluk
                          // + butonu
                          GestureDetector(
                            onTap: increaseTemperature,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10), // Aradaki boşluk
                          GestureDetector(
                            onTap: copykordinat,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('X: $kordinatx,\n Y: $kordinaty'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      drawer: DrawerWidget(),
    );
  }
}