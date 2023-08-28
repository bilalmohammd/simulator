import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.connectionInProgress.value
      ?
       Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
            InkWell(
              onTap: () async{
            controller.stopConnectionProgress();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      null;
                    },
                  ),
                  Center(child: CircularProgressIndicator())
                ],
              ),
            )
         ],
       )
      : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            controller.scanIsInProgress.value
            ?  Expanded(
              child: Container(

                child: ListView(
                   children: [

                     ListTile(
                         title: const Text("Scanning..."),
                         contentPadding: const EdgeInsets.only(right: 20),
                         leading: IconButton(
                           icon: const Icon(Icons.stop_circle_outlined),
                           padding: EdgeInsets.all(5),
                           onPressed: () async {
                             controller.stopWhileScan();
                           },
                         )),
                     const Padding(
                       padding: EdgeInsets.only(bottom: 8.0),
                       child: Center(
                         child: LinearProgressIndicator(
                           minHeight: 1,
                           color: Colors.cyanAccent,
                         ),
                       ),
                     ),
                     ...controller.devicesList.map(
                           (device) => ListTile(
                         title: Text(
                           device.name,
                           style: const TextStyle(color: Colors.black),
                         ),
                         // subtitle: Text("${device}\n RSSI: ${device.rssi}"),
                         leading: const Icon(Icons.bluetooth, size: 20),
                         onTap: () async {
                           if (device.name.endsWith("Simulator")) {
                             controller.stopBleScan();
                             controller.selectSimulatorDevice(device);
                           } else {
                             controller.stopBleScan();
                             controller.connectBleDevice(device);
                           }
                         },
                       ),
                     ).toList(),
                           ],
                     ),
                ))

                : controller.isConnected.value
                                  ? Expanded(
                                flex: 1,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          height: 10,
                                          width: 100,
                                          child: Image.asset('images/img_bt_device.png')),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Simulator s2",
                                            style: TextStyle(color: Colors.black, fontSize: 23),
                                          ),
                                          InkWell(
                                            onTap: controller.bleDisconnect,
                                            child: SizedBox(
                                                height: 35,
                                                width: 35,
                                                child: SvgPicture.asset('images/Bluetooth_Disconnect.svg')),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              )
                                  : Expanded(
                                flex: 1,
                                child: Padding(
                                  padding:  EdgeInsets.all(20.0),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                            onTap: () => controller.startBleScan([]), child: SvgPicture.asset('images/qrcode.svg', width: 100)),
                                        SizedBox(height: 20),
                                        // Text("or"),
                                        // Text(AppLocalizations.of(context)!.or,
                                        //     style: TextStyle(
                                        //         fontSize: blackText36.fontSize, color: whiteText18.color, fontWeight: Text26.fontWeight)),
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                height: 40,
                                                width: 40,
                                                child: IconButton(
                                                    icon: const Icon(
                                                      Icons.list,
                                                      color: Colors.white,
                                                      size: 32,
                                                    ),
                                                    onPressed: () {
                                                      print('');
                                                    }))
                                          ],
                                        ),
                                      ]),
                                ),
                              ),
          ],
        ),
      )
      ),
    );
  }
}
