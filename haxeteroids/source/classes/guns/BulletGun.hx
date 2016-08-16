package classes.guns;

import flixel.FlxSprite;

import classes.guns.Bullet;
import classes.guns.Gun;
import classes.Ship;

import qamar.io.Sound;
import qamar.State;
import qamar.Time;

// Gun shoots a single bullet in a straight line. Unlimited ammo.
class BulletGun extends Gun
{
    private static inline var BULLET_VELOCITY:Int = 450;
    private static inline var SECONDS_BETWEEN_SHOTS:Float = 0.25;
    private var shotSound:Sound;
    
    private var lastShotTime:Float = Time.currentTime();

    public function new(ship:Ship)
    {
        super(ship);
        shotSound = new Sound('assets/sounds/bullet-gun.ogg');
    }
    
    // Angle in degrees
    override public function fire(angle:Float):Array<Bullet>
    {
        var toReturn = new Array<Bullet>();
        
        if (Time.currentTime() - lastShotTime >= SECONDS_BETWEEN_SHOTS)
        {
            lastShotTime = Time.currentTime();
            var bullet:Bullet = new Bullet(angle);
            toReturn.push(bullet);
            shotSound.play();
        }
        
        return toReturn;
    }
}