package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

import qamar.Random;
import qamar.Sprite;
import qamar.State;
import qamar.Time;

import classes.AlienShip;
import classes.Asteroid;
import classes.Powerup;
import classes.Ship;
import classes.guns.Bullet;
import classes.guns.SpreadShotGun;

class PlayState extends State
{
    private var ship:Ship;
    private var powerup:Powerup;
    
    // TODO: remove/splice is not working. We have to use .members.length
    // Wrap this in some other sensible class
    private var asteroids = new FlxTypedGroup<Asteroid>();
    
    private var bullets = new FlxGroup();
    private var enemyBullets = new FlxGroup();
    
    private var asteroidsToSpawn:Int = 3;

    // Pattern: text + variable
    private var points:Int = 0;
    private var pointsText:FlxText;

    private var lives:Int = 3;
    private var livesText:FlxText;

    private var alienShip:AlienShip;
    private var nextAlienShip:Float;
    
    private var lastPowerup:Date = Date.now();
    private var reviveOn:Float;
    
	override public function create():Void
	{
        this.createAsteroids();
        ship = new Ship(this.addBullet);
        ship.x = (Main.SCREEN_WIDTH - ship.width) / 2;
        ship.y = (Main.SCREEN_HEIGHT - ship.height) / 2;
        this.add(ship);

        this.pointsText = new FlxText(16, 16, 0, "", 24);
        add(this.pointsText);

        this.livesText = new FlxText(Main.SCREEN_WIDTH - 150, 16, 0, 'Lives: ${lives}', 24);
        add(this.livesText);

        this.nextAlienShip = Random.randomFutureTime(10, 15);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
        ship.update(elapsed);
		super.update(elapsed);

        if (lives > 0 && !ship.alive && Time.currentTime() > reviveOn)
        {
            ship.revive();
            ship.x = (Main.SCREEN_WIDTH - ship.width) / 2;
            ship.y = (Main.SCREEN_HEIGHT - ship.height) / 2;
        }
        
        if (powerup != null)
        {
            powerup.update(elapsed);
            FlxG.collide(powerup, ship, collectPowerup);
            if (!powerup.exists)
            { 
                powerup.destroy();
                powerup = null;
            }
        }
        else
        {
            var now = Date.now();
            // Spawns every 30 seconds, like clockwork
            if ((now.getTime() - lastPowerup.getTime()) >= 30 * 1000)
            {
                this.powerup = new Powerup();
                add(this.powerup);
                lastPowerup = now;
            }
        }
        
        for (a in this.asteroids)
        {
            a.update(elapsed);
        }
        
        FlxG.collide(asteroids, bullets, shotAsteroid);
        FlxG.collide(ship, enemyBullets, died);
        FlxG.collide(ship, alienShip, died);
        FlxG.collide(ship, asteroids, hitAsteroid);
        FlxG.collide(asteroids, asteroids, asteroidCollision);

        this.pointsText.text = '${this.points} points';

        if (this.alienShip == null && Time.currentTime() >= nextAlienShip)
        {
            this.alienShip = new AlienShip(this);
            add(this.alienShip);
        }
        else if (this.alienShip != null)
        {
            if (this.alienShip.x < -this.alienShip.width || this.alienShip.x > Main.SCREEN_WIDTH)
            {
                this.alienShip.kill();
                this.alienShip = null;
                nextAlienShip = Random.randomFutureTime(10, 15);
            }
            FlxG.collide(this.alienShip, bullets, shotAlienShip);
        }
	}

    private function shotAlienShip(alienShip:AlienShip, bullet:Bullet):Void
    {
        alienShip.playSound();
        alienShip.kill();
        this.alienShip = null;
        this.points += 50;

        bullet.kill();
        bullets.remove(bullet);
        remove(bullet);
        remove(alienShip);
        nextAlienShip = Random.randomFutureTime(10, 15);        
    }
    
    private function collectPowerup(powerup:Powerup, ship:Ship):Void
    {
        powerup.playSound();
        powerup.destroy();
        powerup = null;
        
        ship.changeGun(new SpreadShotGun(ship));
    }
    
    private function createAsteroids():Void
    {
        this.asteroids.clear();
        
        while (this.asteroids.length < asteroidsToSpawn)
        {
            var a = new Asteroid();
            
            // Position off-screen
            if (Random.randomBool() == true)
            {
                // Position on top/bottom of screen
                a.x = Math.random() * Main.SCREEN_WIDTH;
                a.y = Random.randomBool() == true ? 0 : Main.SCREEN_HEIGHT;
            }
            else
            {
                // Position on left/right of screen
                a.x = Random.randomBool() == true ? 0 : Main.SCREEN_WIDTH;
                a.y = Math.random() * Main.SCREEN_HEIGHT;
            }
            
            this.asteroids.add(a);
            this.add(a);
        }
    }
    
    private function addBullet(bullet:Bullet)
    {
        this.add(bullet);
        this.bullets.add(bullet);
    }

    public function addEnemyBullet(bullet:Bullet)
    {
        this.add(bullet);
        this.enemyBullets.add(bullet);
    }

    private function hitAsteroid(ship:Ship, asteroid:Asteroid):Void
    {
        damageAsteroid(asteroid);
        ship.kill();
        this.decrementLife();
    }

    private function shotAsteroid(asteroid:Asteroid, bullet:Bullet):Void
    {
        damageAsteroid(asteroid);

        if (bullet != null)
        {
            this.bullets.remove(bullet);
            bullet.destroy();
        }
    }

    private function asteroidCollision(a1:Asteroid, a2:Asteroid)
    {
        a1.velocity.x *= -1;
        a1.velocity.y *= -1;

        a2.velocity.x *= -1;
        a2.velocity.y *= -1;

        this.shotAsteroid(a1, null);
        this.shotAsteroid(a2, null);
    }

    private function died(ship:Ship, target:Sprite):Void
    {
        ship.kill();        
        target.destroy();
        this.decrementLife();
    }

    private function decrementLife():Void
    {
        this.lives -= 1;
        this.livesText.text = 'Lives: ${lives}';
        ship.playSound();
        if (lives > 0)
        {
            this.reviveOn = Time.currentTime() + 3;
        }
        else
        {
            var text = new FlxText(300, 150, 0, "", 48);
            text.text = "Game Over!";
            add(text);
        }
    }

    private function damageAsteroid(asteroid:Asteroid):Void
    {
        var splits = asteroid.damage();

        if (asteroid.health <= 0)
        {
            remove(asteroid); 
            this.asteroids.remove(asteroid, true);
            this.points += 10;

            if (splits.length > 0)
            {
                for (asteroid in splits)
                {
                    add(asteroid);
                    this.asteroids.add(asteroid);
                }
            }
            
            if (this.asteroids.members.length == 0)
            {
                this.asteroidsToSpawn += 2;
                this.createAsteroids();
            }
        }
    }
}
