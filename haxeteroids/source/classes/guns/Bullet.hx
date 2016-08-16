package classes.guns;

import qamar.Sprite;

class Bullet extends Sprite
{
    private static inline var BULLET_VELOCITY:Int = 200;
    
    // Angle in degrees
    public function new(angle:Float)
    {
        super('assets/images/bullet.png');            
        var radians = Math.PI * angle / 180;            
        var vX = BULLET_VELOCITY * Math.cos(radians);
        var vY = BULLET_VELOCITY * Math.sin(radians);
        this.velocity.x = vX;
        this.velocity.y = vY;
    }
}