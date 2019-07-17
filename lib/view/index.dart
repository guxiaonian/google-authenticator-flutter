import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera.dart';
import 'toast.dart';
import 'sqlite.dart';
import 'utils.dart';
import 'timer.dart';
import 'listener.dart';
import 'dart:async';

class IndexPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  IndexPage(this.cameras);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> implements ViewListener {
  List<OTP> data = [];
  OTPProvider otpProvider;

//  Timer _timer;
  bool canTouch = true;

  @override
  void initState() {
    super.initState();
    otpProvider = OTPProvider();
    otpProvider.open("validator.db").then((result) {
      _queryDb();
    });
  }

  void _queryDb() {
    otpProvider.query().then((maps) {
      if (!mounted) {
        return;
      }
      setState(() {
        data.clear();
        for (Map map in maps) {
          print(map.toString());
          data.add(OTP.fromMap(map));
        }
      });
    });
  }

  void _dataOfValidator(var data) {
    if (null == data) {
      return;
    }
    String result = data.toString();
    print('扫描结果为:$result');
    if (result.startsWith("otpauth://totp")) {
      _otpData(result, true);
      return;
    }

    if (result.startsWith("otpauth://hotp")) {
      _otpData(result, false);
      return;
    }

    ToastHelper.showToast(context, '扫描结果为:$result');
  }

  void _otpData(String result, bool isTotp) {
    Uri uri = Uri.parse(result);
    String period =
        isTotp ? uri.queryParameters['period'] : uri.queryParameters['counter'];
    if (null == period) {
      period = isTotp ? '30' : '1';
    } else if (!isTotp) {
      period = (int.parse(period) + 1).toString();
    }
    String secret = uri.queryParameters["secret"];
    if (null == secret) {
      ToastHelper.showToast(context, 'QR码非法');
      return;
    }
    String path = uri.path;
    if (null == path) {
      ToastHelper.showToast(context, 'QR码非法');
      return;
    }
    path = path.substring(1);
    String issuer = uri.queryParameters["issuer"];
    OTP otp = OTP(null, path, secret, period, issuer, isTotp);
    otpProvider.getOTP(path).then((result) {
      if (null == result) {
        print("未找到数据库中相同的数据");
        otpProvider.insert(otp).then((result) {
          print("开始遍历数据库");
          _queryDb();
        });
      } else {
        print("找到数据库中相同的数据");
        otp.id = result.id;
        otpProvider.update(otp).then((result) {
          print("开始遍历数据库");
          _queryDb();
        });
      }
    }).catchError((error) {
      print(error);
    });
  }

  Widget _bodyView() {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int position) {
          return getItem(data[position]);
        });
  }

  getItem(OTP data) {
    const styleNumber = TextStyle(
        color: Colors.white,
        fontSize: 26.0,
        decoration: TextDecoration.none,
        letterSpacing: 2);
    const styleSubtitle = TextStyle(
        color: Colors.white60, fontSize: 16.0, decoration: TextDecoration.none);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      color: Colors.white10,
      margin: EdgeInsets.only(top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            trailing: data.isTotp ? _totpIcon() : _hotpIcon(data.id),
            title: Text(
              Utils.getNumber(data.secret, data.isTotp, data.period),
              style: styleNumber,
            ),
            subtitle: Text(
              Utils.getPath(data.path, data.issuer),
              style: styleSubtitle,
            ),
            onTap: () => {_hotpTap(data)},
            onLongPress: () => {_show(data)},
          ),
        ],
      ),
    );
  }

  Map<int, Timer> valueMap = Map();

  void _show(OTP data) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('提示'),
              content: Text(('是否删除本账号...')),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("取消"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text("确定"),
                  onPressed: () {
                    int id = data.id;
                    otpProvider.delete(id).then((result) {
                      print("开始遍历数据库");
                      _queryDb();
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            ));
  }

  void _hotpTap(OTP data) {
    print("点击");
    if (!valueMap.containsKey(data.id) && !data.isTotp) {
      startCountdownTimer(data.id);
      int counter = int.parse(data.period) + 1;
      data.period = counter.toString();
      otpProvider.update(data).then((result) {
        print("开始遍历数据库");
        _queryDb();
      });
    }
  }

  void startCountdownTimer(id) {
    Timer timer = Timer(new Duration(seconds: 5), () {
      print("倒计时完成");
      setState(() {
        valueMap.remove(id);
      });
    });
    setState(() {
      valueMap[id] = timer;
    });
  }

  Widget _hotpIcon(id) {
    return Icon(
      Icons.refresh,
      color: !valueMap.containsKey(id) ? Colors.white60 : Colors.white10,
      size: 24,
    );
  }

  Widget _totpIcon() {
    return TimerWidget(this);
  }

  @override
  void dispose() {
    otpProvider?.close();
    valueMap.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text("Google 身份验证器"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _bodyView(),
      floatingActionButton: FloatingActionButton(
          onPressed: () => {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) =>
                            new CameraPage(widget.cameras))).then((result) {
                  _dataOfValidator(result);
                }).catchError((onError) {
                  print(onError);
                })
              },
          child: new Icon(Icons.add),
          backgroundColor: Colors.red),
    );
  }

  @override
  void onSuccess() {
    _queryDb();
  }
}
