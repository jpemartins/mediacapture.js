package device.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public final class RecordingEvent extends Event
	{
		public static const RECORDING:String = "recording";
		
		private var _time:Number;
		private var _diff:Number;
		private var _frames:ByteArray;
		
		/**
		 * 
		 * @param type
		 * @param time
		 * 
		 */		
		public function RecordingEvent(type:String, time:Number)
		{
			super(type, false, false);
			_time = time;
			_frames = null;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get diff():Number
		{
			return _diff;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set diff(value:Number):void
		{
			_diff = value;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get time():Number
		{
			return _time;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set time(value:Number):void
		{
			_time = value;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get frames():ByteArray
		{
			return _frames;
		}

		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set frames(value:ByteArray):void
		{
			_frames = value;
		}

		/**
		 * 
		 * @return 
		 * 
		 */		
		public override function clone(): Event
		{
			return new RecordingEvent(type, _time)
		}
	}
}
