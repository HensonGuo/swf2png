package anime {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	import utils.Caller;
	
	public class Anime extends MovieClip {
		
		private var cels:Array;
		private var _centering:Boolean;
		private var _smoothing:Boolean;
		private var _bytesLoaded:Array;
		private var _bytesTotal:Array;
		private var _currentFrame:int;
		private var _totalFrames:int;
		private var _loop:Boolean;
		
		private var _isDestoryed:Boolean = true;
		public static const Destoryed:String = 'Destoryed';
		
		private var _skippedFrames:int = 0;
		private var _skipFrame:int = 0;
		
		public function Anime():void {
			
		}
		
		/**
		 * @param _head
		 * @param _num
		 * @param _tail
		 * @param _begin
		 * @param _figure
		 * @param _center
		 * @param _smooth
		 */		
		public function setParams(_head:String = "", _num:int = 1, _tail:String = ".png", _begin:int = 0, _figure:int = 0, _center:Boolean = false, _smooth:Boolean = false, loop:Boolean = false, skipFrames:int = 0):void
		{
			if (!isDestroyed)
				destory();
			
			_isDestoryed = false;
			
			cels = new Array();
			_centering = _center;
			_smoothing = _smooth;
			_bytesLoaded = new Array();
			_bytesTotal = new Array();
			_currentFrame = 1;
			_totalFrames = _num;
			_skipFrame = skipFrames;
			
			var l:int = _begin + _num - 1;
			var loader:Loader;
			var file:String;
			var url:String;
			
			for (var i:int = _begin; i <= l; i ++) {
				
				file = String(i);
				if (_figure != 0) {
					file = ("0000000000" + file).substr(-_figure);
				}
				url = _head + file + _tail;
				loader = new Loader();
				loader.load(new URLRequest(url));
				
				addChild(loader);
				loader.visible = false;
				cels.push(loader);
				
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, Progress(i));
				if (i == l) {
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, Complete);
				}
			}
			
			_loop = loop;
		}
		
		
		/** Progress
		 * @param _loader
		 * @return void
		*/
		private function Progress(_loader:int):Function {
			return function(e:ProgressEvent):void {
				_bytesLoaded[_loader] = e.bytesLoaded;
				_bytesTotal[_loader] = e.bytesTotal;
				dispatchEvent(new AnimeEvent("progress"));
			}
		}
		
		
		/** Completed
		 * @param e Eventt
		 * @return void
		*/
		private function Complete(e:Event):void {
			if (_centering) {
				this.centering = _centering;
			}
			if (_smoothing) {
				this.smoothing = _smoothing;
			}
			Show(_currentFrame);
			dispatchEvent(new AnimeEvent("complete"));
		}
		
		
		/** Show
		 * @return void
		*/
		private function Show(_frame:int):void {
			if (_frame < 1) {
				_frame = _totalFrames;
			}
			else if (_frame > _totalFrames) {
				if (_loop)
					_frame = 1;
				else
				{
					destory();
					return;
				}
			}
			cels[(_currentFrame - 1)].visible = false;
			cels[(_frame - 1)].visible = true;
			_currentFrame = _frame;
		}
		
		
		/** EnterFrame
		 * @param e Event
		 * @return 無し
		*/
		private function EnterFrame(e:Event):void {
			if (_skippedFrames == _skipFrame)
			{
				Show((currentFrame + 1));
				_skippedFrames = 0;
			}
			else
				_skippedFrames ++;
		}
		
		
		/** gotoAndPlay
		 * @param _frame playhead to the specified frame
		 * @return void
		*/
		override public function gotoAndPlay(_frame:Object, _scene:String=null):void {
			Show(int(_frame));
			play();
		}
		
		
		/** gotoAndStop
		 * @param _frame playhead to the specified frame
		 * @return void
		*/
		override public function gotoAndStop(_frame:Object, _scene:String=null):void {
			Show(int(_frame));
			stop();
		}
		
		
		/** nextFrame
		 * @return void
		*/
		override public function nextFrame():void {
			Show((_currentFrame + 1));
			stop();
		}
		
		
		/** play
		 * @return void
		*/
		override public function play():void {
			addEventListener(Event.ENTER_FRAME, EnterFrame);
		}
		
		
		/** prevFrame
		 * @return void
		*/
		override public function prevFrame():void {
			Show((_currentFrame - 1));
			stop();
		}
		
		
		/** stop
		 * @return void
		*/
		override public function stop():void {
			removeEventListener(Event.ENTER_FRAME, EnterFrame);
		}
		
		
		/** centering
		 * @param _center true=on false=off
		 * @return void
		*/
		public function set centering(_center:Boolean):void {
			for (var i:int = 0; i < _totalFrames; i ++) {
				try {
					if (_center) {
						cels[i].x = -cels[i].width / 2;
						cels[i].y = -cels[i].height / 2;
					}
					else {
						cels[i].x = cels[i].y = 0;
					}
				}
				catch (e:Error) {
					
				}
			}
			_centering = _center;
		}
		
		/** centering
		 * @return true=on false=off
		*/
		public function get centering():Boolean {
			return _centering;
		}
		
		/** smoothing
		 * @param _smooth true=on false=off
		 * @return void
		*/
		public function set smoothing(_smooth:Boolean):void {
			for (var i:int = 0; i < _totalFrames; i ++) {
				try {
					var bmp:Bitmap = Bitmap(cels[i].content);
					bmp.smoothing = _smooth;
				}
				catch (e:Error) {
					
				}
			}
			_smoothing = _smooth;
		}
		
		/** smoothing
		 * @return true=on false=off
		*/
		public function get smoothing():Boolean {
			return _smoothing;
		}
		
		/** bytesLoaded
		 * @return bytes
		*/
		public function get bytesLoaded():uint {
			var data:uint = 0;
			for (var i:int = 0; i < _bytesLoaded.length; i ++) {
				try {
					data += _bytesLoaded[i];
				}
				catch (e:Error) {
					
				}
			}
			return data;
		}
		
		/** bytesTotal
		 * @return bytes
		*/
		public function get bytesTotal():uint {
			var data:uint = 0;
			for (var i:int = 0; i < _bytesTotal.length; i ++) {
				try {
					data += _bytesTotal[i];
				}
				catch (e:Error) {
					
				}
			}
			return data;
		}
		
		/** currentFrame
		 * @return current frame number
		*/
		override public function get currentFrame():int {
			return _currentFrame;
		}
		
		/** totalFrames
		 * @return total frame number
		*/
		override public function get totalFrames():int {
			return _totalFrames;
		}
		
		public function destory():void
		{
			if (_isDestoryed)
				return;
			stop();
			cels[(_currentFrame - 1)].visible = false;
			for (var i:int = 0; i < cels.length; i++)
			{
				var loader:Loader = cels[i];
				this.removeChild(loader);
			}
			cels.length = 0;
			_bytesLoaded.length = 0;
			_bytesTotal.length = 0;
			_isDestoryed = true;
			_skipFrame = 0;
			_skippedFrames = 0;
//			Caller.dispatchCmd(Destoryed);
		}
		
		public function get isDestroyed():Boolean
		{
			return _isDestoryed;
		}
		
	}
}