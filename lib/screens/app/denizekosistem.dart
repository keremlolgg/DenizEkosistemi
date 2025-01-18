import 'package:DenizEkosistemi/util.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class Denizekosistem extends StatefulWidget {
  @override
  _DenizState createState() => _DenizState();
}

class _DenizState extends State<Denizekosistem> {


  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await readFromFile((update) => setState(update));
    denizoyunkurallari();
  }

  Future<void> denizoyunkurallari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // kullanıcı mutlaka düğmeye basmalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Yazi.get('kurallar')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(Yazi.get('denizkural1')),
                Text(Yazi.get('denizkural2')),
                Text(Yazi.get('denizkural3')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Yazi.get('tamam')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final Map<String, double> effects = {
    'temperature': 5.0,
    'salinity': 2.0,
    'nitrate': 5.0,
    'iron': -0.5,
    'phosporus': 5.0,
    'chlorophyll': 5.0,
  };
  Map<String, Map<String, dynamic>> bolgedeger = {
    "ARK": {
      "ad": "Arktik Okyanusu",
      "deger": 0.8,
      "polygon": [
        LatLng(80.0, -1.0),
        LatLng(84.0, 4.0),
        LatLng(84.0, 132.0),
        LatLng(81.0, 115.0)
      ]
    },
    "KUZ_ATL": {
      "ad": "Kuzey Atlantik Okyanusu",
      "deger": 0.75,
      "polygon": [
        LatLng(57.0, -45.0),
        LatLng(57.0, -14.0),
        LatLng(37.0, -15.0),
        LatLng(39.0, -46.0)
      ]
    },
    "KUZ_PAS": {
      "ad": "Kuzey Pasifik Okyanusu",
      "deger": 0.78,
      "polygon": [
        LatLng(48.0, -168.0),
        LatLng(47.0, -136.0),
        LatLng(18.0, -133.0),
        LatLng(19.0, -163.0)
      ]
    },
    "GUN_ATL": {
      "ad": "Güney Atlantik Okyanusu",
      "deger": 0.65,
      "polygon": [
        LatLng(-6.0,-30.0),
        LatLng(-1.0,3.0),
        LatLng(-39.0,11.0),
        LatLng(-40.0,-41.0)
      ]
    },
    "GUN_PAS": {
      "ad": "Güney Pasifik Okyanusu",
      "deger": 0.68,
      "polygon": [
        LatLng(-2.0,-86.0),
        LatLng(-52.0,-82.0),
        LatLng(-55.0,-131.0),
        LatLng(-6.0,-132.0)
      ]
    },
    "HNT": {
      "ad": "Hint Okyanusu",
      "deger": 0.7,
      "polygon": [
        LatLng(17.0,64.0),
        LatLng(-4.0,83.0),
        LatLng(-16.0,68.0),
        LatLng(3.6,51.0)
      ]
    },
    "BER": {
      "ad": "Bering Denizi",
      "deger": 0.9,
      "polygon": [
        LatLng(65.0, -180.0),
        LatLng(65.0, -160.0),
        LatLng(55.0, -160.0),
        LatLng(55.0, -180.0)
      ]
    },
    "BAR": {
      "ad": "Barents Denizi",
      "deger": 0.88,
      "polygon": [
        LatLng(71.0, 49.0),
        LatLng(78.0, 55.0),
        LatLng(76.0, 21.0),
        LatLng(71.0, 22.0)
      ]
    },
    "ANT": {
      "ad": "Antarktika Yarımadası",
      "deger": 0.92,
      "polygon": [
        LatLng(-75.0, -58.0),
        LatLng(-75.0, -27.0),
        LatLng(-68.0, -15.0),
        LatLng(-68.0, -58.0)
      ]
    }
  };

  List<LatLng> _points = [];
  double planktonDensity = 60.0;
  double atmosphericCO2 = 400.0;

  double nitrate = 0.2;   // µM, Range: 0 - 5
  double iron = 0.1;      // nM, Range: 0 - 2
  double ph = 7.5;        // pH, Range: 6.5 - 8.0
  double salinity = 35.0; // PSU, Range: 30 - 40
  double temperature = 23.5; // °C, Range: -2 - 30
  double phosporus = 0.2; // µM, Range: 0 - 0.5
  double chlorophyll = 5.0; // mg/m³, Range: 0 - 20

  void updatePlanktonDensity() {
    setState(() {
      double effectSum = 1.0;

      // Çevresel faktörlerin etkisini hesapla
      effectSum += effects['nitrate']! * (nitrate / 5.0);
      effectSum += effects['iron']! * (iron / 2.0);
      effectSum += effects['phosporus']! * (phosporus / 0.5);
      effectSum += effects['salinity']! * (1 - exp(-(salinity - 35.0).abs() / 10.0));
      effectSum += effects['temperature']! * (1 - exp(-(temperature - 23.5).abs() / 10.0));
      effectSum += effects['chlorophyll']! * (chlorophyll / 20.0);

      // Plankton yoğunluğunu güncelle ve sınırları koru
      planktonDensity = (60.0 * effectSum).clamp(0.0, 100.0);

      // CO2 miktarını plankton yoğunluğuna göre güncelle
      atmosphericCO2 = (400.0 * (1 - (planktonDensity / 100) * 0.4)).clamp(0.0, 400.0);

      // Plankton yoğunluğu optimizasyonu için kademeli azaltma
      if (planktonDensity > 80) {
        planktonDensity *= 0.90; // 80 üzeri %10 azalt
      } else if (planktonDensity > 60) {
        planktonDensity *= 0.95; // 60-80 arası %5 azalt
      }
    });
  }

  String tespitEdilenBolge = ""; // tespit edilen bölgeyi tutacak global değişken

  bool bolgeninicindemi(double latitude, double longitude) {
    // Noktanın koordinatlarını LatLng olarak oluştur
    LatLng point = LatLng(latitude, longitude);
    tespitEdilenBolge = "";  // Önceki bölgeyi temizle

    bolgedeger.forEach((key, value) {
      List<LatLng> Aralik = value["polygon"];

      // Poligon içinde mi diye kontrol et
      if (isPointInPolygon(point, Aralik)) {
        tespitEdilenBolge = value["ad"];
        print("Nokta ${value["ad"]} bölgesinde.");
      }
    });

    if (tespitEdilenBolge.isNotEmpty) {
      return true; // Nokta bir bölgede
    } else {
      print("Nokta hiçbir bölgede değil.");
      return false; // Nokta hiçbir bölgede değil
    }
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    int n = polygon.length;
    for (int i = 0; i < n; i++) {
      LatLng vertA = polygon[i];
      LatLng vertB = polygon[(i + 1) % n];

      if (rayCastIntersect(point, vertA, vertB)) {
        intersections++;
      }
    }

    // Kesişim sayısının tek olması gerekmektedir
    return intersections % 2 != 0;
  }

  bool rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double px = point.latitude;
    double py = point.longitude;
    double ax = vertA.latitude;
    double ay = vertA.longitude;
    double bx = vertB.latitude;
    double by = vertB.longitude;

    // Kenarları sırala (düşükten yükseğe)
    if (ay > by) {
      LatLng temp = vertA;
      vertA = vertB;
      vertB = temp;
      ax = vertA.latitude;
      ay = vertA.longitude;
      bx = vertB.latitude;
      by = vertB.longitude;
    }

    // Eğer nokta yatayda dışarıdaysa kesişim olmaz
    if (ay > py && by > py || ay < py && by < py || ax > px && bx > px) {
      return false;
    }

    double slope = (by - ay) / (bx - ax);
    double intercept = ay - (slope * ax);
    double xIntersect = (py - intercept) / slope;

    // Eğer kesişim sağda olursa, xIntersect sağda olmalı
    return xIntersect > px;
  }



  Color getDensityColor(double density) {
    if (density >= 95) {
      return Color(0xFF0000FF); // Dark blue (95-100)
    } else if (density >= 90) {
      return Color(0xFF1A4DFF); // Light blue (90-94)
    } else if (density >= 85) {
      return Color(0xFF3373FF); // Medium blue (85-89)
    } else if (density >= 80) {
      return Color(0xFF66A3FF); // Light blue (80-84)
    } else if (density >= 75) {
      return Color(0xFF99CCFF); // Very light blue (75-79)
    } else if (density >= 70) {
      return Color(0xFFCCE5FF); // Pale blue (70-74)
    } else if (density >= 65) {
      return Color(0xFFE0F7FF); // Very pale blue (65-69)
    } else if (density >= 60) {
      return Color(0xFFB3D9FF); // Light blue (60-64)
    } else if (density >= 55) {
      return Color(0xFF66B3FF); // Medium blue (55-59)
    } else if (density >= 50) {
      return Color(0xFFB3A399); // Light blue transitioning to beige (50-54)
    } else if (density >= 45) {
      return Color(0xFFD6D6B3); // Beige (45-49)
    } else if (density >= 40) {
      return Color(0xFFB39E66); // Dark beige (40-44)
    } else if (density >= 35) {
      return Color(0xFFFFA64D); // Light orange (35-39)
    } else if (density >= 30) {
      return Color(0xFFFF7F32); // Medium orange (30-34)
    } else if (density >= 25) {
      return Color(0xFFFD5C29); // Orange-red (25-29)
    } else if (density >= 20) {
      return Color(0xFFFF4C4C); // Light red (20-24)
    } else if (density >= 15) {
      return Color(0xFFCC3333); // Medium red (15-19)
    } else if (density >= 10) {
      return Color(0xFFB71C1C); // Dark red (10-14)
    } else if (density >= 5) {
      return Color(0xFF880000); // Very dark red (5-9)
    } else {
      return Color(0xFF500000); // Darkest red (0-4)
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deniz Ekosistemi'),
        centerTitle: true,
        leading: Builder(
          builder: (context) =>
              IconButton(
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
      drawer: DrawerWidget(),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(0.0, 0.0),
              minZoom: 3,
              maxZoom: 7,
              initialZoom: 3.0,
              initialRotation: 0,
                onTap: (tapPosition, point) {
                  bool bulundu = false;

                  // Nokta eklenmeden önce önceki noktayı kontrol et
                  if (bolgeninicindemi(point.latitude, point.longitude)) {
                    print("Tıklanan nokta poligon içinde: $tespitEdilenBolge");
                  } else {
                    print("Tıklanan nokta poligon dışında.");
                    tespitEdilenBolge = "Dışında";
                  }

                  setState(() {
                    _points.add(point); // Yalnızca burada ekleyin
                    print("Tıklanan Nokta: ${point.latitude}, ${point.longitude}");
                    postMessage2('LatLng(${point.latitude},${point.longitude}),');
                  });
                }
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _points, // Tüm tıklanan noktalar
                    strokeWidth: 4.0,
                    color: Colors.red, // Çizgi rengi
                  ),
                ],
              ),
              PolygonLayer(
                polygons: bolgedeger.values.map((bolge) {
                  return Polygon(
                    points: bolge["polygon"],
                    color: Colors.blue.withOpacity(0.2),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  );
                }).toList(),
              ),
              /*
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: [

                    ],
                    color: getDensityColor(planktonDensity),
                    borderColor: getDensityColor(planktonDensity),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              */

              // sağ sınır
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: [
                      LatLng(90, 180.0),
                      LatLng(-90, 180.0)

                    ],
                    color: Colors.red,
                    borderColor: Colors.red,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              // sol sınır
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: [
                      LatLng(90, -180.0),
                      LatLng(-90, -180.0)

                    ],
                    color: Colors.red,
                    borderColor: Colors.red,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plankton density and CO2 level texts
              Text(
                'Plankton Yoğunluğu: ${planktonDensity.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Atmosferik CO2 Seviyesi: ${atmosphericCO2.toStringAsFixed(1)} ppm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),  // Add space between the two columns
              // Second Column for selected region
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Seçilen Bölge: $tespitEdilenBolge',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: darktema ? Colors.black26 : Colors.white38,
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16.0),
                  children: [
                    // Nitrat (NO3-) kontrolü
                    buildParameterControl('Nitrat NO3- (µM)', nitrate, "🧪", "🧪", 0.2, (value) {
                      setState(() {
                        nitrate = value;
                        updatePlanktonDensity();
                      });
                    }, min: 0.2, max: 5), // Min 0.2, max 5 µM

                    // Demir (Fe) kontrolü
                    buildParameterControl('Demir Fe (nM)', iron, "🔩", "🔩", 0.05, (value) {
                      setState(() {
                        iron = value;
                        updatePlanktonDensity();
                      });
                    }, min: 0, max: 2), // Min 0, max 2 nM

                    // Fosfat (PO₄³⁻) kontrolü
                    buildParameterControl('Fosfat PO₄³⁻ (µM)', phosporus, "⚛️", "⚛️", 0.002, (value) {
                      setState(() {
                        phosporus = value;
                        updatePlanktonDensity();
                      });
                    }, min: 0, max: 0.5), // Min 0, max 0.5 µM

                    // pH kontrolü
                    buildParameterControl('       pH', ph, "🧼", "🧪", 0.05, (value) {
                      setState(() {
                        ph = value;
                        updatePlanktonDensity();
                      });
                    }, min: 6.5, max: 8.0), // Min 6.5, max 8.0

                    // Tuzluluk kontrolü
                    buildParameterControl('Tuzluluk (PSU)', salinity, "🧂", "💧", 1, (value) {
                      setState(() {
                        salinity = value;
                        updatePlanktonDensity();
                      });
                    }, min: 30, max: 40), // Min 30, max 40 PSU

                    // Sıcaklık kontrolü
                    buildParameterControl('Sıcaklık °C', temperature, "☀️", "❄️", 0.1, (value) {
                      setState(() {
                        temperature = value;
                        updatePlanktonDensity();
                      });
                    }, min: -2, max: 30), // Min -2, max 30 °C

                    // Klorofil-a kontrolü
                    buildParameterControl('Klorofil-a (mg/m³)', chlorophyll, "🌿", "🌱", 0.5, (value) {
                      setState(() {
                        chlorophyll = value;
                        updatePlanktonDensity();
                      });
                    }, min: 0, max: 20), // Min 0, max 20 mg/m³
                  ],

                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget buildParameterControl(
    String name, double value, String artiresim, String eksiresim, double artismiktari, Function(double) onChanged,
    {double min = double.negativeInfinity, double max = double.infinity}) {
  return Row(
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              final newValue = (value + artismiktari).clamp(min, max);
              onChanged(newValue);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(artiresim), // Artı işareti
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = (value - artismiktari).clamp(min, max);
              onChanged(newValue);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(eksiresim), // Eksi işareti
          ),
          SizedBox(height: 8),
        ],
      ),
      SizedBox(width: 30), // Butonlar ve metin arasına boşluk eklemek için
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            ((value * 1000).roundToDouble() / 1000).toString(),
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    ],
  );
}
