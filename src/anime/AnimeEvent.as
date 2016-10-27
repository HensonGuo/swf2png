package anime {
	import flash.events.Event;
	
	public class AnimeEvent extends Event {
		
		/**
		* Defines the value of the type property of a progress event object.
		*/
		public static const PROGRESS:String = "progress";
		
		/**
		* The Event.COMPLETE constant defines the value of the type property of a complete event object.
		*/
		public static const COMPLETE:String = "complete";
		
		public function AnimeEvent(_type:String):void {
			super(_type, false, false);
		}
		
		public override function clone():Event {
			return new AnimeEvent(type);
		}
		
		public function get bytesLoaded():uint {
			return target.bytesLoaded;
		}
		
		public function get bytesTotal():uint {
			return target.bytesTotal;
		}
	}
}