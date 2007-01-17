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

import org.casaframework.movieclip.Reversible;
import org.casaframework.time.EnterFrame;
import org.casaframework.util.ArrayUtil;

/**
	Gives the ability to dynamically place and change <code>stop()</code> actions on frames.

	@author Aaron Clinger
	@version 11/10/06
	@since Flash Player 7
	@example This will start playing a MovieClip at frame 5 and will stop once the MovieClip has reached frame 10:
		<code>
			this.stoppable_mc.addStopFrame(10);
		</code>
	@usageNote See {@link Reversible}.
*/

class org.casaframework.movieclip.Stoppable extends Reversible {
	private var $stopFrames:Array;
	private var $framePulse:EnterFrame;
	private var $hasStoppedBefore:Boolean;
	
	/**
		@exclude 
	*/
	public function Stoppable() {
		super();
		
		this.$framePulse       = EnterFrame.getInstance();
		this.$stopFrames       = new Array();
		this.$hasStoppedBefore = false;
		
		this.$setClassDescription('org.casaframework.movieclip.Stoppable');
	}
	
	/**
		Marks a frame which will trigger <code>stop</code> when playhead reaches it.

		@param frame: A number representing the frame number.
		@return Returns <code>true</code> frame was successfully added and unique; otherwise <code>false</code>.
	*/
	public function addStopFrame(frame:Number):Boolean {
		if (frame > this._totalframes || ArrayUtil.contains(this.$stopFrames, frame) > 0) return false;
		this.$stopFrames.push(frame);
		
		if (!this.$hasStoppedBefore) this.$addStopFrameCheck();
		
		return true;
	}
	
	/**
		Removes frame number from triggering <code>stop</code> when playhead reaches.

		@param frame: A number representing the frame number.
		@return Returns <code>true</code> frame was found and removed; otherwise <code>false</code>.
	*/
	public function removeStopFrame(frame:Number):Boolean {
		return ArrayUtil.removeArrayItem(this.$stopFrames, frame) >= 1;
	}
	
	private function $addStopFrameCheck():Void {
		if (this.$stopFrames.length == 0) return;
		this.$framePulse.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$checkForStopFrame');
	}
	
	private function $checkForStopFrame():Void {
		if (ArrayUtil.contains(this.$stopFrames, this._currentframe) > 0) this.stop();
	}
	
	/**
		@exclude 
	*/
	public function playBackwards():Void {
		this.$addStopFrameCheck();
		super.playBackwards();
	}
	
	/**
		@exclude 
	*/
	public function gotoAndPlayBackwards(frame:Object):Void {
		this.$addStopFrameCheck();
		super.gotoAndPlayBackwards(frame);
	}
	
	/**
		@exclude
	*/
	public function gotoAndPlay(frame:Object):Void {
		this.$addStopFrameCheck();
		super.gotoAndPlay(frame);
	}
	
	/**
		@exclude
	*/
	public function play():Void {
		this.$addStopFrameCheck();
		super.play();
	}
	
	/**
		@exclude
	*/
	public function stop():Void {
		this.$hasStoppedBefore = true;
		this.$framePulse.removeEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$checkForStopFrame');
		super.stop();
	}
	
	/**
		@exclude 
	*/
	public function gotoAndStop(frame:Object):Void {
		this.$hasStoppedBefore = true;
		this.$framePulse.removeEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$checkForStopFrame');
		super.gotoAndStop(frame);
	}
	
	public function destroy():Void {
		this.$framePulse.removeEventObserversForScope(this);
		
		delete this.$stopFrames;
		delete this.$framePulse;
		delete this.$hasStoppedBefore;
		
		super.destroy();
	}
}