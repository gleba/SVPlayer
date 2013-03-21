package {
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	[SWF(backgroundColor="#000000")]
	public class WindPlayer extends Sprite {
		
		private var sv:SoulVplayer;
		private var logo:GfxLogo;
		private var intro:GfxIntro;
		private var info:GfxInfo;
		
		public function WindPlayer() {
			sv  = new SoulVplayer();
			intro = new GfxIntro();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			sv.setStream("rtmp://195.110.52.107:1935/stream/","serf");
			addChild(intro);
			intro.addEventListener(MouseEvent.CLICK, intro_clickHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			sv.onInfo = onInfo
		}
		
		private function onInfo(s:String):void{
			if(infoField){
				infoField.appendText(s+"\n");
				infoField.scrollV = infoField.maxScrollV;
			}
		}
		
		private function resize():void {
			if (intro){
				intro.y = stage.stageHeight/2;
				intro.x = stage.stageWidth/2;
			}
			if(logo){
				logo.x = 0;
				logo.y = stage.stageHeight;
			}
		}
		
		private var infoField:TextField;
		private function intro_clickHandler(event:MouseEvent):void {
			info = new GfxInfo();
			addChild(sv);
			intro.removeEventListener(MouseEvent.CLICK, intro_clickHandler);
			removeChild(intro);
			logo = new GfxLogo();
			resize();
			addChild(logo);
			addChild(info);
			infoField = info.getChildAt(0) as TextField;
			infoField.text = "";
			info.visible = false;
		}
		
		private function resizeHandler(event:Event):void { ;
			resize();
		}
		
		private function addedToStageHandler(event:Event):void {
			resize();
			sv.initStage(stage);
			stage.addEventListener(Event.RESIZE, resizeHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function keyDownHandler(event:KeyboardEvent):void {
			trace(event.keyCode);
			switch(event.keyCode)
			{
				case Keyboard.NUMBER_1:
				{
					playChannel("serf");
					break;
				}
				case Keyboard.NUMBER_2:
				{
					playChannel("plyaj");
					break;
				}
				case Keyboard.NUMBER_3:
				{
					playChannel("novin");
					break;
				}
				case Keyboard.NUMBER_4:
				{
					playChannel("centr");
					break;
				}
				case Keyboard.Z:
				{
					switcHD();
					break;
				}
				case Keyboard.X:
				{
					sv.swithClassicVideo();
					break;
				}
				case Keyboard.C:
				{
					sv.swithStageVideo();
					break;
				}
				case Keyboard.SPACE:
				{
					if ( stage.displayState == StageDisplayState.NORMAL)
						stage.displayState = StageDisplayState.FULL_SCREEN
					else
						stage.displayState = StageDisplayState.NORMAL
					break;
				}
				case Keyboard.CONTROL:
				{
					if (info)
						info.visible = !info.visible;
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		private var currentChannel:String = "surf";
		private var hd:Boolean = false;
		private function playChannel(channelName:String):void{
			currentChannel = channelName;
			hd = false;
			sv.playChannel(currentChannel);
		}
		
		private function switcHD():void{
			if (hd){
				hd = false;
				sv.playChannel(currentChannel);
			} else {
				hd =  true;
				sv.playChannel(currentChannel+"_full")
			}
		}
		
	}
}
