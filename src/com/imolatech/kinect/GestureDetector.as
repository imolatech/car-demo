package src.com.imolatech.kinect
{
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint;
	import src.com.imolatech.kinect.ValueHolder;
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
				
				righthandHorizontalMoveStep = righthandXNew - ValueHolder.righthandXOld;
				righthandVerticalMoveStep = righthandYNew - ValueHolder.righthandYOld;
				righthandDepthMoveStep = righthandZNew - ValueHolder.righthandZOld;
				
				ValueHolder.righthandXOld = righthandXNew;
				ValueHolder.righthandYOld = righthandYNew;
				ValueHolder.righthandZOld = righthandZNew;
		
				//左手点以及左右上下挥动的位移
				lefthandXNew = theSelectedUser.leftHand.position.world.x;
				lefthandYNew = theSelectedUser.leftHand.position.world.y;
				lefthandZNew = theSelectedUser.leftHand.position.world.z;
				
				lefthandHorizontalMoveStep = lefthandXNew - ValueHolder.lefthandXOld;
				lefthandVerticalMoveStep = lefthandYNew - ValueHolder.lefthandYOld;
				lefthandDepthMoveStep = lefthandZNew - ValueHolder.lefthandZOld;
				
				ValueHolder.lefthandXOld = lefthandXNew;
				ValueHolder.lefthandYOld = lefthandYNew;
				ValueHolder.lefthandZOld = lefthandZNew;
		
				//躯干部位点以及左右上下挥动的位移，用以判断用户是否处于稳定站立状态
				torsoXNew = theSelectedUser.torso.position.world.x;
				torsoYNew = theSelectedUser.torso.position.world.y;
				torsoZNew = theSelectedUser.torso.position.world.z;
				
				torsoHorizontalMoveStep = torsoXNew - ValueHolder.torsoXOld;
				torsoVerticalMoveStep = torsoYNew - ValueHolder.torsoYOld;
				torsoDepthMoveStep = torsoZNew - ValueHolder.torsoZOld;
				
				ValueHolder.torsoXOld = torsoXNew;
				ValueHolder.torsoYOld = torsoYNew;
				ValueHolder.torsoZOld = torsoZNew;
				
				//判断是否右手向左挥动	
				if(righthandHorizontalMoveStep<-40 && Math.abs(righthandVerticalMoveStep)<35 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(ValueHolder.idleTimer.running)
					{
						ValueHolder.righthandMoveLeftSum = 0;
						ValueHolder.righthandSwipeLeft = false;
						return
					}
					else
					{
						ValueHolder.righthandMoveLeftSum++;
						if(ValueHolder.righthandMoveLeftSum>2 && righthandDepthMoveStep>35)
						{
							ValueHolder.righthandSwipeLeft = true;
							ValueHolder.righthandMoveLeftSum = 0;
							ValueHolder.idleTimer = new Timer(1000,1)
							ValueHolder.idleTimer.start();
						}
					}
				}
				
				else
				{
					ValueHolder.righthandMoveLeftSum=0;
					ValueHolder.righthandSwipeLeft = false;
				}
				
				//判断是否右手向右挥动
				if(righthandHorizontalMoveStep>40 && Math.abs(righthandVerticalMoveStep)<35 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(ValueHolder.idleTimer.running)
					{
						ValueHolder.righthandMoveLeftSum = 0;
						ValueHolder.righthandSwipeRight = false;
						return
					}
					else
					{
						ValueHolder.righthandMoveRightSum++;
						if(ValueHolder.righthandMoveRightSum>2 && righthandDepthMoveStep>35)
						{
							ValueHolder.righthandSwipeRight = true;
							ValueHolder.righthandMoveRightSum = 0;
							ValueHolder.idleTimer = new Timer(1000,1)
							ValueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					ValueHolder.righthandMoveRightSum=0;
					ValueHolder.righthandSwipeRight = false;
				}
				
				//判断是否右手向上挥动:有待改进，目前用户在做自燃动作时（比如用手扶眼镜），可能会误触发
				if(righthandVerticalMoveStep>40 && Math.abs(righthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(ValueHolder.idleTimer.running)
					{
						ValueHolder.righthandMoveLeftSum = 0;
						ValueHolder.righthandSwipeUp = false;
						return
					}
					else
					{
						ValueHolder.righthandMoveUpSum++;
						if(ValueHolder.righthandMoveUpSum>2 && righthandDepthMoveStep>25)
						{
							ValueHolder.righthandSwipeUp = true;
							ValueHolder.righthandMoveUpSum = 0;
							ValueHolder.idleTimer = new Timer(1000,1)
							ValueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					ValueHolder.righthandMoveUpSum=0;
					ValueHolder.righthandSwipeUp = false;
				}
		
				//判断是否右手向下挥动
				if(righthandVerticalMoveStep<-40 && Math.abs(righthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(ValueHolder.idleTimer.running)
					{
						ValueHolder.righthandMoveLeftSum = 0;
						ValueHolder.righthandSwipeDown = false;
						return
					}
					else
					{
						ValueHolder.righthandMoveDownSum++;
						if(ValueHolder.righthandMoveDownSum>2 && righthandDepthMoveStep>25 && theSelectedUser.rightHip.position.world.y > theSelectedUser.rightHand.position.world.y)
						{
							ValueHolder.righthandSwipeDown = true;
							ValueHolder.righthandMoveDownSum = 0;
							ValueHolder.idleTimer = new Timer(1000,1)
							ValueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					ValueHolder.righthandMoveDownSum=0;
					ValueHolder.righthandSwipeDown = false;
				}
		
				//判断是否左手向左挥动
				if(lefthandHorizontalMoveStep<-40 && Math.abs(lefthandVerticalMoveStep)<25 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(ValueHolder.idleTimer.running)
					{
						ValueHolder.righthandMoveLeftSum = 0;
						ValueHolder.lefthandSwipeLeft = false;
						return
					}
					else
					{
						ValueHolder.lefthandMoveLeftSum++;
						if(ValueHolder.lefthandMoveLeftSum>2 && lefthandDepthMoveStep>35)
						{
							ValueHolder.lefthandSwipeLeft = true;
							ValueHolder.lefthandMoveLeftSum = 0;
							ValueHolder.idleTimer = new Timer(1000,1)
							ValueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					ValueHolder.lefthandMoveLeftSum=0;
					ValueHolder.lefthandSwipeLeft = false;
				}
		
				//判断是否左手向右挥动
				if(lefthandHorizontalMoveStep>40 && Math.abs(lefthandVerticalMoveStep)<25 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(ValueHolder.idleTimer.running)
					{
						ValueHolder.righthandMoveLeftSum = 0;
						ValueHolder.lefthandSwipeRight = false;
						return
					}
					else
					{
						ValueHolder.lefthandMoveRightSum++;
						if(ValueHolder.lefthandMoveRightSum>2 && lefthandDepthMoveStep>35)
						{
							ValueHolder.lefthandSwipeRight = true;
							ValueHolder.lefthandMoveRightSum = 0;
							ValueHolder.idleTimer = new Timer(1000,1)
							ValueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					ValueHolder.lefthandMoveRightSum=0;
					ValueHolder.lefthandSwipeRight = false;
				}
		
				//判断是否左手向上挥动：有待改进，目前用户在做自然动作时（比如用手扶眼镜），可能会误触发
				if(lefthandVerticalMoveStep>40 && Math.abs(lefthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(ValueHolder.idleTimer.running)
					{
						ValueHolder.righthandMoveLeftSum = 0;
						ValueHolder.lefthandSwipeUp = false;
						return
					}
					else
					{
						ValueHolder.lefthandMoveUpSum++;
						if(ValueHolder.lefthandMoveUpSum>2 && lefthandDepthMoveStep>25)
						{
							ValueHolder.lefthandSwipeUp = true;
							ValueHolder.lefthandMoveUpSum = 0;
							ValueHolder.idleTimer = new Timer(1000,1)
							ValueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					ValueHolder.lefthandMoveUpSum=0;
					ValueHolder.lefthandSwipeUp = false;
				}
		
				//判断是否左手向下挥动
				if(lefthandVerticalMoveStep<-40 && Math.abs(lefthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(ValueHolder.idleTimer.running)
					{
						ValueHolder.righthandMoveLeftSum = 0;
						ValueHolder.lefthandSwipeDown = false;
						return
					}
					else
					{
						ValueHolder.lefthandMoveDownSum++;
						if(ValueHolder.lefthandMoveDownSum>2 && lefthandDepthMoveStep>25 && theSelectedUser.leftHip.position.world.y > theSelectedUser.leftHand.position.world.y)
						{
							ValueHolder.lefthandSwipeDown = true;
							ValueHolder.lefthandMoveDownSum = 0;
							ValueHolder.idleTimer = new Timer(1000,1)
							ValueHolder.idleTimer.start();
						}
					}
				}
				else
				{
					ValueHolder.lefthandMoveDownSum=0;
					ValueHolder.lefthandSwipeDown = false;
				}
			}
		}
	}
}