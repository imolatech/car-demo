package com.imolatech.cardemo
{
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;
	import com.as3nui.nativeExtensions.air.kinect.events.UserEvent;
	import com.imolatech.kinect.GestureDetector;
	import com.imolatech.kinect.UserSelector;
	import com.imolatech.kinect.ValueHolder;
	import com.imolatech.kinect.JointSmoother;
	import fl.video.*
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Loader
	import flash.events.MouseEvent;
	
	public class Maintwo extends MovieClip {
		//声明变量
		public var kinect:Kinect;
		public var kinectImageBmp:Bitmap;	//用于储存kinect图像的bmp
		public var skeletonContainer:Sprite;	//用于储存用户骨骼图形
		public var theSelectedUser:User		//被选中的用户
		public var getUser:UserSelector;	//外部类UserSelector的实例
		public var getGesture:GestureDetector;	//外部类GestureDetector的实例
		public var smoothedJoints:JointSmoother;	//外部类JointSmoother的实例
		public var generalkinectEventTimer:Timer = new Timer(50,0);	//单独为需要获取kinect数据的事件设置的Timer,由于kinect每秒最多提供30帧图像，为了保证稳定，这个Timer每秒只执行20次。
		public var interfaceOneKinectEventTimer:Timer = new Timer(50,0);
		public var interfaceTwoKinectEventTimer:Timer = new Timer(50,0);
		public var interfaceThreeKinectEventTimer:Timer = new Timer(50,0);
		public var kinectWindowWidth:Number = 320;	//kinect图像小窗口的宽度
		public var kinectWindowHeight:Number = 240;	//kinect图像小窗口的高度
		var vidList_XML:XML;
		var vidCount:int = 0;
		var vidXmlLoader:URLLoader = new URLLoader();
		
		public function Maintwo()
		{
			stage.scaleMode=StageScaleMode.SHOW_ALL;    //全部显示
			//首先检测是否支持kinect
			if(Kinect.isSupported())
			{
				kinect = Kinect.getDevice();
				var settings:KinectSettings = new KinectSettings();
				settings.depthEnabled = true;
				settings.rgbEnabled = true;
				settings.rgbResolution = CameraResolution.RESOLUTION_640_480;
				settings.skeletonEnabled = true;
				kinect.start(settings);
			}
			generalkinectEventTimer.addEventListener(TimerEvent.TIMER, generalKinectEvent);	//有关kinect数据的事件，使用timer，每秒执行20次
			generalkinectEventTimer.start();
			onCompleteInterfaceOne();
		}
		
		private function onCompleteInterfaceOne():void
		{
			if(currentFrame == 2)
			{
				interfaceTwoKinectImageWindow.removeChild(kinectImageBmp);
				interfaceTwoKinectImageWindow.removeChild(skeletonContainer);
				removeEventListener(Event.ENTER_FRAME, interfaceTwoEnterFrameHandler);		//flash每一帧都执行的事件
				interfaceTwoKinectEventTimer.removeEventListener(TimerEvent.TIMER, interfaceTwoKinectEvent);		//flash每一帧都执行的事件
				interfaceTwoKinectEventTimer.stop();
				interfaceTwoKinectEventTimer.reset();
			}
			if(currentFrame == 3)
			{
				removeEventListener(Event.ENTER_FRAME, interfaceThreeEnterFrameHandler);		//flash每一帧都执行的事件
				interfaceThreeKinectEventTimer.removeEventListener(TimerEvent.TIMER, interfaceThreeKinectEvent);		//flash每一帧都执行的事件
				interfaceThreeKinectEventTimer.stop();
				interfaceThreeKinectEventTimer.reset();
			}
			gotoAndStop(1);
			kinectImageBmp = new Bitmap;
			skeletonContainer = new Sprite();
			interfaceOneKinectImageWindow.addChild(kinectImageBmp);
			interfaceOneKinectImageWindow.addChild(skeletonContainer);
			kinect.addEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, rgbImageHandler);	//每当RGB图像更新时执行的事件
			addEventListener(Event.ENTER_FRAME, interfaceOneEnterFrameHandler);		//flash每一帧都执行的事件
			interfaceOneKinectEventTimer.addEventListener(TimerEvent.TIMER, interfaceOneKinectEvent);		//flash每一帧都执行的事件
			interfaceOneKinectEventTimer.start();
		}
		
		private function onCompleteInterfaceTwo():void
		{
			if(currentFrame == 1)
			{
				interfaceOneKinectImageWindow.removeChild(kinectImageBmp);
				interfaceOneKinectImageWindow.removeChild(skeletonContainer);
				removeEventListener(Event.ENTER_FRAME, interfaceOneEnterFrameHandler);
				interfaceOneKinectEventTimer.removeEventListener(TimerEvent.TIMER, interfaceOneKinectEvent);		//flash每一帧都执行的事件
			}
			gotoAndStop(2);
			kinectImageBmp = new Bitmap;
			skeletonContainer = new Sprite();
			interfaceTwoKinectImageWindow.addChild(kinectImageBmp);
			interfaceTwoKinectImageWindow.addChild(skeletonContainer);
			addEventListener(Event.ENTER_FRAME, interfaceTwoEnterFrameHandler);
			interfaceTwoKinectEventTimer.addEventListener(TimerEvent.TIMER, interfaceTwoKinectEvent);		//flash每一帧都执行的事件
			interfaceTwoKinectEventTimer.start();
		}

		private function onCompleteInterfaceThree():void
		{
			if(currentFrame == 1)
			{
				interfaceOneKinectImageWindow.removeChild(kinectImageBmp);
				interfaceOneKinectImageWindow.removeChild(skeletonContainer);
				removeEventListener(Event.ENTER_FRAME, interfaceOneEnterFrameHandler);
				interfaceOneKinectEventTimer.removeEventListener(TimerEvent.TIMER, interfaceOneKinectEvent);		//flash每一帧都执行的事件
			}
			if(currentFrame == 2)
			{
				interfaceTwoKinectImageWindow.removeChild(kinectImageBmp);
				interfaceTwoKinectImageWindow.removeChild(skeletonContainer);
				removeEventListener(Event.ENTER_FRAME, interfaceTwoEnterFrameHandler);
				interfaceTwoKinectEventTimer.removeEventListener(TimerEvent.TIMER, interfaceTwoKinectEvent);		//flash每一帧都执行的事件
			}
			gotoAndStop(3);
			addEventListener(Event.ENTER_FRAME, interfaceThreeEnterFrameHandler);
			interfaceThreeKinectEventTimer.addEventListener(TimerEvent.TIMER, interfaceThreeKinectEvent);		//flash每一帧都执行的事件
			interfaceThreeKinectEventTimer.start();
			
			vidPlayer.x = 0;
			vidPlayer.y = 0;
			vidPlayer.width = stage.stageWidth;
			vidPlayer.height = stage.stageHeight;
			vidXmlLoader.load(new URLRequest("app:/config/CarVideos.xml"))
			vidXmlLoader.addEventListener(Event.COMPLETE, vidXmlLoaded);
		}
		
		private function interfaceOneEnterFrameHandler(e:Event):void
		{
			
		}
		
		private function interfaceTwoEnterFrameHandler(e:Event):void
		{
			
		}
		
		private function interfaceThreeEnterFrameHandler(e:Event):void
		{
			
		}
		//以下是所有需要用到kinect数据的function
		private function generalKinectEvent(e:TimerEvent):void
		{
			getUser = new UserSelector(kinect);
			theSelectedUser = getUser.theSelectedUser;
			smoothedJoints = new JointSmoother(theSelectedUser, 8); //JointSmoother类，第一个参数为需要smooth的User, 第二个参数为smooth系数，从0到20均可
			getGesture = new GestureDetector(theSelectedUser);
			getGesture.detectWave();
			getGesture.detectSwipe();
		}
		
		private function interfaceOneKinectEvent(e:TimerEvent):void
		{
			skeletonContainer.graphics.clear();
			if(theSelectedUser !== null)
			{
				for each(var joint:SkeletonJoint in theSelectedUser.skeletonJoints)
				{
					skeletonContainer.graphics.beginFill(0x00FC00);
					skeletonContainer.graphics.drawCircle(joint.position.rgbRelative.x*kinectWindowWidth, joint.position.rgbRelative.y*kinectWindowHeight, 3);
					skeletonContainer.graphics.endFill();
				}
			}
			if(ValueHolder.righthandWave == true)
			{
				trace("WAVE!!!!!!!")
			}
		}
		
		private function interfaceTwoKinectEvent(e:TimerEvent):void
		{
			skeletonContainer.graphics.clear();
			if(theSelectedUser !== null)
			{
				for each(var joint:SkeletonJoint in theSelectedUser.skeletonJoints)
				{
					skeletonContainer.graphics.beginFill(0x00FC00);
					skeletonContainer.graphics.drawCircle(joint.position.rgbRelative.x*kinectWindowWidth, joint.position.rgbRelative.y*kinectWindowHeight, 3);
					skeletonContainer.graphics.endFill();
				}
			}
		}
		
		private function interfaceThreeKinectEvent(e:TimerEvent):void
		{
			if(theSelectedUser !== null)
			{
				
			}
		}
		
		//小窗口的kinect图像
		private function rgbImageHandler(event:CameraImageEvent):void
		{
			kinectImageBmp.bitmapData = event.imageData;
			kinectImageBmp.width = kinectWindowWidth;
			kinectImageBmp.height = kinectWindowHeight;
		}
		
		private function vidXmlLoaded(event:Event):void
		{
			vidList_XML = new XML(vidXmlLoader.data);
			vidPlayer.addEventListener(VideoEvent.COMPLETE, changeVid);
		}
			
		private	function changeVid(e:VideoEvent):void
		{
			var nextVid:String = vidList_XML.vid[vidCount].file;
			vidPlayer.source = nextVid;
			vidCount++;
		}
		
	}
	
}