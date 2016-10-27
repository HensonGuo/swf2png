package ui
{
	import anime.Anime;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import utils.Caller;

	public class PreviewWindow extends Window
	{
		private var _anima:Anime;
		private const _offsetWidth:int = 20;
		private const _offsetHeight:int = 40;
		
		public function PreviewWindow()
		{
			_alwaysInFront = true;
//			_systemChrome = NativeWindowSystemChrome.NONE;
//			_transparent = true;
			_anima = new Anime();
			this.addChild(_anima);
			
			Caller.addCmdListener(Anime.Destoryed, close);
		}
		
		public function setParams(head:String = "", num:int = 1, tail:String = ".png", begin:int = 0, figure:int = 0, center:Boolean = false, smooth:Boolean = false, loop:Boolean = false, skipFrames:int = 0):void
		{
			_anima.setParams(head, num, tail, begin, figure, center, smooth, loop, skipFrames);
		}
		
		override public function open():void
		{
			super.open();
			_anima.play();
		}
		
		override public function close(event:Event=null):void
		{
			super.close(event);
			_anima.destory();
		}
		
		override public function setSize(width:Number, height:Number):void
		{
			width += _offsetWidth;
			height += _offsetHeight;
			super.setSize(width, height);
			_nativeWin.x = (Screen.mainScreen.visibleBounds.width - width) / 2;
			_nativeWin.y = (Screen.mainScreen.visibleBounds.height - height) / 2;
		}
		
	}
}