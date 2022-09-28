import 'package:allshare/controller/resetter.dart';
import 'package:allshare/controller/responsive.dart';
import 'package:allshare/controller/select_file.dart';
import 'package:allshare/controller/sender.dart';
import 'package:allshare/controller/websocket.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/profileData.dart';
import 'package:allshare/view/receive_display/receive_gellary.dart';
import 'package:allshare/view/receive_progress.dart';
import 'package:allshare/view/save_success.dart';
import 'package:allshare/view/send_progress.dart';
import 'package:allshare/view/send_success.dart';
import 'package:allshare/view/users.dart';
import 'package:flutter/material.dart';
import '../view/saving.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Websocket? socketConnection;
  late Future<String?> webRTCconnectionStates;
  bool isSender = false;

  final TextEditingController textInputController = TextEditingController();
  final Websocket socketInstance = Websocket(); //socket Instance
  final FileSelector fileSelectorInstance =
      FileSelector(); //file Selector class Instance
  final LocalSender localSenderInstance =
      LocalSender(); // LocalSender class Instance
  final RemoteSender remoteSenderInstance =
      RemoteSender(); // RemoteSender class Instance
  final AppStates appStatesInstance = AppStates(); // AppStates class Instance;
  final Resetter reSetterInstance = Resetter(); //Resetter class instance
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();
  @override
  dispose() {
    //To stop multiple calling websocket, use the following code.
    socketConnection!.disposeSocket();
    socketInstance.closeAllConnection();
    super.dispose();
  }

  //Initiate all connection
  @override
  void initState() {
    //socketConnection is an Instance of Active Websocket class

    socketInstance.startSocketConnection(appStatesInstance, reSetterInstance);

    super.initState();
    print("InitState is called, sOCKET iD : ${socketInstance.socket!.id}");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print("homepage build methode is called!!");
    return Scaffold(
      key: _drawerKey,
      drawer: Drawer(
        child: ReceiveGellary(appStates: appStatesInstance),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false, //hide default menu icon
        leading: Responsive.isMobile(context)
            ? IconButton(
                icon: const Icon(Icons.heart_broken),
                onPressed: () => _drawerKey.currentState?.openDrawer())
            : null,
        title: const Text("Allshare"),
      ),
      body: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              // constraints: const BoxConstraints(
              //     minWidth: 420, maxWidth: 800, minHeight: 500, maxHeight: 600),
              padding: const EdgeInsets.all(20),
              //width: 850,
              height: double.infinity,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey, width: 1)),
              ),
              // decoration: BoxDecoration(
              //   border: Border.all(width: 1, color: Colors.grey),
              //   borderRadius: const BorderRadius.all(Radius.circular(10)),
              // ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    //width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // constraints: BoxConstraints(
                          //   minWidth: Responsive.value(100, 200, 200, context),
                          //   maxHeight: Responsive.value(180, 200, 200, context),
                          // ),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          // width: 200,
                          // height: 150,
                          width:
                              Responsive.value(width * 0.35, 200, 200, context),
                          height: Responsive.value(80, 150, 150, context),
                          //child: const Text("Sender Offline"),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: appStatesInstance.localUserStatus,
                            builder: (context, value, child) {
                              return value
                                  ? ValueListenableBuilder<ProfileData>(
                                      valueListenable:
                                          appStatesInstance.localUserInfo,
                                      builder: (context, value, child) {
                                        return Users(
                                            name: "${value.name}",
                                            id: "${value.id}",
                                            status: value.status!);
                                      })
                                  : const Center(
                                      child: Text("Sender Offline"),
                                    );
                            },
                          ),
                        ),
                        SizedBox(
                          width:
                              Responsive.value(width * 0.1, 100, 100, context),
                          height:
                              Responsive.value(width * 0.1, 100, 100, context),
                          child: const Center(
                              child: Icon(
                            Icons.sync_alt,
                            color: Colors.green,
                          )),
                        ),
                        Container(
                          // constraints: BoxConstraints(
                          //   minWidth: Responsive.value(100, 200, 200, context),
                          //   maxHeight: Responsive.value(180, 200, 200, context),
                          // ),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          // width: 200,
                          // height: 150,
                          width:
                              Responsive.value(width * 0.35, 200, 200, context),
                          height: Responsive.value(80, 150, 150, context),
                          //child: const Text("Receiver Offline"),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: appStatesInstance.remoteUserStatus,
                            builder: (context, value, child) {
                              return value
                                  ? ValueListenableBuilder<ProfileData>(
                                      valueListenable:
                                          appStatesInstance.remoteUserInfo,
                                      builder: (context, value, child) {
                                        return Users(
                                            name: "${value.name}",
                                            id: "${value.id}",
                                            status: value.status!);
                                      },
                                    )
                                  : const Center(
                                      child: Text("Receiver Offline"),
                                    );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      socketInstance.updateUsers(appStatesInstance);

                      print('Refresh Button is Clicked!!');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      width: 300,
                      height: 60,
                      child: ValueListenableBuilder<bool>(
                          valueListenable: appStatesInstance.localUserStatus,
                          builder: (_, localUserStatus, __) {
                            return localUserStatus
                                ? ValueListenableBuilder<bool>(
                                    valueListenable:
                                        appStatesInstance.remoteUserStatus,
                                    builder: (_, remoteUserStatus, __) {
                                      return remoteUserStatus
                                          ? const Center(
                                              child: Text(
                                                "Users Active",
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          : const Center(
                                              child: Text("Refresh Users"));
                                    })
                                : const Center(child: Text("Refresh Users"));
                          }),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  //Create Connection
                  GestureDetector(
                    onTap: () {
                      socketInstance.localInstance.createLocalConnection(
                          socketInstance.socket!,
                          appStatesInstance,
                          reSetterInstance);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      width: 300,
                      height: 60,
                      child: Center(
                          //Showing webrtc connection status
                          child: ValueListenableBuilder<bool>(
                              valueListenable: appStatesInstance.isSender,
                              builder: (context, value, child) {
                                return value
                                    ? ValueListenableBuilder<String>(
                                        valueListenable:
                                            appStatesInstance.localState,
                                        builder: (context, value, child) {
                                          return Text(value);
                                        })
                                    : ValueListenableBuilder<String>(
                                        valueListenable:
                                            appStatesInstance.remoteState,
                                        builder: (context, value, child) {
                                          return Text(value);
                                        });
                              })
                          //child: connectBtnText(),
                          ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  //Show Selected File name
                  ValueListenableBuilder<bool>(
                      valueListenable: appStatesInstance.isFileSelected,
                      builder: (_, isFileSelected, __) {
                        return isFileSelected
                            ? Text(appStatesInstance.selectedFileName.value)
                            : const SizedBox(
                                width: 0,
                                height: 0,
                              );
                      }),

                  const SizedBox(
                    height: 10,
                  ),

                  // Select file button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          //onPressed: () {},
                          onPressed: (() {
                            fileSelectorInstance.selectFile(appStatesInstance);
                          }),
                          icon: const Icon(Icons.attach_file)),
                      const SizedBox(
                        width: 7,
                      ),
                      Expanded(
                        child: TextField(
                          controller: textInputController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter text here',
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ValueListenableBuilder<bool>(
                          valueListenable: appStatesInstance.isSender,
                          builder: (context, value, child) {
                            return value
                                ? ValueListenableBuilder<bool>(
                                    valueListenable:
                                        appStatesInstance.isFileSelected,
                                    builder: (context, isFileSelected, child) {
                                      return isFileSelected
                                          ? ElevatedButton(
                                              onPressed: () {
                                                localSenderInstance.sendFile(
                                                    socketInstance.localInstance
                                                        .localDataChannel,
                                                    fileSelectorInstance
                                                        .selectedfile,
                                                    fileSelectorInstance.chunks,
                                                    appStatesInstance,
                                                    reSetterInstance);
                                              },
                                              child: const Text('Send File'))
                                          : ElevatedButton(
                                              onPressed: () {
                                                localSenderInstance.sendtext(
                                                  socketInstance.localInstance
                                                      .localDataChannel,
                                                  textInputController,
                                                );
                                              },
                                              child: const Text('Send Text'));
                                    })
                                : ValueListenableBuilder<bool>(
                                    valueListenable:
                                        appStatesInstance.isFileSelected,
                                    builder: (context, isFileSelected, child) {
                                      return isFileSelected
                                          ? ElevatedButton(
                                              onPressed: () {
                                                remoteSenderInstance.sendFile(
                                                    socketInstance
                                                        .remoteInstance
                                                        .remoteDataChannel,
                                                    fileSelectorInstance
                                                        .selectedfile,
                                                    fileSelectorInstance.chunks,
                                                    appStatesInstance,
                                                    reSetterInstance);
                                              },
                                              child: const Text('Send File'))
                                          : ElevatedButton(
                                              onPressed: () {
                                                remoteSenderInstance.sendtext(
                                                  socketInstance.remoteInstance
                                                      .remoteDataChannel,
                                                  textInputController,
                                                );
                                              },
                                              child: const Text('Send Text'));
                                    });
                          }),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),

                  //Send Progress Indicator
                  ValueListenableBuilder<bool>(
                      valueListenable: appStatesInstance.isShowSendProgress,
                      builder: (context, isShowSendProgress, child) {
                        return isShowSendProgress
                            ? SendProgressIndicator(
                                appStates: appStatesInstance)
                            : const SizedBox(
                                width: 0,
                                height: 0,
                              );
                      }),
                  //Receive Progress Indicator
                  ValueListenableBuilder<bool>(
                      valueListenable: appStatesInstance.isShowReceiveProgress,
                      builder: (context, isShowReceiveProgress, child) {
                        return isShowReceiveProgress
                            ? ReceiveProgressIndicator(
                                appStates: appStatesInstance)
                            : const SizedBox(
                                width: 0,
                                height: 0,
                              );
                      }),

                  //Show Send Success Indicator
                  ValueListenableBuilder<bool>(
                      valueListenable: appStatesInstance.isShowSendSuccess,
                      builder: (context, isShowSendSuccess, child) {
                        return isShowSendSuccess
                            ? const SendSuccessIndicator()
                            : const SizedBox(
                                width: 0,
                                height: 0,
                              );
                      }),
                  //Show Save Success Indicator
                  ValueListenableBuilder<bool>(
                      valueListenable: appStatesInstance.isShowSaveSuccess,
                      builder: (context, isShowSaveSuccess, child) {
                        return isShowSaveSuccess
                            ? const SaveSuccessIndicator()
                            : const SizedBox(
                                width: 0,
                                height: 0,
                              );
                      }),
                  //Show Saving Indicator
                  ValueListenableBuilder<bool>(
                      valueListenable: appStatesInstance.isShowSaving,
                      builder: (context, isShowSaving, child) {
                        return isShowSaving
                            ? const FileSavingIndicator()
                            : const SizedBox(
                                width: 0,
                                height: 0,
                              );
                      }),
                ],
              ),
            ),
          ),

          // File Received Area
          if (!Responsive.isMobile(context))
            ReceiveGellary(appStates: appStatesInstance),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
