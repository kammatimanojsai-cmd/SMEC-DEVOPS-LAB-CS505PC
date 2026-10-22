// Experiment 11 - JavaScript program: increments a counter on every click.
let count = 0;
const counterElement = document.getElementById("counter");

function render() {
  counterElement.textContent = count;
}

document.getElementById("incrementButton").addEventListener("click", function () {
  count = count + 1;
  render();
});

document.getElementById("resetButton").addEventListener("click", function () {
  count = 0;
  render();
});
