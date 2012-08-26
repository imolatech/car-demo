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
	import com.imolatech.kinect.JointSmoother;
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
		private var kinect:Kinect;
		private var kinectImageBmp:Bitmap;	//用于储存kinect图像的bmp
		private var kinectWindowWidth:Number = 320;	//kinect图像小窗口的宽度
		private var kinectWindowHeight:Number = 240;	//kinect图像小窗口的高度
		private var skeletonContainer:Sprite;	//用于储存用户骨骼图形
		private var theSelectedUser:User		//被选中的用户
		
		private var getUser:UserSelector;	//外部类UserSelector的实例
		private var getGesture:GestureDetector;	//外部类GestureDetector的实例
		private var getSmoothedJoints:JointSmoother;	//外部类JointSmoother的实例
		
		private var hoverTimer:Timer=new Timer(hoverTime,1);
		private var handDistance:Number = -50;
		private var hoverTime:Number = 1000;
		private var kinectEventsTimer:Timer = new Timer(50,0);	//单独为需要获取kinect数据的事件设置的Timer,由于kinect每秒最多提供30帧图像，为了保证稳定，这个Timer每秒只执行20次。

		private var picList_XML:XML;
		private var xmlLoader:URLLoader=new URLLoader();
		private var picLoader:Loader = new Loader();

		private var modelNum:Number=1;	//初始车型号码为1
		private var colorNum:Number=1;	//初始颜色号码为1
		private var tireNum:Number=1;	//初始轮胎号码为1
		private var picNum:Number=1;	//初始播放图片页数为1
		private var colorHit:Number = 1;		//光标碰到的颜色按钮
		private var modelHit:Number = 1;		//光标碰到的车型按钮
		private var tireHit:Number = 1;			//光标碰到的轮胎按钮
		private var newColorCircleX:Number;	//颜色按钮下面的绿圈移动到的新X坐标
		private var newColorCircleY:Number;	//颜色按钮下面的绿圈移动到的新y坐标
		private var newModelCircleX:Number;	//车型按钮下面的绿圈移动到的新X坐标
		private var newModelCircleY:Number;	//车型按钮下面的绿圈移动到的新y坐标
		private var newTireCircleX:Number;		//轮胎按钮下面的绿圈移动到的新X坐标
		private var newTireCircleY:Number;		//轮胎按钮下面的绿圈移动到的新y坐标
		
		private var lefthandHitButton:Boolean;	//检测左手是否碰到任何按键
		private var righthandHitButton:Boolean;	//检测右手是否碰到任何按键
		
		public function Main()
		{
			//stage.displayState=StageDisplayState.FULL_SCREEN;    //全屏
			stage.scaleMode=StageScaleMode.SHOW_ALL;    //全部显示
			//Mouse.hide();  //原始鼠标隐藏

			//首先检测是否支持kinect
			if(Kinect.isSupported())
			{
				xmlLoader.load(new URLRequest("app:/config/CarPictures.xml"));    //图片存放信息在piclist.xml中
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
			kinect.addEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, rgbImageHandler);	//每当RGB图像更新时执行的事件
			addEventListener(Event.ENTER_FRAME, handsHitTest);
			addEventListener(Event.ENTER_FRAME, buttonCheckHit);
			addEventListener(Event.ENTER_FRAME, theSelectedUserChange);
			kinectEventsTimer.addEventListener(TimerEvent.TIMER, kinectEvents);	//有关kinect数据的事件，使用timer，每秒执行20次
			kinectEventsTimer.start();
			getUser = new UserSelector(kinect);	//UserSelector类，需要传一个Kinect参数
			getGesture = new GestureDetector(theSelectedUser);	//GestureDetector类，需要传一个User参数
			getSmoothedJoints = new JointSmoother(theSelectedUser, 8); //JointSmoother类，第一个参数为需要smooth的User, 第二个参数为smooth系数，从0到20均可
			
			//下面是六个箭头按钮的侦听器
			distanceUpButton.addEventListener(MouseEvent.CLICK, distanceUp);			
			distanceDownButton.addEventListener(MouseEvent.CLICK, distanceDown);
			handForwardButton.addEventListener(MouseEvent.CLICK, handForward);
			handBackwardButton.addEventListener(MouseEvent.CLICK, handBackward);
			hoverUpButton.addEventListener(MouseEvent.CLICK, hovertimeUp);
			hoverDownButton.addEventListener(MouseEvent.CLICK, hovertimeDown);
			
			picList_XML=new XML(xmlLoader.data);
			picLoader.load(new URLRequest(picList_XML.model[0].tire[0].color[0]+1+".png"));	//程序初始化时加载的第一张图片
			pic_mc.addChild(picLoader);
			pic_mc.x=600;	//加载的汽车图片的位置
			pic_mc.y=350;	//加载的汽车图片的位置
			
			distanceText.text = String(getUser.distance); //用以显示感应区距离的文本
			handText.text = String(handDistance * -1);	//用以显示手距离躯干距离的文本
			hoverText.text = String(hoverTime);			//用以显示悬停时间的文本
		}
		
		//点箭头按钮触发的function
		private function hovertimeUp(e:MouseEvent):void
		{
			hoverTime += 500;
			hoverText.text = String(hoverTime);
			hoverTimer=new Timer(hoverTime,1);
		}
		private function hovertimeDown(e:MouseEvent):void
		{
			if(hoverTime>0)
			{
				hoverTime -= 500;
				hoverText.text = String(hoverTime);
				hoverTimer=new Timer(hoverTime,1);
			}
		}
		private function distanceUp(e:MouseEvent):void
		{
			getUser.distance += 200;
			distanceText.text = String(getUser.distance);
		}
		private function distanceDown(e:MouseEvent):void
		{
			getUser.distance -= 200;
			distanceText.text = String(getUser.distance);
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
		
		private function theSelectedUserChange(e:Event):void
		{
			if(getUser.userChange == true)
			{
				getSmoothedJoints = new JointSmoother(theSelectedUser, 8);
				getGesture = new GestureDetector(theSelectedUser);
			}
		}
		
		//以下是所有需要用到kinect数据的function
		private function kinectEvents(e:TimerEvent):void
		{
			getUser.UserSelect();
			theSelectedUser = getUser.getTheSelectedUser;
			getSmoothedJoints.smoothJoints();
			getGesture.detectSwipe();
			getGesture.detectWave();
			swipeEvents();
			skeletonContainer.graphics.clear();
			if(theSelectedUser !== null)
			{
				drawSkeleton();
				cursorMove();
			}
			else
			{
				cursorRighthand.visible = false;
				cursorLefthand.visible = false;
				righthandLoadingCircle.visible = false;
				lefthandLoadingCircle.visible = false;
			}
		}
		
		private function handsHitTest(e:Event):void
		{
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
		private function buttonCheckHit(e:Event):void
		{
			if(righthandHitButton == false)
			{
				righthandLoadingCircle.gotoAndStop(1);
			}
			if(lefthandHitButton == false)
			{
				lefthandLoadingCircle.gotoAndStop(1);
			}
			if(righthandHitButton == false && lefthandHitButton == false)
			{
				hoverTimer.reset();
				hoverTimer.stop();
				hoverTimer.removeEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimer.removeEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimer.removeEventListener(TimerEvent.TIMER,hitTireButton);
			}
			
			if((cursorRighthand.hitTestObject(c1) && cursorRighthand.hitTestObject(c2)) || (cursorRighthand.hitTestObject(c2) && cursorRighthand.hitTestObject(c3)) || (cursorRighthand.hitTestObject(c3) && cursorRighthand.hitTestObject(c4)) || (cursorRighthand.hitTestObject(c4) && cursorRighthand.hitTestObject(c5)))
			{
				hoverTimer.reset();
				hoverTimer.stop();
				hoverTimer.removeEventListener(TimerEvent.TIMER,hitColorButton);
			}
			if((cursorLefthand.hitTestObject(c1) && cursorLefthand.hitTestObject(c2)) || (cursorLefthand.hitTestObject(c2) && cursorLefthand.hitTestObject(c3)) || (cursorLefthand.hitTestObject(c3) && cursorLefthand.hitTestObject(c4)) || (cursorLefthand.hitTestObject(c4) && cursorLefthand.hitTestObject(c5)))
			{
				hoverTimer.reset();
				hoverTimer.stop();
				hoverTimer.removeEventListener(TimerEvent.TIMER,hitColorButton);
			}
			if((cursorRighthand.hitTestObject(c1) && cursorRighthand.hitTestObject(c2) == false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c1) && cursorLefthand.hitTestObject(c2) == false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				colorHit = 1;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimer.start();
				newColorCircleX = 1512;
				newColorCircleY = 160;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}

			if((cursorRighthand.hitTestObject(c2) && cursorRighthand.hitTestObject(c1) == false && cursorRighthand.hitTestObject(c3)== false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c2) && cursorLefthand.hitTestObject(c1) == false && cursorLefthand.hitTestObject(c3)== false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				colorHit = 2;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimer.start();
				newColorCircleX = 1510;
				newColorCircleY = 265;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}

			if((cursorRighthand.hitTestObject(c3) && cursorRighthand.hitTestObject(c2)==false && cursorRighthand.hitTestObject(c4)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c3) && cursorLefthand.hitTestObject(c2)==false && cursorLefthand.hitTestObject(c4)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				colorHit = 3;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimer.start();
				newColorCircleX = 1510;
				newColorCircleY = 369;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
	
			if((cursorRighthand.hitTestObject(c4) && cursorRighthand.hitTestObject(c3)==false && cursorRighthand.hitTestObject(c5)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c4) && cursorLefthand.hitTestObject(c3)==false && cursorLefthand.hitTestObject(c5)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				colorHit = 4;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimer.start();
				newColorCircleX = 1510;
				newColorCircleY = 473;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
	
			if((cursorRighthand.hitTestObject(c5) && cursorRighthand.hitTestObject(c4)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(c5) && cursorLefthand.hitTestObject(c4)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				colorHit = 5;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitColorButton);
				hoverTimer.start();
				newColorCircleX = 1510;
				newColorCircleY = 577;
				if(lefthandHitButton == false && colorHit !== colorNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && colorHit !== colorNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			
			if((cursorRighthand.hitTestObject(m1) && cursorRighthand.hitTestObject(m2)) || (cursorRighthand.hitTestObject(m2) && cursorRighthand.hitTestObject(m3)) || (cursorRighthand.hitTestObject(m3) && cursorRighthand.hitTestObject(m4)) || (cursorRighthand.hitTestObject(m4) && cursorRighthand.hitTestObject(m5)) || (cursorRighthand.hitTestObject(m5) && cursorRighthand.hitTestObject(m6)))
			{
				hoverTimer.reset();
				hoverTimer.stop();
				hoverTimer.removeEventListener(TimerEvent.TIMER,hitModelButton);
			}
			if((cursorLefthand.hitTestObject(m1) && cursorLefthand.hitTestObject(m2)) || (cursorLefthand.hitTestObject(m2) && cursorLefthand.hitTestObject(m3)) || (cursorLefthand.hitTestObject(m3) && cursorLefthand.hitTestObject(m4)) || (cursorLefthand.hitTestObject(m4) && cursorLefthand.hitTestObject(m5)) || (cursorLefthand.hitTestObject(m5) && cursorLefthand.hitTestObject(m6)))
			{
				hoverTimer.reset();
				hoverTimer.stop();
				hoverTimer.removeEventListener(TimerEvent.TIMER,hitModelButton);
			}
			if((cursorRighthand.hitTestObject(m1) && cursorRighthand.hitTestObject(m2)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m1) && cursorLefthand.hitTestObject(m2)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				modelHit = 1;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimer.start();
				newModelCircleX = 160;
				newModelCircleY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
	
			if((cursorRighthand.hitTestObject(m2) && cursorRighthand.hitTestObject(m1)==false && cursorRighthand.hitTestObject(m3)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m2) && cursorLefthand.hitTestObject(m1)==false && cursorLefthand.hitTestObject(m3)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				modelHit = 2;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimer.start();
				newModelCircleX = 422;
				newModelCircleY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
	
			if((cursorRighthand.hitTestObject(m3) && cursorRighthand.hitTestObject(m4)==false && cursorRighthand.hitTestObject(m2)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m3) && cursorLefthand.hitTestObject(m4)==false && cursorLefthand.hitTestObject(m2)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				modelHit = 3;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimer.start();
				newModelCircleX = 695;
				newModelCircleY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
	
			if((cursorRighthand.hitTestObject(m4) && cursorRighthand.hitTestObject(m5)==false && cursorRighthand.hitTestObject(m3)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m4) && cursorLefthand.hitTestObject(m5)==false && cursorLefthand.hitTestObject(m3)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				modelHit = 4;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimer.start();
				newModelCircleX = 975;
				newModelCircleY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
	
			if((cursorRighthand.hitTestObject(m5) && cursorRighthand.hitTestObject(m6)==false && cursorRighthand.hitTestObject(m4)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m5) && cursorLefthand.hitTestObject(m6)==false && cursorLefthand.hitTestObject(m4)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				modelHit = 5;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimer.start();
				newModelCircleX = 1235;
				newModelCircleY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
	
			if((cursorRighthand.hitTestObject(m6) && cursorRighthand.hitTestObject(m5)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(m6) && cursorLefthand.hitTestObject(m5)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				modelHit = 6;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitModelButton);
				hoverTimer.start();
				newModelCircleX = 1480;
				newModelCircleY = 935;
				if(lefthandHitButton == false && modelHit !== modelNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && modelHit !== modelNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
			
			if(cursorRighthand.hitTestObject(t1) && cursorRighthand.hitTestObject(t2))
			{
				hoverTimer.reset();
				hoverTimer.stop();
				hoverTimer.removeEventListener(TimerEvent.TIMER,hitTireButton);
			}
			if(cursorLefthand.hitTestObject(t1) && cursorLefthand.hitTestObject(t2))
			{
				hoverTimer.reset();
				hoverTimer.stop();
				hoverTimer.removeEventListener(TimerEvent.TIMER,hitTireButton);
			}
			if((cursorRighthand.hitTestObject(t1) && cursorRighthand.hitTestObject(t2)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(t1) && cursorLefthand.hitTestObject(t2)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				tireHit = 1;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitTireButton);
				hoverTimer.start();
				newTireCircleX = 163;
				newTireCircleY = 400;
				if(lefthandHitButton == false && tireHit !== tireNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && tireHit !== tireNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
			}
	
			if((cursorRighthand.hitTestObject(t2) && cursorRighthand.hitTestObject(t1)==false && lefthandHitButton == false) || (cursorLefthand.hitTestObject(t2) && cursorLefthand.hitTestObject(t1)==false && righthandHitButton == false))
			{
				if (hoverTimer.running)
				{
					return;
				}
				tireHit = 2;
				hoverTimer.addEventListener(TimerEvent.TIMER,hitTireButton);
				hoverTimer.start();
				newTireCircleX = 163;
				newTireCircleY = 565;
				if(lefthandHitButton == false && tireHit !== tireNum)
				{
					righthandLoadingCircle.gotoAndPlay(2);
				}
				if(righthandHitButton == false && tireHit !== tireNum)
				{
					lefthandLoadingCircle.gotoAndPlay(2);
				}
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
				colorCircle.x = newColorCircleX;
				colorCircle.y = newColorCircleY;
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
				modelCircle.x = newModelCircleX;
				modelCircle.y = newModelCircleY;
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
				tireCircle.x = newTireCircleX;
				tireCircle.y = newTireCircleY;
				tireCircle.gotoAndPlay(1);
				var changePic:String=picList_XML.model[modelNum-1].tire[tireNum-1].color[colorNum-1] + picNum +".png";
				picLoader.unload();
				picLoader.load(new URLRequest(changePic));
		
			}
		}
		
		private function drawSkeleton():void
		{
			for each(var joint:SkeletonJoint in theSelectedUser.skeletonJoints)
				{
					skeletonContainer.graphics.beginFill(0x00FC00);
					skeletonContainer.graphics.drawCircle(joint.position.rgbRelative.x*kinectWindowWidth, joint.position.rgbRelative.y*kinectWindowHeight, 3);
					skeletonContainer.graphics.endFill();
				}
		}
		
		private function cursorMove():void
		{
			if(getSmoothedJoints.righthandZ - getSmoothedJoints.torsoZ < handDistance)
			{
				cursorRighthand.visible = true;
				righthandLoadingCircle.visible = true;
				var righthandToTorsoX:Number = getSmoothedJoints.righthandX - getSmoothedJoints.torsoX;
				var righthandToTorsoY:Number = getSmoothedJoints.righthandY - getSmoothedJoints.torsoY;
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
			if(getSmoothedJoints.lefthandZ - getSmoothedJoints.torsoZ < handDistance)
			{
				cursorLefthand.visible = true;
				lefthandLoadingCircle.visible = true;
				var lefthandToTorsoX:Number = getSmoothedJoints.lefthandX - getSmoothedJoints.torsoX;
				var lefthandToTorsoY:Number = getSmoothedJoints.lefthandY - getSmoothedJoints.torsoY;
				cursorLefthand.x = (lefthandToTorsoX+400)/600*stage.stageWidth;
				cursorLefthand.y = lefthandToTorsoY/300*stage.stageHeight*-1+stage.stageHeight;
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
		private function swipeEvents():void
		{
			if(getGesture.rightWave == true)
			{
				trace("WAVE!!!!!!");
			}
			if(getGesture.righthandGoLeft == true || getGesture.lefthandGoLeft == true)
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
				var nextPic:String=picList_XML.model[modelNum-1].tire[tireNum-1].color[colorNum-1] + picNum+".png";
				picLoader.unload();
				picLoader.load(new URLRequest(nextPic));
			}
			//检测到向右挥手时触发的翻页事件
			if(getGesture.lefthandGoRight == true || getGesture.righthandGoRight == true)
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
				var prePic:String=picList_XML.model[modelNum-1].tire[tireNum-1].color[colorNum-1] + picNum +".png";
				picLoader.unload();
				picLoader.load(new URLRequest(prePic));
			}
		}
	}
	
}