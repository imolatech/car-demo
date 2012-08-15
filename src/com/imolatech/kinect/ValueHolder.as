package  {
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.display.Sprite;
	
	public class valueHolder extends Sprite 
	{
		public static var righthandHorizontalMoveStep:Number;
		public static var righthandVerticalMoveStep:Number;
		public static var righthandDepthMoveStep:Number
		public static var righthandXOld:Number=0;
		public static var righthandYOld:Number=0;
		public static var righthandZOld:Number=0;
		public static var righthandMoveLeftSum:Number = 0;
		public static var righthandMoveRightSum:Number = 0;
		public static var righthandMoveUpSum:Number = 0;
		public static var righthandMoveDownSum:Number = 0;
		public static var righthandSwipeLeft:Boolean;
		public static var righthandSwipeRight:Boolean;
		public static var righthandSwipeUp:Boolean;
		public static var righthandSwipeDown:Boolean;
		public static var righthandWave:Boolean;
		
		public static var lefthandHorizontalMoveStep:Number;
		public static var lefthandVerticalMoveStep:Number;
		public static var lefthandDepthMoveStep:Number
		public static var lefthandXOld:Number=0;
		public static var lefthandYOld:Number=0;
		public static var lefthandZOld:Number=0;
		public static var lefthandMoveLeftSum:Number = 0;
		public static var lefthandMoveRightSum:Number = 0;
		public static var lefthandMoveUpSum:Number = 0;
		public static var lefthandMoveDownSum:Number = 0;
		public static var lefthandSwipeLeft:Boolean;
		public static var lefthandSwipeRight:Boolean;
		public static var lefthandSwipeUp:Boolean;
		public static var lefthandSwipeDown:Boolean;
		public static var lefthandWave:Boolean;
		

		public static var torsoHorizontalMoveStep:Number;
		public static var torsoVerticalMoveStep:Number;
		public static var torsoDepthMoveStep:Number;
		public static var torsoXOld:Number=0;
		public static var torsoYOld:Number=0;
		public static var torsoZOld:Number=0;

		public static var idleTimer:Timer = new Timer(1000,1);
		
		public function valueHolder() 
		{
		
		}
	}
}
