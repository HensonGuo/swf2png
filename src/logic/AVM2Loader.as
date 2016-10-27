package logic
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.errors.EOFError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class AVM2Loader extends Sprite
	{
		private var _urlLoader : URLLoader;
		private var _loader:Loader = new Loader();
		
		private var _clip : MovieClip;
		private var _loaderInfo:LoaderInfo;
		private var _movieType:String;
		
		public function AVM2Loader():void
		{
		}                
		
		//外部得到当前加载的SWF
		public function get movieClip():MovieClip
		{
			return _clip;
		}
		
		override public function get loaderInfo():LoaderInfo
		{
			return _loaderInfo;
		}
		
		public function get movieType():String
		{
			return _movieType;
		}
		
		//加载SWF入口
		public function load(url : String):void
		{
			var path : String = url;
			
			if(!path) 
				return;
			
			if (_urlLoader)
				_urlLoader = null;
			
			//先用一个壳去加载AVM1---SWF
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			_urlLoader.addEventListener(Event.COMPLETE, completeHandler);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			_urlLoader.load( new URLRequest(path));
		}                
		
		private function completeHandler(event:Event):void
		{
			event.currentTarget.removeEventListener(Event.COMPLETE, completeHandler);
			
			//壳加载完成后解析成字节数组
			var inputBytes:ByteArray = ByteArray(_urlLoader.data);
			inputBytes.endian = Endian.LITTLE_ENDIAN;
			
			if (isCompressed(inputBytes)) 
				uncompress(inputBytes);
			
			var version:uint = uint(inputBytes[3]); 
//			if (version <= 10)
//			{ 
//				if (version == 8 || version == 9 || version == 10)
//					flagSWF9Bit(inputBytes);
//				else if (version <= 7)
//					insertFileAttributesTag(inputBytes);
//				_movieType = "AVM1"
//				updateVersion(inputBytes, 9);
//			}
			
			//_movieType的判断类型还是有问题
			if  (version <= 7)
			{
				insertFileAttributesTag(inputBytes);
				_movieType = "AVM1"
			}
			else
			{
				flagSWF9Bit(inputBytes);
				_movieType = "AVM2"
			}
			updateVersion(inputBytes, 9);
			
			/*
			* 以ByteArray形式再对contentLoaderInfo进行加载侦听
			* 一便转换成AVM2中方便使用的SWF
			*/ 
			var cxt:LoaderContext = new LoaderContext();
			cxt.allowCodeImport = true;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
			_loader.loadBytes(inputBytes, cxt);
		}
		
		private function loadCompleteHandler(event : Event) : void
		{
			event.currentTarget.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			
			//OK 得到我们想要的东西了
			_loaderInfo = _loader.content.loaderInfo;
			_clip = _loader.content as MovieClip;
			
			dispatchEvent(event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR));
		}
		
		/*
		*  以下为将加载的AVM1的壳进行ByteArray转换
		*/                
		private function isCompressed(bytes:ByteArray):Boolean
		{
			return bytes[0] == 0x43;
		}                
		
		private function uncompress(bytes:ByteArray):void
		{
			var cBytes:ByteArray = new ByteArray();
			cBytes.writeBytes(bytes, 8);
			bytes.length = 8;
			bytes.position = 8;
			cBytes.uncompress();
			bytes.writeBytes(cBytes);
			bytes[0] = 0x46;
			cBytes.length = 0;
		}                
		
		private function getBodyPosition(bytes:ByteArray):uint
		{
			var result:uint = 0;                        
			result += 3; // FWS/CWS
			result += 1; // version(byte)
			result += 4; // length(32bit-uint)                        
			var rectNBits:uint = bytes[result] >>> 3;
			result += (5 + rectNBits * 4) / 8; // stage(rect)                        
			result += 2;                        
			result += 1; // frameRate(byte)
			result += 2; // totalFrames(16bit-uint)                        
			return result;
		}                
		
		private function findFileAttributesPosition(offset:uint, bytes:ByteArray):uint
		{
			bytes.position = offset;                        
			try {
				for (;;) {
					var byte:uint = bytes.readShort();
					var tag:uint = byte >>> 6;
					if (tag == 69) {
						return bytes.position - 2;
					}
					var length:uint = byte & 0x3f;
					if (length == 0x3f) {
						length = bytes.readInt();
					}
					bytes.position += length;
				}
			}
			catch (e:EOFError) {
			}                        
			return NaN;
		}
		
		private function flagSWF9Bit(bytes:ByteArray):void
		{
			var pos:uint = findFileAttributesPosition(getBodyPosition(bytes), bytes);
			if (!isNaN(pos)) {
				bytes[pos + 2] |= 0x08;
			}
		}
		private function insertFileAttributesTag(bytes:ByteArray):void
		{
			var pos:uint = getBodyPosition(bytes);
			var afterBytes:ByteArray = new ByteArray();
			afterBytes.writeBytes(bytes, pos);
			bytes.length = pos;
			bytes.position = pos;
			bytes.writeByte(0x44);
			bytes.writeByte(0x11);
			bytes.writeByte(0x08);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			bytes.writeBytes(afterBytes);
			afterBytes.length = 0;
		}
		
		private function updateVersion(bytes:ByteArray, version:uint):void
		{
			bytes[3] = version;
		}
		
	}
	
}