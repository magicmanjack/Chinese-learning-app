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
            next.onclick = nextPhase;

            document.getElementById("content-area").appendChild(p);
            document.getElementById("content-area").appendChild(next);
        }

    }

    function checkHanzi() {
        if(checkAnswers(hanzi)) {            
            //All were correct
            document.getElementById("check-answers-button").parentNode.remove();
            const p = document.createElement("p");
            p.textContent = "Nice work!";
            const next = document.createElement("button");
            next.type = "button";
            next.textContent = "Try new set";
            next.onclick = startPractice;

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

    function nextPhase() {
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

}

