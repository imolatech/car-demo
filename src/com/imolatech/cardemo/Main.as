package  {
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	import com.as3nui.nativeExtensions.air.kinect.data.SkeletonJoint
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.constants.CameraResolution;
	import com.as3nui.nativeExtensions.air.kinect.events.UserEvent;
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
	
	public class Main extends MovieClip {
		//声明变量
		public var kinect:Kinect;
		public var kinectImageBmp:Bitmap;	//用于储存kinect图像的bmp
		public var skeletonContainer:Sprite;	//用于储存用户骨骼图形
		public var theSelectedUser:User		//被选中的用户
		public var getUser:getSelectedUser;	//外部类getSelectedUser的实例
		public var getGesture:gestureDetector;	//外部类gestureDetector的实例

		//每个按键都单独设置了一个用于悬停的Timer，这里也许可以简化。
		public var hoverTimerc1:Timer=new Timer(hoverTime,1);
		public var hoverTimerc2:Timer=new Timer(hoverTime,1);
		public var hoverTimerc3:Timer=new Timer(hoverTime,1);
		public var hoverTimerc4:Timer=new Timer(hoverTime,1);
		public var hoverTimerc5:Timer=new Timer(hoverTime,1);
		public var hoverTimerm1:Timer=new Timer(hoverTime,1);
		public var hoverTimerm2:Timer=new Timer(hoverTime,1);
		public var hoverTimerm3:Timer=new Timer(hoverTime,1);
		public var hoverTimerm4:Timer=new Timer(hoverTime,1);
		public var hoverTimerm5:Timer=new Timer(hoverTime,1);
		public var hoverTimerm6:Timer=new Timer(hoverTime,1);
		public var hoverTimert1:Timer=new Timer(hoverTime,1);
		public var hoverTimert2:Timer=new Timer(hoverTime,1);

		public var kinectEventTimer:Timer = new Timer(50,0);	//单独为需要获取kinect数据的事件设置的Timer,由于kinect每秒最多提供30帧图像，为了保证稳定，这个Timer每秒只执行20次。

		public var picList_XML:XML;
		public var xmlLoader:URLLoader=new URLLoader();
		public var picLoader:Loader = new Loader();

		public var modelNum:Number=1;	//初始车型号码为1
		public var colorNum:Number=1;	//初始颜色号码为1
		public var tireNum:Number=1;	//初始轮胎号码为1
		public var picNum:Number=1;	//初始播放图片页数为1
		public var kinectWindowWidth:Number;	//kinect图像小窗口的宽度
		public var kinectWindowHeight:Number;	//kinect图像小窗口的高度
		public var colorHit:Number = 1;		//光标碰到的颜色按钮
		public var modelHit:Number = 1;		//光标碰到的车型按钮
		public var tireHit:Number = 1;			//光标碰到的轮胎按钮
		public var colorCircleChangetoX:Number;	//颜色按钮下面的绿圈移动到的新X坐标
		public var colorCircleChangetoY:Number;	//颜色按钮下面的绿圈移动到的新y坐标
		public var modelCircleChangetoX:Number;	//车型按钮下面的绿圈移动到的新X坐标
		public var modelCircleChangetoY:Number;	//车型按钮下面的绿圈移动到的新y坐标
		public var tireCircleChangetoX:Number;		//轮胎按钮下面的绿圈移动到的新X坐标
		public var tireCircleChangetoY:Number;		//轮胎按钮下面的绿圈移动到的新y坐标
		public var lefthandHitButton:Boolean;	//检测左手是否碰到任何按键
		public var righthandHitButton:Boolean;	//检测右手是否碰到任何按键
		
		public static var sensorDistance:Number = 2000;
		public static var handDistance:Number = -50;
		public static var hoverTime:Number = 1000;
		//public static var sensorDistance:Number = 2000
		
		public function main()
		{
			//stage.displayState=StageDisplayState.FULL_SCREEN;    //全屏
			stage.scaleMode=StageScaleMode.SHOW_ALL;    //全部显示
			//Mouse.hide();  //原始鼠标隐藏

			distanceText.text = String(sensorDistance); //用以显示感应区距离的文本
			handText.text = String(handDistance * -1);	//用以显示手距离躯干距离的文本
			hoverText.text = String(hoverTime);			//用以显示悬停时间的文本

			//首先检测是否支持kinect
			if(Kinect.isSupported())
			{
				xmlLoader.load(new URLRequest("piclistok.xml"));    //图片存放信息在piclist.xml中
				xmlLoader.addEventListener(Event.COMPLETE,xmlLoaded);     //使用complete事件以备远程操作
				kinectImageBmp = new Bitmap;
				kinectImageWindow.addChild(kinectImageBmp);
				skeletonContainer = new Sprite();
				kinectImageWindow.addChild(skeletonContainer);
				kinect = Kinect.getDevice();
				var settings:KinectSettings = new KinectSettings();
				settings.depthEnabled = true;
				settings.rgbEnabled = true;
				settings.rgbResolution = CameraResolution.RESOLUTION_640_480;
				settings.skeletonEnabled = true;
				kinect.start(settings);
			}
		}
		
		//xml文件读取完成后触发的事件
		private function xmlLoaded(e:Event):void
		{
			kinectWindowWidth = 320;	//kinect图像小窗口的宽度为320
			kinectWindowHeight = 240;	//kinect图像小窗口的高度为320
			kinect.addEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, rgbImageHandler);	//每当RGB图像更新时执行的事件
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);		//flash每一帧都执行的事件
			addEventListener(Event.ENTER_FRAME, checkHit);
			kinectEventTimer.addEventListener(TimerEvent.TIMER, kinectEvent);	//有关kinect数据的事件，使用timer，每秒执行20次
			kinectEventTimer.start();
			
			//下面是六个箭头按钮的侦听器
			dup.addEventListener(MouseEvent.CLICK, distanceUp);			
			ddown.addEventListener(MouseEvent.CLICK, distanceDown);
			hforward.addEventListener(MouseEvent.CLICK, handForward);
			hbackward.addEventListener(MouseEvent.CLICK, handBackward);
			hoverUp.addEventListener(MouseEvent.CLICK, hovertimeUp);
			hoverDown.addEventListener(MouseEvent.CLICK, hovertimeDown);
			
			picList_XML=new XML(xmlLoader.data);
			picLoader.load(new URLRequest(picList_XML.model[0].tire[0].color[0]+1+".png"));	//程序初始化时加载的第一张图片
			pic_mc.addChild(picLoader);
			pic_mc.x=600;	//加载的汽车图片的位置
			pic_mc.y=350;	//加载的汽车图片的位置
		}
		
		//点箭头按钮触发的function
		private function hovertimeUp(e:MouseEvent):void
		{
			hoverTime += 500;
			hoverText.text = String(hoverTime);
			hoverTimerc1=new Timer(hoverTime,1);
			hoverTimerc2=new Timer(hoverTime,1);
			hoverTimerc3=new Timer(hoverTime,1);
			hoverTimerc4=new Timer(hoverTime,1);
			hoverTimerc5=new Timer(hoverTime,1);
			hoverTimerm1=new Timer(hoverTime,1);
			hoverTimerm2=new Timer(hoverTime,1);
			hoverTimerm3=new Timer(hoverTime,1);
			hoverTimerm4=new Timer(hoverTime,1);
			hoverTimerm5=new Timer(hoverTime,1);
			hoverTimerm6=new Timer(hoverTime,1);
			hoverTimert1=new Timer(hoverTime,1);
			hoverTimert2=new Timer(hoverTime,1);
		}
		private function hovertimeDown(e:MouseEvent):void
		{
			if(hoverTime>0)
			{
				hoverTime -= 500;
				hoverText.text = String(hoverTime);
				hoverTimerc1=new Timer(hoverTime,1);
				hoverTimerc2=new Timer(hoverTime,1);
				hoverTimerc3=new Timer(hoverTime,1);
				hoverTimerc4=new Timer(hoverTime,1);
				hoverTimerc5=new Timer(hoverTime,1);
				hoverTimerm1=new Timer(hoverTime,1);
				hoverTimerm2=new Timer(hoverTime,1);
				hoverTimerm3=new Timer(hoverTime,1);
				hoverTimerm4=new Timer(hoverTime,1);
				hoverTimerm5=new Timer(hoverTime,1);
				hoverTimerm6=new Timer(hoverTime,1);
				hoverTimert1=new Timer(hoverTime,1);
				hoverTimert2=new Timer(hoverTime,1);
			}
		}
		private function distanceUp(e:MouseEvent):void
		{
			sensorDistance += 200;
			distanceText.text = String(sensorDistance);
		}
		private function distanceDown(e:MouseEvent):void
		{
			sensorDistance -= 200;
			distanceText.text = String(sensorDistance);
		}
		private function handForward(e:MouseEvent):void
		{
			handDistance -= 50;
			handText.text = String(handDistance * -1);
		}
		private function handBackward(e:MouseEvent):void
		{
			handDistance += 50;
			handText.text = String(handDistance * -1);
		}
		
		//以下是所有需要用到kinect数据的function
		private function kinectEvent(e:TimerEvent):void
		{
			getUser = new getSelectedUser(kinect);
			theSelectedUser = getUser.theSelectedUser;
			getGesture = new gestureDetector(theSelectedUser);
			getGesture.detectStart();
			//检测到向左挥手时触发的翻页事件
			if(valueHolder.righthandSwipeLeft == true || valueHolder.lefthandSwipeLeft == true)
			{
				rightLeftArrow.gotoAndPlay(1);

				if(picNum == 5)
				{
					picNum=1;
				}
				else
				{
					picNum++;
				}
				trace(picNum);
				trace("next picture");
				var nextPic:String=picList_XML.model[modelNum-1].tire[tireNum-1].color[colorNum-1] + picNum+".png";
				picLoader.unload();
				picLoader.load(new URLRequest(nextPic));
			}
			//检测到向右挥手时触发的翻页事件
			if(valueHolder.lefthandSwipeRight == true || valueHolder.righthandSwipeRight == true)
			{
				leftRightArrow.gotoAndPlay(1);

				if(picNum == 1)
				{
					picNum=5;
				}
				else
				{
					picNum--;
				}
				trace(picNum);
				trace("previous picture");
				var prePic:String=picList_XML.model[modelNum-1].tire[tireNum-1].color[colorNum-1] + picNum +".png";
				picLoader.unload();
				picLoader.load(new URLRequest(prePic));

			}
		}
		
		//xml文件读取完成后一直循环的事件
		private function enterFrameHandler(e:Event):void
		{
			skeletonContainer.graphics.clear();
			if(theSelectedUser !== null)
			{
				//在kinect窗口中给被选中的人的躯干部位画点
				for each(var joint:SkeletonJoint in theSelectedUser.skeletonJoints)
				{
					skeletonContainer.graphics.beginFill(0x00FC00);
					skeletonContainer.graphics.drawCircle(joint.position.rgbRelative.x*kinectWindowWidth, joint.position.rgbRelative.y*kinectWindowHeight, 3);
					skeletonContainer.graphics.endFill();
				}
				//左右手光标跟踪用户骨骼的方法
				if(theSelectedUser.rightHand.position.world.z - theSelectedUser.torso.position.world.z < handDistance)
				{
					cursorRighthand.visible = true;
					righthandLoadingCircle.visible = true;
					
					//cursorRighthand.x = (theSelectedUser.rightHand.position.worldRelative.x*stage.stageWidth*1.3)+825-150;
					//cursorRighthand.y = (theSelectedUser.rightHand.position.worldRelative.y*stage.stageHeight*-1.3)+1000;
					var righthandToTorsoX:Number = theSelectedUser.rightHand.position.world.x - theSelectedUser.torso.position.world.x;
					var righthandToTorsoY:Number = theSelectedUser.rightHand.position.world.y - theSelectedUser.torso.position.world.y;
					cursorRighthand.x = (righthandToTorsoX+200)/600*stage.stageWidth;
					cursorRighthand.y = righthandToTorsoY/300*stage.stageHeight*-1+stage.stageHeight;
					
					righthandLoadingCircle.x = cursorRighthand.x;
					righthandLoadingCircle.y = cursorRighthand.y;
				}
				else
				{
					cursorRighthand.visible = false;
					cursorRighthand.x = -100;
					cursorRighthand.x = -100;
					righthandLoadingCircle.visible = false;
					righthandLoadingCircle.x = -100;
					righthandLoadingCircle.y = -100;
				}
				if(theSelectedUser.leftHand.position.world.z - theSelectedUser.torso.position.world.z < handDistance)
				{
					cursorLefthand.visible = true;
					lefthandLoadingCircle.visible = true;
					//cursorLefthand.x = (theSelectedUser.leftHand.position.worldRelative.x*stage.stageWidth*1.3)+825+150;
					//cursorLefthand.y = (theSelectedUser.leftHand.position.worldRelative.y*stage.stageHeight*-1.3)+1000;
					var lefthandToTorsoX:Number = theSelectedUser.leftHand.position.world.x - theSelectedUser.torso.position.world.x;
					var lefthandToTorsoY:Number = theSelectedUser.leftHand.position.world.y - theSelectedUser.torso.position.world.y;
					cursorLefthand.x = (lefthandToTorsoX+400)/600*stage.stageWidth;
					cursorLefthand.y = lefthandToTorsoY/300*stage.stageHeight*-1+stage.stageHeight;
					
					righthandLoadingCircle.x = cursorRighthand.x;
					righthandLoadingCircle.y = cursorRighthand.y;
					lefthandLoadingCircle.x = cursorLefthand.x;
					lefthandLoadingCircle.y = cursorLefthand.y;
				}
				else
				{
					cursorLefthand.visible = false;
					cursorLefthand.x = -100;
					cursorLefthand.x = -100;
					lefthandLoadingCircle.visible = false;
					lefthandLoadingCircle.x = -100;
					lefthandLoadingCircle.y = -100;
				}
			}
			else
			{
				cursorRighthand.visible = false;
				cursorLefthand.visible = false;
				righthandLoadingCircle.visible = false;
				lefthandLoadingCircle.visible = false;
			}
	
			//检测左手是否碰到任何按键
			if(cursorLefthand.hitTestObject(m1) || cursorLefthand.hitTestObject(m2) || cursorLefthand.hitTestObject(m3) || cursorLefthand.hitTestObject(m4) 
	  		 || cursorLefthand.hitTestObject(m5) || cursorLefthand.hitTestObject(m6) || cursorLefthand.hitTestObject(c1) || cursorLefthand.hitTestObject(c2)
			 || cursorLefthand.hitTestObject(c3) || cursorLefthand.hitTestObject(c4) || cursorLefthand.hitTestObject(c5) || cursorLefthand.hitTestObject(t1)
			 || cursorLefthand.hitTestObject(t2))
			{
				lefthandHitButton = true;
			}
			else
			{
				lefthandHitButton = false
			}
	
			//检测右手是否碰到任何按键
			if(cursorRighthand.hitTestObject(m1) || cursorRighthand.hitTestObject(m2) || cursorRighthand.hitTestObject(m3) || cursorRighthand.hitTestObject(m4) 
			 || cursorRighthand.hitTestObject(m5) || cursorRighthand.hitTestObject(m6) || cursorRighthand.hitTestObject(c1) || cursorRighthand.hitTestObject(c2)
			 || cursorRighthand.hitTestObject(c3) || cursorRighthand.hitTestObject(c4) || cursorRighthand.hitTestObject(c5) || cursorRighthand.hitTestObject(t1)
	  		 || cursorRighthand.hitTestObject(t2))
			{
				righthandHitButton = true 
			}
			else
			{
				righthandHitButton = false
			}
		}
		
		//按钮被碰到后的事件
		private function checkHit(e:Event):void
		{
			if(righthandHitButton == false)
			{
				righthandLoadingCircle.gotoAndStop(1);
			}
			if(lefthandHitButton == false)
			{
				lefthandLoadingCircle.gotoAndStop(1);
			}
			if((cursorRighthand.hitTestObject(c1) && cursorRighthand.hitTestObject(c2) == false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c1) && cursorLefthand.hitTestObject(c2) == false && righthandHitButton == false))
			{
				if (hoverTimerc1.running)
				{
					return;
				}
				colorHit = 1;
				hoverTimerc1.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimerc1.start();
				colorCircleChangetoX = 1512;
				colorCircleChangetoY = 160;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerc1.reset();
				hoverTimerc1.stop();
				hoverTimerc1.removeEventListener(TimerEvent.TIMER,hitColorButton);
			}

			if((cursorRighthand.hitTestObject(c2) && cursorRighthand.hitTestObject(c1) == false && cursorRighthand.hitTestObject(c3)== false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c2) && cursorLefthand.hitTestObject(c1) == false && cursorLefthand.hitTestObject(c3)== false && righthandHitButton == false))
			{
				if (hoverTimerc2.running)
				{
					return;
				}
				colorHit = 2;
				hoverTimerc2.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimerc2.start();
				colorCircleChangetoX = 1510;
				colorCircleChangetoY = 265;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerc2.reset();
				hoverTimerc2.stop();
				hoverTimerc2.removeEventListener(TimerEvent.TIMER,hitColorButton);
			}

			if((cursorRighthand.hitTestObject(c3) && cursorRighthand.hitTestObject(c2)==false && cursorRighthand.hitTestObject(c4)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c3) && cursorLefthand.hitTestObject(c2)==false && cursorLefthand.hitTestObject(c4)==false && righthandHitButton == false))
			{
				if (hoverTimerc3.running)
				{
					return;
				}
				colorHit = 3;
				hoverTimerc3.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimerc3.start();
				colorCircleChangetoX = 1510;
				colorCircleChangetoY = 369;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerc3.reset();
				hoverTimerc3.stop();
				hoverTimerc3.removeEventListener(TimerEvent.TIMER,hitColorButton);
			}
	
			if((cursorRighthand.hitTestObject(c4) && cursorRighthand.hitTestObject(c3)==false && cursorRighthand.hitTestObject(c5)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c4) && cursorLefthand.hitTestObject(c3)==false && cursorLefthand.hitTestObject(c5)==false && righthandHitButton == false))
			{
				if (hoverTimerc4.running)
				{
					return;
				}
				colorHit = 4;
				hoverTimerc4.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimerc4.start();
				colorCircleChangetoX = 1510;
				colorCircleChangetoY = 473;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerc4.reset();
				hoverTimerc4.stop();
				hoverTimerc4.removeEventListener(TimerEvent.TIMER,hitColorButton);
			}
	
			if((cursorRighthand.hitTestObject(c5) && cursorRighthand.hitTestObject(c4)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c5) && cursorLefthand.hitTestObject(c4)==false && righthandHitButton == false))
			{
				if (hoverTimerc5.running)
				{
					return;
				}
				colorHit = 5;
				hoverTimerc5.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimerc5.start();
				colorCircleChangetoX = 1510;
				colorCircleChangetoY = 577;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerc5.reset();
				hoverTimerc5.stop();
				hoverTimerc5.removeEventListener(TimerEvent.TIMER,hitColorButton);
			}
	
			if((cursorRighthand.hitTestObject(m1) && cursorRighthand.hitTestObject(m2)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m1) && cursorLefthand.hitTestObject(m2)==false && righthandHitButton == false))
			{
				if (hoverTimerm1.running)
				{
					return;
				}
				modelHit = 1;
				hoverTimerm1.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimerm1.start();
				modelCircleChangetoX = 160;
				modelCircleChangetoY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerm1.reset();
				hoverTimerm1.stop();
				hoverTimerm1.removeEventListener(TimerEvent.TIMER,hitModelButton);
			}
	
			if((cursorRighthand.hitTestObject(m2) && cursorRighthand.hitTestObject(m1)==false && cursorRighthand.hitTestObject(m3)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m2) && cursorLefthand.hitTestObject(m1)==false && cursorLefthand.hitTestObject(m3)==false && righthandHitButton == false))
			{
				if (hoverTimerm2.running)
				{
					return;
				}
				modelHit = 2;
				hoverTimerm2.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimerm2.start();
				modelCircleChangetoX = 422;
				modelCircleChangetoY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerm2.reset();
				hoverTimerm2.stop();
				hoverTimerm2.removeEventListener(TimerEvent.TIMER,hitModelButton);
			}
	
			if((cursorRighthand.hitTestObject(m3) && cursorRighthand.hitTestObject(m4)==false && cursorRighthand.hitTestObject(m2)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m3) && cursorLefthand.hitTestObject(m4)==false && cursorLefthand.hitTestObject(m2)==false && righthandHitButton == false))
			{
				if (hoverTimerm3.running)
				{
					return;
				}
				modelHit = 3;
				hoverTimerm3.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimerm3.start();
				modelCircleChangetoX = 695;
				modelCircleChangetoY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerm3.reset();
				hoverTimerm3.stop();
				hoverTimerm3.removeEventListener(TimerEvent.TIMER,hitModelButton);
			}
	
			if((cursorRighthand.hitTestObject(m4) && cursorRighthand.hitTestObject(m5)==false && cursorRighthand.hitTestObject(m3)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m4) && cursorLefthand.hitTestObject(m5)==false && cursorLefthand.hitTestObject(m3)==false && righthandHitButton == false))
			{
				if (hoverTimerm4.running)
				{
					return;
				}
				modelHit = 4;
				hoverTimerm4.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimerm4.start();
				modelCircleChangetoX = 975;
				modelCircleChangetoY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerm4.reset();
				hoverTimerm4.stop();
				hoverTimerm4.removeEventListener(TimerEvent.TIMER,hitModelButton);
			}
	
			if((cursorRighthand.hitTestObject(m5) && cursorRighthand.hitTestObject(m6)==false && cursorRighthand.hitTestObject(m4)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m5) && cursorLefthand.hitTestObject(m6)==false && cursorLefthand.hitTestObject(m4)==false && righthandHitButton == false))
			{
				if (hoverTimerm5.running)
				{
					return;
				}
				modelHit = 5;
				hoverTimerm5.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimerm5.start();
				modelCircleChangetoX = 1235;
				modelCircleChangetoY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerm5.reset();
				hoverTimerm5.stop();
				hoverTimerm5.removeEventListener(TimerEvent.TIMER,hitModelButton);
			}
	
			if((cursorRighthand.hitTestObject(m6) && cursorRighthand.hitTestObject(m5)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m6) && cursorLefthand.hitTestObject(m5)==false && righthandHitButton == false))
			{
				if (hoverTimerm6.running)
				{
					return;
				}
				modelHit = 6;
				hoverTimerm6.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimerm6.start();
				modelCircleChangetoX = 1480;
				modelCircleChangetoY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimerm6.reset();
				hoverTimerm6.stop();
				hoverTimerm6.removeEventListener(TimerEvent.TIMER,hitModelButton);
			}
	
			if((cursorRighthand.hitTestObject(t1) && cursorRighthand.hitTestObject(t2)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(t1) && cursorLefthand.hitTestObject(t2)==false && righthandHitButton == false))
			{
				if (hoverTimert1.running)
				{
					return;
				}
				tireHit = 1;
				hoverTimert1.addEventListener(TimerEvent.TIMER,hitTireButton);
				hoverTimert1.start();
				tireCircleChangetoX = 163;
				tireCircleChangetoY = 400;
				if(lefthandHitButton == false && tireHit !== tireNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && tireHit !== tireNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimert1.reset();
				hoverTimert1.stop();
				hoverTimert1.removeEventListener(TimerEvent.TIMER,hitTireButton);
			}
	
			if((cursorRighthand.hitTestObject(t2) && cursorRighthand.hitTestObject(t1)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(t2) && cursorLefthand.hitTestObject(t1)==false && righthandHitButton == false))
			{
				if (hoverTimert2.running)
				{
					return;
				}
				tireHit = 2;
				hoverTimert2.addEventListener(TimerEvent.TIMER,hitTireButton);
				hoverTimert2.start();
				tireCircleChangetoX = 163;
				tireCircleChangetoY = 565;
				if(lefthandHitButton == false && tireHit !== tireNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && tireHit !== tireNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			else
			{
				hoverTimert2.reset();
				hoverTimert2.stop();
				hoverTimert2.removeEventListener(TimerEvent.TIMER,hitTireButton);
			}
		}
		
		//小窗口的kinect图像
		private function rgbImageHandler(event:CameraImageEvent):void
		{
			kinectImageBmp.bitmapData = event.imageData;
			kinectImageBmp.width = kinectWindowWidth;
			kinectImageBmp.height = kinectWindowHeight;
		}
		
		//悬停时间结束后触发的事件
		private function hitColorButton(e:TimerEvent):void
		{
			if(colorNum !== colorHit)
			{
				colorNum = colorHit;
				colorCircle.x = colorCircleChangetoX;
				colorCircle.y = colorCircleChangetoY;
				colorCircle.gotoAndPlay(1);
				var changePic:String=picList_XML.model[modelNum-1].tire[tireNum-1].color[colorNum-1] + picNum +".png";
				picLoader.unload();
				picLoader.load(new URLRequest(changePic));
			}
		}
		
		private function hitModelButton(e:TimerEvent):void
		{
			if(modelNum !== modelHit)
			{
				modelNum = modelHit;
				modelCircle.x = modelCircleChangetoX;
				modelCircle.y = modelCircleChangetoY;
				modelCircle.gotoAndPlay(1);
				var changePic:String=picList_XML.model[modelNum-1].tire[tireNum-1].color[colorNum-1] + picNum +".png";
				picLoader.unload();
				picLoader.load(new URLRequest(changePic));
			}
		}
		
		private function hitTireButton(e:TimerEvent):void
		{
			if(tireNum !== tireHit)
			{
				tireNum = tireHit;
				tireCircle.x = tireCircleChangetoX;
				tireCircle.y = tireCircleChangetoY;
				tireCircle.gotoAndPlay(1);
				var changePic:String=picList_XML.model[modelNum-1].tire[tireNum-1].color[colorNum-1] + picNum +".png";
				picLoader.unload();
				picLoader.load(new URLRequest(changePic));
		
			}
		}
	}
	
}