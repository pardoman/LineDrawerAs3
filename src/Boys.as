package  
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author ...
	 */
	public class Boys extends Sprite
	{
		//[Embed(source = "../lib/boys.png")] private static const IMG_BOYS_WHITE:Class;
		//[Embed(source = "../lib/boysColors.png")] private static const IMG_BOYS_COLORS:Class;
		[Embed(source = "../lib/boy1.png")] private static const IMG_BOY_1:Class;
		[Embed(source = "../lib/boy2.png")] private static const IMG_BOY_2:Class;
		[Embed(source = "../lib/boy3.png")] private static const IMG_BOY_3:Class;
		[Embed(source = "../lib/boy4.png")] private static const IMG_BOY_4:Class;
		[Embed(source = "../lib/boy5.png")] private static const IMG_BOY_5:Class;
		[Embed(source = "../lib/boy6.png")] private static const IMG_BOY_6:Class;
		[Embed(source = "../lib/boy7.png")] private static const IMG_BOY_7:Class;
		
		//public static const BOY_ALL_WHITE:uint = 101;
		//public static const BOY_ALL_COLOR:uint = 102;
		public static const BOY_1:uint = 1;
		public static const BOY_2:uint = 2;
		public static const BOY_3:uint = 3;
		public static const BOY_4:uint = 4;
		public static const BOY_5:uint = 5;
		public static const BOY_6:uint = 6;
		public static const BOY_7:uint = 7;
		
		private var mSpr:Sprite;
		private var mAngle:Number = 0;
		private var mBoyId:uint;
		private var mBoyImageId:uint;
		private var mAmplitude:Number;
		private var mBitmap:Bitmap;
		private var mColorTransform:ColorTransform;
		
		public function Boys(colorId:int) 
		{
			mBoyId = colorId;
			mBoyImageId = colorId;
			
			mSpr = new Sprite();
			addChild(mSpr);
			
			var tintColor:uint = getColorFromId(colorId);
			var rr:int = (tintColor >> 16) & 0xFF;
			var gg:int = (tintColor >> 8) & 0xFF;
			var bb:int = (tintColor >> 0) & 0xFF;
			var rr01:Number = rr / 255.0;
			var gg01:Number = gg / 255.0;
			var bb01:Number = bb / 255.0;
			mColorTransform = new ColorTransform(1,1,1,1,-255+rr,-255+gg,-255+bb);
			
			resetBoyBitmap();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			mAmplitude = 50;
		}
		
		private function resetBoyBitmap():void 
		{			
			if (mBitmap != null) {
				mSpr.removeChild(mBitmap);				
			}
			
			mBitmap = getBoyBitmap();
			mBitmap.y = -mBitmap.height;
			mBitmap.x = -mBitmap.width / 2;
			mBitmap.transform.colorTransform = mColorTransform;
			mSpr.addChild(mBitmap);
			
			mBoyImageId++;
			if (mBoyImageId >= 7) {
				mBoyImageId = 0;
			}
		}
		
		private function getBoyBitmap():Bitmap
		{
			var bitmaps:Array = [IMG_BOY_1, IMG_BOY_2, IMG_BOY_3, IMG_BOY_4, IMG_BOY_5, IMG_BOY_6, IMG_BOY_7];
			return new bitmaps[mBoyImageId] as Bitmap;
		}
		
		private function getColorFromId(colorId:int):uint
		{
			var colors:Array = [0xFE02F5, 0xFE0201, 0xFFCD04, 0xF0FF0A, 0x09AC05, 0x0C05AB, 0xBB04FF];
			return uint(colors[colorId % colors.length]);
		}
		
		public static function getRandomBoyId():uint
		{
			var ids:Array = [
				BOY_1,
				BOY_2,
				BOY_3,
				BOY_4,
				BOY_5,
				BOY_6,
				BOY_7
			];
			
			var index:int = Math.floor(Math.random() * ids.length);
			return uint(ids[index]);
		}
		
		private function onEnterFrame(e:Event):void 
		{
			var dt:Number = 1 / stage.frameRate;
			mAngle += Math.PI * dt;
			
			if (mAngle > Math.PI)
			{
				mAngle -= Math.PI;
				mAmplitude = 40 + Math.random() * 15;
				resetBoyBitmap();
			}

			mSpr.y = -Math.sin(mAngle) * mAmplitude;
		}
		
	}

}