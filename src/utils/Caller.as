package utils
{
	import flash.utils.Dictionary;
	
	import utils.ArrayUtil;
	
	/**
	 * @author g7842
	 */	
	public class Caller
	{
		private static var _map:Dictionary = new Dictionary(true);
		
		public function Caller()
		{
			
		}
		
		/**
		 * 加侦听
		 */
		public static function addCmdListener( type:Object, listener:Function ) : void 
		{
			var list:Array = getCmdList(type);
			list.push(listener);
		}
		
		/**
		 * 移除侦听
		 */
		public static function removeCmdListener( type:Object, listener:Function ) : void 
		{
			var list:Array = _map[type] as Array;
			if( list && list.length>0 )
			{
				ArrayUtil.removeItem(list, listener);
			}
		}
		
		/**
		 * 派发事件
		 */
		public static function dispatchCmd( type:Object, ...rect ) : Boolean
		{
			
			var list:Array = getCmdList(type);
			if( list && list.length > 0 )
			{
				for each( var fun:Function in list)
				{
					fun.apply( null , rect );
				}
			}
			return true;
		}
		
		/**
		 * 返回是否有这个侦听
		 */
		public static function hasCmdListener( type:Object ) : Boolean 
		{
			return type in _map;
		}
		
		
		private static function getCmdList(type:Object):Array
		{
			var list:Array
			if( type in _map )
				list = _map[type];
			else
			{
				list = new Array();
				_map[type] = list;
			}
			return list;
		}
		
	}
}