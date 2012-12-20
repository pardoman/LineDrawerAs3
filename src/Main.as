package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Federico Medina
	 */
	public class Main extends Sprite 
	{
		private var mSpr:Sprite;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//generateLines();
			drawGeneratedLines();
		}
		
		private function generateLines():void
		{
			var generator:LineGenerator = new LineGenerator(stage);
			generator.run();
		}
		
		private function drawGeneratedLines():void
		{
			var generator:LineArtDrawer = new LineArtDrawer(stage);
			generator.run();
		}
		
		
	}
	
}