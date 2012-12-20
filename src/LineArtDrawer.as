package  
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Federico Medina
	 */
	public class LineArtDrawer 
	{
		private var mStage:Stage;
		private var mLayerStars:Sprite;
		private var mSpr:Sprite;
		private var mSprShadow:Sprite;
		private var mPoints:Vector.<Point> = new Vector.<Point>;
		private var mIndex:int = 0;
		
		private var mState:uint;
		private const STATE_DRAWING:uint = 0;
		private const STATE_FINISHED:uint = 1;
		
		public function LineArtDrawer(aStage:Stage) 
		{
			mStage = aStage;
			mLayerStars = new Sprite;
			mSpr = new Sprite;
			mSprShadow = new Sprite;
			
			mStage.addChild(mLayerStars);
			mStage.addChild(mSprShadow);
			mStage.addChild(mSpr);
			
			mSprShadow.x = 2;
			mSprShadow.y = 2;
		}
		
		private function setFinishState():void
		{
			if (mState != STATE_FINISHED)
			{
				mState = STATE_FINISHED;
				createBoys();
				createStars();
				createDisclaimer();
			}
		}
		
		private function createDisclaimer():void 
		{
			var spr:Sprite = new Disclaimer;
			spr. x = mStage.stageWidth - spr.width;
			mStage.addChild(spr);
		}
		
		public function run():void
		{
			definePoints();
			incrementLineSegments(3);
			normalizeSegments();
			randomizeSegments();
			initializeDrawingSurface();
			mStage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
		private function createBoys():void
		{
			for (var i:int = 0; i < 7; i++)
			{
				var boys:Sprite = new Boys(i);
				boys.x = (i+1) * (mStage.stageWidth / 8);
				boys.y = mStage.stageHeight + 40;
				mStage.addChild(boys);
			}
		}
		
		private function createStars():void
		{
			var fallingStars:FallingStars = new FallingStars();
			mLayerStars.addChild(fallingStars);
			fallingStars.begin();
		}
		
		private function initializeDrawingSurface():void
		{
			mSpr.graphics.lineStyle(5, 0xB40C10, 1, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND, 3);
			mSprShadow.graphics.lineStyle(5, 0x000000, 1, false, LineScaleMode.NORMAL, CapsStyle.ROUND, JointStyle.ROUND,3);
		}
		
		private function normalizeSegments():void 
		{
			// Changes the way points are stored
			// Go from: [A,B,C,null,D,E,F]
			// into: [a,b,d,e],   where a = segment from A to B,
			//							b = segment from B to C,
			//							d = segment from D to E,
			//							e = segment from E to F,
			//   also, each segment is stored as 2 consecutive points
			//   so the ending array would be:
			//    [A,B, B,C, D,E, E,F]
			
			var outList:Vector.<Point> = new Vector.<Point>;
			
			for (var i:int = 1; i < mPoints.length; ++i)
			{
				if (mPoints[i] != null && mPoints[i-1] != null)
				{
					outList.push(mPoints[i - 1].clone(), mPoints[i].clone());
				}
			}
			
			// Resulting vector will have an even quantity of elements
			mPoints = outList;
		}
		
		private function randomizeSegments():void 
		{
			var outList:Vector.<Point>  = new Vector.<Point>;
			
			while (mPoints.length > 0)
			{
				var index:int = Math.floor(Math.random() * mPoints.length);
				if (index & 1 == 1)
				{
					//Odd number, make it even
					index--;
				}
				
				// Add the two elements from here
				outList.push(mPoints[index]);
				outList.push(mPoints[index + 1]);
				
				// Remove added elements
				mPoints.splice(index, 2);
			}
			
			mPoints = outList;
		}
		
		private function addSegment(value:int, outVec:Vector.<Point>):void 
		{
			for (var i:int = value; i < mPoints.length; i++)
			{
				if (mPoints[i] == null)
				{
					return;
				}
					
				outVec.push(mPoints[i]);
			}
		}
		
		private function onEnterFrame(e:Event):void 
		{
			switch (mState)
			{
				case STATE_DRAWING:
					drawNextLine();
					drawNextLine();
					drawNextLine();
					drawNextLine();
					break;
					
				case STATE_FINISHED:
					break;
			}
		}
		
		private function drawNextLine():void 
		{
			// Abort if reached the last point
			if (mIndex >= mPoints.length) 
			{
				setFinishState();
				return;
			}
			
			var pointA:Point = mPoints[mIndex++];
			var pointB:Point = mPoints[mIndex++];
			
			mSpr.graphics.moveTo(pointA.x, pointA.y);
			mSpr.graphics.lineTo(pointB.x, pointB.y);
			
			mSprShadow.graphics.moveTo(pointA.x, pointA.y);
			mSprShadow.graphics.lineTo(pointB.x, pointB.y);
		}
		
		private function incrementLineSegments(iterations:int):void
		{
			while (iterations > 0)
			{
				incrementLineSegmentsAux();
				iterations--;
			}
		}
		
		private function incrementLineSegmentsAux():void
		{
			var otherPoints:Vector.<Point> = new Vector.<Point>();
			var prevPoint:Point = null
			var currPoint:Point = null;
			
			for (var i:int = 1; i < mPoints.length; ++i)
			{
				prevPoint = mPoints[i-1];
				currPoint = mPoints[i];
				
				if (currPoint == null)
				{
					otherPoints.push(null);
				}
				else if (currPoint != null && prevPoint != null)
				{
					insertSegmentDivided(prevPoint, currPoint, otherPoints);
				}
			}
			
			mPoints = otherPoints;
		}
		
		private function insertSegmentDivided(pA:Point, pB:Point, outList:Vector.<Point>):void 
		{
			var midPoint:Point = new Point( (pA.x + pB.x) / 2, (pA.y + pB.y) / 2);
			
			outList.push(pA);
			outList.push(midPoint);
			outList.push(pB);
		}
		
		private function definePoints():void
		{
			//definePoints_DVJWpromo();
			//definePoints_bender();
			//definePoints_WeAreTheRobots();
			//definePoints_ArielyMauro();
			definePoints_blogPost();
		}
		
		private function definePoints_blogPost():void
		{
			//Begin drawing
mPoints = new Vector.<Point>();
mPoints.push(new Point(97, 227));
mPoints.push(new Point(223, 96));
mPoints.push(new Point(152, 284));
mPoints.push(new Point(317, 112));
mPoints.push(new Point(277, 261));
mPoints.push(new Point(555, 224));
mPoints.push(null);
mPoints.push(new Point(94, 457));
mPoints.push(new Point(302, 369));
mPoints.push(new Point(455, 448));
mPoints.push(new Point(660, 372));
//End drawing

		}
		
		private function definePoints_DVJWpromo():void
		{
			//Begin drawing
mPoints = new Vector.<Point>();
mPoints.push(new Point(85, 325));
mPoints.push(new Point(54, 98));
mPoints.push(new Point(125, 104));
mPoints.push(new Point(178, 149));
mPoints.push(new Point(200, 192));
mPoints.push(new Point(201, 258));
mPoints.push(new Point(175, 300));
mPoints.push(new Point(88, 324));
mPoints.push(null);
mPoints.push(new Point(211, 94));
mPoints.push(new Point(265, 315));
mPoints.push(new Point(342, 93));
mPoints.push(null);
mPoints.push(new Point(380, 97));
mPoints.push(new Point(542, 91));
mPoints.push(null);
mPoints.push(new Point(460, 93));
mPoints.push(new Point(463, 224));
mPoints.push(new Point(461, 285));
mPoints.push(new Point(437, 317));
mPoints.push(new Point(388, 316));
mPoints.push(new Point(365, 286));
mPoints.push(new Point(352, 243));
mPoints.push(null);
mPoints.push(new Point(500, 124));
mPoints.push(new Point(563, 307));
mPoints.push(new Point(595, 207));
mPoints.push(new Point(641, 300));
mPoints.push(new Point(706, 96));
mPoints.push(null);
mPoints.push(new Point(74, 367));
mPoints.push(new Point(31, 366));
mPoints.push(new Point(37, 419));
mPoints.push(new Point(78, 418));
mPoints.push(null);
mPoints.push(new Point(36, 391));
mPoints.push(new Point(58, 390));
mPoints.push(null);
mPoints.push(new Point(129, 388));
mPoints.push(new Point(100, 379));
mPoints.push(new Point(91, 398));
mPoints.push(new Point(110, 403));
mPoints.push(new Point(122, 422));
mPoints.push(new Point(96, 419));
mPoints.push(null);
mPoints.push(new Point(178, 350));
mPoints.push(new Point(162, 432));
mPoints.push(null);
mPoints.push(new Point(222, 389));
mPoints.push(new Point(188, 385));
mPoints.push(new Point(179, 417));
mPoints.push(new Point(204, 426));
mPoints.push(new Point(219, 406));
mPoints.push(new Point(225, 362));
mPoints.push(new Point(194, 360));
mPoints.push(null);
mPoints.push(new Point(264, 408));
mPoints.push(new Point(284, 384));
mPoints.push(new Point(292, 403));
mPoints.push(new Point(315, 375));
mPoints.push(new Point(316, 420));
mPoints.push(null);
mPoints.push(new Point(336, 402));
mPoints.push(new Point(368, 402));
mPoints.push(new Point(357, 377));
mPoints.push(new Point(335, 380));
mPoints.push(new Point(334, 417));
mPoints.push(new Point(360, 426));
mPoints.push(new Point(372, 416));
mPoints.push(null);
mPoints.push(new Point(397, 375));
mPoints.push(new Point(399, 429));
mPoints.push(new Point(374, 458));
mPoints.push(new Point(360, 451));
mPoints.push(null);
mPoints.push(new Point(396, 350));
mPoints.push(new Point(386, 360));
mPoints.push(new Point(394, 367));
mPoints.push(new Point(403, 358));
mPoints.push(new Point(396, 349));
mPoints.push(null);
mPoints.push(new Point(426, 422));
mPoints.push(new Point(421, 370));
mPoints.push(null);
mPoints.push(new Point(422, 382));
mPoints.push(new Point(437, 374));
mPoints.push(new Point(454, 375));
mPoints.push(null);
mPoints.push(new Point(482, 396));
mPoints.push(new Point(513, 395));
mPoints.push(new Point(509, 372));
mPoints.push(new Point(492, 375));
mPoints.push(new Point(481, 398));
mPoints.push(new Point(485, 419));
mPoints.push(new Point(510, 420));
mPoints.push(null);
mPoints.push(new Point(526, 408));
mPoints.push(new Point(525, 333));
mPoints.push(null);
mPoints.push(new Point(540, 388));
mPoints.push(new Point(570, 387));
mPoints.push(new Point(562, 363));
mPoints.push(new Point(541, 366));
mPoints.push(new Point(540, 404));
mPoints.push(new Point(553, 413));
mPoints.push(new Point(569, 411));
mPoints.push(null);
mPoints.push(new Point(621, 373));
mPoints.push(new Point(597, 363));
mPoints.push(new Point(584, 377));
mPoints.push(new Point(582, 406));
mPoints.push(new Point(600, 414));
mPoints.push(new Point(617, 408));
mPoints.push(null);
mPoints.push(new Point(646, 328));
mPoints.push(new Point(642, 416));
mPoints.push(null);
mPoints.push(new Point(630, 348));
mPoints.push(new Point(665, 352));
mPoints.push(null);
mPoints.push(new Point(659, 407));
mPoints.push(new Point(665, 373));
mPoints.push(null);
mPoints.push(new Point(670, 358));
mPoints.push(new Point(675, 352));
mPoints.push(null);
mPoints.push(new Point(681, 369));
mPoints.push(new Point(696, 412));
mPoints.push(new Point(713, 368));
mPoints.push(null);
mPoints.push(new Point(759, 375));
mPoints.push(new Point(735, 372));
mPoints.push(new Point(724, 391));
mPoints.push(new Point(740, 409));
mPoints.push(new Point(763, 403));
mPoints.push(new Point(756, 349));
mPoints.push(new Point(737, 342));
mPoints.push(new Point(721, 353));
mPoints.push(null);
mPoints.push(new Point(218, 465));
mPoints.push(new Point(242, 542));
mPoints.push(new Point(257, 506));
mPoints.push(new Point(276, 539));
mPoints.push(new Point(293, 460));
mPoints.push(null);
mPoints.push(new Point(323, 499));
mPoints.push(new Point(295, 506));
mPoints.push(new Point(294, 529));
mPoints.push(new Point(313, 539));
mPoints.push(new Point(335, 526));
mPoints.push(new Point(322, 500));
mPoints.push(null);
mPoints.push(new Point(372, 497));
mPoints.push(new Point(343, 511));
mPoints.push(new Point(347, 532));
mPoints.push(new Point(373, 537));
mPoints.push(new Point(390, 517));
mPoints.push(new Point(370, 493));
mPoints.push(null);
mPoints.push(new Point(411, 457));
mPoints.push(new Point(398, 536));
mPoints.push(null);
mPoints.push(new Point(403, 499));
mPoints.push(new Point(430, 503));
mPoints.push(new Point(432, 539));
mPoints.push(null);
mPoints.push(new Point(468, 498));
mPoints.push(new Point(442, 507));
mPoints.push(new Point(452, 535));
mPoints.push(new Point(479, 529));
mPoints.push(new Point(488, 504));
mPoints.push(new Point(466, 496));
mPoints.push(null);
mPoints.push(new Point(519, 494));
mPoints.push(new Point(496, 506));
mPoints.push(new Point(497, 531));
mPoints.push(new Point(528, 535));
mPoints.push(new Point(551, 508));
mPoints.push(new Point(519, 490));
mPoints.push(null);
mPoints.push(new Point(590, 486));
mPoints.push(new Point(560, 500));
mPoints.push(new Point(559, 524));
mPoints.push(new Point(583, 535));
mPoints.push(new Point(607, 516));
mPoints.push(new Point(610, 496));
mPoints.push(new Point(587, 483));
mPoints.push(null);
mPoints.push(new Point(657, 482));
mPoints.push(new Point(627, 492));
mPoints.push(new Point(621, 519));
mPoints.push(new Point(648, 533));
mPoints.push(new Point(674, 512));
mPoints.push(new Point(654, 481));
mPoints.push(null);
mPoints.push(new Point(696, 496));
mPoints.push(new Point(676, 437));
mPoints.push(new Point(704, 436));
mPoints.push(new Point(694, 495));
mPoints.push(null);
mPoints.push(new Point(699, 509));
mPoints.push(new Point(681, 523));
mPoints.push(new Point(697, 538));
mPoints.push(new Point(720, 524));
mPoints.push(new Point(706, 508));
mPoints.push(null);
mPoints.push(new Point(56, 464));
mPoints.push(new Point(73, 496));
mPoints.push(null);
mPoints.push(new Point(91, 460));
mPoints.push(new Point(103, 489));
mPoints.push(null);
mPoints.push(new Point(63, 515));
mPoints.push(new Point(82, 537));
mPoints.push(new Point(122, 526));
mPoints.push(new Point(127, 497));
//End drawing
		}
		
		private function definePoints_bender():void
		{
			//Begin drawing
mPoints = new Vector.<Point>();
mPoints.push(new Point(376, 229));
mPoints.push(new Point(275, 228));
mPoints.push(new Point(244, 161));
mPoints.push(new Point(264, 120));
mPoints.push(new Point(311, 104));
mPoints.push(new Point(395, 107));
mPoints.push(new Point(540, 106));
mPoints.push(new Point(575, 120));
mPoints.push(new Point(587, 161));
mPoints.push(new Point(586, 190));
mPoints.push(new Point(561, 210));
mPoints.push(new Point(523, 223));
mPoints.push(new Point(481, 234));
mPoints.push(new Point(372, 229));
mPoints.push(null);
mPoints.push(new Point(310, 227));
mPoints.push(new Point(295, 199));
mPoints.push(new Point(288, 175));
mPoints.push(new Point(297, 150));
mPoints.push(new Point(332, 134));
mPoints.push(new Point(361, 134));
mPoints.push(new Point(389, 140));
mPoints.push(new Point(410, 161));
mPoints.push(new Point(389, 202));
mPoints.push(new Point(372, 224));
mPoints.push(null);
mPoints.push(new Point(453, 229));
mPoints.push(new Point(433, 210));
mPoints.push(new Point(423, 191));
mPoints.push(new Point(420, 168));
mPoints.push(new Point(428, 148));
mPoints.push(new Point(448, 139));
mPoints.push(new Point(477, 137));
mPoints.push(new Point(512, 144));
mPoints.push(new Point(532, 163));
mPoints.push(new Point(536, 186));
mPoints.push(new Point(512, 221));
mPoints.push(null);
mPoints.push(new Point(289, 168));
mPoints.push(new Point(307, 162));
mPoints.push(new Point(317, 185));
mPoints.push(new Point(298, 191));
mPoints.push(new Point(296, 191));
mPoints.push(null);
mPoints.push(new Point(423, 166));
mPoints.push(new Point(444, 159));
mPoints.push(new Point(455, 172));
mPoints.push(new Point(445, 189));
mPoints.push(new Point(424, 194));
mPoints.push(null);
mPoints.push(new Point(466, 92));
mPoints.push(new Point(301, 91));
mPoints.push(new Point(247, 117));
mPoints.push(new Point(228, 165));
mPoints.push(new Point(266, 237));
mPoints.push(new Point(484, 244));
mPoints.push(new Point(572, 217));
mPoints.push(new Point(597, 191));
mPoints.push(new Point(599, 155));
mPoints.push(new Point(583, 109));
mPoints.push(new Point(542, 92));
mPoints.push(new Point(461, 91));
mPoints.push(null);
mPoints.push(new Point(328, 83));
mPoints.push(new Point(336, 36));
mPoints.push(new Point(390, 16));
mPoints.push(new Point(466, 14));
mPoints.push(new Point(518, 27));
mPoints.push(new Point(519, 85));
mPoints.push(new Point(520, 89));
mPoints.push(null);
mPoints.push(new Point(324, 86));
mPoints.push(new Point(328, 79));
mPoints.push(null);
mPoints.push(new Point(292, 235));
mPoints.push(new Point(287, 382));
mPoints.push(new Point(488, 388));
mPoints.push(new Point(489, 241));
mPoints.push(null);
mPoints.push(new Point(317, 306));
mPoints.push(new Point(319, 334));
mPoints.push(new Point(332, 350));
mPoints.push(new Point(434, 352));
mPoints.push(new Point(457, 330));
mPoints.push(new Point(455, 296));
mPoints.push(new Point(433, 270));
mPoints.push(new Point(332, 272));
mPoints.push(new Point(314, 306));
mPoints.push(new Point(347, 299));
mPoints.push(new Point(425, 297));
mPoints.push(new Point(453, 304));
mPoints.push(null);
mPoints.push(new Point(456, 328));
mPoints.push(new Point(418, 322));
mPoints.push(new Point(342, 322));
mPoints.push(new Point(320, 328));
mPoints.push(null);
mPoints.push(new Point(340, 348));
mPoints.push(new Point(342, 274));
mPoints.push(null);
mPoints.push(new Point(364, 272));
mPoints.push(new Point(363, 347));
mPoints.push(null);
mPoints.push(new Point(381, 350));
mPoints.push(new Point(385, 273));
mPoints.push(null);
mPoints.push(new Point(408, 273));
mPoints.push(new Point(404, 350));
mPoints.push(null);
mPoints.push(new Point(422, 350));
mPoints.push(new Point(428, 271));
mPoints.push(null);
mPoints.push(new Point(288, 381));
mPoints.push(new Point(196, 425));
mPoints.push(new Point(121, 498));
mPoints.push(new Point(651, 495));
mPoints.push(new Point(590, 411));
mPoints.push(new Point(489, 388));
mPoints.push(null);
mPoints.push(new Point(122, 499));
mPoints.push(new Point(121, 589));
mPoints.push(null);
mPoints.push(new Point(649, 496));
mPoints.push(new Point(651, 587));
mPoints.push(null);
mPoints.push(new Point(219, 589));
mPoints.push(new Point(221, 540));
mPoints.push(new Point(535, 539));
mPoints.push(new Point(534, 586));
mPoints.push(null);
mPoints.push(new Point(630, 457));
mPoints.push(new Point(665, 447));
mPoints.push(new Point(688, 465));
mPoints.push(new Point(704, 506));
mPoints.push(new Point(703, 556));
mPoints.push(new Point(684, 580));
mPoints.push(new Point(657, 584));
mPoints.push(null);
mPoints.push(new Point(168, 440));
mPoints.push(new Point(134, 421));
mPoints.push(new Point(88, 458));
mPoints.push(new Point(70, 507));
mPoints.push(new Point(73, 553));
mPoints.push(new Point(87, 577));
mPoints.push(new Point(117, 580));
mPoints.push(null);
mPoints.push(new Point(681, 454));
mPoints.push(new Point(731, 402));
mPoints.push(new Point(766, 304));
mPoints.push(new Point(776, 188));
mPoints.push(new Point(779, 69));
mPoints.push(new Point(778, 2));
mPoints.push(null);
mPoints.push(new Point(708, 536));
mPoints.push(new Point(775, 476));
mPoints.push(new Point(796, 422));
mPoints.push(null);
mPoints.push(new Point(103, 440));
mPoints.push(new Point(58, 360));
mPoints.push(new Point(37, 243));
mPoints.push(new Point(30, 95));
mPoints.push(new Point(26, 4));
mPoints.push(null);
mPoints.push(new Point(70, 532));
mPoints.push(new Point(8, 451));
mPoints.push(new Point(3, 408));
mPoints.push(null);
mPoints.push(new Point(733, 398));
mPoints.push(new Point(766, 403));
mPoints.push(new Point(791, 426));
mPoints.push(null);
mPoints.push(new Point(768, 301));
mPoints.push(new Point(795, 308));
mPoints.push(null);
mPoints.push(new Point(779, 172));
mPoints.push(new Point(797, 177));
mPoints.push(null);
mPoints.push(new Point(783, 56));
mPoints.push(new Point(796, 58));
mPoints.push(null);
mPoints.push(new Point(55, 361));
mPoints.push(new Point(13, 368));
mPoints.push(new Point(1, 372));
mPoints.push(null);
mPoints.push(new Point(32, 233));
mPoints.push(new Point(4, 235));
mPoints.push(null);
mPoints.push(new Point(23, 105));
mPoints.push(new Point(5, 105));
//End drawing
		}
		
		private function definePoints_WeAreTheRobots():void
		{
//Begin drawing
mPoints = new Vector.<Point>();
mPoints.push(new Point(50, 44));
mPoints.push(new Point(69, 171));
mPoints.push(new Point(93, 116));
mPoints.push(new Point(112, 166));
mPoints.push(new Point(130, 40));
mPoints.push(null);
mPoints.push(new Point(145, 131));
mPoints.push(new Point(200, 126));
mPoints.push(new Point(180, 101));
mPoints.push(new Point(152, 118));
mPoints.push(new Point(145, 134));
mPoints.push(new Point(154, 164));
mPoints.push(new Point(181, 160));
mPoints.push(new Point(200, 151));
mPoints.push(null);
mPoints.push(new Point(251, 160));
mPoints.push(new Point(277, 62));
mPoints.push(new Point(311, 150));
mPoints.push(null);
mPoints.push(new Point(262, 117));
mPoints.push(new Point(298, 116));
mPoints.push(null);
mPoints.push(new Point(338, 148));
mPoints.push(new Point(324, 99));
mPoints.push(null);
mPoints.push(new Point(328, 118));
mPoints.push(new Point(340, 102));
mPoints.push(new Point(358, 100));
mPoints.push(null);
mPoints.push(new Point(393, 121));
mPoints.push(new Point(433, 117));
mPoints.push(new Point(419, 94));
mPoints.push(new Point(395, 109));
mPoints.push(new Point(392, 127));
mPoints.push(new Point(394, 152));
mPoints.push(new Point(420, 148));
mPoints.push(new Point(433, 133));
mPoints.push(null);
mPoints.push(new Point(508, 54));
mPoints.push(new Point(495, 163));
mPoints.push(null);
mPoints.push(new Point(478, 85));
mPoints.push(new Point(529, 90));
mPoints.push(null);
mPoints.push(new Point(557, 61));
mPoints.push(new Point(532, 163));
mPoints.push(null);
mPoints.push(new Point(543, 120));
mPoints.push(new Point(574, 119));
mPoints.push(new Point(576, 159));
mPoints.push(null);
mPoints.push(new Point(603, 126));
mPoints.push(new Point(650, 123));
mPoints.push(new Point(626, 99));
mPoints.push(new Point(600, 103));
mPoints.push(new Point(605, 141));
mPoints.push(new Point(629, 155));
mPoints.push(new Point(657, 145));
mPoints.push(null);
mPoints.push(new Point(75, 320));
mPoints.push(new Point(118, 207));
mPoints.push(new Point(202, 232));
mPoints.push(new Point(177, 273));
mPoints.push(new Point(122, 283));
mPoints.push(new Point(92, 270));
mPoints.push(null);
mPoints.push(new Point(123, 284));
mPoints.push(new Point(146, 328));
mPoints.push(null);
mPoints.push(new Point(235, 265));
mPoints.push(new Point(186, 301));
mPoints.push(new Point(215, 350));
mPoints.push(new Point(268, 320));
mPoints.push(new Point(265, 266));
mPoints.push(new Point(234, 266));
mPoints.push(null);
mPoints.push(new Point(311, 210));
mPoints.push(new Point(295, 355));
mPoints.push(new Point(356, 331));
mPoints.push(new Point(357, 283));
mPoints.push(new Point(305, 289));
mPoints.push(null);
mPoints.push(new Point(434, 245));
mPoints.push(new Point(390, 284));
mPoints.push(new Point(393, 326));
mPoints.push(new Point(438, 346));
mPoints.push(new Point(487, 305));
mPoints.push(new Point(473, 258));
mPoints.push(new Point(430, 246));
mPoints.push(null);
mPoints.push(new Point(549, 189));
mPoints.push(new Point(522, 347));
mPoints.push(null);
mPoints.push(new Point(507, 224));
mPoints.push(new Point(582, 229));
mPoints.push(null);
mPoints.push(new Point(686, 246));
mPoints.push(new Point(625, 254));
mPoints.push(new Point(589, 278));
mPoints.push(new Point(600, 306));
mPoints.push(new Point(648, 305));
mPoints.push(new Point(686, 309));
mPoints.push(new Point(689, 347));
mPoints.push(new Point(645, 366));
mPoints.push(new Point(588, 353));
mPoints.push(null);
mPoints.push(new Point(751, 179));
mPoints.push(new Point(743, 324));
mPoints.push(new Point(719, 181));
mPoints.push(new Point(748, 179));
mPoints.push(null);
mPoints.push(new Point(751, 340));
mPoints.push(new Point(733, 336));
mPoints.push(new Point(726, 357));
mPoints.push(new Point(745, 363));
mPoints.push(new Point(762, 350));
mPoints.push(null);
mPoints.push(new Point(24, 529));
mPoints.push(new Point(34, 447));
mPoints.push(new Point(56, 487));
mPoints.push(new Point(93, 433));
mPoints.push(new Point(83, 529));
mPoints.push(null);
mPoints.push(new Point(101, 525));
mPoints.push(new Point(123, 468));
mPoints.push(new Point(138, 521));
mPoints.push(null);
mPoints.push(new Point(109, 501));
mPoints.push(new Point(135, 501));
mPoints.push(null);
mPoints.push(new Point(157, 463));
mPoints.push(new Point(156, 530));
mPoints.push(null);
mPoints.push(new Point(155, 464));
mPoints.push(new Point(194, 467));
mPoints.push(new Point(201, 481));
mPoints.push(new Point(192, 498));
mPoints.push(new Point(158, 502));
mPoints.push(null);
mPoints.push(new Point(176, 496));
mPoints.push(new Point(192, 526));
mPoints.push(null);
mPoints.push(new Point(219, 519));
mPoints.push(new Point(205, 543));
mPoints.push(null);
mPoints.push(new Point(269, 519));
mPoints.push(new Point(267, 427));
mPoints.push(new Point(329, 426));
mPoints.push(null);
mPoints.push(new Point(267, 473));
mPoints.push(new Point(305, 474));
mPoints.push(null);
mPoints.push(new Point(378, 463));
mPoints.push(new Point(329, 468));
mPoints.push(new Point(326, 517));
mPoints.push(new Point(377, 516));
mPoints.push(null);
mPoints.push(new Point(327, 490));
mPoints.push(new Point(359, 489));
mPoints.push(null);
mPoints.push(new Point(408, 459));
mPoints.push(new Point(403, 514));
mPoints.push(new Point(439, 507));
mPoints.push(new Point(454, 489));
mPoints.push(new Point(450, 466));
mPoints.push(new Point(425, 457));
mPoints.push(new Point(407, 460));
mPoints.push(null);
mPoints.push(new Point(522, 457));
mPoints.push(new Point(475, 457));
mPoints.push(new Point(471, 509));
mPoints.push(new Point(518, 510));
mPoints.push(null);
mPoints.push(new Point(472, 480));
mPoints.push(new Point(498, 483));
mPoints.push(null);
mPoints.push(new Point(544, 504));
mPoints.push(new Point(523, 538));
mPoints.push(null);
mPoints.push(new Point(562, 415));
mPoints.push(new Point(626, 513));
mPoints.push(null);
mPoints.push(new Point(570, 509));
mPoints.push(new Point(620, 405));
mPoints.push(null);
mPoints.push(new Point(640, 458));
mPoints.push(new Point(641, 510));
mPoints.push(null);
mPoints.push(new Point(656, 508));
mPoints.push(new Point(658, 449));
mPoints.push(new Point(681, 478));
mPoints.push(new Point(710, 450));
mPoints.push(new Point(704, 508));
mPoints.push(null);
mPoints.push(new Point(778, 448));
mPoints.push(new Point(733, 449));
mPoints.push(new Point(725, 507));
mPoints.push(new Point(768, 507));
mPoints.push(null);
mPoints.push(new Point(727, 477));
mPoints.push(new Point(755, 479));
//End drawing
		}
		
		private function definePoints_ArielyMauro():void
		{
			//Begin drawing
mPoints = new Vector.<Point>();
mPoints.push(new Point(20, 51));
mPoints.push(new Point(22, 141));
mPoints.push(null);
mPoints.push(new Point(21, 52));
mPoints.push(new Point(75, 48));
mPoints.push(null);
mPoints.push(new Point(22, 88));
mPoints.push(new Point(59, 87));
mPoints.push(null);
mPoints.push(new Point(74, 118));
mPoints.push(new Point(114, 114));
mPoints.push(new Point(97, 85));
mPoints.push(new Point(83, 90));
mPoints.push(new Point(72, 115));
mPoints.push(new Point(76, 139));
mPoints.push(new Point(101, 140));
mPoints.push(new Point(116, 131));
mPoints.push(null);
mPoints.push(new Point(154, 41));
mPoints.push(new Point(133, 138));
mPoints.push(null);
mPoints.push(new Point(157, 138));
mPoints.push(new Point(169, 104));
mPoints.push(null);
mPoints.push(new Point(171, 89));
mPoints.push(new Point(178, 81));
mPoints.push(null);
mPoints.push(new Point(192, 92));
mPoints.push(new Point(235, 90));
mPoints.push(null);
mPoints.push(new Point(187, 135));
mPoints.push(new Point(226, 135));
mPoints.push(null);
mPoints.push(new Point(189, 134));
mPoints.push(new Point(234, 90));
mPoints.push(null);
mPoints.push(new Point(201, 110));
mPoints.push(new Point(224, 116));
mPoints.push(null);
mPoints.push(new Point(338, 64));
mPoints.push(new Point(294, 79));
mPoints.push(new Point(278, 111));
mPoints.push(new Point(282, 135));
mPoints.push(new Point(301, 151));
mPoints.push(new Point(317, 151));
mPoints.push(new Point(336, 146));
mPoints.push(new Point(349, 135));
mPoints.push(null);
mPoints.push(new Point(370, 101));
mPoints.push(new Point(369, 133));
mPoints.push(new Point(379, 148));
mPoints.push(new Point(396, 151));
mPoints.push(new Point(416, 146));
mPoints.push(new Point(419, 142));
mPoints.push(new Point(421, 123));
mPoints.push(new Point(424, 100));
mPoints.push(new Point(426, 90));
mPoints.push(null);
mPoints.push(new Point(432, 143));
mPoints.push(new Point(436, 106));
mPoints.push(new Point(440, 88));
mPoints.push(new Point(454, 98));
mPoints.push(new Point(458, 113));
mPoints.push(new Point(465, 91));
mPoints.push(new Point(479, 89));
mPoints.push(new Point(489, 110));
mPoints.push(new Point(488, 129));
mPoints.push(new Point(486, 142));
mPoints.push(null);
mPoints.push(new Point(511, 205));
mPoints.push(new Point(506, 88));
mPoints.push(new Point(534, 85));
mPoints.push(new Point(551, 99));
mPoints.push(new Point(553, 120));
mPoints.push(new Point(538, 133));
mPoints.push(new Point(520, 138));
mPoints.push(new Point(511, 138));
mPoints.push(null);
mPoints.push(new Point(554, 143));
mPoints.push(new Point(565, 120));
mPoints.push(new Point(577, 77));
mPoints.push(new Point(581, 52));
mPoints.push(new Point(581, 45));
mPoints.push(null);
mPoints.push(new Point(587, 116));
mPoints.push(new Point(627, 116));
mPoints.push(new Point(628, 92));
mPoints.push(new Point(610, 82));
mPoints.push(new Point(583, 103));
mPoints.push(new Point(583, 114));
mPoints.push(new Point(582, 133));
mPoints.push(new Point(590, 138));
mPoints.push(new Point(612, 141));
mPoints.push(new Point(627, 137));
mPoints.push(null);
mPoints.push(new Point(73, 292));
mPoints.push(new Point(126, 180));
mPoints.push(new Point(138, 292));
mPoints.push(null);
mPoints.push(new Point(95, 240));
mPoints.push(new Point(133, 247));
mPoints.push(null);
mPoints.push(new Point(155, 288));
mPoints.push(new Point(153, 229));
mPoints.push(null);
mPoints.push(new Point(153, 240));
mPoints.push(new Point(175, 231));
mPoints.push(new Point(190, 232));
mPoints.push(new Point(199, 238));
mPoints.push(null);
mPoints.push(new Point(202, 288));
mPoints.push(new Point(215, 240));
mPoints.push(null);
mPoints.push(new Point(221, 222));
mPoints.push(new Point(230, 216));
mPoints.push(null);
mPoints.push(new Point(237, 261));
mPoints.push(new Point(280, 254));
mPoints.push(new Point(269, 239));
mPoints.push(new Point(249, 230));
mPoints.push(new Point(237, 263));
mPoints.push(new Point(267, 291));
mPoints.push(new Point(288, 274));
mPoints.push(null);
mPoints.push(new Point(296, 290));
mPoints.push(new Point(327, 188));
mPoints.push(null);
mPoints.push(new Point(464, 394));
mPoints.push(new Point(406, 366));
mPoints.push(new Point(381, 304));
mPoints.push(new Point(397, 254));
mPoints.push(new Point(431, 221));
mPoints.push(new Point(445, 274));
mPoints.push(new Point(405, 300));
mPoints.push(new Point(351, 412));
mPoints.push(new Point(380, 407));
mPoints.push(new Point(413, 387));
mPoints.push(new Point(451, 361));
mPoints.push(new Point(458, 349));
mPoints.push(null);
mPoints.push(new Point(420, 536));
mPoints.push(new Point(446, 421));
mPoints.push(new Point(460, 479));
mPoints.push(null);
mPoints.push(new Point(512, 413));
mPoints.push(new Point(496, 548));
mPoints.push(null);
mPoints.push(new Point(512, 415));
mPoints.push(new Point(461, 479));
mPoints.push(null);
mPoints.push(new Point(516, 540));
mPoints.push(new Point(552, 461));
mPoints.push(new Point(573, 550));
mPoints.push(null);
mPoints.push(new Point(530, 511));
mPoints.push(new Point(566, 515));
mPoints.push(null);
mPoints.push(new Point(592, 463));
mPoints.push(new Point(595, 533));
mPoints.push(null);
mPoints.push(new Point(617, 557));
mPoints.push(new Point(650, 547));
mPoints.push(new Point(657, 510));
mPoints.push(new Point(658, 456));
mPoints.push(null);
mPoints.push(new Point(616, 559));
mPoints.push(new Point(596, 531));
mPoints.push(null);
mPoints.push(new Point(675, 468));
mPoints.push(new Point(671, 560));
mPoints.push(null);
mPoints.push(new Point(676, 483));
mPoints.push(new Point(703, 468));
mPoints.push(new Point(721, 479));
mPoints.push(null);
mPoints.push(new Point(763, 495));
mPoints.push(new Point(731, 497));
mPoints.push(new Point(686, 514));
mPoints.push(new Point(697, 545));
mPoints.push(new Point(717, 565));
mPoints.push(new Point(783, 548));
mPoints.push(new Point(793, 524));
mPoints.push(new Point(755, 492));
//End drawing
		}
		
	}

}