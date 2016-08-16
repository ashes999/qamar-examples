package classes;

import qamar.Sprite;
import qamar.io.Sound;

class Powerup extends Sprite
{
    // Powerup is a sine-wave with 50-pixel amplitude
    private static inline var WAVE_AMPLITUDE:Int = 50;
    // We can't use Date.now() for wave time, because it has per-second granularity
    // Instead, we accumulate the total time. The wave is quite long; this multiplier
    // shortens it, so we get more cycles as it moves across the screen.
    private static inline var PERIOD_SHORTENER:Int = 2;
    private var totalTime:Float = 0;
    
    // Basic y-coordinate, before we add wave motion
    private var baseY:Float = 0;    
    private var sound:Sound;
    
    public function new()
    {
        super('assets/images/powerup.png');
        
        this.sound = new Sound('assets/sounds/powerup.ogg');
        this.x = 0;
        this.velocity.x = 100;
        
        if (qamar.Random.randomBool())
        {
            this.x = Main.SCREEN_WIDTH;
            this.velocity.x = -100;
        }
                
        this.baseY = 100 + Math.random() * 200;                
    }
    
    override public function update(elapsed:Float):Void
    {
        if (this.exists) {
            super.update(elapsed);
            totalTime += elapsed;
            this.y = this.baseY + WAVE_AMPLITUDE * Math.cos(PERIOD_SHORTENER * totalTime);
            
            if (this.x < -this.width || this.x >= Main.SCREEN_WIDTH)
            {
                this.exists = false;
            }
        }
    }
    
    public function playSound() 
    {
        this.sound.play();
    }
}