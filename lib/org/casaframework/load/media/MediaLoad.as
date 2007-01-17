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
import org.casaframework.time.FrameDelay;

/**
	Allows the implementation of event observers that provide status information while SWF, JPEG, GIF, and PNG files are being loaded into a MovieClip or level. This is designed to replace <code>loadMovie()</code>.
	
	Advantages over MovieClipLoader &amp; <code>loadMovie</code>:
	<ul>
		<li>Includes {@link RetryableLoad#setLoadRetries} and {@link BytesLoad#setLoadTimeout}.</li>
		<li>Sends load events using {@link EventDispatcher}.</li>
		<li>Does not immediatly start loading on definition. Load can be started at anytime with {@link Load#start}.</li>
		<li>Built in {@link Load#stop} which ends a current load or unloads a completed load.</li>
		<li>Option to hide content until file has completely loaded.</li>
	</ul>
	
	@author Aaron Clinger
	@version 12/20/06
	@since Flash Player 7
	@example
		<code>
			this.createEmptyMovieClip("loadZone_mc", this.getNextHighestDepth());
			
			function onImageLoadProgress(sender:MediaLoad, bytesLoaded:Number, bytesTotal:Number):Void {
				trace(bytesLoaded + "/" + bytesTotal + " bytes have been loaded into " + sender.getMovieClip());
			}
			
			var mediaLoad:MediaLoad = new MediaLoad(this.loadZone_mc, "test.jpg");
			this.mediaLoad.addEventObserver(this, MediaLoad.EVENT_LOAD_PROGRESS, "onImageLoadProgress");
			this.mediaLoad.start();
		</code>
*/

class org.casaframework.load.media.MediaLoad extends BytesLoad {
	private var $target:MovieClip;
	private var $hideLoad:Boolean;
	
	/**
		Defines file and location of load triggered by {@link #start}.
		
		@param target_mc: A path to a MovieClip container where the file specified by <code>filePath</code> should be loaded into.
		@param filePath: The absolute or relative URL of the SWF, JPEG, GIF, or PNG file to be loaded.
		@param hideUntilLoaded: <strong>[optional]</strong> Indicates to hide <code>target_mc</code> and its contents until file has completely loaded <code>true</code>, or to display contents while loading <code>false</code>; defaults to <code>false</code>.
		@usageNote Loading of GIF or PNG is only allowed when publishing to Flash Player 8 or greater.
	*/
	public function MediaLoad(target_mc:MovieClip, filePath:String, hideUntilLoaded:Boolean) {
		super(target_mc, filePath);
		
		this.$hideLoad  = (hideUntilLoaded != undefined) ? hideUntilLoaded : false;
		
		this.$setClassDescription('org.casaframework.load.media.MediaLoad');
	}
	
	/**
		@return Returns MovieClip specified in {@link #MediaLoad}.
	*/
	public function getMovieClip():MovieClip {
		return this.$target;
	}
	
	public function destroy():Void {
		delete this.$hideLoad;
		
		super.destroy();
	}
	
	private function $startLoad():Void {
		if (this.$target.getBytesLoaded() > 4) {
			this.$stopLoad();
			
			this.$isLoading = true;
			
			this.$frameDelay = new FrameDelay(this, '$startLoad');
			this.$frameDelay.start();
			return;
		}
		
		super.$startLoad();
		this.$target.loadMovie(this.getFilePath());
	}
	
	private function $stopLoad():Void {
		super.$stopLoad();
		this.$target.unloadMovie();
	}
	
	private function $loadProgress(bytesLoaded:Number, currentTime:Number):Void {
		super.$loadProgress(bytesLoaded, currentTime);
		
		if (!this.$isProgressing)
			if (this.$hideLoad)
				this.$target._visible = false;
	}
	
	private function $onComplete():Void {
		super.$onComplete();
		
		if (this.$hideLoad)
			this.$target._visible = true;
	}
}