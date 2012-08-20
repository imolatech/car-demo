package com.imolatech.kinect 
{
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint
	import com.imolatech.kinect.ValueHolder;
	
	public class JointSmoother {
		
		public var smoothedRighthandX:Number = 0;
		public var smoothedRighthandY:Number = 0;
		public var smoothedRighthandZ:Number = 0;
		public var smoothedLefthandX:Number = 0;
		public var smoothedLefthandY:Number = 0;
		public var smoothedLefthandZ:Number = 0;
		public var smoothedTorsoX:Number = 0;
		public var smoothedTorsoY:Number = 0;
		public var smoothedTorsoZ:Number = 0;
		public var righthandXSum:Number = 0;
		public var righthandYSum:Number = 0;
		public var righthandZSum:Number = 0;
		public var lefthandXSum:Number = 0;
		public var lefthandYSum:Number = 0;
		public var lefthandZSum:Number = 0;
		public var torsoXSum:Number = 0;
		public var torsoYSum:Number = 0;
		public var torsoZSum:Number = 0;
		
		public var theSelectedUser:User;
		public var smoothParameter:uint;
		
		public function JointSmoother(theSelectedUser:User, smoothParameter:uint)
		{
			this.theSelectedUser = theSelectedUser;
			this.smoothParameter = smoothParameter;
			if(theSelectedUser !== null)
			{
			ValueHolder.righthandXArray.push(theSelectedUser.rightHand.position.world.x);
			ValueHolder.righthandYArray.push(theSelectedUser.rightHand.position.world.y);
			ValueHolder.righthandZArray.push(theSelectedUser.rightHand.position.world.z);
			ValueHolder.lefthandXArray.push(theSelectedUser.leftHand.position.world.x);
			ValueHolder.lefthandYArray.push(theSelectedUser.leftHand.position.world.y);
			ValueHolder.lefthandZArray.push(theSelectedUser.leftHand.position.world.z);
			ValueHolder.torsoXArray.push(theSelectedUser.torso.position.world.x);
			ValueHolder.torsoYArray.push(theSelectedUser.torso.position.world.y);
			ValueHolder.torsoZArray.push(theSelectedUser.torso.position.world.z);
			
			var i:int;
			if(ValueHolder.righthandXArray.length == smoothParameter+1)
			{
				for(i=0;i<smoothParameter+1;i++)
				{
					righthandXSum = righthandXSum + ValueHolder.righthandXArray[i]
				}
				smoothedRighthandX = righthandXSum/(smoothParameter+1);
				ValueHolder.righthandXArray.shift();
			}
			if(ValueHolder.righthandYArray.length == smoothParameter+1)
			{
				for(i=0;i<smoothParameter+1;i++)
				{
					righthandYSum = righthandYSum + ValueHolder.righthandYArray[i]
				}
				smoothedRighthandY = righthandYSum/(smoothParameter+1)
				ValueHolder.righthandYArray.shift();
			}
			if(ValueHolder.righthandZArray.length == smoothParameter+1)
			{
				for(i=0;i<smoothParameter+1;i++)
				{
					righthandZSum = righthandZSum + ValueHolder.righthandZArray[i]
				}
				smoothedRighthandZ = righthandZSum/(smoothParameter+1)
				ValueHolder.righthandZArray.shift();
			}
			if(ValueHolder.lefthandXArray.length == smoothParameter+1)
			{
				for(i=0;i<smoothParameter+1;i++)
				{
					lefthandXSum = lefthandXSum + ValueHolder.lefthandXArray[i]
				}
				smoothedLefthandX = lefthandXSum/(smoothParameter+1)
				ValueHolder.lefthandXArray.shift();
			}
			if(ValueHolder.lefthandYArray.length == smoothParameter+1)
			{
				for(i=0;i<smoothParameter+1;i++)
				{
					lefthandYSum = lefthandYSum + ValueHolder.lefthandYArray[i]
				}
				smoothedLefthandY = lefthandYSum/(smoothParameter+1)
				ValueHolder.lefthandYArray.shift();
			}
			if(ValueHolder.lefthandZArray.length == smoothParameter+1)
			{
				for(i=0;i<smoothParameter+1;i++)
				{
					lefthandZSum = lefthandZSum + ValueHolder.lefthandZArray[i]
				}
				smoothedLefthandZ = lefthandZSum/(smoothParameter+1)
				ValueHolder.lefthandZArray.shift();
			}
			if(ValueHolder.torsoXArray.length == smoothParameter+1)
			{
				for(i=0;i<smoothParameter+1;i++)
				{
					torsoXSum = torsoXSum + ValueHolder.torsoXArray[i]
				}
				smoothedTorsoX = torsoXSum/(smoothParameter+1);
				ValueHolder.torsoXArray.shift();
			}
			if(ValueHolder.torsoYArray.length == smoothParameter+1)
			{
				for(i=0;i<smoothParameter+1;i++)
				{
					torsoYSum = torsoYSum + ValueHolder.torsoYArray[i]
				}
				smoothedTorsoY = torsoYSum/(smoothParameter+1)
				ValueHolder.torsoYArray.shift();
			}
			if(ValueHolder.torsoZArray.length == smoothParameter+1)
			{
				for(i=0;i<smoothParameter+1;i++)
				{
					torsoZSum = torsoZSum + ValueHolder.torsoZArray[i]
				}
				smoothedTorsoZ = torsoZSum/(smoothParameter+1)
				ValueHolder.torsoZArray.shift();
			}
			}
		}

	}
	
}
