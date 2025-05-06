const { spawn } = require("child_process");


// const pythonPath = process.env.PYTHON_PATH;
// const pythonScript = "Python/app.py"; // Adjust the path to your Python script
 
// const pythonProcess = spawn(pythonPath, [pythonScript]);
 
// // Read output from Python
// pythonProcess.stdout.on("data", (data) => {
//     const messages = data.toString().trim().split("\n");
//     console.log("Raw output from Python:", messages);
//     messages.forEach((message) => {
//         try {
//             const response = JSON.parse(message);
//             console.log(`Assistant: ${response.message}`);
//         } catch (error) {
//             console.log(`Python Output: ${message}`);
//         }
//     });
// });
 
// // Handle Python errors
// pythonProcess.stderr.on("data", (data) => {
//     console.error(`Python Error: ${data.toString()}`);
// });

// // Handle process exit
// process.on("exit", () => {
//     console.log("Node.js is exiting... Killing Python process.");
//     pythonProcess.kill();
// });
 
// process.on("SIGINT", () => { // Handle Ctrl+C
//     console.log("Received SIGINT. Exiting...");
//     pythonProcess.kill();
//     process.exit();
// });

exports.analyzeText = async (req, res) => {
    try {
        return res.status(200).json({ message: "Done" });
    } catch (error) {
        return res.status(500).json({ error: true, message: error.message || 'Something went wrong' });
    }
}

