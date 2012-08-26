package com.imolatech.kinect
{
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.utils.Timer;
	
	public class GestureDetector extends MovieClip
	{
		private var righthandHorizontalMoveStep:Number;
		private var righthandVerticalMoveStep:Number;
		private var righthandDepthMoveStep:Number
		private var righthandXNew:Number;
		private var righthandYNew:Number;
		private var righthandZNew:Number;
		private var righthandXOld:Number = 0;
		private var righthandYOld:Number = 0;
		private var righthandZOld:Number = 0;
		private var righthandMoveLeftSum:Number = 0;
		private var righthandMoveRightSum:Number = 0;
		private var righthandMoveUpSum:Number = 0;
		private var righthandMoveDownSum:Number = 0;
		private var righthandSwipeLeft:Boolean;
		private var righthandSwipeRight:Boolean;
		private var righthandSwipeUp:Boolean;
		private var righthandSwipeDown:Boolean;
		private var righthandWave:Boolean;
		private var righthandPrePosition:Number = 0;
		private var righthandWaveSum:Number = 0;

		private var lefthandHorizontalMoveStep:Number;
		private var lefthandVerticalMoveStep:Number;
		private var lefthandDepthMoveStep:Number
		private var lefthandXNew:Number;
		private var lefthandYNew:Number;
		private var lefthandZNew:Number;	
		private var lefthandXOld:Number = 0;
		private var lefthandYOld:Number = 0;
		private var lefthandZOld:Number = 0;	
		private var lefthandMoveLeftSum:Number = 0;
		private var lefthandMoveRightSum:Number = 0;
		private var lefthandMoveUpSum:Number = 0;
		private var lefthandMoveDownSum:Number = 0;
		private var lefthandSwipeLeft:Boolean;
		private var lefthandSwipeRight:Boolean;
		private var lefthandSwipeUp:Boolean;
		private var lefthandSwipeDown:Boolean;
		private var lefthandWave:Boolean;

		private var torsoHorizontalMoveStep:Number;
		private var torsoVerticalMoveStep:Number;
		private var torsoDepthMoveStep:Number
		private var torsoXNew:Number;
		private var torsoYNew:Number;
		private var torsoZNew:Number;
		private var torsoXOld:Number = 0;
		private var torsoYOld:Number = 0;
		private var torsoZOld:Number = 0;
		
		private var idleTimer:Timer = new Timer(1000,1);
		private var waveTimer:Timer = new Timer(1000,1);
		
		private var theSelectedUser:User;
		
		public function GestureDetector(theSelectedUser:User) 
		{
			this.theSelectedUser = theSelectedUser;
		}
		
		public function detectSwipe():void
		{
			if(theSelectedUser !== null)
			{
				//右手点以及左右上下挥动的位移
				righthandXNew = theSelectedUser.rightHand.position.world.x;
				righthandYNew = theSelectedUser.rightHand.position.world.y;
				righthandZNew = theSelectedUser.rightHand.position.world.z;
				
				righthandHorizontalMoveStep = righthandXNew - righthandXOld;
				righthandVerticalMoveStep = righthandYNew - righthandYOld;
				righthandDepthMoveStep = righthandZNew - righthandZOld;
				
				righthandXOld = righthandXNew;
				righthandYOld = righthandYNew;
				righthandZOld = righthandZNew;
		
				//左手点以及左右上下挥动的位移
				lefthandXNew = theSelectedUser.leftHand.position.world.x;
				lefthandYNew = theSelectedUser.leftHand.position.world.y;
				lefthandZNew = theSelectedUser.leftHand.position.world.z;
				
				lefthandHorizontalMoveStep = lefthandXNew - lefthandXOld;
				lefthandVerticalMoveStep = lefthandYNew - lefthandYOld;
				lefthandDepthMoveStep = lefthandZNew - lefthandZOld;
				
				lefthandXOld = lefthandXNew;
				lefthandYOld = lefthandYNew;
				lefthandZOld = lefthandZNew;
		
				//躯干部位点以及左右上下挥动的位移，用以判断用户是否处于稳定站立状态
				torsoXNew = theSelectedUser.torso.position.world.x;
				torsoYNew = theSelectedUser.torso.position.world.y;
				torsoZNew = theSelectedUser.torso.position.world.z;
				
				torsoHorizontalMoveStep = torsoXNew - torsoXOld;
				torsoVerticalMoveStep = torsoYNew - torsoYOld;
				torsoDepthMoveStep = torsoZNew - torsoZOld;
				
				torsoXOld = torsoXNew;
				torsoYOld = torsoYNew;
				torsoZOld = torsoZNew;
				
				//判断是否右手向左挥动	
				if(righthandHorizontalMoveStep<-40 && Math.abs(righthandVerticalMoveStep)<35 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(idleTimer.running)
					{
						righthandMoveLeftSum = 0;
						righthandSwipeLeft = false;
						return
					}
					else
					{
						righthandMoveLeftSum++;
						if(righthandMoveLeftSum>2 && righthandDepthMoveStep>35)
						{
							righthandSwipeLeft = true;
							righthandMoveLeftSum = 0;
							idleTimer = new Timer(1000,1)
							idleTimer.start();
						}
					}
				}
				
				else
				{
					righthandMoveLeftSum=0;
					righthandSwipeLeft = false;
				}
				
				//判断是否右手向右挥动
				if(righthandHorizontalMoveStep>40 && Math.abs(righthandVerticalMoveStep)<35 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(idleTimer.running)
					{
						righthandMoveRightSum = 0;
						righthandSwipeRight = false;
						return
					}
					else
					{
						righthandMoveRightSum++;
						if(righthandMoveRightSum>2 && righthandDepthMoveStep>35)
						{
							righthandSwipeRight = true;
							righthandMoveRightSum = 0;
							idleTimer = new Timer(1000,1)
							idleTimer.start();
						}
					}
				}
				else
				{
					righthandMoveRightSum=0;
					righthandSwipeRight = false;
				}
				
				//判断是否右手向上挥动:有待改进，目前用户在做自燃动作时（比如用手扶眼镜），可能会误触发
				if(righthandVerticalMoveStep>40 && Math.abs(righthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(idleTimer.running)
					{
						righthandMoveLeftSum = 0;
						righthandSwipeUp = false;
						return
					}
					else
					{
						righthandMoveUpSum++;
						if(righthandMoveUpSum>2 && righthandDepthMoveStep>25)
						{
							righthandSwipeUp = true;
							righthandMoveUpSum = 0;
							idleTimer = new Timer(1000,1)
							idleTimer.start();
						}
					}
				}
				else
				{
					righthandMoveUpSum=0;
					righthandSwipeUp = false;
				}
		
				//判断是否右手向下挥动
				if(righthandVerticalMoveStep<-40 && Math.abs(righthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(idleTimer.running)
					{
						righthandMoveLeftSum = 0;
						righthandSwipeDown = false;
						return
					}
					else
					{
						righthandMoveDownSum++;
						if(righthandMoveDownSum>2 && righthandDepthMoveStep>25 && theSelectedUser.rightHip.position.world.y > theSelectedUser.rightHand.position.world.y)
						{
							righthandSwipeDown = true;
							righthandMoveDownSum = 0;
							idleTimer = new Timer(1000,1)
							idleTimer.start();
						}
					}
				}
				else
				{
					righthandMoveDownSum=0;
					righthandSwipeDown = false;
				}
		
				//判断是否左手向左挥动
				if(lefthandHorizontalMoveStep<-40 && Math.abs(lefthandVerticalMoveStep)<25 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(idleTimer.running)
					{
						righthandMoveLeftSum = 0;
						lefthandSwipeLeft = false;
						return
					}
					else
					{
						lefthandMoveLeftSum++;
						if(lefthandMoveLeftSum>2 && lefthandDepthMoveStep>35)
						{
							lefthandSwipeLeft = true;
							lefthandMoveLeftSum = 0;
							idleTimer = new Timer(1000,1)
							idleTimer.start();
						}
					}
				}
				else
				{
					lefthandMoveLeftSum=0;
					lefthandSwipeLeft = false;
				}
		
				//判断是否左手向右挥动
				if(lefthandHorizontalMoveStep>40 && Math.abs(lefthandVerticalMoveStep)<25 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(idleTimer.running)
					{
						righthandMoveLeftSum = 0;
						lefthandSwipeRight = false;
						return
					}
					else
					{
						lefthandMoveRightSum++;
						if(lefthandMoveRightSum>2 && lefthandDepthMoveStep>35)
						{
							lefthandSwipeRight = true;
							lefthandMoveRightSum = 0;
							idleTimer = new Timer(1000,1)
							idleTimer.start();
						}
					}
				}
				else
				{
					lefthandMoveRightSum=0;
					lefthandSwipeRight = false;
				}
		
				//判断是否左手向上挥动：有待改进，目前用户在做自然动作时（比如用手扶眼镜），可能会误触发
				if(lefthandVerticalMoveStep>40 && Math.abs(lefthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(idleTimer.running)
					{
						righthandMoveLeftSum = 0;
						lefthandSwipeUp = false;
						return
					}
					else
					{
						lefthandMoveUpSum++;
						if(lefthandMoveUpSum>2 && lefthandDepthMoveStep>25)
						{
							lefthandSwipeUp = true;
							lefthandMoveUpSum = 0;
							idleTimer = new Timer(1000,1)
							idleTimer.start();
						}
					}
				}
				else
				{
					lefthandMoveUpSum=0;
					lefthandSwipeUp = false;
				}
		
				//判断是否左手向下挥动
				if(lefthandVerticalMoveStep<-40 && Math.abs(lefthandHorizontalMoveStep)<30 && Math.abs(torsoHorizontalMoveStep)<10 &&  Math.abs(torsoVerticalMoveStep)<10)
				{
					if(idleTimer.running)
					{
						righthandMoveLeftSum = 0;
						lefthandSwipeDown = false;
						return
					}
					else
					{
						lefthandMoveDownSum++;
						if(lefthandMoveDownSum>2 && lefthandDepthMoveStep>25 && theSelectedUser.leftHip.position.world.y > theSelectedUser.leftHand.position.world.y)
						{
							lefthandSwipeDown = true;
							lefthandMoveDownSum = 0;
							idleTimer = new Timer(1000,1)
							idleTimer.start();
						}
					}
				}
				else
				{
					lefthandMoveDownSum=0;
					lefthandSwipeDown = false;
				}
			}
		}
		
		public function detectWave():void
		{
			if(theSelectedUser !== null)
			{
				
				if(waveTimer.running == false)
				{
					righthandWaveSum = 0;
				}
				
				if(righthandWaveSum ==4)
				{
					righthandWaveSum = 0;
					righthandWave = true;
					idleTimer.start();
				}
				else
				{
					righthandWave = false;
				}
				
				if(waveTimer.running == false && idleTimer.running == false)
				{
					if(theSelectedUser.rightHand.position.world.x - theSelectedUser.rightElbow.position.world.x < -50 && righthandPrePosition == 0)
					{
						righthandPrePosition = 1;
					}
					if(theSelectedUser.rightHand.position.world.x - theSelectedUser.rightElbow.position.world.x > 30 && righthandPrePosition == 0)
					{
						righthandPrePosition = 2;
					}
					if(theSelectedUser.rightHand.position.world.x - theSelectedUser.rightElbow.position.world.x < -50 && righthandPrePosition == 2)
					{
						righthandPrePosition = 1;
						righthandWaveSum++;
						waveTimer.start();
					}
					if(theSelectedUser.rightHand.position.world.x - theSelectedUser.rightElbow.position.world.x > 30 && righthandPrePosition == 1)
					{
						righthandPrePosition = 2;
						righthandWaveSum++;
						waveTimer.start();
					}
				}
				
				if(waveTimer.running == true && idleTimer.running == false)
				{
					if(theSelectedUser.rightHand.position.world.x - theSelectedUser.rightElbow.position.world.x < -50 && righthandPrePosition == 2)
					{
						righthandPrePosition = 1;
						righthandWaveSum++;
						waveTimer.stop();
						waveTimer.reset();
						waveTimer.start();
					}
					if(theSelectedUser.rightHand.position.world.x - theSelectedUser.rightElbow.position.world.x > 30 && righthandPrePosition == 1)
					{
						righthandPrePosition = 2;
						righthandWaveSum++;
						waveTimer.stop();
						waveTimer.reset();
						waveTimer.start();
					}
				}
			}
		}
		public function get righthandGoLeft():Boolean
		{
			return righthandSwipeLeft;
		}
		public function get righthandGoRight():Boolean
		{
			return righthandSwipeRight;
		}
		public function get righthandGoUp():Boolean
		{
			return righthandSwipeUp;
		}
		public function get righthandGoDown():Boolean
		{
			return righthandSwipeDown;
		}
		public function get lefthandGoLeft():Boolean
		{
			return lefthandSwipeLeft;
		}
		public function get lefthandGoRight():Boolean
		{
			return lefthandSwipeRight;
		}
		public function get lefthandGoUp():Boolean
		{
			return lefthandSwipeUp;
		}
		public function get lefthandGoDown():Boolean
		{
			return lefthandSwipeDown;
		}
		public function get rightWave():Boolean
		{
			return righthandWave;
		}
	}
}