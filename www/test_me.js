//Only have to deal with letters a e i o u ü
const tonedVowels = 
    ['ā', 'á', 'ǎ', 'à',
     'ē', 'é', 'ě', 'è',
     'ī', 'í', 'ǐ', 'ì',
     'ō', 'ó', 'ǒ', 'ò',
     'ū', 'ú', 'ǔ', 'ù',
     'ǖ', 'ǘ', 'ǚ', 'ǜ'];
const nonTonedVowels = ['a', 'e', 'i', 'o', 'u', 'ü'];

function removeTone(p) {
    //Removes tone from pinyin
    if(!tonedVowels.includes(p)) {
        return p;
    }
    
    return nonTonedVowels[Math.floor(tonedVowels.indexOf(p) / 4)];
}

function addTone(vowel, toneNumber) {
    if(!nonTonedVowels.includes(vowel)) {
        return vowel;
    }

    return tonedVowels[nonTonedVowels.indexOf(vowel) * 4 + toneNumber - 1];
}

let debug;

function startPractice() {
    //Send GET request to the server indicating practice start.
    let url = '/get_practice_hanzi.php';
    const content = document.getElementById("content-area");

    let inputs = [];
    
    let hanzi;
    let english;
    let pinyin;

    fetch(url).then(res => {
        if(!res.ok) {
            throw new Error(`HTTP error! ${res.status}`);
        }
        return res.text();
    }).then(data => {
        //Clear everything in content area
        document.getElementById("content-area").innerHTML = "";
        
        console.log(data)
        const d = JSON.parse(data);
        hanzi = d.hanzi;
        english = d.english;
        pinyin = d.pinyin;
        //Got words to test, now populate with html

        const instructions = document.createElement("p");

        instructions.textContent = "Translate from 汉字 to english.";

        content.appendChild(instructions);
        
        //Populate input boxes.
        populateQuestions(hanzi);
        

        //Check answers button
        const div = document.createElement('div');
        const submit = document.createElement('button');
        submit.type = "button";
        submit.textContent = "Check answers";
        submit.id = "check-answers-button";
        submit.onclick = checkEnglish;
        div.appendChild(submit);
        content.appendChild(div);


    }).catch(error => {
        console.error(error);
    });

    function checkEnglish() {
        if(checkAnswers(english)) {            
            //All were correct
            document.getElementById("check-answers-button").parentNode.remove();
            const p = document.createElement("p");
            p.textContent = "Nice work! Now lets try in reverse.";
            const next = document.createElement("button");
            next.type = "button";
            next.textContent = "Lets go";
            next.onclick = phase2;

            document.getElementById("content-area").appendChild(p);
            document.getElementById("content-area").appendChild(next);
        }

    }

    function checkHanzi() {
        if(checkAnswers(hanzi)) {            
            //All were correct
            document.getElementById("check-answers-button").parentNode.remove();
            const p = document.createElement("p");
            p.textContent = "Nice work! Now lets try the pīnyīn";
            const next = document.createElement("button");
            next.type = "button";
            next.textContent = "Lets go";
            next.onclick = phase3;

            document.getElementById("content-area").appendChild(p);
            document.getElementById("content-area").appendChild(next);
        }
    }

    function checkAnswers(correctAnswers) {
        //iterate through input list, checking input against correct answers
        let allRight = true;

        for(let i = 0; i < inputs.length; i++) {
            if(correctAnswers[i] == inputs[i].value) {
                //console.log(`${i} is correct`);
                inputs[i].parentNode.classList.add("right-answer");
            } else {
                //console.log(`${i} is incorrect`);
                allRight = false;
                inputs[i].parentNode.classList.add("wrong-answer");
            }
        }

        return allRight;
    }

    function populateQuestions(questions) {
        //Creates elements and adds to page for each question in the questions array.
        inputs = [];
        for(let i = 0; i < questions.length; i++) {
            const input = document.createElement('input');
            const div = document.createElement('div');
            const question = document.createElement('p');
            question.textContent = questions[i];
            input.type = "text";
            input.class = "test-me-text-box";
            input.id = `in${i}`;
            inputs.push(input);
            div.appendChild(question);
            div.appendChild(input);
            content.appendChild(div);

        }
    }

    function phase2() {
        //User has to translate from english to 汉字

        //Extract user inputs from last phase
        const userEntries = [];

        for(let i = 0; i < inputs.length; i++) {
            userEntries.push(inputs[i].value);    
        }

        //Clear everything
        content.innerHTML = "";

        const instructions = document.createElement("p");
        instructions.textContent = "Translate from English to 汉字";
        content.appendChild(instructions);
        
        populateQuestions(userEntries);

        //Check answers button
        const div = document.createElement('div');
        const submit = document.createElement('button');
        submit.type = "button";
        submit.textContent = "Check answers";
        submit.id = "check-answers-button";
        submit.onclick = checkHanzi;
        div.appendChild(submit);
        content.appendChild(div);


    }


    
    function phase3() {
        //Test the users pinyin

        //Clear everything
        content.innerHTML = "";

        const instructions = document.createElement("p");
        instructions.textContent = "Select the correct tone for the pīnyīn"
        content.appendChild(instructions);

        //Add row of buttons
        const buttonDiv = document.createElement("div");
        buttonDiv.classList.add("button-div");

        toneButtons = [];

        for(let i = 1; i < 5; i++) {
            const tone = document.createElement("button");
            tone.type="button";
            tone.classList.add("img-button");
            tone.id = `tone${i}`;
            tone.onclick = () => {
                //Go through and find highlighted character
                for(let j = 0; document.getElementById(`char${j}`); j++) {
                    const c = document.getElementById(`char${j}`);
                    if(c.classList.contains("highlight")) {
                        //Found current highlighted character span. Need to unhighlight
                        c.classList.remove("highlight");
                        //Convert to tone
                        c.textContent = addTone(c.textContent, i);
                        if(document.getElementById(`char${j + 1}`)) {
                            // If wasn't last character then highlight next
                            document.getElementById(`char${j + 1}`).classList.add("highlight");
                        }

                        break;
                    }
                }
            }
            const img = document.createElement("img");
            img.src = `res/button${i}.png`;
            tone.appendChild(img);
            toneButtons.push(tone);
            buttonDiv.appendChild(tone);
        }

        content.appendChild(buttonDiv);


        //Now to add pinyin
        const div = document.createElement("div");
        div.classList.add("pinyin-div");
        const toTest = document.createElement("p");

        // Iterate through and assign ids to each tonal letter
        let p = pinyin[0];

        let id = 0;
        for(let i = 0; i < p.length; i++) {
            
            if(tonedVowels.includes(p[i])) {
                //Contains tone 
                //console.log(`character ${p[i]} is value toned. -> ${removeTone(p[i])}`);
                p = p.replace(p[i], `<span id=char${id}>` + removeTone(p[i]) + "</span>");
                id++;
            }
            
        }

        toTest.innerHTML = p;

        toTest.id = "test-pinyin";

        div.appendChild(toTest);
        content.appendChild(div);

        //Highlight first character to be toned
        document.getElementById(`char${0}`).classList.add("highlight");

    }
    debug = phase3;

}

