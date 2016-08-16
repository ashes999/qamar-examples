package classes.guns;

import flixel.FlxSprite;
import classes.Ship;

class Gun
{
    private var ship:Ship;
    
    public function new(ship:Ship)
    {
        this.ship = ship;
    }
    public function fire(angle:Float):Array<Bullet>
    {
        // Virtual method, override me
        return new Array<Bullet>();        
    }
}