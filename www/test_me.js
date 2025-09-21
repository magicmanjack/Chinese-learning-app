let hanzi = [];
let pinyin = [];
let english = [];
let inputs = [];

function startPractice() {
    //Send GET request to the server indicating practice start.
    let url = '/get_practice_hanzi.php';

    fetch(url).then(res => {
        if(!res.ok) {
            throw new Error(`HTTP error! ${res.status}`);
        }
        return res.text();
    }).then(data => {
        //Hide start button
        document.getElementById("start-button").remove();
        
        console.log(data)
        const d = JSON.parse(data);
        hanzi = d.hanzi;
        english = d.english;
        pinyin = d.pinyin;
        //Got words to test, now populate with html

        //Populate input boxes.
        for(let i = 0; i < hanzi.length; i++) {
            const input = document.createElement('input');
            const div = document.createElement('div');
            const hanziText = document.createElement('p');
            hanziText.textContent = hanzi[i];
            input.type = "text";
            input.class = "test-me-text-box";
            input.id = `in${i}`;
            inputs.push(input);
            div.appendChild(hanziText);
            div.appendChild(input);
            document.getElementById("content-area").appendChild(div);

        }
        

        //Check answers button
        const div = document.createElement('div');
        const submit = document.createElement('button');
        submit.type = "button";
        submit.textContent = "Check answers";
        submit.onclick = checkAnswers;
        div.appendChild(submit);
        document.getElementById("content-area").appendChild(div);


    }).catch(error => {
        console.error(error);
    });

    function checkAnswers() {
        //iterate through input list, checking hanzi against corrosponding english
        for(let i = 0; i < inputs.length; i++) {
            if(english[i] == inputs[i].value) {
                //console.log(`${i} is correct`);
                inputs[i].parentNode.classList.add("right-answer");
            } else {
                //console.log(`${i} is incorrect`);
                inputs[i].parentNode.classList.add("wrong-answer");
            }
        }
    }

}