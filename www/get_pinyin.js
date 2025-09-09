function get_pinyin() {
    //Send GET request to web API
    let hanzi = document.getElementById("hanzi").value;
    let url = `/auto_fill_pinyin.php?hanzi=${encodeURIComponent(hanzi)}`;
    
    fetch(url).then(res => {
        if(!res.ok) {
            throw new Error(`HTTP error! ${res.status}`);
        }
        return res.text();
    }).then(data => {
        if(data !== "") {
            let sentenceObject = JSON.parse(data);
            let sentence = "";
            for(let i = 0; i < sentenceObject.pinyin.length; i++) {
                sentence = sentence + " " + sentenceObject.pinyin[i][0];
            }
            document.getElementById("pinyin").value = sentence;
        }
    }).catch(error => {
        console.error(error);
    });

}