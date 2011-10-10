package device
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;

	import flash.media.Camera;
	import flash.media.Video;
	
	import flash.geom.Matrix;	
	
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	import flash.display.Bitmap;
	import flash.display.BitmapData;

	import com.adobe.images.JPGEncoder;
	import com.adobe.images.PNGEncoder;

	[Event(name='recording', type='device.events.RecordingEvent')]
	[Event(name='complete', type='flash.events.Event')]

	/**
	 * This tiny helper class allows you to quickly record the audio stream coming from the camera and save this as a physical file.
	 * A WavEncoder is bundled to save the audio stream as a WAV file
	 * @author João Martins
	 * @version 1.2
	 *
	 */
	public final class CamRecorder extends EventDispatcher
	{
		private var _placeholder:Video = new Video();
		private var _timeOut:uint;
		private var _bandwidth:uint = 0;
		private var _quality:uint = 100;
		private var _recording:Boolean = false;

		
		private var _difference:uint;
		private var _lastTime:uint = 0;
		private var _camera:Camera;
		private var NFRAMES:uint = 1;		

		private var jpg:JPGEncoder = new JPGEncoder();

		private var _output:ByteArray;

		/**
		 *
		 * @param encoder The audio encoder to use
		 * @param camera The camera device to use
		 * @param gain The gain
		 * @param rate Audio rate
		 * @param silenceLevel The silence level
		 * @param timeOut The timeout
		 *
		 */
		public function CamRecorder(camera:Camera=null, timeOut:uint=10000) {
			_camera = camera;
			_timeOut = timeOut;
		}

		public function init():void {
			if ( _camera == null ){
				_camera = Camera.getCamera();
				_bandwidth = 0;
				_quality = 100;		
				_camera.setQuality(_bandwidth, _quality);
				_camera.setMode(320,240,30,false); // (videoWidth, videoHeight, video fps, favor area)			
				_placeholder.attachCamera(_camera);
				//addChild(_placeholder);
			}
		}

		/**
		 * Starts recording from the default or specified camera.
		 * The first time the record() method is called the settings manager may pop-up to request access to the camera.
		 */
		public function record():void {
			init();

			_difference = getTimer();

			_camera.addEventListener(StatusEvent.STATUS, onStatus);
			//_camera.addEventListener(ActivityEvent.STATUS, onMotion);
			_recording = true;
		}

		public function stop():void {
			_camera.removeEventListener(StatusEvent.STATUS, onStatus);
			_recording = true;
			_placeholder.attachCamera(null);
			_camera = null;
		}

		public function takePicture(codec:String):ByteArray {
			var output:BitmapData = new BitmapData(_placeholder.width,_placeholder.height, false);
			output.draw(_placeholder, new Matrix());

			if (codec == "jpeg" || codec == "jpg") {
				return jpg.encode(output);
			}

			if (codec == "png") {
				return PNGEncoder.encode(output);
			}

			return null;
		}

		private function onStatus(event:StatusEvent):void {
			_difference = getTimer();
		}

		/**
		 * Dispatched during the recording.
		 * @param event
		 */
		private function onMotion():void {
			_difference = getTimer();
		}

		/**
		 * Dispatched during the recording.
		 * @param event
		 */
		private function onSampleData(event:SampleDataEvent):void {				
		}

		/**
		 *
		 * @return
		 *
		 */
		public function get placeholder():Video {
			return _placeholder;
		}

		/**
		 *
		 * @param value
		 *
		 */
		public function set placeholder(value:Video):void {
			_placeholder = value;
		}

		/**
		 *
		 * @return
		 *
		 */
		public function get camera():Camera {
			return _camera;
		}

		/**
		 *
		 * @param value
		 *
		 */
		public function set camera(value:Camera):void {
			_camera = value;
		}

		/**
		 *
		 * @return
		 *
		 */
		public function get output():ByteArray {
			return null
		}


		/**
		 *
		 * @return
		 *
		 */
		public override function toString():String {
			return "CamRecorder: FPS=, FRAMES=";
		}
	}
}
