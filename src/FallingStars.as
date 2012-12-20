package  
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class FallingStars extends Sprite
	{
		[Embed(source = "../lib/star.png")] private static const IMG_STAR:Class;
		
		private var mStars:Vector.<Bitmap> = new Vector.<Bitmap>;
		private var mFallSpeed:Vector.<Point> = new Vector.<Point>;
		private var mTimeAdd:Number = 0;
		
		public function FallingStars() 
		{
		}
		
		public function begin():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);	
		}
		
		private function onEnterFrame(e:Event):void 
		{
			var dt:Number = 1 / stage.frameRate;
			
			mTimeAdd -= dt;
			if (mTimeAdd < 0)
			{
				mTimeAdd = 0.25 + Math.random() * 0.15;
				addStar();
			}
			
			for (var i:int = 0; i < mStars.length; i++)
			{
				var vStar:Bitmap = mStars[i];
				var vVelocity:Point = mFallSpeed[i];
				
				vStar.x += vVelocity.x * dt;
				vStar.y += vVelocity.y * dt;
				vStar.rotation += 180 * dt;
				
				if (vStar.y > stage.stageHeight + 50)
				{
					this.removeChild(vStar);
					mStars.splice(i, 1);
					mFallSpeed.splice(i, 1);
					i--;
				}
			}
		}
		
		private function addStar():void 
		{
			var star:Bitmap = new IMG_STAR;
			star.x = stage.stageWidth * Math.random();
			star.y = -20;
			star.rotation = Math.random() * 360;
			this.addChild(star)
			
			var velX:Number = 0;
			var velY:Number = 80 + Math.random() * 20;
			
			mStars.push(star);
			mFallSpeed.push(new Point(velX,velY));
		}
		
	}

}