window.addEventListener('message', function (event) {
    if (event.data.action === "showXP") {
        document.getElementById("xp-container").style.display = event.data.visible ? "block" : "none";
        document.getElementById("level-text").innerText = "Level " + event.data.level;
        document.getElementById("xp-text").innerText = `${event.data.currentXP} / ${event.data.maxXP} XP`;
        document.getElementById("xp-fill").style.width = ((event.data.currentXP / event.data.maxXP) * 100) + "%";
        document.getElementById("xp-fill").style.backgroundColor = event.data.color;
    }

    if (event.data.action === "toggleXP") {
        document.getElementById("xp-container").style.display = event.data.visible ? "block" : "none";
    }
});