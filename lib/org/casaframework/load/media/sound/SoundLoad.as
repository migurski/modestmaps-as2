/*
	CASA Framework for ActionScript 2.0
	Copyright (C) 2006  CASA Framework
	http://casaframework.org
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

import org.casaframework.load.base.BytesLoad;

/**
	Eases the chore of loading mp3s.
	
	@author Aaron Clinger
	@version 12/22/06
	@usageNote This class only works with event sounds and does not support streaming sounds. Event <code>onInstantiate</code> is called once the first loaded byte(s) have been received.
	@example
		<code>
			function onSoundComplete(sender:SoundLoad):Void {
				sender.getSound().start();
			}
			
			function onSoundLoading(sender:SoundLoad, bytesLoaded:Number, bytesTotal:Number):Void {
				trace(bytesLoaded + "/" + bytesTotal + " bytes have been loaded into " + sender.getMovieClip());
			}
			
			this.createEmptyMovieClip("soundContainer_mc", this.getNextHighestDepth());
			
			var audioClip:SoundLoad = new SoundLoad(this.soundContainer_mc, "audio.mp3");
			this.audioClip.addEventObserver(this, SoundLoad.EVENT_LOAD_COMPLETE, "onSoundComplete");
			this.audioClip.addEventObserver(this, SoundLoad.EVENT_LOAD_PROGRESS, "onSoundLoading");
			this.audioClip.start();
		</code>
*/

class org.casaframework.load.media.sound.SoundLoad extends BytesLoad {
	private var $sound:Sound;
	private var $target:MovieClip;
	private var $isUnloading:Boolean;
	
	
	/**
		Defines file and location of load triggered by {@link #start}.
		
		@param target_mc: The MovieClip instance on which the Sound object operates.
		@param mp3Path: The absolute or relative URL of the MP3 file to be loaded.
	*/
	public function SoundLoad(target_mc:MovieClip, mp3Path:String) {
		super(target_mc, mp3Path);
		
		this.$sound = new Sound(target_mc);
		
		this.$remapOnLoadHandler(this.$sound);
		
		this.$setClassDescription('org.casaframework.load.media.sound.SoundLoad');
	}
	
	/**
		@return Returns the sound object SoundLoad class is wrapping and loading.
	*/
	public function getSound():Sound {
		return this.$sound;
	}
	
	/**
		@return Returns MovieClip specified as <code>target_mc</code> in {@link #SoundLoad}.
	*/
	public function getMovieClip():MovieClip {
		return this.$target;
	}
	
	public function getBytesLoaded():Number {
		return this.$sound.getBytesLoaded();
	}
	
	public function getBytesTotal():Number {
		return this.$sound.getBytesTotal();
	}
	
	public function destroy():Void {
		delete this.$sound;
		delete this.$isUnloading;
		
		super.destroy();
	}
	
	private function $startLoad():Void {
		super.$startLoad();
		
		delete this.$isUnloading;
		this.$sound.loadSound(this.getFilePath(), false);
	}
	
	private function $stopLoad():Void {
		super.$stopLoad();
		
		this.$isUnloading = true;
		this.$sound.loadSound(null, false); // Cancels the current load.
	}
	
	private function $onLoad(success:Boolean):Void {
		if (!this.$isUnloading) {
			super.$onLoad(success);
		} else
			delete this.$isUnloading;
	}
	
	private function $checkForLoadComplete():Void {}
}