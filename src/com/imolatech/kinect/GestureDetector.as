package  
{
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.utils.Timer;
	
	public class GestureDetector extends MovieClip
	{
		public var righthandHorizontalMoveStep:Number;
		public var righthandVerticalMoveStep:Number;
		public var righthandDepthMoveStep:Number
		public var righthandXNew:Number;
		public var righthandYNew:Number;
		public var righthandZNew:Number;

		public var lefthandHorizontalMoveStep:Number;
		public var lefthandVerticalMoveStep:Number;
		public var lefthandDepthMoveStep:Number
		public var lefthandXNew:Number;
		public var lefthandYNew:Number;
		public var lefthandZNew:Number;		

		public var torsoHorizontalMoveStep:Number;
		public var torsoVerticalMoveStep:Number;
		public var torsoDepthMoveStep:Number
		public var torsoXNew:Number;
		public var torsoYNew:Number;
		public var torsoZNew:Number;
		
		public var theSelectedUser:User;
		
		public function GestureDetector(theSelectedUser:User) 
		{
			this.theSelectedUser = theSelectedUser;
		}
		
		public function detectStart():void
		{
			if(theSelectedUser !== null)
			{
				//右手点以及左右上下挥动的位移
				righthandXNew = theSelectedUser.rightHand.position.world.x;
				righthandYNew = theSelectedUser.rightHand.position.world.y;
				righthandZNew = theSelectedUser.rightHand.position.world.z;
				
				righthandHorizontalMoveStep = righthandXNew - valueHolder.righthandXOld;
				righthandVerticalMoveStep = righthandYNew - valueHolder.righthandYOld;
				righthandDepthMoveStep = righthandZNew - valueHolder.righthandZOld;
				
				valueHolder.righthandXOld = righthandXNew;
				valueHolder.righthandYOld = righthandYNew;
				valueHolder.righthandZOld = righthandZNew;
		
				//左手点以及左右上下挥动的位移
				lefthandXNew = theSelectedUser.leftHand.position.world.x;
				lefthandYNew = theSelectedUser.leftHand.position.world.y;
				lefthandZNew = theSelectedUser.leftHand.position.world.z;
				
				lefthandHorizontalMoveStep = lefthandXNew - valueHolder.lefthandXOld;
				lefthandVerticalMoveStep = lefthandYNew - valueHolder.lefthandYOld;
				lefthandDepthMoveStep = lefthandZNew - valueHolder.lefthandZOld;
				
				valueHolder.lefthandXOld = lefthandXNew;
				valueHolder.lefthandYOld = lefthandYNew;
				valueHolder.lefthandZOld = lefthandZNew;
		
				//躯干部位点以及左右上下挥动的位移，用以判断用户是否处于稳定站立状态
				torsoXNew = theSelectedUser.torso.position.world.x;
				torsoYNew = theSelectedUser.torso.position.world.y;
				torsoZNew = theSelectedUser.torso.position.world.z;
				
				torsoHorizontalMoveStep = torsoXNew - valueHolder.torsoXOld;
				torsoVerticalMoveStep = torsoYNew - valueHolder.torsoYOld;
				torsoDepthMoveStep = torsoZNew - valueHolder.torsoZOld;
				
				valueHolder.torsoXOld = torsoXNew;
				valueHolder.torsoYOld = torsoYNew;
				valueHolder.torsoZOld = torsoZNew;
				
				//判断是否右手向左挥动	
				if(righthandHorizontalMoveStep<-40 && Math.abs(righthandVerticalMoveStep)<35 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(valueHolder.idleTimer.running)
					{
						valueHolder.righthandMoveLeftSum = 0;
						valueHolder.righthandSwipeLeft = false;
						return
					}
					else
					{
						valueHolder.righthandMoveLeftSum++;
						if(valueHolder.righthandMoveLeftSum>2 && righthandDepthMoveStep>35)
						{
							valueHolder.righthandSwipeLeft = true;
							valueHolder.righthandMoveLeftSum = 0;
							valueHolder.idleTimer = new Timer(1000,1)
							valueHolder.idleTimer.start();
						}
					}
				}
				
				else
				{
					valueHolder.righthandMoveLeftSum=0;
					valueHolder.righthandSwipeLeft = false;
				}
				
				//判断是否右手向右挥动
				if(righthandHorizontalMoveStep>40 && Math.abs(righthandVerticalMoveStep)<35 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(valueHolder.idleTimer.running)
					{
						valueHolder.righthandMoveLeftSum = 0;
						valueHolder.righthandSwipeRight = false;
						return
					}
					else
					{
						valueHolder.righthandMoveRightSum++;
						if(valueHolder.righthandMoveRightSum>2 && righthandDepthMoveStep>35)
						{
							valueHolder.righthandSwipeRight = true;
							valueHolder.righthandMoveRightSum = 0;
							valueHolder.idleTimer = new Timer(1000,1)
							valueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					valueHolder.righthandMoveRightSum=0;
					valueHolder.righthandSwipeRight = false;
				}
				
				//判断是否右手向上挥动:有待改进，目前用户在做自燃动作时（比如用手扶眼镜），可能会误触发
				if(righthandVerticalMoveStep>40 && Math.abs(righthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(valueHolder.idleTimer.running)
					{
						valueHolder.righthandMoveLeftSum = 0;
						valueHolder.righthandSwipeUp = false;
						return
					}
					else
					{
						valueHolder.righthandMoveUpSum++;
						if(valueHolder.righthandMoveUpSum>2 && righthandDepthMoveStep>25)
						{
							valueHolder.righthandSwipeUp = true;
							valueHolder.righthandMoveUpSum = 0;
							valueHolder.idleTimer = new Timer(1000,1)
							valueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					valueHolder.righthandMoveUpSum=0;
					valueHolder.righthandSwipeUp = false;
				}
		
				//判断是否右手向下挥动
				if(righthandVerticalMoveStep<-40 && Math.abs(righthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(valueHolder.idleTimer.running)
					{
						valueHolder.righthandMoveLeftSum = 0;
						valueHolder.righthandSwipeDown = false;
						return
					}
					else
					{
						valueHolder.righthandMoveDownSum++;
						if(valueHolder.righthandMoveDownSum>2 && righthandDepthMoveStep>25 && theSelectedUser.rightHip.position.world.y > theSelectedUser.rightHand.position.world.y)
						{
							valueHolder.righthandSwipeDown = true;
							valueHolder.righthandMoveDownSum = 0;
							valueHolder.idleTimer = new Timer(1000,1)
							valueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					valueHolder.righthandMoveDownSum=0;
					valueHolder.righthandSwipeDown = false;
				}
		
				//判断是否左手向左挥动
				if(lefthandHorizontalMoveStep<-40 && Math.abs(lefthandVerticalMoveStep)<25 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(valueHolder.idleTimer.running)
					{
						valueHolder.righthandMoveLeftSum = 0;
						valueHolder.lefthandSwipeLeft = false;
						return
					}
					else
					{
						valueHolder.lefthandMoveLeftSum++;
						if(valueHolder.lefthandMoveLeftSum>2 && lefthandDepthMoveStep>35)
						{
							valueHolder.lefthandSwipeLeft = true;
							valueHolder.lefthandMoveLeftSum = 0;
							valueHolder.idleTimer = new Timer(1000,1)
							valueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					valueHolder.lefthandMoveLeftSum=0;
					valueHolder.lefthandSwipeLeft = false;
				}
		
				//判断是否左手向右挥动
				if(lefthandHorizontalMoveStep>40 && Math.abs(lefthandVerticalMoveStep)<25 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(valueHolder.idleTimer.running)
					{
						valueHolder.righthandMoveLeftSum = 0;
						valueHolder.lefthandSwipeRight = false;
						return
					}
					else
					{
						valueHolder.lefthandMoveRightSum++;
						if(valueHolder.lefthandMoveRightSum>2 && lefthandDepthMoveStep>35)
						{
							valueHolder.lefthandSwipeRight = true;
							valueHolder.lefthandMoveRightSum = 0;
							valueHolder.idleTimer = new Timer(1000,1)
							valueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					valueHolder.lefthandMoveRightSum=0;
					valueHolder.lefthandSwipeRight = false;
				}
		
				//判断是否左手向上挥动：有待改进，目前用户在做自燃动作时（比如用手扶眼镜），可能会误触发
				if(lefthandVerticalMoveStep>40 && Math.abs(lefthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(valueHolder.idleTimer.running)
					{
						valueHolder.righthandMoveLeftSum = 0;
						valueHolder.lefthandSwipeUp = false;
						return
					}
					else
					{
						valueHolder.lefthandMoveUpSum++;
						if(valueHolder.lefthandMoveUpSum>2 && lefthandDepthMoveStep>25)
						{
							valueHolder.lefthandSwipeUp = true;
							valueHolder.lefthandMoveUpSum = 0;
							valueHolder.idleTimer = new Timer(1000,1)
							valueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					valueHolder.lefthandMoveUpSum=0;
					valueHolder.lefthandSwipeUp = false;
				}
		
				//判断是否左手向下挥动
				if(lefthandVerticalMoveStep<-40 && Math.abs(lefthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(valueHolder.idleTimer.running)
					{
						valueHolder.righthandMoveLeftSum = 0;
						valueHolder.lefthandSwipeDown = false;
						return
					}
					else
					{
						valueHolder.lefthandMoveDownSum++;
						if(valueHolder.lefthandMoveDownSum>2 && lefthandDepthMoveStep>25 && theSelectedUser.leftHip.position.world.y > theSelectedUser.leftHand.position.world.y)
						{
							valueHolder.lefthandSwipeDown = true;
							valueHolder.lefthandMoveDownSum = 0;
							valueHolder.idleTimer = new Timer(1000,1)
							valueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					valueHolder.lefthandMoveDownSum=0;
					valueHolder.lefthandSwipeDown = false;
				}
			}
		}
	}
}
