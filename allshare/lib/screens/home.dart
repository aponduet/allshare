import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:allshare/model/file_info.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:allshare/model/profileData.dart';
import 'package:allshare/view/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:file_picker/file_picker.dart';
import '../controller/controller.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textInputController = TextEditingController();
  late IO.Socket socket;
  ProfileData? firstUser;
  ProfileData? secondUser;
  bool isConnectedSender = false;
  bool isConnectedReceiver = false;
  bool isFirstUserInfoSet = false;
  RTCPeerConnection? localConnection;
  RTCPeerConnection? remoteConnection;
  String? localstate = "Connect";
  String? remotestate = "Connect";
  RTCDataChannel? sendChannel;
  RTCDataChannel? receiveChannel;
  RTCDataChannelInit? _dataChannelDict;
  List<Uint8List>? receivedChunks = [];
  double sendprogress = 0;
  double receiveprogress = 0;
  int? totalChunks;
  bool showSendProgressBar = false;
  bool showReceiveProgressBar = false;
  int currentChunkIndex = 0;

  @override
  dispose() {
    //To stop multiple calling websocket, use the following code.
    if (socket.disconnected) {
      socket.disconnect();
    }
    closeAllConnection();
    super.dispose();
  }

  //Initiate all connection
  @override
  void initState() {
    initSocket();
    super.initState();
    print("InitState is called");
  }

  closeAllConnection() {
    remoteConnection!.close();
    localConnection!.close();
    sendChannel!.close();
    receiveChannel!.close();
  }

  // Socket Connection Start
  void initSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.on('connect', (_) {
      print('Connected id : ${socket.id}');
    });

    socket.onConnect((data) async {
      print('Socket Server Successfully connected');
    });

    socket.on("userDisconnected", (data) {
      setState(() {
        isConnectedReceiver = false;
      });
    });

    //receive Second User Information from Server
    socket.on('secondUserInfo', (data) {
      Map<String, dynamic> json = jsonDecode(data);
      ProfileData secondUserData = ProfileData.fromJson(json);
      setState(() {
        secondUser = secondUserData;
        isConnectedReceiver = true;
      });
      if (!isFirstUserInfoSet) {
        if (socket.connected) {
          ProfileData userInfo = ProfileData(
            name: "Sohel Rana",
            id: socket.id,
            status: socket.connected,
          );

          setState(() {
            firstUser = userInfo;
            isConnectedSender = true;
            isFirstUserInfoSet = true;
          });
          socket.emit("firstUserInfo", jsonEncode(userInfo));
        }
      }
    });

    //Answer received from Second client which is set as remote description
    socket.on("receiveAnswer", (data) async {
      print("Answer received: $data");
      String sdp = write(data["session"], null);
      print('Sring SDP is : $sdp');

      RTCSessionDescription description = RTCSessionDescription(sdp, 'answer');

      await localConnection!.setRemoteDescription(description);
    });

    //Remote area

    //Offer received from First client
    socket.on("receiveOffer", (data) async {
      print("Offer received $data");

      remoteConnection =
          await createPeerConnection(configuration, offerSdpConstraints);
      String sdp = write(data["session"], null);

      RTCSessionDescription description = RTCSessionDescription(sdp, 'offer');

      await remoteConnection!.setRemoteDescription(description);

      RTCSessionDescription description2 = await remoteConnection!
          .createAnswer({
        'offerToReceiveAudio': 1
      }); // {'offerToReceiveVideo': 1 for video call

      print("Remote Session Description : ${description2.sdp}");

      var session = parse(description2.sdp.toString());

      await remoteConnection!.setLocalDescription(description2);

      socket.emit("createAnswer", {"session": session});

      remoteConnection!.onConnectionState = (state) {
        print("Remote Connection State is : $state");
      };

      //ICE Candidate
      remoteConnection!.onIceCandidate = (e) {
        print("On-ICE Candidate is Finding");
        //Transmitting candidate data from answerer to caller
        if (e.candidate != null) {
          socket.emit("sendCandidateToLocal", {
            "candidate": {
              'candidate': e.candidate.toString(),
              'sdpMid': e.sdpMid.toString(),
              'sdpMlineIndex': e.sdpMLineIndex,
            },
          });
        }
      };
      remoteConnection!.onIceConnectionState = (e) {
        print(e);
      };

      // Checking Connection State

      remoteConnection!.onConnectionState = (state) async {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state ==
                RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          setState(() {
            remotestate = "Disconnected";
          });
        }
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          setState(() {
            remotestate = "Connection Closed";
          });
        }
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          setState(() {
            remotestate = "Connected";
          });
        }
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateNew ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
          setState(() {
            remotestate = "Connecting..";
          });
        }
      };

      // Remote Data channel
      remoteConnection!.onDataChannel = (channel) {
        receiveChannel = channel;
        receiveChannel!.onMessage = (message) async {
          if (message.isBinary) {
            receivedChunks!.add(message.binary);
            // Update progress bar value
            double percent = (receivedChunks!.length) / totalChunks!;

            setState(() {
              receiveprogress = percent;
            });
            print(receiveprogress);
            print("Chunk Received Successfully!! ${message.binary}");
          }
          if (!message.isBinary) {
            FileInfo fileheaders = FileInfo.fromJson(jsonDecode(message.text));
            if (fileheaders.isLastChunk) {
              saveFile(message.text);
            }
            setState(() {
              totalChunks = fileheaders.totalChunk;
            });
          }
          //Show Received Progress
          setState(() {
            showReceiveProgressBar = true;
          });
        };
      };
    });

    //Receiving Local Candidates
    //THIS COMPELETES THE CONNECTION PROCEDURE
    socket.on("receiveLocalCandidate", (data) async {
      print("Local Candidate received $data");
      dynamic candidate = RTCIceCandidate(data['candidate']['candidate'],
          data['candidate']['sdpMid'], data['candidate']['sdpMlineIndex']);
      await remoteConnection!.addCandidate(candidate);
    });
    //Receiving Remote Candidates
    //THIS COMPELETES THE CONNECTION PROCEDURE
    socket.on("receiveRemoteCandidate", (data) async {
      print("Remote Candidate received $data");
      dynamic candidate = RTCIceCandidate(data['candidate']['candidate'],
          data['candidate']['sdpMid'], data['candidate']['sdpMlineIndex']);
      await localConnection!.addCandidate(candidate);
    });
  }

  //Search Receiver
  refreshUsers() {
    if (socket.connected) {
      ProfileData userInfo = ProfileData(
        name: "Sohel Rana",
        id: socket.id,
        status: socket.connected,
      );

      setState(() {
        firstUser = userInfo;
        isConnectedSender = true;
        isFirstUserInfoSet = true;
      });
      socket.emit("firstUserInfo", jsonEncode(userInfo));
    }
  }

  //****** WEBRTC Connection Start Here ******** */
  bool offer = false;
  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
      {
        "url": 'turn:192.158.29.39:3478?transport=udp',
        "credential": 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
        "username": '28224511:1379330808'
      }
    ]
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true, //for video call
    },
    "optional": [],
  };

  // Local area
  Future<void> createConnection() async {
    localConnection =
        await createPeerConnection(configuration, offerSdpConstraints);

    // local data channel
    _dataChannelDict = RTCDataChannelInit();
    // _dataChannelDict!.id = 1;
    // _dataChannelDict!.ordered = true;
    // _dataChannelDict!.maxRetransmitTime = -1;
    // _dataChannelDict!.maxRetransmits = -1;
    // _dataChannelDict!.protocol = 'sctp';
    // _dataChannelDict!.negotiated = false;
    sendChannel = await localConnection!
        .createDataChannel("sendChannel", _dataChannelDict!);
    sendChannel!.onMessage = (message) {
      if (message.isBinary) {
        receivedChunks!.add(message.binary);
        // Update progress bar value
        double percent = (receivedChunks!.length) / totalChunks!;
        setState(() {
          receiveprogress = percent;
        });

        print("Chunk Received Successfully!! ${message.binary}");
      }
      if (!message.isBinary) {
        FileInfo fileheaders = FileInfo.fromJson(jsonDecode(message.text));
        if (fileheaders.isLastChunk) {
          saveFile(message.text);
        }
        setState(() {
          totalChunks = fileheaders.totalChunk;
        });
      }

      //Show Received Progress
      setState(() {
        showReceiveProgressBar = true;
      });

      // if (message.isBinary) {
      //   receivedChunks.add(message.binary);
      //   print("Chunk Received Successfully!! ${message.binary}");
      // }
      // if (!message.isBinary) {
      //   saveFile(message.text);
      // }
    };

    //Create Offer
    RTCSessionDescription description =
        await localConnection!.createOffer({'offerToReceiveAudio': 1});
    print("Local Session Description ${description.sdp}");
    localConnection!.setLocalDescription(description);
    var session = parse(description.sdp.toString());
    socket.emit("createOffer", {"session": session});
    setState(() {
      offer = true;
    });

    //Sending Caller Ice Candidate
    localConnection!.onIceCandidate = (e) {
      print("On-ICE Candidate is Finding");
      //Transmitting candidate data from answerer to caller
      if (e.candidate != null) {
        socket.emit("sendCandidateToRemote", {
          "candidate": {
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          },
        });
      }
    };

    //Check WebRTC Connection
    localConnection!.onConnectionState = (state) {
      print("Local Connection State is : $state");
    };

    localConnection!.onIceConnectionState = (e) {
      print("Ice Connection State is : $e");
    };

    // Checking Connection State

    localConnection!.onConnectionState = (state) async {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        setState(() {
          localstate = "Disconnected";
        });
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        setState(() {
          localstate = "Connection Closed";
        });
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        setState(() {
          localstate = "Connected";
        });
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateNew ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        setState(() {
          localstate = "Connecting..";
        });
      }
    };
  }

  //Button Text Depending on WEBSocket Connection State
  Widget buttonText(bool x, bool y) {
    if (x == y) {
      return const Text("Users Active");
    } else {
      return const Text("Refresh");
    }
  }

  //Update Maximum Size
  // int maximumMessageSize = 16000;
  // Future updateMaximumMessageSize() async {
  //   RTCSessionDescription? local = await localConnection!.getLocalDescription();
  //   RTCSessionDescription? remote =
  //       await remoteConnection!.getRemoteDescription();

  //   int localMaximumSize = parseMaximumSize(local!);
  //   int remoteMaximumSize = parseMaximumSize(remote);
  //   int messageSize = min(localMaximumSize, remoteMaximumSize);

  //   print(
  //       'SENDER: Updated max message size: $messageSize Local: $localMaximumSize Remote: $remoteMaximumSize ');
  //   maximumMessageSize = messageSize;
  // }

  // //Set Max Cunk Size
  // int parseMaximumSize(RTCSessionDescription? description) {
  //   var remoteLines = description?.sdp?.split('\r\n') ?? [];

  //   int remoteMaximumSize = 0;
  //   for (final line in remoteLines) {
  //     if (line.startsWith('a=max-message-size:')) {
  //       var string = line.substring('a=max-message-size:'.length);
  //       remoteMaximumSize = int.parse(string);
  //       break;
  //     }
  //   }

  //   if (remoteMaximumSize == 0) {
  //     print('SENDER: No max message size session description');
  //   }

  //   // 16 kb should be supported on all clients so we can use it
  //   // even if no max message is set
  //   return max(remoteMaximumSize, maximumMessageSize);
  // }

  //Send Message
  sendtext() {
    //Send message to Remote
    String messageText = textInputController.text;
    RTCDataChannelMessage textMessage = RTCDataChannelMessage(messageText);
    offer ? sendChannel!.send(textMessage) : receiveChannel!.send(textMessage);
    textInputController.text = "";
  }

  //Send Message
  File? file;
  Uint8List? fileInBytes;
  sendFile() async {
    //Send files to Remote

    fileInBytes = selectedfile!.bytes;
    var chunks = [];
    int chunkSize = 262144;
    for (var i = 0; i < fileInBytes!.length; i += chunkSize) {
      chunks.add(fileInBytes!.sublist(
          i,
          i + chunkSize > fileInBytes!.length
              ? fileInBytes!.length
              : i + chunkSize));
    }
    sendChannel!.bufferedAmountLowThreshold =
        16768090; // max allowable buffered amount in Bytes
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (sendChannel!.bufferedAmount! >=
          sendChannel!.bufferedAmountLowThreshold!) {
        print(
            "Send Bucket is full, Threshold: ${sendChannel!.bufferedAmountLowThreshold}, & Buffered Amount: ${sendChannel!.bufferedAmount}");
        Timer(const Duration(seconds: 2), () {
          print("Checking Buffered amount...");
        });
      }

      if (currentChunkIndex == 0) {
        //Sending total chunk to Receiver
        FileInfo fileHistory = FileInfo(
            name: selectedfile!.name,
            extn: selectedfile!.extension,
            totalChunk: chunks.length,
            isLastChunk: false);
        String info = jsonEncode(fileHistory);
        RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
        offer ? sendChannel!.send(fileData) : receiveChannel!.send(fileData);
        print("This is First Message with Total Chunk");
      }

      if (currentChunkIndex < chunks.length) {
        RTCDataChannelMessage binaryMessage =
            RTCDataChannelMessage.fromBinary(chunks[currentChunkIndex]);
        //print(binaryMessage);

        offer
            ? sendChannel!.send(binaryMessage)
            : receiveChannel!.send(binaryMessage);

        double percent = currentChunkIndex / (chunks.length);
        setState(() {
          sendprogress = percent;
        });
      }

      if (currentChunkIndex == chunks.length) {
        FileInfo fileHistory = FileInfo(
            name: selectedfile!.name,
            extn: selectedfile!.extension,
            totalChunk: chunks.length,
            isLastChunk: true);
        String info = jsonEncode(fileHistory);
        RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
        setState(() {
          sendprogress = 1.0;
        });

        offer ? sendChannel!.send(fileData) : receiveChannel!.send(fileData);
        print("Total chunk : ${chunks.length}");
        print("Last Chunk has been sent");
        timer.cancel();
      }

      setState(() {
        currentChunkIndex = currentChunkIndex + 1;
      });
    });

    /* sendNext(int currentChunkIndex) {
      if (sendChannel!.bufferedAmount! >= 1676809) {
        print(
            "Send Bucket is full, Threshold: ${sendChannel!.bufferedAmountLowThreshold}, & Buffered Amount: ${sendChannel!.bufferedAmount}");
        Future.delayed(const Duration(seconds: 3), () {
          print("Checking Buffered amount...");
          sendNext(currentChunkIndex);
        });

        //sleep(const Duration(seconds: 1));
      } else {
        if (currentChunkIndex == 0) {
          //Sending total chunk to Receiver
          FileInfo fileHistory = FileInfo(
              name: selectedfile!.name,
              extn: selectedfile!.extension,
              totalChunk: chunks.length,
              isLastChunk: false);
          String info = jsonEncode(fileHistory);
          RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
          offer ? sendChannel!.send(fileData) : receiveChannel!.send(fileData);
          print("This is First Message with Total Chunk");
        }

        if (currentChunkIndex < chunks.length) {
          RTCDataChannelMessage binaryMessage =
              RTCDataChannelMessage.fromBinary(chunks[currentChunkIndex]);
          //print(binaryMessage);

          offer
              ? sendChannel!.send(binaryMessage)
              : receiveChannel!.send(binaryMessage);

          double percent = currentChunkIndex / (chunks.length);
          setState(() {
            sendprogress = percent;
          });
        }

        if (currentChunkIndex == chunks.length) {
          FileInfo fileHistory = FileInfo(
              name: selectedfile!.name,
              extn: selectedfile!.extension,
              totalChunk: chunks.length,
              isLastChunk: true);
          String info = jsonEncode(fileHistory);
          RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
          setState(() {
            sendprogress = 1.0;
          });

          offer ? sendChannel!.send(fileData) : receiveChannel!.send(fileData);
          print("Total chunk : ${chunks.length}");
          print("Last Chunk has been sent");
        }
      }
    }      */

    //Large File Sending System codes

    /* 

    for (var i = 0; i <= chunks.length; i++) {
      //Large File Sending System codes
      //bool sendNextChunk = true;

      if (sendChannel!.bufferedAmount! >= 1676809) {
        print(
            "Send Bucket is full, Threshold: ${sendChannel!.bufferedAmountLowThreshold}, & Buffered Amount: ${sendChannel!.bufferedAmount}");
        Future.delayed(const Duration(seconds: 3));

        //sleep(const Duration(seconds: 1));
      }

      if (i == 0) {
        //Sending total chunk to Receiver
        FileInfo fileHistory = FileInfo(
            name: selectedfile!.name,
            extn: selectedfile!.extension,
            totalChunk: chunks.length,
            isLastChunk: false);
        String info = jsonEncode(fileHistory);
        RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
        offer ? sendChannel!.send(fileData) : receiveChannel!.send(fileData);
        print("This is First Message with Total Chunk");
      }
      if (i < chunks.length) {
        RTCDataChannelMessage binaryMessage =
            RTCDataChannelMessage.fromBinary(chunks[i]);
        //print(binaryMessage);

        offer
            ? sendChannel!.send(binaryMessage)
            : receiveChannel!.send(binaryMessage);

        double percent = i / (chunks.length);
        setState(() {
          sendprogress = percent;
        });
      }
      if (i == chunks.length) {
        FileInfo fileHistory = FileInfo(
            name: selectedfile!.name,
            extn: selectedfile!.extension,
            totalChunk: chunks.length,
            isLastChunk: true);
        String info = jsonEncode(fileHistory);
        RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
        setState(() {
          sendprogress = 1.0;
        });

        offer ? sendChannel!.send(fileData) : receiveChannel!.send(fileData);
        print("Total chunk : ${chunks.length}");
        print("Last Chunk has been sent");
      }
    }

    */

    // Showing Progress indicator
    setState(() {
      showSendProgressBar = true;
    });
  }

  //Save Files in Devices

  saveFile(String message) async {
    if (!kIsWeb) {
      if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
        bool status = await Permission.storage.isGranted;
        if (!status) await Permission.storage.request();
      }
    }

    FileInfo fileheaders = FileInfo.fromJson(jsonDecode(message));
    String? filename = fileheaders.name ?? "";
    String? extension = fileheaders.extn ?? "";
    //Convert List<Uint8List> to List<int>  //https://stackoverflow.com/questions/62295468/listuint8list-to-listint-in-dart
    List<int> readyChunks = [
      for (var sublist in receivedChunks!) ...sublist,
    ];

    Uint8List finalChunks = Uint8List.fromList(readyChunks);
    await FileSaver.instance
        .saveFile(filename, finalChunks, extension, mimeType: MimeType.OTHER);
    //Set ReceivedChunk List empty after saving file.
    setState(() {
      receivedChunks = null;
    });
    print(" Total Received Chunks : ${receivedChunks!.length}");
    print("${receivedChunks}");
  }

  //File input Handler

  PlatformFile? selectedfile;
  inputfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        selectedfile = file;
      });
      print(file.name);
      // print(file.bytes);
      // print(file.size);
      // print(file.extension);
      // print(file.path);
    } else {
      print("No Files Selected!!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: Container(
          // constraints: const BoxConstraints(
          //     minWidth: 420, maxWidth: 800, minHeight: 500, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          width: 850,
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
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
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      width: 350,
                      height: 150,
                      child: isConnectedSender
                          ? Users(
                              name: "${firstUser!.name}",
                              id: "${firstUser!.id}",
                              status: firstUser!.status!)
                          : const Center(
                              child: Text("Sender Offline"),
                            ),
                    ),
                    const SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                          child: Icon(
                        Icons.sync_alt,
                        color: Colors.green,
                      )),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      width: 350,
                      height: 150,
                      child: isConnectedReceiver
                          ? Users(
                              name: "${secondUser!.name}",
                              id: "${secondUser!.id}",
                              status: secondUser!.status!)
                          : const Center(
                              child: Text("Receiver Offline"),
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
                  refreshUsers();
                  print('Clicked Button');
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  width: 300,
                  height: 60,
                  child: Center(
                    //child: Text("Refresh"),
                    child: buttonText(isConnectedReceiver, isConnectedSender),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  createConnection();
                  print('Clicked Refreshed Button');
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  width: 300,
                  height: 60,
                  child: Center(
                    child: offer ? Text("$localstate") : Text("$remotestate"),
                    //child: connectBtnText(),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              if (selectedfile != null)
                Text(
                  selectedfile!.name,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(
                height: 10,
              ),

              // File attach area
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: inputfile,
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
                  ElevatedButton(
                      onPressed: sendtext, child: const Text('Send Text')),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                      onPressed: sendFile, child: const Text('Send File File')),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              if (showSendProgressBar)
                LinearPercentIndicator(
                  width: 800.0,
                  lineHeight: 14.0,
                  percent: sendprogress,
                  backgroundColor: Colors.grey,
                  progressColor: Colors.blue,
                ),
              //Progress Indicator

              if (showReceiveProgressBar)
                LinearPercentIndicator(
                  width: 800.0,
                  lineHeight: 14.0,
                  percent: receiveprogress,
                  backgroundColor: Colors.grey,
                  progressColor: Colors.blue,
                ),

              const SizedBox(
                height: 20,
              ),
              //Received Files Area

              // Container(
              //   height: 70,
              //   padding: const EdgeInsets.all(5),
              //   decoration: BoxDecoration(
              //       border: Border.all(width: 1, color: Colors.grey),
              //       borderRadius: const BorderRadius.all(Radius.circular(3))),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       Container(
              //         width: 50,
              //         height: 60,
              //         decoration: BoxDecoration(
              //             border: Border.all(width: 1, color: Colors.grey),
              //             borderRadius:
              //                 const BorderRadius.all(Radius.circular(5))),
              //         child: const Center(
              //           child: Icon(Icons.image),
              //         ),
              //       ),
              //       const SizedBox(
              //         width: 10,
              //       ),
              //       const Expanded(child: Text('Sohelrana.jpg')),
              //       ElevatedButton(
              //           onPressed: () {},
              //           child: const Padding(
              //             padding: EdgeInsets.all(8.0),
              //             child: Text('View'),
              //           ))
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
