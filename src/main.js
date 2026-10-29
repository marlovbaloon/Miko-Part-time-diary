// src/main.js
import KaoruBedroomScene from './scenes/KaoruBedroomScene.js';

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
    scene: [KaoruBedroomScene] 
};

let gameInstance = null;

document.getElementById('start-btn').addEventListener('click', () => {
    console.log("Start button clicked, launching game...");
    
    // 1. ซ่อนองค์ประกอบของหน้าเมนูทั้งหมด
    const menuElements = document.querySelectorAll(
        '.morning-sun, .mist-band, .torii-container, #petals-container, .ui-overlay, .game-footer'
    );
    menuElements.forEach(el => {
        if (el) el.style.display = 'none';
    });

    // 2. ปรับพื้นหลังของ container ให้เป็นสีดำสนิทสำหรับตัวเกม
    const container = document.getElementById('game-container');
    container.style.background = '#000000';

    // 3. เริ่มรัน Phaser Game Instance (ถ้ายังไม่เคยถูกสร้าง)
    if (!gameInstance) {
        gameInstance = new Phaser.Game(config);
    }
});

document.getElementById('exit-btn').addEventListener('click', () => {
    alert("Exiting demo...");
});