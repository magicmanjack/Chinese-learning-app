function startPractice() {
    //Send POST request to the server indicating practice start.
    let url = '/practice1.php';

    fetch(url).then(res => {
        if(!res.ok) {
            throw new Error(`HTTP error! ${res.status}`);
        }
        return res.text();
    }).then(data => {
        
        document.getElementById("content-area").innerHTML = data;
    }).catch(error => {
        console.error(error);
    });


}