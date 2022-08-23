const express = require('express');
const cors = require('cors');
const app = express();
const http = require('http');
const server = http.createServer(app);
const io = require("socket.io")(server);

require('dotenv').config();
//const port = process.env.PORT || 3000;
const port = 3000;
app.use(express.json());
app.use(cors()); 

app.get('/', (req, res) => {
    res.send( 'Hello Sohel');
  });

//************WebSocket Signaling for Sharing Connection Information***************

io.on("connection",  (socket)=> {
     console.log(`New client ${socket.id} connected`);
      //console.log(io.sockets.adapter.rooms);
      //console.log(io);
    //  console.log(socket.id);

    socket.on("firstUserInfo", (data) => {
        socket.broadcast.emit('secondUserInfo', data);
        console.log(`Second User Info ${data}` );
    });


    socket.on("disconnect", (reason) => {
        socket.broadcast.emit("userDisconnected", 'Hi, He is disconnected');
        //console.log(`${data['id']} is Disconnected.`);
        console.log(reason);
    });

    // Offer from FirstUser
    socket.on("createOffer", (data) => {
        console.log(data);
        console.log("createOffer event is called.");
        //console.log(session);
        //socket.broadcast.emit("receiveOffer", { session: data.session });
        socket.broadcast.emit("receiveOffer", data);
        
    })

    // Answer from Second User to First User
    socket.on("createAnswer", (data) => {
        console.log("createAnswer event is called.");
        
        //socket.broadcast.emit("receiveAnswer", { session: data.session});
        socket.broadcast.emit("receiveAnswer", data);
    })

    //Candidate from both

    socket.on("sendCandidateToLocal", (data) => {
        console.log("sendCandidateToLocal event is called.");
        
        
        //console.log(data);
        //socket.broadcast.emit("receiveRemoteCandidate", { candidate: data.candidate});
        socket.broadcast.emit("receiveRemoteCandidate", data);
    });

    socket.on("sendCandidateToRemote", (data) => {
        console.log("sendCandidateToLocal event is called.");
        //console.log(data);
        //socket.broadcast.emit("receiveLocalCandidate", { candidate: data.candidate});
        socket.broadcast.emit("receiveLocalCandidate", data);
    })

    
    

    

    socket.on("newConnect", (roomId, callback) => {
        //convert Socket.io map to Array and separate users and room names. https://logfetch.com/js-socketio-active-rooms/
        
            const arr = Array.from(io.sockets.adapter.rooms);
            // Filter rooms whose name exist in set:
            // ==> [['room1', Set(2)], ['room2', Set(2)]]
            const filtered = arr.filter(room => !room[1].has(room[0]));
            const filteredRoom = filtered.filter(room => room[0]==roomId);
            const roomUsers = filteredRoom[0][1];
            const value = roomUsers.values(); // Values Set
            const a = Array.from(value);//Convert Set to Array
            //const res = roomUsers.map(i => i[0]);
            //const [first] = roomUsers;
            console.log(a);
        callback({ originId: socket.id, destinationIds: a });
    })

    

    

    
    socket.on("disconnect", () => {
        console.log("Disconnect event is called.");
        socket.broadcast.emit("userDisconnected", socket.id);
        //console.log("Client disconnected", socket.id);
    })
})



server.listen(port, () => console.log(`Server Listening on port ${port}`));