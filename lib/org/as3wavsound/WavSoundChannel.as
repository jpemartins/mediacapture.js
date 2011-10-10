package org.as3wavsound {
	import flash.media.SoundChannel;
	import org.as3wavsound.sazameki.core.AudioSamples;
	import org.as3wavsound.WavSound;

	/**
	 * Used to keep track of open channels during playback. Each channel represents
	 * an 'instance' of a sound and so each channel is responsible for its own mixing.
	 * 
	 * Also see buffer().
	 * 
	 * @author b.bottema [Codemonkey]
	 */
	internal class WavSoundChannel {
		
		/*
		 * creation-time information 
		 */
		
		// a WavSound currently playing back on one or several channels
		private var _wavSound:WavSound;
		
		// The channel that contains playback info for a single sound 'instance'.
		// There can be multiple 'instances' of a WavSound, represented by SoundChannels.
		private var _channel:SoundChannel;
		
		/*
		 * play-time information *per WavSound*
		 */
		
		// starting phase if not at the beginning, made global to avoid recalculating all the time
		private var startPhase:Number; 
		// current phase of the sound, basically matches a single current sample frame for each WavSound
		private var phase:Number = 0;
		// how many loops we need to buffer
		private var loopsLeft:Number;
		// indicates if the phase has reached total sample count and no loops are left
		private var finished:Boolean;
		
		/**
		 * Constructor: pre-calculates starting phase (and performs some validation for this).
		 */
		public function WavSoundChannel(wavSound:WavSound, startTime:Number, loops:int, channel:SoundChannel) {
			this._wavSound = wavSound;
			this._channel = channel;
			init(startTime, loops);
		}
		
		/**
		 * Calculates and validates the starting time. Starting time in milliseconds is converted into 
		 * sample position and then marked as starting phase.
		 */
		private function init(startTime:Number, loops:int):void {
			var startPositionInMillis:Number = Math.floor(startTime);
			var maxPositionInMillis:Number = Math.floor(length);
			if (startPositionInMillis > maxPositionInMillis) {
				throw new Error("startTime greater than sound's length, max startTime is " + maxPositionInMillis);
			}
			phase = startPhase = Math.floor(startPositionInMillis * _wavSound.samples.length / _wavSound.length);
			finished = false;
			loopsLeft = loops;
		}
		
		/**
		 * Fills a target samplebuffer with optionally transformed samples from the current 
		 * WavSound instance (which is the current channel).
		 * 
		 * Keeps filling the buffer for each loop the sound should be mixed in the target buffer.
		 * When the buffer is full, phase and loopsLeft keep track of how which and many samples 
		 * still need to be buffered in the next buffering cycle (when this method is called again).
		 * 
		 * @param	sampleBuffer The target buffer to mix in the current (transformed) samples.
		 * @param	soundTransform The soundtransform that belongs to a single channel being played 
		 * 			(containing volume, panning etc.).
		 */	
		public function buffer(sampleBuffer:AudioSamples):void {
			// calculate volume and panning
			var volume: Number = (_channel.soundTransform.volume / 1);
			var volumeLeft: Number = volume * (1 - _channel.soundTransform.pan) / 2;
			var volumeRight: Number = volume * (1 + _channel.soundTransform.pan) / 2;
			// channel settings
			var needRightChannel:Boolean = _wavSound.playbackSettings.channels == 2;
			var hasRightChannel:Boolean = _wavSound.samples.setting.channels == 2;
			
			// extra references to avoid excessive getter calls in the following 
			// for-loop (it appeares CPU is being hogged otherwise)
			var samplesLength:Number = _wavSound.samples.length;
			var samplesLeft:Vector.<Number> = _wavSound.samples.left;
			var samplesRight:Vector.<Number> = _wavSound.samples.right;
			var sampleBufferLength:Number = sampleBuffer.length;
			var sampleBufferLeft:Vector.<Number> = sampleBuffer.left;
			var sampleBufferRight:Vector.<Number> = sampleBuffer.right;
			
			// finally, mix the samples in the master sample buffer
			for (var i:int = 0; i < sampleBufferLength; i++) {
				if (!finished) {					
					// write (transformed) samples to buffer
					sampleBufferLeft[i] += samplesLeft[phase] * volumeLeft;
					var channelValue:Number = ((needRightChannel && hasRightChannel) ? samplesRight[phase] : samplesLeft[phase]);
					sampleBufferRight[i] += channelValue * volumeRight;
					
					// check playing and looping state
					finished = ++phase >= samplesLength;
					if (finished) {
						phase = startPhase;
						finished = loopsLeft-- == 0;
					}
				}
			}
		}
		
		public function get wavSound():WavSound {
			return _wavSound
		}
	}
}