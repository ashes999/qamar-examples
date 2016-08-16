package classes;

import qamar.io.Sound;
import qamar.Random;
import qamar.Sprite;
import qamar.State;
import qamar.Time;

import classes.guns.Bullet;

class AlienShip extends Sprite
{
    private static inline var SHIP_VELOCITY:Int = 100;
    private var lastShotTime:Float = 0;
    private var state:PlayState;
    private var sound:Sound;

    public function new(state:PlayState)
    {
        super("assets/images/alien-ship.png");
        this.y = Math.random() * Main.SCREEN_HEIGHT;
        this.state = state;

        if (Random.randomBool() == true)
        {
            this.x = 0;
            this.velocity.x = SHIP_VELOCITY;
        }
        else
        {
            this.x = Main.SCREEN_WIDTH;
            this.velocity.x = -SHIP_VELOCITY;
        }        
        sound = new Sound('assets/sounds/alien-ship-explosion.ogg');
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (Time.currentTime() >= lastShotTime + 0.5)
        {
            lastShotTime = Time.currentTime();
            var angle = Random.between(0, 360);
            var bullet = new Bullet(angle);
            bullet.x = this.x + (this.width / 2);
            bullet.y = this.y + (this.height / 2);

            state.addEnemyBullet(bullet);
        }
    }

    public function playSound()
    {
        this.sound.play();
    }
}