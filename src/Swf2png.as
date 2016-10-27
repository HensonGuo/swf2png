package
{
	import anime.Anime;
	
	import com.adobe.images.PNGEncoder;
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.ScrollPane;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import logic.TransCore;
	
	import ui.PreviewWindow;
	
	import utils.Caller;
	
	[SWF(width="660", height="420", frameRate="24")]
	public class Swf2png extends Sprite
	{
		private var _importLabel:Label
		private var _importFilePath:String;
		
		private var _exportDirPath:String;
		private var _exportDirLabel:Label;
		
		private var _frameComb:ComboBox;
		private var _prefixField:InputText;
		
		private var _scaleFactor:Number;
		private var _scaleField:InputText
		
		private var _isCompressCB:CheckBox;
		private var _isSmoothingCB:CheckBox;
		private var _autoApplySkipFrameCB:CheckBox;
		
		private var _logfield:TextField;
		private var _logPane:ScrollPane;
		
		private var _previewBtn:PushButton
		
		private var _transCore:TransCore;
		private var _anime:Anime;
		private var _previewWin:PreviewWindow;
		
		private var _pngNums:int;
		private var _skippFrames:int;
		
		public function Swf2png() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = 'noScale';
			stage.frameRate = 12;
			stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			initUI();
		}
		
		private function initUI():void
		{
			new PushButton(this, 20, 10, '导入SWF', onImport);
			_importLabel = new Label(this, 150, 10);
			
			new PushButton(this, 20, 40, '设置导出文件夹', onSelectExportDir);
			_exportDirLabel = new Label(this, 150, 40);
			
			new Label(this, 20, 70, '跳帧数:')
			_frameComb = new ComboBox(this, 80, 70, "0", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
			
			new Label(this, 20, 100, '前缀名称')
			_prefixField = new InputText(this, 80, 100)
			_prefixField.height = 20;
			_prefixField.text = 'default';
			
			new Label(this, 20, 130, '缩放比例')
			_scaleField = new InputText(this, 80, 130)
			_scaleField.text = '1';
			
			_isCompressCB = new CheckBox(this, 200, 135, "是否压缩图像");
			_isCompressCB.selected = true;
			
			_isSmoothingCB = new CheckBox(this, 300, 135, "是否平滑处理");
			
			new PushButton(this, 20, 160, '开始转换', onConvert)
			_previewBtn = new PushButton(this, 150, 160, '预览PNG序列效果', onPreview);
			_previewBtn.width = 120;
			_previewBtn.enabled = false;
			
			_autoApplySkipFrameCB = new CheckBox(this, 300, 164, "是否根据跳帧数来调整预览效果");
			_autoApplySkipFrameCB.enabled = false;
			
			_logfield = new TextField();
			_logfield.multiline = true;
//			_logfield.wordWrap = true;
			_logfield.autoSize = TextFieldAutoSize.LEFT;
			_logPane = new ScrollPane(this);
			_logPane.y = 200;
			_logPane.width = stage.stageWidth;
			_logPane.height = stage.stageHeight - 200;
			_logPane.addChild(_logfield);
			
			log('如有问题请联系gzylguo@corp.netease.com', LogWarn, false);
			
			_anime = new Anime();
			_previewWin = new PreviewWindow();
			
			_transCore = new TransCore(log);
			Caller.addCmdListener(TransCore.TransComplete, onTransComplete);
		}
		
		private function onResize(event:Event):void
		{
			if (_logPane == null)
				return;
			_logPane.width = stage.stageWidth;
			_logPane.height = stage.stageHeight - 200;
		}
		
		private function onImport(event:MouseEvent):void{
			var file:File = new File();
			file.addEventListener(Event.SELECT, onImportComplete);
			var fileFilter:FileFilter = new FileFilter("Swf文件 *.swf", "*.swf");
			file.browseForOpen("请选择一个swf文件", [fileFilter]);
		}
		
		private function onImportComplete(event:Event):void
		{
			_importFilePath = event.target.nativePath;
			_importLabel.text = _importFilePath + '   SIZE: ' + int(event.target.size / 1024) + ' KB';
		}
		
		private function onSelectExportDir(event:MouseEvent):void{
			var file:File = new File();
			file.browseForDirectory('设置导出文件夹')
			file.addEventListener(Event.SELECT, onSelectExportDirComplete);
		}
		
		private function onSelectExportDirComplete(event:Event):void
		{
			_exportDirPath = event.target.nativePath;
			_exportDirLabel.text = _exportDirPath;
		}
		
		private function onConvert(event:MouseEvent):void{
			if (_importFilePath == ''|| _importFilePath == null)
			{
				log('请先选择一个swf文件', LogWarn);
				return;
			}
			if(_exportDirPath == '' || _exportDirPath == null)
			{
				log('请先设置好png序列的导出目录', LogWarn);
				return;
			}
			
			_scaleFactor = Number(_scaleField.text);
			if (_scaleFactor <= 0)
			{
				log('Scale Factor Invalid', LogWarn)
				return;
			}
			log("Input file: " + _importFilePath);
			log("Output directory: " + _exportDirPath);
			
			var skipFrames:int = int(_frameComb.selectedItem);
			var smoothing:Boolean = _isSmoothingCB.selected;
			_transCore.startTrans(_prefixField.text, _importFilePath, _exportDirPath, _scaleFactor, skipFrames, _isCompressCB.selected, smoothing);
			_previewBtn.enabled = false;
			_autoApplySkipFrameCB.enabled = false;
		}
		
		private function onPreview(event:MouseEvent):void
		{
			var figure:int = _pngNums.toString().length;
			var skippedFrames:int = _autoApplySkipFrameCB.selected ? _skippFrames : 0;
			_previewWin.setParams(_exportDirPath + '\\' + _prefixField.text + '_', _pngNums, ".png", 1, figure, false, true, false, skippedFrames);
			_previewWin.open();
			_previewWin.setSize(_transCore.maxWidth, _transCore.maxHeight);
			return;
		}
		
		private function onTransComplete(pngNums:int, skippFrames:int):void
		{
			_pngNums = pngNums;
			_skippFrames  = skippFrames
			_previewBtn.enabled = true;
			_autoApplySkipFrameCB.enabled = true;
		}
		
		private var _logColor:String = '';
		public static var LogDebug:int = 0;
		public static var LogInfo:int = 1;
		public static var LogWarn:int = 2;
		
		private function log(message:String="", level:int = 0, add_new_line:Boolean=true):void {
			if (level == LogInfo)
				_logColor = '#009933'
			else if (level == LogWarn)
				_logColor = '#ff0000'
			else
				_logColor = '#000000';
			
			_logfield.htmlText = _logfield.htmlText + (add_new_line ? "</br>" : "") + '<p><font color= "' + _logColor + '">' + message + '</font></p>';
			_logfield.width = _logfield.textWidth + 2;
			_logPane.update();
		}
		
	}
}