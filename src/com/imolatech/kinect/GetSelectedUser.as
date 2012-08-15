package  
{
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	
	public class getSelectedUser extends Sprite
	{
		public var kinect:Kinect
		public var theSelectedUser:User;
		public var theSelectedUserIds:Vector.<uint> = new Vector.<uint>(1);
		public var skeletonContainer:Sprite;
		
		public function getSelectedUser(kinect:Kinect) 
		{
			this.kinect = kinect;
			if(theSelectedUser !== null)
			{
				if(theSelectedUser.position.world.z< main.sensorDistance || theSelectedUser.position.world.z>main.sensorDistance+1000 || theSelectedUser.position.world.x<-450 || theSelectedUser.position.world.x>450)
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
					if(user.position.world.z>main.sensorDistance && user.position.world.z<main.sensorDistance+1000 && user.position && user.position.world.x>-500 && user.position.world.x<500)
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
		
		public function displaySelectedUser(skeletonContainer:Sprite)
		{
			this.skeletonContainer = skeletonContainer
			skeletonContainer.graphics.clear();
			if(theSelectedUser !==null)
			{
				for each(var joint:SkeletonJoint in theSelectedUser.skeletonJoints)
				{
					skeletonContainer.graphics.beginFill(0x00FC00);
					//graphics.drawCircle(joint.position.rgbRelative.x*stage.stageWidth, joint.position.rgbRelative.y*stage.stageHeight, 4);
					skeletonContainer.graphics.drawCircle(300,300, 4);
					skeletonContainer.graphics.endFill();
				}
			}
		}
	}
}