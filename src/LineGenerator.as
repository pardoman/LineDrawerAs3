package  
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Federico Medina
	 */
	public class LineGenerator 
	{
		private var mStage:Stage;
		private var mSpr:Sprite;
		private var mSprLine:Sprite;
		private var mPoints:Vector.<Point> = new Vector.<Point>;
		
		public function LineGenerator(aStage:Stage) 
		{
			mStage = aStage;
			mSpr = new Sprite;
			mSprLine = new Sprite;
			mStage.addChild(mSpr);
			mStage.addChild(mSprLine);
		}
		
		public function run():void
		{
			mStage.addEventListener(MouseEvent.CLICK, onMouseClick);
			mStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			mStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.charCode == Keyboard.ENTER)
				writeLinesToConsole();
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			reDrawShadowLine(e);
		}
		
		private function onMouseClick(e:MouseEvent):void 
		{
			if (mPoints.length == 0)
			{
				mPoints.push(new Point(mStage.mouseX, mStage.mouseY));
			}
			else
			{
				if (e.shiftKey && mPoints.length > 0)
				{
					mPoints.push(null);
				}
				mPoints.push(new Point(mStage.mouseX, mStage.mouseY));
				reDrawShadowLine(e);
			}
			
			reDraw();
		}
		
		private function reDraw():void
		{
			mSpr.graphics.clear();
			mSpr.graphics.lineStyle(1, 0xB40C10, 1);
			
			if (mPoints.length == 0) {
				return;
			}
			
			// Move to fist point
			var point:Point = mPoints[0];
			mSpr.graphics.moveTo(point.x, point.y);
			
			
			// All other points
			for (var i:int = 1; i < mPoints.length; i++)
			{
				point = mPoints[i];
				
				if (point == null)
				{
					point = mPoints[++i];
					mSpr.graphics.moveTo(point.x, point.y);
				}
				else
				{
					mSpr.graphics.lineTo(point.x, point.y);
				}
			}
		}
		
		private function reDrawShadowLine(e:MouseEvent):void
		{
			if (mPoints.length == 0)
				return;
				
			var p:Point = mPoints[mPoints.length - 1];
			
			mSprLine.graphics.clear();
			
			if (e.shiftKey == false)
			{
				mSprLine.graphics.lineStyle(1, 0xB40C10, 1);
				mSprLine.graphics.moveTo(p.x, p.y);
				mSprLine.graphics.lineTo(mStage.mouseX, mStage.mouseY);
			}
		}
		
		
		private function writeLinesToConsole():void 
		{
			trace("//Begin drawing");
			trace("mPoints = new Vector.<Point>();");
			for each (var point:Point in mPoints)
			{
				if (point == null)
				{
					trace("mPoints.push(null);");
				}
				else
				{
					trace("mPoints.push(new Point(" + int(point.x) + ", " + int(point.y) + "));");
				}
			}
			trace("//End drawing");
		}
		
	}

}