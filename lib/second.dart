import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chromecast/cast_mini_media_controls.dart';
import 'package:chromecast/service_discovery.dart';
import 'package:dart_chromecast/casting/cast.dart';
import 'package:chromecast/device_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class second extends StatefulWidget {
  second({Key key}) : super(key: key);

  @override
  _secondState createState() => _secondState();
}

class _secondState extends State<second> {
  bool _servicesFound = false;
  bool _castConnected = false;
  ServiceDiscovery _serviceDiscovery;
  CastSender _castSender;
  List _videoItems = [
    CastMedia(
      title: 'Chromecast Audio 1',
      contentId:
          'https://firebasestorage.googleapis.com/v0/b/aarti-sangraha-c85a2.appspot.com/o/Ganesh_aarti%2F%E0%A4%B8%E0%A5%81%E0%A4%96%20%E0%A4%95%E0%A4%B0%E0%A4%A4%E0%A4%BE%20%E0%A4%A6%E0%A5%81%E0%A4%96%E0%A4%B9%E0%A4%B0%E0%A5%8D%E0%A4%A4%E0%A4%BE%20%E0%A4%B5%E0%A4%BE%E0%A4%B0%E0%A5%8D%E0%A4%A4%E0%A4%BE%20%E0%A4%B5%E0%A4%BF%E0%A4%98%E0%A5%8D%E0%A4%A8%E0%A4%BE%E0%A4%9A%E0%A5%80%2FSukhkarta%20Dukhharta%20Ganesh%20Aarti.mp3?alt=media&token=3347ff76-af3b-40b7-bfd9-45d2d5164168',
      images: [
        'https://firebasestorage.googleapis.com/v0/b/aarti-sangraha-c85a2.appspot.com/o/Ganesh_aarti%2F%E0%A4%B8%E0%A5%81%E0%A4%96%20%E0%A4%95%E0%A4%B0%E0%A4%A4%E0%A4%BE%20%E0%A4%A6%E0%A5%81%E0%A4%96%E0%A4%B9%E0%A4%B0%E0%A5%8D%E0%A4%A4%E0%A4%BE%20%E0%A4%B5%E0%A4%BE%E0%A4%B0%E0%A5%8D%E0%A4%A4%E0%A4%BE%20%E0%A4%B5%E0%A4%BF%E0%A4%98%E0%A5%8D%E0%A4%A8%E0%A4%BE%E0%A4%9A%E0%A5%80%2Fsukhkarta_dukhahrta.jpg?alt=media&token=52e9edf3-93df-423f-ba43-3c459fe9329c'
      ],
    ),
    CastMedia(
      title: 'Chromecast Audio 2',
      contentId:
          'https://firebasestorage.googleapis.com/v0/b/aarti-sangraha-c85a2.appspot.com/o/vithal_aart%2F%7C%7C%20%E0%A4%AF%E0%A5%81%E0%A4%97%E0%A5%87%20%E0%A4%85%E0%A4%A0%E0%A5%8D%E0%A4%A0%E0%A4%BE%E0%A4%B5%E0%A5%80%E0%A4%B8%20%E0%A4%B5%E0%A4%BF%E0%A4%9F%E0%A5%87%E0%A4%B5%E0%A4%B0%E0%A5%80%20%E0%A4%8A%E0%A4%AD%E0%A4%BE%20%E0%A5%A4%7C%2FYuge%20Atthavis%20%20Vitthal.mp3?alt=media&token=9b25863d-33e6-4df7-aac9-98acb271debb',
      images: [
        'https://firebasestorage.googleapis.com/v0/b/aarti-sangraha-c85a2.appspot.com/o/vithal_aart%2F%7C%7C%20%E0%A4%AF%E0%A5%81%E0%A4%97%E0%A5%87%20%E0%A4%85%E0%A4%A0%E0%A5%8D%E0%A4%A0%E0%A4%BE%E0%A4%B5%E0%A5%80%E0%A4%B8%20%E0%A4%B5%E0%A4%BF%E0%A4%9F%E0%A5%87%E0%A4%B5%E0%A4%B0%E0%A5%80%20%E0%A4%8A%E0%A4%AD%E0%A4%BE%20%E0%A5%A4%7C%2Fyuge%20atthavis.jpg?alt=media&token=c2125599-0db9-44ab-a309-95182d6d3ae3'
      ],
    ),
    CastMedia(
        title: 'Chromecast video 1',
        contentId:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        images: ['https://i.ytimg.com/vi/YlYCO2VLUEc/maxresdefault.jpg'])
  ];

  void initState() {
    super.initState();

    _reconnectOrDiscover();
  }

