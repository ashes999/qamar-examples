package classes.guns;

import flixel.FlxSprite;

import classes.guns.BulletGun;
import classes.Ship;

import qamar.io.Sound;
import qamar.State;
import qamar.Time;

// Gun shoots a single bullet in a straight line. Unlimited ammo.
class SpreadShotGun extends BulletGun
{
    private static inline var BULLET_VELOCITY:Int = 250;
    private static inline var SPREAD_ANGLE_OFFSET = 15;
    private static inline var SECONDS_BETWEEN_SHOTS:Float = 0.5;

    private var bulletsLeft:Int = 10;

    public function new(ship:Ship)
    {
        super(ship);
        shotSound = new Sound('assets/sounds/spread-shot-gun.ogg');
    }
    
    override public function fire(angle:Float):Array<Bullet>
    {
        var toReturn = new Array<Bullet>();
        
        if (Time.currentTime() - lastShotTime >= SECONDS_BETWEEN_SHOTS)
        {
            lastShotTime = Time.currentTime();
            var offset = angle < 0 ? -SPREAD_ANGLE_OFFSET : SPREAD_ANGLE_OFFSET;
            
            toReturn.push(new Bullet(angle));
            toReturn.push(new Bullet(angle + offset));
            toReturn.push(new Bullet(angle - offset));
            
            shotSound.play();
            
            bulletsLeft -= 1;
            if (bulletsLeft == 0)
            {
                ship.changeGun(new BulletGun(ship));
            }
        }
        return toReturn;
    }
}