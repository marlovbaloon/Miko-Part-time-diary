// src/main.js
import BootScene from './scenes/BootScene.js';
// หรือง่ายๆ สำหรับเริ่มโครงสร้าง Phaser 3:

const config = {
    type: Phaser.AUTO,
    width: 640,
    height: 360,
    parent: 'game-container', 
    pixelArt: true,
    physics: {
        default: 'arcade',
        arcade: { gravity: { y: 0 }, debug: false }
    },
    scene: [] 
};


document.getElementById('start-btn').addEventListener('click', () => {
    console.log("Start button clicked, launching game...");
});

document.getElementById('exit-btn').addEventListener('click', () => {
    alert("Exiting demo...");
});