  _reconnectOrDiscover() async {
    bool reconnectSuccess = await reconnect();
    if (!reconnectSuccess) {
      _discover();
    }
  }

  _discover() async {
    _serviceDiscovery = ServiceDiscovery();
    _serviceDiscovery.changes.listen((_) {
      setState(
          () => _servicesFound = _serviceDiscovery.foundServices.length > 0);
    });
    _serviceDiscovery.startDiscovery();
  }

  Future<bool> reconnect() async {
    final prefs = await SharedPreferences.getInstance();
    String host = prefs.getString('cast_session_host');
    String name = prefs.getString('cast_session_device_name');
    String type = prefs.getString('cast_session_device_type');
    String sourceId = prefs.getString('cast_session_sender_id');
    String destinationId = prefs.getString('cast_session_destination_id');
    if (null == host ||
        null == name ||
        null == type ||
        null == sourceId ||
        null == destinationId) {
      return false;
    }

    CastDevice device = CastDevice(
        name: name,
        host: host,
        port: prefs.getInt('cast_session_port') ?? 8009,
        type: type);
    _castSender = CastSender(device);
    StreamSubscription subscription = _castSender.castSessionController.stream
        .listen((CastSession castSession) {
      print('CastSession update ${castSession.isConnected.toString()}');
      if (castSession.isConnected) {
        _castSessionIsConnected(castSession);
      }
    });
    bool didReconnect = await _castSender.reconnect(
      sourceId: sourceId,
      destinationId: destinationId,
    );
    if (!didReconnect) {
      subscription.cancel();
      _castSender = null;
    }
    return didReconnect;
  }

  void disconnect() async {
    if (null != _castSender) {
      await _castSender.disconnect();
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('cast_session_host');
      prefs.remove('cast_session_port');
      prefs.remove('cast_session_device_name');
      prefs.remove('cast_session_device_type');
      prefs.remove('cast_session_sender_id');
      prefs.remove('cast_session_destination_id');
      setState(() {
        _castSender = null;
        _servicesFound = false;
        _castConnected = false;
        _discover();
      });
    }
  }

  void _castSessionIsConnected(CastSession castSession) async {
    setState(() {
      _castConnected = true;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cast_session_host', _castSender.device.host);
    prefs.setInt('cast_session_port', _castSender.device.port);
    prefs.setString('cast_session_device_name', _castSender.device.name);
    prefs.setString('cast_session_device_type', _castSender.device.type);
    prefs.setString('cast_session_sender_id', castSession.sourceId);
    prefs.setString('cast_session_destination_id', castSession.destinationId);
  }

  void _connectToDevice(CastDevice device) async {
    // stop discovery, only has to be on when we're not casting already
    _serviceDiscovery.stopDiscovery();

    _castSender = CastSender(device);
    StreamSubscription subscription = _castSender.castSessionController.stream
        .listen((CastSession castSession) {
      if (castSession.isConnected) {
        _castSessionIsConnected(castSession);
      }
    });
    bool connected = await _castSender.connect();
    if (!connected) {
      // show error message...
      subscription.cancel();
      _castSender = null;
      return;
    }

    // SAVE STATE SO WE CAN TRY TO RECONNECT!
    _castSender.launch();
  }

  Widget _buildVideoListItem(BuildContext context, int index) {
    CastMedia castMedia = _videoItems[index];
    return GestureDetector(
      onTap: () => null != _castSender ? _castSender.load(castMedia) : null,
      child: Card(
        child: Column(
          children: <Widget>[
            Image.network(castMedia.images.first),
            Text(castMedia.title),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actionButtons = [];
    if (_servicesFound || _castConnected) {
      IconData iconData = _castConnected ? Icons.cast_connected : Icons.cast;
      actionButtons.add(
        IconButton(
          icon: Icon(iconData),
          onPressed: () {
            if (_castConnected) {
              print('SHOW DISCONNECT DIALOG!');
              // for now just immediately disconnect
              disconnect();
              return;
            }
            Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => DevicePicker(
                  serviceDiscovery: _serviceDiscovery,
                  onDevicePicked: _connectToDevice),
              fullscreenDialog: true,
            ));
          },
        ),
      );
    }
    List<Widget> stackChildren = [
      ListView.builder(
        itemBuilder: _buildVideoListItem,
        itemCount: _videoItems.length,
      ),
    ];

    if (null != _castSender) {
      stackChildren.add(Positioned(
        bottom: 0.0,
        right: 0.0,
        left: 0.0,
        child: CastMiniMediaControls(_castSender, canExtend: true),
      ));
    }
    return Builder(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Chromecast Audio and Video"),
          actions: actionButtons,
        ),
        body: Stack(children: stackChildren),
      );
    });
  }
}
