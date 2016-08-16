package classes;

import flixel.FlxG;
import flixel.FlxSprite;

import classes.guns.Bullet;
import classes.guns.Gun;
import classes.guns.BulletGun;

import qamar.Sprite;
import qamar.io.MouseMove;
import qamar.io.Sound;

class Ship extends Sprite
{
    private static inline var SHIP_VELOCITY:Int = 5;
    private static inline var SHIP_ROTATION:Int = 1;
    private static inline var MAX_VELOCITY:Int = 100;
    // At 60FPS, v = 0.99v gives us ~50% decay in one second.
    private static inline var DECAY_VELOCITY:Float = 0.99;
    
    private var addBulletCallback:Bullet->Void;
    private var gun:Gun;
    private var mouseMove:MouseMove;
    private var sound:Sound;

    public function new(addBulletCallback:Bullet->Void)
    {
        super('assets/images/spaceship.png');
        this.addBulletCallback = addBulletCallback;
        this.mouseMove = new MouseMove(faceMouse);
        this.gun = new BulletGun(this);
        this.sound = new Sound('assets/sounds/died.ogg');
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        this.mouseMove.update();
        if (!this.alive)
        {
            return;
        }
        
        if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W || FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S)
        {
            var radians = Math.PI * this.angle / 180;            
            var vX = SHIP_VELOCITY * Math.cos(radians);
            var vY = SHIP_VELOCITY * Math.sin(radians);
            
            if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S)
            {
                vX *= -1;
                vY *= -1;
            }
            
            this.velocity.x += vX;
            this.velocity.y += vY;
            
            // Horrible, terrible, dirty hack
            if (this.velocity.x > MAX_VELOCITY) {
                this.velocity.x = MAX_VELOCITY;
            } else if (this.velocity.x < -MAX_VELOCITY) {
                this.velocity.x = -MAX_VELOCITY;
            }
            if (this.velocity.y > MAX_VELOCITY) {
                this.velocity.y = MAX_VELOCITY;
            } else if (this.velocity.y < -MAX_VELOCITY) {
                this.velocity.y = -MAX_VELOCITY;
            }
        }
        
        // TODO: break into move component
        if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
        {
            this.angle -= SHIP_ROTATION;
        }
        
        else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
        {
            this.angle += SHIP_ROTATION;
        }
        
        // TODO: shot component?
        if (FlxG.keys.pressed.SPACE || FlxG.mouse.pressed)
        {
            var bullets = this.gun.fire(this.angle);
            for (bullet in bullets)
            {
                bullet.x = this.x + (this.width - bullet.width) / 2;
                bullet.y = this.y + (this.height - bullet.height) / 2;        
                this.addBulletCallback(bullet);
            }
        }
        
        this.decayVelocity();
        this.wrapAroundOnScreen();
    }
    
    public function changeGun(gun:Gun):Void
    {
        this.gun = gun;
    }

    // TODO: push down, make sound an optional constructor argument
    public function playSound():Void
    {
        this.sound.play();
    }
    
    private function faceMouse(mouseX:Int, mouseY:Int):Void
    {
        var x = mouseX - this.x;
        var y= mouseY - this.y;
        var degrees:Float = 0;
        
        var radians = Math.atan2(x, y);
        // Spin clockwise, not counterclockwise (hence -180)
        // Pointing right is 90 degrees, not up (hence +90)
        degrees = 90 + (-180 * radians) / Math.PI;
        this.angle = degrees;
    }
    
    private function decayVelocity():Void
    {
        this.velocity.x *= DECAY_VELOCITY;
        this.velocity.y *= DECAY_VELOCITY;
        
        if (Math.abs(this.velocity.x) <= 0.01) {
            this.velocity.x = 0;
        }
        if (Math.abs(this.velocity.y) <= 0.01) {
            this.velocity.y = 0;
        }
    }

}