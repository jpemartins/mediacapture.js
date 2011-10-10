package {
	// Flash libs
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.utils.Dictionary;

	import org.as3wavsound.WavSound;
	import org.bytearray.micrecorder.MicRecorder;
	import org.bytearray.micrecorder.encoder.WaveEncoder;

	import device.CamRecorder;

	/**
	  * MicRecorder code from http://www.bytearray.org/?p=1858
	  * - Modifications to get samples during recording
	  */

	[SWF(width="320", height="240", frameRate="31", backgroundColor="#FFFFFF")]
    public class MediaCapture extends Sprite {
		private var mic:MicRecorder = new MicRecorder( new WaveEncoder());
		private var cam:CamRecorder = new CamRecorder();
		private var mic_recording:Boolean;
		private var cam_recording:Boolean;

		private var flags:Dictionary = new Dictionary();

		private var _audio_duration:uint; // Duration
		private var _video_duration:uint; // Duration

		private var _audio_limit:uint; // Limit
		private var _video_limit:uint; // Limit
	
		public function MediaCapture() {
			flags['CAPTURE_INTERNAL_ERR'] = 0;
			flags['CAPTURE_APPLICATION_BUSY'] = 1;
			flags['CAPTURE_INVALID_ARGUMENT'] = 2;
			flags['CAPTURE_NO_MEDIA_FILES'] = 3;
			
			ExternalInterface.addCallback("initMicrophone", initMicrophone);
			ExternalInterface.addCallback("initCamera", initCamera);

			ExternalInterface.addCallback("captureImage", captureImage);
			ExternalInterface.addCallback("captureAudio", captureAudio);
			ExternalInterface.addCallback("captureVideo", captureVideo);
			
			ExternalInterface.addCallback("cancelAudio", cancelAudio);
			ExternalInterface.addCallback("cancelVideo", cancelVideo);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function onAddedToStage(event:Event):void {
			//recorder.addEventListener(RecordingEvent.RECORDING, onRecording);			
		}

		public function initMicrophone(limit:String, duration:String):void {
			_audio_limit = int(limit);
			_audio_duration = int(duration);
			mic.init();
			mic.addEventListener(Event.COMPLETE, onAudioRecordComplete);
		}

		public function initCamera(limit:String, duration:String):void {
			_video_limit = int(limit);
			_video_duration = int(duration);
			cam.init();
			addChild(cam.placeholder);			
		}

		public function captureImage(codec:String):void {			
			var frame:String = Base64.encode(cam.takePicture(codec));
			--_video_limit;

			if (ExternalInterface) {
			    ExternalInterface.call("__mediacapture_cameracomplete", frame);
			}

			if (_video_limit == 0 || !_video_limit) {				
				removeChild(cam.placeholder);
			}
		}


		public function captureAudio():void {
			if (!mic_recording)
				mic.record();
			else if (ExternalInterface)
			    ExternalInterface.call("__mediacapture_audioerror", flags['CAPTURE_APPLICATION_BUSY']);
			
			
			mic_recording = !mic_recording;

			if (_audio_duration > 0) {
				var timer:Timer = new Timer(_audio_duration, 1); // miliseconds

				function runOnce(event:TimerEvent):void {
					mic.stop();
					mic_recording = false;
				}

				timer.addEventListener(TimerEvent.TIMER, runOnce);
				timer.start();
			}

			--_audio_limit;
			if (_audio_limit == 0) {								
			}	
		}

		public function captureVideo():void {
		}

		public function cancelAudio():void {
			mic.stop();
			mic_recording = false;
		}

		public function cancelVideo():void {
			cam.stop();
			cam_recording = false;
		}

		public function onAudioRecordComplete(event:Event):void {
			var samples:String = Base64.encode(mic.output);
			if (ExternalInterface) {
			    ExternalInterface.call("__mediacapture_audiocomplete", samples);
			}			
		}
		
		public function onCameraRecordComplete(event:Event):void {
			var samples:String = Base64.encode(cam.output);
			if (ExternalInterface) {
			    ExternalInterface.call("__mediacapture_cameracomplete", samples);
			}
		}			
	}
}