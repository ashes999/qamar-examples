package classes;

import flixel.math.FlxPoint;
import qamar.Sprite;
import qamar.io.Sound;

class Asteroid extends Sprite {
    
    private static inline var MIN_VELOCITY:Int = 10;
    private static inline var MAX_VELOCITY:Int = 100;
    private static inline var DONT_SPLIT_AT_SCALE:Float = 0.2;
    // Health at 100% scale. Scales down with asteroid size.
    private static inline var FULL_HEALTH:Int = 5;
    
    private var rotationDirection:Int = 0;
    private var damageSound:Sound;
    private var splitSound:Sound;

    public function new(scale:Float = 1.0)
    {
        super('assets/images/asteroid');

        // TODO: push down. Updating scale should always update hitbox.        
        this.scale.set(scale, scale);
        this.updateHitbox();
        
        this.health = Math.round(FULL_HEALTH * scale);
        
        this.damageSound = new Sound('assets/sounds/asteroid-hit.ogg');
        this.splitSound = new Sound('assets/sounds/asteroid-split.ogg');
        
        this.rotationDirection = qamar.Random.randomBool() ? 1 : -1;
        
        this.velocity.x = Math.random() * (MAX_VELOCITY - MIN_VELOCITY) + MIN_VELOCITY;
        this.velocity.y = Math.random() * (MAX_VELOCITY - MIN_VELOCITY) + MIN_VELOCITY;
        
        if (qamar.Random.randomBool())
        {
            this.velocity.x *= -1;
        }
        
        if (qamar.Random.randomBool())
        {
            this.velocity.y *= -1;
        }
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        this.angle += rotationDirection;
        this.wrapAroundOnScreen();
    }
    
    // Return multiple asteroids if dead/split.
    public function damage():Array<Asteroid>
    {
        var toReturn = new Array<Asteroid>();
        
        // automatically kills when health is 0
        this.hurt(1);
        
        if (this.health <= 0)
        {
            this.splitSound.play();
            
            var targetScale = new FlxPoint(this.scale.x / 2, this.scale.y / 2);
            if (targetScale.x > DONT_SPLIT_AT_SCALE)
            {
                toReturn.push(new Asteroid(targetScale.x));
                toReturn.push(new Asteroid(targetScale.x));
                
                for (a in toReturn)
                {
                    // Spawn almost over the existing asteroid
                    a.x = this.x + Math.random() * 64 - 32;
                    a.y = this.y + Math.random() * 64 - 32;
                }
            }   
        }
        else
        {
            this.damageSound.play();
        }
        
        return toReturn;
    }
}