const {Server} = require('socket.io');
const { CLIENT_URL } = require('../config/urlsConfig');

let connectedUsers = new Map()
let io;

module.exports = {
    initializeSocket: (server) => {
        io = new Server(server, {
            cors: {
                origin: CLIENT_URL,
                credentials: true,
            }
        });
        io.on('connection', (socket) => {
            socket.on('INITIALIZE_SOCKET', (userId) => {
                connectedUsers.set(+userId, socket.id);
            })
            socket.on('disconnect', (reason) => {
                if (reason === 'client namespace disconnect') {    // if user manually disconnect when clicked on logout
                    const disconnectedUser = Array.from(connectedUsers.keys()).find((key) => connectedUsers.get(key) === socket.id);
                    if (disconnectedUser) {
                        connectedUsers.delete(disconnectedUser);
                        // console.log('Connected users:', connectedUsers);
                    }
                }
            });
        });
    },

    getIo: () => io,
    getConnectedUsers: () => connectedUsers
}