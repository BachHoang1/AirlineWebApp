const http = require("http");
const host = 'localhost';
const port = 8000;
const fs = require('fs');
const requestListener = function (req, res) {
    fs.readFile('airlineWebApp.html', function(err, data) {
        res.writeHead(200, {'Content-Type': 'text/html'});
        res.write(data);
        return res.end();
    });
};
const server = http.createServer(requestListener);
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});

async function connectToDatabase()
{
    var path = "C:/Users/beast/OneDrive/Documents/Javascript/password.txt"
    const fs = require('fs');
    const Client = require('pg');
    
    var data = fs.readFileSync(path, "utf8").split(",");

    const client = new Client({
        user: data[0],
        password: data[1],
        host: "code.cs.uh.edu",
        database: "COSC3380"
    })

    try 
    {
        await client.connect()
        const result = await client.query("select * from bookings.aircraft;")
        client.end()
        console.log(console.table(result.rows));
    } 
    catch (error) 
    {
        console.log(error);
    }
}
