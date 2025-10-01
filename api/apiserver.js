/**
 * Uses publicly available node.js module pinyin (MIT license)
 * https://pinyin.js.org/en-US
 */

const express = require('express')
const {pinyin} = require('pinyin')
const app = express()
const port = 3000

app.get('/pinyin/:p', (req, res) => {
    res.send(JSON.stringify({pinyin:pinyin(req.params.p)}));
})

app.listen(port, () => {
    console.log(`Listening on port ${port}`)
})