function getInfo()
{
    form = document.getElementById("UserInfo");
    form.addEventListener("submit", function(e){
    e.preventDefault();
  
    var text = "";
    for(var i = 0; i < form.elements.length-1; i++){
        text += "Output from input element " + (i+1) + ": " + form.elements[i].value;
        text += "<br>";
    }
  
  document.getElementById("output").innerHTML = text;
});
}