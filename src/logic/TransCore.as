package logic
{
	import com.adobe.images.PNGEncoder;
	
	import flash.display.BitmapData;
	import flash.display.BitmapEncodingColorSpace;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.PNGEncoderOptions;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import utils.Caller;
	

	public class TransCore
	{
		public static const TransComplete:String = 'TransComplete';
		
		private var _transInfoOutputFunc:Function
		private var _prefix:String;
		private var _fileUrl:String;
		private var _exportDirUrl:String;
		private var _scaleFactor:Number;
		private var _skipFrames:int;
		
		private var _loader:AVM2Loader;
		private var _loadedSwf:MovieClip;
		
		public var maxWidth:Number;
		public var maxHeight:Number;
		public var totalFrames:int;
		
		private var _timer:Timer;
		private var _counter:int;
		
		private var _isCompress:Boolean;
		private var _smoothing:Boolean;
		
		public function TransCore(transInfoOutputFunc:Function)
		{
			_transInfoOutputFunc = transInfoOutputFunc;
		}
		
		public function startTrans(prefix:String, fileUrl:String, exportDirUrl:String, scaleFactor:Number, skipFrames:int = 0,  isCompress:Boolean = false, smoothing:Boolean = false):void
		{
			reset();
			_prefix= prefix;
			_fileUrl = fileUrl;
			_exportDirUrl = exportDirUrl;
			_scaleFactor = scaleFactor;
			_skipFrames = skipFrames;
			_isCompress = isCompress
			_smoothing = smoothing;
			
			_loader = new AVM2Loader();
			_transInfoOutputFunc("Loading " + _fileUrl);
			_loader.load("file://" + _fileUrl);
			_loader.addEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		private function reset():void
		{
			_counter = 0;
		}
		
		private function onLoadComplete(ev:Event):void {
			_loadedSwf = _loader.movieClip;
			maxWidth = Math.ceil(_loader.loaderInfo.width) * _scaleFactor;
			maxHeight = Math.ceil(_loader.loaderInfo.height) * _scaleFactor;
			totalFrames = _loadedSwf.totalFrames;
			
			_transInfoOutputFunc("Loaded!");
			_transInfoOutputFunc("\tmovieType:\t\t\t" + _loader.movieType, Swf2png.LogInfo)
			_transInfoOutputFunc("\tswfVersion:\t\t\t" + _loader.loaderInfo.swfVersion, Swf2png.LogInfo);
			_transInfoOutputFunc("\tsize: \t\t\t\t" + int(_loader.loaderInfo.bytesLoaded / 1024), Swf2png.LogInfo);
			_transInfoOutputFunc("\tframeCount: \t\t" + totalFrames, Swf2png.LogInfo);
			_transInfoOutputFunc("\tframeRate:\t\t\t" + _loader.loaderInfo.frameRate, Swf2png.LogInfo);
			_transInfoOutputFunc("\twidth:\t\t\t\t" + _loader.loaderInfo.width, Swf2png.LogInfo);
			_transInfoOutputFunc("\theight:\t\t\t\t" + _loader.loaderInfo.height, Swf2png.LogInfo);
			
			stopClip(_loadedSwf);
			goToFrame(_loadedSwf, 0);
			
			var interval:int = 100 * _scaleFactor * (_isCompress ? 2 : 1);
			_timer = new Timer(interval);
			_timer.addEventListener(TimerEvent.TIMER, loop);
			_timer.start();
		}
		
		private function loop(event:TimerEvent):void {
			_counter++;
			var nextFrame:int = _counter * (_skipFrames + 1);
			if(nextFrame <= totalFrames) {
				goToFrame(_loadedSwf, nextFrame);
				saveFrame();
			}
			else {
				_timer.stop();
				_transInfoOutputFunc("Done!");
				Caller.dispatchCmd(TransComplete, _counter - 1, _skipFrames);
				return;
			}
		}
		
		private function goToFrame(inMc:MovieClip, frameNo:int):void {
			var l:int = inMc.numChildren;
			for (var i:int = 0; i < l; i++) 
			{
				var mc:MovieClip = inMc.getChildAt(i) as MovieClip;
				if(mc) {
					mc.gotoAndStop(frameNo % (inMc.totalFrames + 1));
					if(mc.numChildren > 0) {
						goToFrame(mc, frameNo);
					}
				}
			}
			inMc.gotoAndStop(frameNo % inMc.totalFrames);
		}
		
		private function saveFrame():void {
			var bitmapData:BitmapData = new BitmapData(maxWidth, maxHeight, true, 0x0);
			var quality:String = _isCompress ? StageQuality.LOW : StageQuality.BEST
			bitmapData.drawWithQuality(_loadedSwf, new Matrix(_scaleFactor, 0, 0, _scaleFactor, 0, 0), null, null, null, _smoothing, quality)
//			var bytearr:ByteArray = PNGEncoder.encode(bitmapData);
			var bytearr:ByteArray = new ByteArray();
			bitmapData.encode(new Rectangle(0,0, maxWidth, maxHeight),  new PNGEncoderOptions(!_isCompress), bytearr);
			var increment:String = '';
			if(totalFrames > 1) 
			{
				increment = "_" + padNumber(_counter, totalFrames / (_skipFrames + 1));
			}
			var outfileName:String = _exportDirUrl + File.separator + _prefix + increment + ".png"
			var file:File = new File(outfileName);
			_transInfoOutputFunc("Writing: " + outfileName);
			var stream:FileStream = new FileStream();
			stream.open(file, "write");
			stream.writeBytes(bytearr);
			stream.close();
		}
		
		private function padNumber(input:int, target:int):String {
			var out:String = input.toString();
			var targetCount:int = target.toString().length;
			while(out.length < targetCount) {
				out = '0' + out;
			}
			return out;
		}
		
		private function stopClip(inMc:MovieClip):void {
			var l:int = inMc.numChildren;
			for (var i:int = 0; i < l; i++) 
			{
				var mc:MovieClip = inMc.getChildAt(i) as MovieClip;
				if(mc) {
					mc.stop();
					if(mc.numChildren > 0) {
						stopClip(mc);
					}
				}
			}
			inMc.stop();
		}
		
	}
}