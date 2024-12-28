import 'package:DenizEkosistemi/util.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {


  @override
  void initState() {
    super.initState();
    readFromFile((update) => setState(update));
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
    } else if (selectedIndex == 2) {
      selectedIndex == 4;
      Yenitur();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }
  void restartApp() {
    selectedIndex = 0;
    Yazi.loadDil(secilenDil);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GeoGameLobi()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Yazi.get('ayarlarlist')),
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
      ),
      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  Yazi.get('ayarlar'),
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ), // baslık
              buildSwitch(Yazi.get('secilentema')+(darktema ? 'Dark': 'Light'), darktema, (value) {
                setState(() {
                  darktema = value;
                  if(darktema)
                    ThemeModeBuilderConfig.setDark();
                  else
                    ThemeModeBuilderConfig.setLight();
                  writeToFile();
                });
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(Yazi.get('secilendil'), style: TextStyle(fontSize: 16.0)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: DropdownButton<String>(
                        hint: Text(secilenDil),
                        isExpanded: true,
                        items: diller.map((String dil) {
                          return DropdownMenuItem<String>(
                            value: dil,
                            child: Text(dil),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            secilenDil = value.toString();
                            writeToFile();
                          });
                          restartApp();
                        },
                      ),
                    ),
                  ),
                ],
              ), // dil değiştirme
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(secilenDil!="Türkçe"? 'If there is a translation error,': '',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      Text(secilenDil!="Türkçe" ? 'please report the error.': '',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      Text(secilenDil!="Türkçe" ? 'The translations are machine translations.': '',
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ), //makine çeviri uyarı
            ],
          ),
        ),
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
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

Widget buildSwitch(String title, bool currentValue,
    ValueChanged<bool> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16.0)),
        Switch(
          value: currentValue,
          onChanged: onChanged,
          activeColor: Colors.green,
          inactiveTrackColor: Colors.grey,
          inactiveThumbColor: Colors.red,
        ),
      ],
    ),
  );
}
