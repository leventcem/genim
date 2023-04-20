async function main() {
  var bot_input = document.getElementById("bot_input").value;
  var img_size = document.getElementById("img_size").value;

  if (bot_input == "" || img_size == "") {
    alert("Please fill all the fields!");
  } else {
    console.log(bot_input, img_size);
    url =
      "http://127.0.0.1:3000/image_generator?&botinput=" +
      bot_input +
      "&imgsize=" +
      img_size;
    console.log(url);
    fetch(url)
      .then((response) => {
        return response.json();
      })
      .then((output) => {
        console.log(output["url"]);
        document.getElementById("img_output_1").src = output["url_1"];
        document.getElementById("img_output_2").src = output["url_2"];
      })
      .catch((error) => console.log(error));
  }
}
function reset() {
  console.log("reset");
  document.getElementById("img_output").src = "";
  document.getElementById("bot_input").value = "";
  document.getElementById("img_size").value = "";
}
