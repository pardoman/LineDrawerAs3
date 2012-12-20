package  
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author ...
	 */
	public class Disclaimer extends Sprite
	{
		[Embed(source = "../lib/disclaimer1.png")] private static const IMG_1:Class;
		[Embed(source = "../lib/disclaimer2.png")] private static const IMG_2:Class;
		[Embed(source = "../lib/disclaimer3.png")] private static const IMG_3:Class;
		
		private var mBitmap1:Bitmap;
		private var mBitmap2:Bitmap;
		private var mBitmap3:Bitmap;
		private var mIndex:int = 1;
		private var mFrameCounter:int;
		
		public function Disclaimer() 
		{
			this.buttonMode = true;
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			mBitmap1 = new IMG_1;
			mBitmap2 = new IMG_2;
			mBitmap3 = new IMG_3;
			
			addChild(mBitmap1);
			addChild(mBitmap2);
			addChild(mBitmap3);
			
			resetImage();
		}
		
		private function onEnterFrame(e:Event):void 
		{
			mFrameCounter--;
		}
		
		private function onMouseClick(e:MouseEvent):void 
		{
			if (mFrameCounter > 0)
				return;
			
			mIndex++;
			
			resetImage();
			mFrameCounter = 5;
		}
		
		private function resetImage():void 
		{
			mBitmap1.visible = mIndex == 1;
			mBitmap2.visible = mIndex == 2;
			mBitmap3.visible = mIndex == 3;
		}
		
	}

}