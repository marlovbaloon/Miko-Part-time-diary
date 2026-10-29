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