import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/widgets.dart';

import 'hexadecimal_str_to_int_array.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        title: '测试蓝牙开门',
        home: new TestPage());
  }
}

class TestPage extends StatefulWidget {
  TestPage({Key key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Map<String, ScanResult> _scanResultMap = Map();

  String keyContent = "4441aa"
      "bd2551"
      "da5bdd"
      "5e9c91"
      "e7f094"
      "0ee81d"
      "303044"
      "41212e"
      "93cc55"
      "a9e442"
      "7926f6"
      "43d699"
      "c9cf30"
      "314441"
      "ed24d3"
      "2f947d"
      "486df47a0c28f5771e4e30324441cd41608733632a514677e18224d2851730334441490aa503282e6a4aaff4e9430c1a5dfb30344441e9e6542f13d982bfccd2a6448efe21cb30354441e21c01bdeb6875e329a35a808efd9ea94646";

  List keyContentInts;
  BluetoothCharacteristic _bluetoothCharacteristic;
  BluetoothService _bluetoothService;

  bool findTagetCharacter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('测试蓝牙开门')),
        body: Column(
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  print('开始扫描');
                  FlutterBlue.instance
                      .startScan(timeout: Duration(seconds: 4))
                      .then((value) {
                    List<ScanResult> mScanResult = value;
                    mScanResult.forEach((e) {
                      if (e.device.name == 'MD_43266168A') {
                        _scanResultMap['MD_43266168A'] = e;
                        print("扫描到了目标设备");
                      }
                    });
                  }); //List<ScanResult>
                },
                child: Text(
                  '开始扫描',
                  style: TextStyle(color: Colors.blueAccent),
                )),
            FlatButton(
              onPressed: () {
                FlutterBlue.instance.stopScan();
                print('停止扫描');
              },
              child: Text("停止扫描", style: TextStyle(color: Colors.blueAccent)),
            ),
            FlatButton(
                onPressed: () {
                  print("尝试链接目标设备");
                  _scanResultMap['MD_43266168A']
                      .device
                      .connect(
                          timeout: Duration(seconds: 5), //TODO 链接设备
                          autoConnect: false)
                      .then((value) {
                    print("成功链接目标设备");
                  });
                },
                child:
                    Text('建立连接', style: TextStyle(color: Colors.blueAccent))),
            FlatButton(
                onPressed: () {
                  findTagetCharacter = false;
                  _scanResultMap['MD_43266168A']
                      .device
                      .discoverServices()
                      .then((value) {
                    List<BluetoothService> _BluetoothServices = value;

                    _scanResultMap['MD_43266168A']
                        .device
                        .discoverServices()
                        .then((value) {
                      List<BluetoothService> _BluetoothServices = value;

                      if (_BluetoothServices != null &&
                          _BluetoothServices.isNotEmpty) {
                        for (int j = 0; j < _BluetoothServices.length; j++) {
                          _bluetoothService = _BluetoothServices[j];
                          print('服务$j:' + _bluetoothService.uuid.toString());
                          if (_bluetoothService.uuid.toString() ==
                              '49535343-FE7D-4AE5-8FA9-9FAFD205E455'
                                  .toLowerCase()) {
                            break;
                          } else {
                            _bluetoothService = null;
                          }
                        }

                        if (_bluetoothService != null) {
                          //TODO 发现服务uuid
                          print('发现目标服务');
                          List<BluetoothCharacteristic> characteristicList =
                              _bluetoothService.characteristics;

                          for (int i = 0; i < characteristicList.length; i++) {
                            _bluetoothCharacteristic = characteristicList[i];
                            //'49535343-1E4D-4BD9-BA61-23C647249616' 通知的
                            if ('49535343-8841-43F4-A8D4-ECBE34729BB3'
                                    .toLowerCase() ==
                                _bluetoothCharacteristic.uuid.toString()) {
                              findTagetCharacter = true;
                              print('发现目标写特征');
                              break;
                            }
                          }

                          if (!findTagetCharacter) {
                            print('没有发现目标写特征');
                          }
                        } else {
                          print('没有发现目标服务');
                        }
                      }
                    });
                  });
                },
                child:
                    Text('发现服务', style: TextStyle(color: Colors.blueAccent))),
            FlatButton(
                onPressed: () async {
                  await _bluetoothCharacteristic
                      .setNotifyValue(true); //TODO 设置可通知
                  _bluetoothCharacteristic.value.listen((value) {
                    // do something with new value
                    print('设置通知回调');
                    //   writeData();
                  });
                  print("设置可通知");
                },
                child:
                    Text('设置可通知', style: TextStyle(color: Colors.blueAccent))),
            FlatButton(
                onPressed: () {
                  writeData2(1);
                },
                child: Text('往特征写数据（开门）',
                    style: TextStyle(color: Colors.blueAccent))),
            FlatButton(
              onPressed: () {
                _scanResultMap['MD_43266168A'].device.disconnect();
                print('断开链接');
              },
              child: Text('断开链接', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        ));
  }



  int time = 100;

  void writeData2(int times) async {
    if (times > 7) {
      return;
    }
    print("准备写第$times次数据");
    new Future.delayed(Duration(milliseconds: time), () {
      _bluetoothCharacteristic
          .write(Hexadecimal.covert().sublist((times - 1) * 20, (times - 1) * 20 + 20))
          .then((value) {
        print("写完第$times次数据");
        writeData2(times + 1);
      }).catchError((error){
        if( error.runtimeType== PlatformException){
          printPlatExcep(error);
        }else {
          print("写数据出错信息 2");
          print(error);
        }

      //  retry();


      });
    });
  }

  void printPlatExcep(error) {
          PlatformException _error = error;
    print('写数据出错信息 1');
    print('code = ' + _error.code);
    print(_error.details);
    print('message' + _error.message);
  }


  int retryTimes = 0;
  void retry() {
    print('重试第$retryTimes次');
    _scanResultMap['MD_43266168A'].device.disconnect();
    _scanResultMap['MD_43266168A'].device.disconnect();
    _scanResultMap['MD_43266168A'].device.disconnect();
  }
}


