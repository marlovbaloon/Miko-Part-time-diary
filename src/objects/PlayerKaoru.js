/**
 * PlayerKaoru.js
 * Character Object for Takahiro Kaoru
 * Author: Marlov
 */
export default class PlayerKaoru extends Phaser.Physics.Arcade.Sprite {
    /**
     * @param {Phaser.Scene} scene - The current Phaser Scene
     * @param {number} x - Initial X position
     * @param {number} y - Initial Y position
     */
    constructor(scene, x, y) {
        // 1. Initialize Sprite with key 'player_kaoru'
        super(scene, x, y, 'player_kaoru');

        // 2. Add to scene and enable physics
        scene.add.existing(this);
        scene.physics.add.existing(this);

        // 3. Set Base Attributes
        this.speed = 100; // Movement speed
        this.direction = 'down';
        this.isMoving = false;
        this.isLocked = false; // Flag to lock movement during dialogs/menus

        // 4. Custom Hitbox setup (at Kaoru's feet for top-down perspective)
        // Sprite size: 32x32 -> Feet hitbox: 16x12 offsetted to the bottom center
        this.body.setSize(16, 12);
        this.body.setOffset(8, 20);
        this.setCollideWorldBounds(true);

        // 5. Initialize Keyboard Controls (WASD + Arrow Keys)
        this.cursors = scene.input.keyboard.createCursorKeys();
        this.wasd = scene.input.keyboard.addKeys('W,A,S,D');

        // 6. Create Character Animations if not created yet
        this.initAnimations(scene);

        // Play default idle animation
        this.play('kaoru-idle-down');
    }

    /**
     * Create Frame Animations from Sprite Sheet (32x32)
     */
    initAnimations(scene) {
        if (scene.anims.exists('kaoru-walk-down')) return;

        const anims = scene.anims;
        const key = 'player_kaoru';

        // Walk Animations (Row 1: Down, Row 2: Right, Row 3: Up, Row 4: Left)
        anims.create({
            key: 'kaoru-walk-down',
            frames: anims.generateFrameNumbers(key, { start: 0, end: 3 }),
            frameRate: 8,
            repeat: -1
        });
        anims.create({
            key: 'kaoru-walk-right',
            frames: anims.generateFrameNumbers(key, { start: 4, end: 7 }),
            frameRate: 8,
            repeat: -1
        });
        anims.create({
            key: 'kaoru-walk-up',
            frames: anims.generateFrameNumbers(key, { start: 8, end: 11 }),
            frameRate: 8,
            repeat: -1
        });
        anims.create({
            key: 'kaoru-walk-left',
            frames: anims.generateFrameNumbers(key, { start: 12, end: 15 }),
            frameRate: 8,
            repeat: -1
        });

        // Idle Animations (Single Frame per direction)
        anims.create({
            key: 'kaoru-idle-down',
            frames: [{ key: key, frame: 0 }],
            frameRate: 1
        });
        anims.create({
            key: 'kaoru-idle-right',
            frames: [{ key: key, frame: 4 }],
            frameRate: 1
        });
        anims.create({
            key: 'kaoru-idle-up',
            frames: [{ key: key, frame: 8 }],
            frameRate: 1
        });
        anims.create({
            key: 'kaoru-idle-left',
            frames: [{ key: key, frame: 12 }],
            frameRate: 1
        });
    }

    /**
     * Called automatically in Scene's update loop
     */
    update() {
        if (this.isLocked) {
            this.body.setVelocity(0, 0);
            this.isMoving = false;
            this.play(`kaoru-idle-${this.direction}`, true);
            return;
        }

        this.handleMovement();
    }

    /**
     * Calculate 8-direction movement & normalize vector
     */
    handleMovement() {
        // Reset velocity
        this.body.setVelocity(0, 0);

        let moveX = 0;
        let moveY = 0;

        // Check Keyboard Inputs
        if (this.cursors.left.isDown || this.wasd.A.isDown) moveX = -1;
        else if (this.cursors.right.isDown || this.wasd.D.isDown) moveX = 1;

        if (this.cursors.up.isDown || this.wasd.W.isDown) moveY = -1;
        else if (this.cursors.down.isDown || this.wasd.S.isDown) moveY = 1;

        // Calculate Direction & Velocity
        if (moveX !== 0 || moveY !== 0) {
            this.isMoving = true;

            // Determine primary facing direction
            if (Math.abs(moveX) > Math.abs(moveY)) {
                this.direction = moveX < 0 ? 'left' : 'right';
            } else {
                this.direction = moveY < 0 ? 'up' : 'down';
            }

            // Phaser Arcade Physics Vector Normalization (Prevents fast diagonal movement)
            const moveVector = new Phaser.Math.Vector2(moveX, moveY).normalize();
            this.body.setVelocity(
                moveVector.x * this.speed,
                moveVector.y * this.speed
            );

            // Play corresponding walk animation
            this.play(`kaoru-walk-${this.direction}`, true);
        } else {
            this.isMoving = false;
            // Play idle animation for current facing direction
            this.play(`kaoru-idle-${this.direction}`, true);
        }
    }

    /**
     * Lock/Unlock player movement (for cutscenes or dialogs)
     * @param {boolean} locked 
     */
    setLock(locked) {
        this.isLocked = locked;
        if (locked) {
            this.body.setVelocity(0, 0);
            this.isMoving = false;
            this.play(`kaoru-idle-${this.direction}`, true);
        }
    }
}