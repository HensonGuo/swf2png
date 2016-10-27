package ui
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	public class Window extends Sprite
	{
		protected var _nativeWin:NativeWindow;
		
		protected var _minimizable:Boolean = true;
		protected var _maximizable:Boolean = true;
		protected var _resizable:Boolean = true;
		protected var _type:String = NativeWindowType.UTILITY
		protected var _systemChrome:String = NativeWindowSystemChrome.STANDARD;
		protected var _transparent:Boolean = false;
		protected var _renderMode:String = "auto";
		protected var _alwaysInFront:Boolean = false;
		
		public function Window()
		{
			super();
		}
		
		public function open():void
		{
			if (!_nativeWin)
			{
				var init:NativeWindowInitOptions = setupWindowInitOptions();
				_nativeWin = new NativeWindow(init);
				_nativeWin.stage.addChild(this);
				_nativeWin.stage.align = StageAlign.TOP_LEFT;
				_nativeWin.stage.scaleMode = StageScaleMode.NO_SCALE;
				_nativeWin.alwaysInFront = _alwaysInFront;
				//default
				_nativeWin.width = 150;
				_nativeWin.height = 150;
				
				_nativeWin.activate();
				_nativeWin.addEventListener(Event.CLOSE, close);
			}
		}
		
		public function close(event:Event = null):void
		{
			if (_nativeWin)
			{
				_nativeWin.stage.removeChild(this);
				_nativeWin.close();
				_nativeWin = null;
			}
		}
		
		protected function setupWindowInitOptions():NativeWindowInitOptions
		{
			var init:NativeWindowInitOptions = new NativeWindowInitOptions();
			init.maximizable = _maximizable;
			init.minimizable = _minimizable;
			init.resizable = _resizable;
			init.type = _type;
			init.systemChrome = _systemChrome;
			init.transparent = _transparent;
			init.renderMode = _renderMode;
			return init;        
		}
		
		public function setSize(width:Number, height:Number):void
		{
			_nativeWin.width = width;
			_nativeWin.height = height;
		}
		
	}
}