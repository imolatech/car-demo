package com.imolatech.kinect 
{
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint
	
	public class JointSmoother 
	{
		
		private var smoothedRighthandX:Number = 0;
		private var smoothedRighthandY:Number = 0;
		private var smoothedRighthandZ:Number = 0;
		private var smoothedLefthandX:Number = 0;
		private var smoothedLefthandY:Number = 0;
		private var smoothedLefthandZ:Number = 0;
		private var smoothedTorsoX:Number = 0;
		private var smoothedTorsoY:Number = 0;
		private var smoothedTorsoZ:Number = 0;
		private var righthandXSum:Number = 0;
		private var righthandYSum:Number = 0;
		private var righthandZSum:Number = 0;
		private var lefthandXSum:Number = 0;
		private var lefthandYSum:Number = 0;
		private var lefthandZSum:Number = 0;
		private var torsoXSum:Number = 0;
		private var torsoYSum:Number = 0;
		private var torsoZSum:Number = 0;
		private var righthandXArray:Array = new Array();
		private var righthandYArray:Array = new Array();
		private var righthandZArray:Array = new Array();
		private var lefthandXArray:Array = new Array();
		private var lefthandYArray:Array = new Array();
		private var lefthandZArray:Array = new Array();
		private var torsoXArray:Array = new Array();
		private var torsoYArray:Array = new Array();
		private var torsoZArray:Array = new Array();
		
		private var theSelectedUser:User;
		private var smoothParameter:uint;
		
		public function JointSmoother(theSelectedUser:User, smoothParameter:uint)
		{
			this.theSelectedUser = theSelectedUser;
			this.smoothParameter = smoothParameter;
		}

		public function smoothJoints():void
		{
			if(theSelectedUser !== null)
			{
				righthandXArray.push(theSelectedUser.rightHand.position.world.x);
				righthandYArray.push(theSelectedUser.rightHand.position.world.y);
				righthandZArray.push(theSelectedUser.rightHand.position.world.z);
				lefthandXArray.push(theSelectedUser.leftHand.position.world.x);
				lefthandYArray.push(theSelectedUser.leftHand.position.world.y);
				lefthandZArray.push(theSelectedUser.leftHand.position.world.z);
				torsoXArray.push(theSelectedUser.torso.position.world.x);
				torsoYArray.push(theSelectedUser.torso.position.world.y);
				torsoZArray.push(theSelectedUser.torso.position.world.z);
			
				var i:int;
				if(righthandXArray.length == smoothParameter+1)
				{
					for(i=0;i<smoothParameter+1;i++)
					{
						righthandXSum = righthandXSum + righthandXArray[i];
					}
					smoothedRighthandX = righthandXSum/(smoothParameter+1);
					righthandXArray.shift();
					righthandXSum = 0;
				}
				if(righthandYArray.length == smoothParameter+1)
				{
					for(i=0;i<smoothParameter+1;i++)
					{
						righthandYSum = righthandYSum + righthandYArray[i];
					}
					smoothedRighthandY = righthandYSum/(smoothParameter+1)
					righthandYArray.shift();
					righthandYSum = 0;
				}
				if(righthandZArray.length == smoothParameter+1)
				{
					for(i=0;i<smoothParameter+1;i++)
					{
						righthandZSum = righthandZSum + righthandZArray[i];
					}
					smoothedRighthandZ = righthandZSum/(smoothParameter+1)
					righthandZArray.shift();
					righthandZSum = 0;
				}
				if(lefthandXArray.length == smoothParameter+1)
				{
					for(i=0;i<smoothParameter+1;i++)
					{
						lefthandXSum = lefthandXSum + lefthandXArray[i];
					}
					smoothedLefthandX = lefthandXSum/(smoothParameter+1)
					lefthandXArray.shift();
					lefthandXSum = 0;
				}
				if(lefthandYArray.length == smoothParameter+1)
				{
					for(i=0;i<smoothParameter+1;i++)
					{
						lefthandYSum = lefthandYSum + lefthandYArray[i];
					}
					smoothedLefthandY = lefthandYSum/(smoothParameter+1)
					lefthandYArray.shift();
					lefthandYSum = 0;
				}
				if(lefthandZArray.length == smoothParameter+1)
				{
					for(i=0;i<smoothParameter+1;i++)
					{
						lefthandZSum = lefthandZSum + lefthandZArray[i];
					}
					smoothedLefthandZ = lefthandZSum/(smoothParameter+1)
					lefthandZArray.shift();
					lefthandZSum = 0;
				}
				if(torsoXArray.length == smoothParameter+1)
				{
					for(i=0;i<smoothParameter+1;i++)
					{
						torsoXSum = torsoXSum + torsoXArray[i];
					}
					smoothedTorsoX = torsoXSum/(smoothParameter+1);
					torsoXArray.shift();
					torsoXSum = 0;
				}
				if(torsoYArray.length == smoothParameter+1)
				{
					for(i=0;i<smoothParameter+1;i++)
					{
						torsoYSum = torsoYSum + torsoYArray[i];
					}
					smoothedTorsoY = torsoYSum/(smoothParameter+1)
					torsoYArray.shift();
					torsoYSum = 0;
				}
				if(torsoZArray.length == smoothParameter+1)
				{
					for(i=0;i<smoothParameter+1;i++)
					{
						torsoZSum = torsoZSum + torsoZArray[i];
					}
					smoothedTorsoZ = torsoZSum/(smoothParameter+1)
					torsoZArray.shift();
					torsoZSum = 0;
				}
			}
		}

		public function get righthandX():Number
		{
			return smoothedRighthandX;
		}
		public function get righthandY():Number
		{
			return smoothedRighthandY;
		}
		public function get righthandZ():Number
		{
			return smoothedRighthandZ;
		}
		public function get lefthandX():Number
		{
			return smoothedLefthandX;
		}
		public function get lefthandY():Number
		{
			return smoothedLefthandY;
		}
		public function get lefthandZ():Number
		{
			return smoothedLefthandZ;
		}
		public function get torsoX():Number
		{
			return smoothedTorsoX;
		}
		public function get torsoY():Number
		{
			return smoothedTorsoY;
		}
		public function get torsoZ():Number
		{
			return smoothedTorsoZ;
		}
	}
	
}
