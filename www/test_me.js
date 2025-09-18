let hanzi = [];

function startPractice() {
    //Send GET request to the server indicating practice start.
    let url = '/get_practice_hanzi.php';

    fetch(url).then(res => {
        if(!res.ok) {
            throw new Error(`HTTP error! ${res.status}`);
        }
        return res.text();
    }).then(data => {
        //console.log(data);
        hanzi = JSON.parse(data).hanzi;
        //Got words to test, now populate with html
        let html = "";
        for(let i = 0; i < hanzi.length; i++) {
            html = html + "<div><p>" + hanzi[i] + `</p><input type='text', class='test-me-text-box', id=in${i}></div>`
        }

        document.getElementById("content-area").innerHTML = html;
        
        const div = document.createElement('div');
        const submit = document.createElement('button');
        submit.type = "button";
        submit.textContent = "Check answers";
        div.appendChild(submit);
        document.getElementById("content-area").appendChild(div);


    }).catch(error => {
        console.error(error);
    });


}