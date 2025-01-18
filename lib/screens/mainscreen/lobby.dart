import 'package:DenizEkosistemi/util.dart';
import 'package:http/http.dart' as http;

void disableCertificateVerification() {
  HttpOverrides.global = MyHttpOverrides();
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;  // Sertifika doğrulamasını geç
    return client;
  }
}

class GeoGameLobi extends StatefulWidget {
  @override
  _GeoGameLobiState createState() => _GeoGameLobiState();
}

class _GeoGameLobiState extends State<GeoGameLobi> {
  List<String> options = List.filled(3, '');
  @override
  void initState() {
    super.initState();
    _initializeGame();
  }
  Future<void> _initializeGame() async {
    if (darktema)
      ThemeModeBuilderConfig.setDark();
    else
      ThemeModeBuilderConfig.setLight();
    await dilDegistir();
    await readFromFile((update) => setState(update));
    await surumkiyasla();
    //await postLeadboard();
  }
  Future<void> dilDegistir() async {
    await Yazi.loadDil(secilenDil).then((_) {
      setState(() {
        navBarItems = [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: Text(Yazi.get('navigasyonbar1')),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(FontAwesomeIcons.info),
            selectedColor: Colors.teal,
            title: Text(Yazi.get('navigasyonbar2')),
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.settings),
            title: Text(Yazi.get('navigasyonbar3')),
            selectedColor: Colors.orange,
          ),
        ];
      });
    });
  }
  Future<void> surumkiyasla() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String? remoteVersion;
    String? apkUrl;

    Future<void> _fetchData() async {
      try {
        final response = await http.get(Uri.parse(
            'https://raw.githubusercontent.com/keremlolgg/DenizEkosistemi/refs/heads/main/latest_version.json'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Null kontrolü ve verinin geçerliliği
          if (data != null && data.containsKey('latest_version') && data.containsKey('apk_url')) {
            setState(() {
              remoteVersion = data['latest_version'] ?? 'N/A';
              apkUrl = data['apk_url'] ?? 'N/A';
            });
          } else {
            throw Exception('Missing keys in the JSON data');
          }
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    await _fetchData();
    void showUpdateDialog(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Yazi.get('yenisurum')),
            content: Text(Yazi.get('indir')),
            actions: <Widget>[
              TextButton(
                child: Text(Yazi.get('red')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(Yazi.get('onay')),
                onPressed: () {
                  Navigator.of(context).pop();
                  EasyLauncher.url(
                    url: apkUrl!,
                  );
                },
              ),
            ],
          );
        },
      );
    }

    if (remoteVersion != null &&
        apkUrl != null &&
        remoteVersion != localVersion) {
      showUpdateDialog(context);
    }
  }
  void _selectIndex(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GeoGameLobi()),
      );
    } else if (selectedIndex == 1) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Ulkelerlist()),
      );
    } else if (selectedIndex == 2 ) {
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }
  void _appbaslat(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (selectedIndex == 0) {
      Yenitur();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Denizekosistem()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Yazi.get('deniztitle'),
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      // yeni bişeyler ekleneceği zaman itemcount u arttır
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () {
                  _appbaslat(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/menu.jpg',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Yazi.get('deniztitle'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              Yazi.get('denizdescription'),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      drawer: DrawerWidget(),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) async {
          setState(() {
            selectedIndex = index;
          });
          _selectIndex(selectedIndex);
        },
        items: navBarItems,
      ),
    );
  }
}
