package {

import avmplus.factoryXml;

import com.greensock.TweenLite;
import com.greensock.easing.Circ;
import com.greensock.easing.Quad;

import flash.display.Bitmap;

import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.StageVideoAvailabilityEvent;
import flash.geom.Rectangle;
import flash.media.StageVideo;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.ui.Mouse;


[SWF (width="1280",height=720,frameRate=30)]

public class SVPlayer extends Sprite {


    private var textField:TextField;
    public function SVPlayer() {
        textField = new TextField();
        textField.textColor = 0x11DD22;
        textField.selectable = false;
        textField.text = "Loading";
        addChild(textField);
        stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, _onStageVideoAvailability);
        try
        {
            stage.addEventListener(MouseEvent.RIGHT_CLICK,fullscreenToggle);
            stage.addEventListener(MouseEvent.CLICK,fullscreenToggle);
        }
        catch(error:Error)
        {
            stage.addEventListener(MouseEvent.CLICK,fullscreenToggle);
        }
    }

    final function fullscreenToggle(event:MouseEvent):void {
        if (stage.displayState == StageDisplayState.FULL_SCREEN){
            stage.displayState = StageDisplayState.NORMAL;
        } else {
            stage.displayState = StageDisplayState.FULL_SCREEN;
        }
    }


    private var availabilityStageVideo:Boolean = false;
    final function _onStageVideoAvailability ( evt : StageVideoAvailabilityEvent ) : void {
        if(evt.availability == "available")
            availabilityStageVideo = true;
        else
            availabilityStageVideo = false;
        connect();
    }


    private var video:Video;
    private var ns:NetStream;
    private var nsClient:Object = {};
    private var stageVideo:StageVideo;
    private var logo:Logo;
final function connect():void
    {
        nsClient.onBWDone = function():void	{trace("BWDone");}
        nsClient.onMetaData = function():void {trace("onMetaData");}
        nsClient.onCuePoint = function():void {trace("onCuePoint");}
        textField.text = "Connecting";
        var nc:NetConnection = new NetConnection();
        nc.client = nsClient;
        nc.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
        nc.connect("rtmp://195.110.52.107:1935/stream/serf");
        textField.text = "Connect..";
    }

    final function onNetStatus(event:NetStatusEvent):void
    {
        trace(event);
        var nc:NetConnection = event.target as NetConnection;
        if (event.info.code == "NetConnection.Connect.Success")
        {

            textField.text = "Success..";
            ns = new NetStream(nc);
            ns.client = nsClient;
            ns.play("serf");
            textField.text = "Play..";
            if (availabilityStageVideo){
                textField.text = "GPU rendering";
                stageVideo = stage.stageVideos[0];
                stageVideo.viewPort = new Rectangle ( 0 , 0 , 1280 , 720 );
                stageVideo.attachNetStream(ns);
            }   else {
                textField.text = "Software rendering";

                if (!video){
                    video = new Video();
                    addChild(video);
                }

                video.height = 720;
                video.width = 1280;
                video.attachNetStream(ns);

            }


            if (!logo){
                logo = new Logo();
    //            logo.x = stage.stageWidth/2 + logo.width/2;
                //logo.y = stage.stageHeight/2;
                logo.alpha = 0;
                var newX:int = stage.stageWidth;
                logo.x = newX+logo.width/8;
                logo.y = -logo.height/20;
                logo.scaleX = 0.1;
                logo.scaleY = 0.1;
                TweenLite.to(logo,2,{alpha:0.5,x:newX,y:0,scaleX:0.3,scaleY:0.3,ease:Circ.easeOut});
                addChild(logo);
            }
        }
    }
}
}
