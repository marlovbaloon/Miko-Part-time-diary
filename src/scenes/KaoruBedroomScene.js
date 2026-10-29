import PlayerKaoru from '../objects/PlayerKaoru.js';

export default class KaoruBedroomScene extends Phaser.Scene {
    constructor() {
        super('KaoruBedroomScene');
    }

    preload() {
        // โหลด Spritesheet ขนาด 32x32 ของคาโอรุ
        this.load.spritesheet('player_kaoru', 'assets/sprites/kaoru_sheet.png', {
            frameWidth: 32,
            frameHeight: 32
        });
    }

    create() {
        this.player = new PlayerKaoru(this, 64, 160);
        this.cameras.main.startFollow(this.player, true, 0.09, 0.09);
    }

    update(time, delta) {
        // เรียกอัปเดตระบบการเดินและอนิเมชันของคาโอรุในลูป
        if (this.player) {
            this.player.update();
        }
    }
}