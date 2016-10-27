package utils
{
	public class ArrayUtil
	{
		public function ArrayUtil()
		{
		}
		
		public static const MergeType_Plus:int = 1;			//加法合并 
		public static const MergeType_Sub:int = 2;			//减法合并
		public static const MergeType_Replace:int = 3;		//替换
		
		/**
		 * 删除数组项 
		 * @param array
		 * @param item
		 * 
		 */		
		public static function removeItem( array:Array , item:Object ):Boolean
		{
			var len:int = array.length;
			for( var i:int = 0;i < len;i++)
			{
				if( array[i] == item )
				{
					array.splice(i,1);
					return true;
				}
			}
			return false;
		}
		
		public static function removeArray(array1:Array,array2:Array):void
		{
			var array2Length:int = array2.length;
			for(var i:int = 0;i < array2Length;i++)
			{
				removeItem(array1,array2[i]);
			}
		}
		
		/**
		 * 数组合并 
		 * @param array1
		 * @param array2
		 * @param key 合并主键
		 * @param mergeType
		 * @return 
		 * 
		 */
		public static function merge(array1:Array,array2:Array,key:*,value:*,mergeType:int = 0):Array
		{
			var result:Array;
			var obj1:Object;
			var obj2:Object;
			
			if(!array1 || array1.length == 0)
			{
				result = array2;
				for each(obj2 in result)
				{
					switch(mergeType)
					{
						case MergeType_Sub:
							obj2[value] = -obj2[value];
							break;
					}
				}
				return result;
			}
			
			if(!array2 || array2.length == 0)
			{
				result = array1;
				return result;
			}
			
			if(!key)
			{
				result = array1.concat(array2);
				return result;
			}
			
			var findList:Array  = [];
			var notFindList:Array = [];
			
			if(!result)
			{
				result = [];
			}
			
			for(var i:int = 0; i < array1.length; i++)
			{
				obj1 = array1[i];
				if(obj1.hasOwnProperty(key))
				{
					for(var j:int = 0; j < array2.length; j++)
					{
						obj2 = array2[j];
						
						if(notFindList.indexOf(j) == -1 && findList.indexOf(j) == -1)
						{
							notFindList.push(j);
						}
						
						if(obj2.hasOwnProperty(key))
						{
							if(obj1[key] == obj2[key])
							{
								if(findList.indexOf(j) == -1)
								{
									findList.push(j);
								}
								
								if(notFindList.indexOf(j) != -1)
								{
									notFindList.splice(notFindList.indexOf(j),1);
								}
								
								switch(mergeType)
								{
									case MergeType_Plus:
										obj1[value] += obj2[value];
										break;
									case MergeType_Sub:
										obj1[value] -= obj2[value];
										break;
									case MergeType_Replace:
										obj1[value] = obj2[value];
										break;
								}
							}
						}
					}
					result.push(obj1);
				}
			}
			
			if(notFindList.length > 0)
			{
				for each(var k:int in notFindList)
				{
					obj2 = array2[k];
					if(mergeType == MergeType_Sub)
					{
						obj2[value] = -obj2[value];
					}
					result.push(obj2);
				}
			}
			
			return result;
		}
		
		/**
		 * 对数组进行排序 
		 * @param ary	排序数组
		 * @param isDesc 是否降序排序
		 * 
		 */	
		public static function soryNumberAry(ary:Array,isDesc:Boolean = true):void
		{
			if(isDesc)
			{
				ary.sort(sortDesc);
			}
			else
			{
				ary.sort(sortAsc);
			}
		}
		
		private static function sortDesc(number1:Number,number2:Number):int
		{
			if(number1 > number2)
			{
				return -1;
			}
			else if(number1 < number2)
			{
				return 1;
			}
			return 0;
		}
		
		private static function sortAsc(number1:Number,number2:Number):int
		{
			if(number1 > number2)
			{
				return 1;
			}
			else if(number1 < number2)
			{
				return -1;
			}
			return 0;
		}
		
		/**
		 * 计算两个数组的差集 
		 * @param array1
		 * @param array2
		 * @return 
		 * 
		 */		
		public static function cut(array1:Array,array2:Array):Array
		{
			var ary:Array = new Array();
			for each(var obj:* in array2)
			{
				var index:int = array1.indexOf(obj);
				if(index == -1)
				{
					ary.push(obj);
				}
			}
			return ary;
		}
		
		/**
		 * 计算两个数组的和集 
		 * @param array1
		 * @param array2
		 * @return 
		 * 
		 */		
		public static function add(array1:Array,array2:Array):Array
		{
			var ary:Array = new Array();
			var obj:*;
			for each(obj in array1)
			{
				ary.push(obj);
			}
			for each(obj in array2)
			{
				var index:int = ary.indexOf(obj);
				if(index == -1)
				{
					ary.push(obj);
				}
			}
			return ary;
		}
	}
}