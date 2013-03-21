/**
 * Created with IntelliJ IDEA. By Gleb
 * 09.03.13 16:08
 * С каждой строчкой с каждым билдом, человек меняет отношение к космосу и космоса к себе.
 */
package {
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.StageVideoAvailabilityEvent;
import flash.events.StageVideoEvent;
import flash.events.VideoEvent;
import flash.geom.Rectangle;
import flash.media.StageVideo;
import flash.media.StageVideoAvailability;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.text.TextField;
import flash.ui.Keyboard;


public class SoulVplayer extends Sprite{

    private static const BORDER:Number = 1;

    private var legend:TextField = new TextField();
    private var sv:StageVideo;
    private var nc:NetConnection;
    private var ns:NetStream;
    private var rc:Rectangle;
    private var video:Video;
    private var thumb:Shape;
    private var interactiveThumb:Sprite;
    private var totalTime:Number;
    private var videoWidth:int;
    private var videoHeight:int;
    private var outputBuffer:String = new String();
    private var rect:Rectangle = new Rectangle(0, 0, 0, BORDER);
    private var videoRect:Rectangle = new Rectangle(0, 0, 0, 0);
    private var gotStage:Boolean;
    private var stageVideoInUse:Boolean;
    private var classicVideoInUse:Boolean;
    private var accelerationType:String;
    private var infos:String = new String();
    public var available:Boolean;
    private var inited:Boolean;
    private var played:Boolean;
    private var connected:Boolean;
    private var container:Sprite;

    private var filename:String;

    private var streamUrl:String;
    private var streamName:String;

    public function SoulVplayer() {
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
    }

    public function initStage(stage:Stage):void{
        stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
    }
    public function setStream(url:String,channel:String):void{
        filename = null;
        streamUrl = url;
        streamName = channel
    }

    public function playChannel(channel:String):void{
        streamName = channel;
//        if (connected)
//            ns.play(channel);
//		else
			reConnect();
    }
    public function playFile(s:String):void {
        filename = s;
        streamUrl = null;
        streamName = null;
        if (connected)
            ns.play(s);
    }

    public function swithStageVideo():void{
        if (connected&&available)
        toggleStageVideo(true);
    }

    public function swithClassicVideo():void{
        if (connected&&available)
            toggleStageVideo(false);
    }
    private function addedToStageHandler(event:Event):void {

        removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

        thumb = new Shape(); 
        interactiveThumb = new Sprite();
        interactiveThumb.addChild(thumb);
        addChild(interactiveThumb);


        // Input Events
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(Event.RESIZE,  onResize);
//        stage.addEventListener(MouseEvent.CLICK, onClick);

		reConnect()
	}
     
	private function reConnect():void{
        if (!nc){
            nc = new NetConnection();
            nc.addEventListener(NetStatusEvent.NET_STATUS,onConnectStatus);
        }
        logInfo("reConnect "+streamName);
        if (streamUrl){
            nc.connect(streamUrl);
        } else {
            nc.connect(null);
            connected = true;
            initStream();
        }
    }
    private function onConnectStatus(event:NetStatusEvent):void  {
//        nc.removeEventListener(NetStatusEvent.NET_STATUS,onConnectStatus)
        logInfo("onConnectStatus "+ event.info.code);
        if (event.info.code == "NetConnection.Connect.Success"){
            initStream();
            connected = true;
            played = false;
        }
		if (event.info.code == "NetConnection.Connect.Closed"){
            connected = false;
            played = false;
		}
    }
    private function initStream():void{
        logInfo("initStream")
        if (ns){
            ns.close();
//            ns.dispose();
            ns.removeEventListener(NetStatusEvent.NET_STATUS, onStreamStatus)
        }
            ns = new NetStream(nc);
            ns.addEventListener(NetStatusEvent.NET_STATUS, onStreamStatus);
            ns.client = this;
//        } else {
//            ns.attach(nc);
//        }
        // Screen
        if(!video){
            video = new Video();
            video.smoothing = true;           // in case of fallback to Video, we listen to the VideoEvent.RENDER_STATE event to handle resize properly and know about the acceleration mode running
            video.addEventListener(VideoEvent.RENDER_STATE, videoStateChange);
        }
        // Video Events
        // the StageVideoEvent.STAGE_VIDEO_STATE informs you if StageVideo is available or not
        if(detected)
            toggleStageVideo(available);
        else
            stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
    }

    private function onStreamStatus(event:NetStatusEvent):void
    {
		logInfo(event.info.code)
    }

    private var detected:Boolean = false;
    private function onStageVideoState(event:StageVideoAvailabilityEvent):void
    {
        detected = true;
        available = inited = (event.availability == StageVideoAvailability.AVAILABLE);
        if (connected)
            toggleStageVideo(available);
    }

    private function toggleStageVideo(on:Boolean):void
    {
        infos = "StageVideo Running (Direct path) : " + on + "\n";
		
		logInfo("toggleStageVideo "+on);
        // If we choose StageVideo we attach the NetStream to StageVideo

        if (on)
        {
            stageVideoInUse = true;
            if ( sv == null )
            {
                sv = stage.stageVideos[0];
                sv.addEventListener(StageVideoEvent.RENDER_STATE, stageVideoStateChange);
            }
            sv.attachNetStream(ns);
            if (classicVideoInUse)
            {
                // If we use StageVideo, we just remove from the display list the Video object to avoid covering the StageVideo object (always in the background)
                stage.removeChild ( video );
                classicVideoInUse = false;
            }
        } else
        {
            // Otherwise we attach it to a Video object
            if (stageVideoInUse)
                stageVideoInUse = false;
            classicVideoInUse = true;

            video.attachNetStream(ns);
            stage.addChildAt(video, 0);
        }

        if ( !played)
        {
            played = true;
            if (filename)
                ns.play(filename);
            if (streamName)
                ns.play(streamName);

        }
    }

    private function resize ():void
    {
        if ( stageVideoInUse )
        {
            // Get the Viewport viewable rectangle
            rc = getVideoRect(sv.videoWidth, sv.videoHeight);
            // set the StageVideo size using the viewPort property
            sv.viewPort = rc;
        } else
        {
            // Get the Viewport viewable rectangle
            rc = getVideoRect(video.videoWidth, video.videoHeight);
            // Set the Video object size
            video.width = rc.width;
            video.height = rc.height;
            video.x = rc.x, video.y = rc.y;
        }

        interactiveThumb.x = BORDER, interactiveThumb.y = stage.stageHeight - (BORDER << 1);
        legend.text = infos;
    }
    private function onResize(event:Event):void
    {
        resize();
    }

    private function stageVideoStateChange(event:StageVideoEvent):void{
        logInfo("StageVideoEvent Render State : " + event.status);
        resize();
    }

    private function videoStateChange(event:VideoEvent):void{
        logInfo("VideoEvent Render State : " + event.status);
        resize();
    }

    private function getVideoRect(width:uint, height:uint):Rectangle
    {
        var videoWidth:uint = width;
        var videoHeight:uint = height;
        var scaling:Number = Math.min ( stage.stageWidth / videoWidth, stage.stageHeight / videoHeight );

        videoWidth *= scaling, videoHeight *= scaling;

        var posX:uint = stage.stageWidth - videoWidth >> 1;
        var posY:uint = stage.stageHeight - videoHeight >> 1;

        videoRect.x = posX;
        videoRect.y = posY;
        videoRect.width = videoWidth;
        videoRect.height = videoHeight;

        return videoRect;
    }


    private function onKeyDown(event:KeyboardEvent):void{
        if (connected)
        if ( event.keyCode == Keyboard.O )
        {
            if ( available )
            // We toggle the StageVideo on and off (fallback to Video and back to StageVideo)
                toggleStageVideo(inited=!inited);

        } else if ( event.keyCode == Keyboard.F ){
            stage.displayState = StageDisplayState.FULL_SCREEN;
        }
    }
    private function onFrame(event:Event):void
    {
        var ratio:Number = (ns.time / totalTime) * (stage.stageWidth - (BORDER << 1));
        rect.width = ratio;
        thumb.graphics.clear();
        thumb.graphics.beginFill(0xFFFFFF);
        thumb.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
    }

    public function onMetaData ( evt:Object ):void
    {
        var s:String = "META: {"
        for (var v:String in evt ){
            s += v +":" +evt[v]+" ";
        }
        s += "}"; 
		logInfo(s);
//        totalTime = evt.duration;
		if (filename)
	        stage.addEventListener(Event.ENTER_FRAME, onFrame);
    }

    public var onInfo:Function;
    public function logInfo(o:Object):void{
        if(onInfo!=null)
            onInfo(o.toString());
    }
}
}
