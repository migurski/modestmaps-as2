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

import org.casaframework.time.EnterFrame;
import org.casaframework.movieclip.CoreMovieClip;

/**
	Extends MovieClip to provide additional timeline controlling functions: {@link #playBackwards} and {@link #gotoAndPlayBackwards}.
	
	@author Aaron Clinger
	@version 11/10/06
	@since Flash Player 7
	@example <code>this.backwards_mc.gotoAndPlayBackwards("frameLabel");</code>
	@usageNote When calling timeline contolling functions (<code>stop</code>, <code>gotoAndStop</code>, <code>play</code> and <code>gotoAndPlay</code>) from inside a MovieClip extended by {@link Reverse} ALWAYS prefix with <code>this</code>. Example:

	<code>this.stop();</code>

	This way the class' methods will handle the call instead of the global function equivalent.
*/

class org.casaframework.movieclip.Reversible extends CoreMovieClip {
	private var $playingInReverse:Boolean;
	private var $reverseController:EnterFrame;
	
	/**
		@exclude
	*/
	public function Reversible() {
		super();
		
		this.$reverseController = EnterFrame.getInstance();
		this.$playingInReverse  = false;
		
		this.$setClassDescription('org.casaframework.movieclip.Reversible');
	}
	
	/**
		Plays the Timeline in reverse from current playhead position.
	*/
	public function playBackwards():Void {
		this.$playInReverse();
	}
	
	/**
		Sends the playhead to the specified frame on the Timeline and plays in reverse from that frame.
		
		@param frame: A number representing the frame number, or a string representing the label of the frame, to which the playhead is sent.
	*/
	public function gotoAndPlayBackwards(frame:Object):Void {
		this.gotoAndStop(frame);
		this.$playInReverse();
	}
	
	/**
		@exclude
	*/
	public function gotoAndPlay(frame:Object):Void {
		this.$stopReversing();
		super.gotoAndPlay(frame);
	}
	
	/**
		@exclude
	*/
	public function gotoAndStop(frame:Object):Void {
		this.$stopReversing();
		super.gotoAndStop(frame);
	}
	
	/**
		@exclude
	*/
	public function play():Void {
		this.$stopReversing();
		super.play();
	}
	
	/**
		@exclude
	*/
	public function stop():Void {
		this.$stopReversing();
		super.stop();
	}
	
	/**
		Returns if the MovieClip is or isn't playing in reverse.
		
		@return Returns <code>true</code> if the MovieClip is currently playing in reverse; otherwise <code>false</code>.
	*/
	public function isPlayingBackwards():Boolean {
		return this.$playingInReverse;
	}
	
	public function destroy():Void {
		this.$reverseController.removeEventObserversForScope(this);
		
		delete this.$playingInReverse;
		delete this.$reverseController;
		
		super.destroy();
	}
	
	private function $stopReversing():Void {
		if (!this.$playingInReverse) return;
		this.$playingInReverse = false;
		
		this.$reverseController.removeEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$gotoFrameBefore');
	}
	
	private function $playInReverse():Void {
		if (this.$playingInReverse) return;
		this.$playingInReverse = true;
		
		this.$reverseController.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$gotoFrameBefore');
	}
	
	private function $gotoFrameBefore():Void {
		if (this._currentframe == 1) {
			// Calling another function to fix super scope event bug.
			this.$gotoLastFrame();
		} else this.prevFrame();
	}
	
	private function $gotoLastFrame():Void {
		super.gotoAndStop(this._totalframes);
	}
}