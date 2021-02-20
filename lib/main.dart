import 'package:chromecast/second.dart';
import 'package:flutter/material.dart';
import 'package:cast/cast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chromecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: second(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _sendMessage(CastSession session) {
    session.sendMessage('urn:x-cast:namespace-of-the-app', {
      'type': 'sample',
    });
  }

  Future<void> _connect(BuildContext context, CastDevice object) async {
    final session = await CastSessionManager().startSession(object);

    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        _sendMessage(session);
      }
    });

    session.messageStream.listen((message) {
      print('receive message: $message');
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': 'YouTube', // set the appId of your app here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter ChromeCast'),
      ),
      body: StreamBuilder<List<CastDevice>>(
        stream: CastDiscoveryService().stream,
        initialData: CastDiscoveryService().devices,
        builder: (context, snapshot) {
          print('snapshot data${snapshot.data}');
          return Column(
            children: snapshot.data.map((device) {
              return ListTile(
                // title: Text(device.name),
                title: Text("RedMo note 3"),
                onTap: () {
                  _connect(context, device);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
