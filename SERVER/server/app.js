const express = require('express');
const fs = require('fs');

const app = express();

// Password bảo mật
const password = "9797964a-2f5c-41c6-91c1-44aa68308631"


module.exports = {
    app: app,
}

app.use(express.static('server'));

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Nhận giá trị truyền
app.post(`/espPost`, (req, res) => {
    const value = req.body.value // Giá trị truyền
    const type = req.body.type // Type
    const isSP = req.body.isSP // Giá trị truyền là `Setpoint` hay `Value`
    const pass = req.body.password // Mật khẩu xác minh

    if (pass == password) {
        fs.readFile('server/data.json', 'utf8', (err, data) => {
            // Chuyển đổi JSON thành Object
            const json = JSON.parse(data);
            
            // Lấy key của node
            const key = `${type}${isSP ? "SP" : ""}`
            
            // In ra giá trị
            console.log(`${type}${isSP ? "SP" : ""}: ${value}`);

            // Tạo trường mới nếu không tồn tại (node mới)
            if (json[key] == undefined) {
                json[`${type}`] = [];
                json[`${type}SP`] = [{value: 40, date: Date.now() / 1000}];
            }

            // Thêm giá trị vào array để lưu trữ
            json[key] = isSP ? [{value: value, date: Date.now() / 1000}] : [...json[key], {value: value, date: Date.now() / 1000}]

            // console.log(json[key]);
            
            // Lưu vào file
            fs.writeFile('server/data.json', JSON.stringify(json), (err, data) => {
                res.header('Access-Control-Allow-Origin', '*');
                res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
                res.send(`${type} is set to ` + value)
            });
        });
    } else {
        // Sai mật khẩu

        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
        res.send(`Key not authorized!`)
    }
});

// Trả giá trị
app.post('/espGet', (req, res) => {
    const pass = req.body.password // Mật khẩu xác minh

    if (pass == password) {
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');

        if (req.body.type != undefined && req.body.isSP!= undefined) {
            // Lấy giá trị node chỉ định

            const type = req.body.type // Node id
            const isSP = req.body.isSP // Giá trị trả là `Setpoint` hay `Value`

            // Lấy Object từ file
            const json = JSON.parse(fs.readFileSync('server/data.json', 'utf8'));

            if (json[`${type}${isSP ? "SP" : ""}`] != undefined) { 
                // Trả giá trị tồn tại

                const values = json[`${type}${isSP ? "SP" : ""}`].sort((a, b) => a.date < b.date)
                res.send(values[values.length - 1] == undefined ? "Unavailable" : `${values[values.length - 1].value}`)
                return
            } else {
                // Giá trị không tồn tại

                res.send("Unavailable")
                return
            }
        }

        // Lấy giá trị tất cả các node
        res.send(fs.readFileSync('server/data.json', 'utf8'))
    } else {
        // Sai mật khẩu

        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
        res.send(`Key not authorized!`)
    }
})

app.post('/espConfig', (req, res) => {
    const pass = req.body.password // Mật khẩu xác minh
    
    if (pass == password) { 
        // Đúng mật khẩu

        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With,Content-type,Accept');
        res.send(password)
    }
})