package com.imolatech.kinect 
{
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	
	public class UserSelector extends Sprite
	{
		private var kinect:Kinect
		private var theSelectedUser:User;
		private var theSelectedUserOld:User;
		private var theSelectedUserIds:Vector.<uint> = new Vector.<uint>(1);
		private var sensorDistance:Number = 2000;
		
		public function UserSelector(kinect:Kinect) 
		{
			this.kinect = kinect;
		}
		
		public function UserSelect():void
		{
			theSelectedUserOld = theSelectedUser;
			if(theSelectedUser !== null)
			{
				if(theSelectedUser.position.world.z < sensorDistance || theSelectedUser.position.world.z > sensorDistance+1000 || theSelectedUser.position.world.x<-450 || theSelectedUser.position.world.x>450)
				{
					theSelectedUser = null;
				}
			}
			if(kinect.usersWithSkeleton.length !== 0)
			{
				var userInAreaZ:Array = new Array();
				for each(var user:User in kinect.usersWithSkeleton)
				{
					//trace(345);
					//被选择人的范围为离kinect距离2000毫米至3000毫米之间，左右距离中心点500毫米之间的一个1平方米的区域
					if(user.position.world.z > sensorDistance && user.position.world.z < sensorDistance+1000 && user.position && user.position.world.x>-500 && user.position.world.x<500)
					{
						userInAreaZ.push(user.position.world.z);
						userInAreaZ.sort(Array.NUMERIC);
						if(user.position.world.z == userInAreaZ[0])
						{
							theSelectedUser = user;
							theSelectedUserIds[0] = user.trackingID;
						}
					}
				}
			}
		}
		
		public function get getTheSelectedUser():User
		{
			return theSelectedUser;
		}
		
		public function get distance():Number
		{
			return sensorDistance;
		}
		
		public function set distance(distance:Number):void
		{
			sensorDistance = distance;
		}
		
		public function get userChange():Boolean
		{
			if(theSelectedUser !== theSelectedUserOld)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
}