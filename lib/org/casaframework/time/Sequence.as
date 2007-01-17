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

import org.casaframework.time.Chain;
import org.casaframework.time.Interval;

/**
	Creates a sequence of methods calls at defined times.
	
	@author Aaron Clinger
	@version 12/11/06
	@example
		<code>
			function hideBox():Void {
				this.box_mc._visible = false;
			}
			
			function showBox():Void {
				this.box_mc._visible = true;
			}
			
			var seq:Sequence = new Sequence(true);
			seq.addTask(this, "hideBox", 3000);
			seq.addTask(this, "showBox", 1000);
			seq.start();
		</code>
*/

class org.casaframework.time.Sequence extends Chain {
	
	
	/**
		Creates a new sequence.
		
		@param isLooping: <strong>[optional]</strong> Indicates the sequence replays once completed <code>true</code>, or stops <code>false</code>; defaults to <code>false</code>.
	*/
	public function Sequence(isLooping:Boolean) {
		super(isLooping);
		
		this.$setClassDescription('org.casaframework.time.Sequence');
	}
	
	/**
		Adds a method call to the sequence.
		
		@param scope: An object that contains the method specified by "methodName".
		@param methodName: A method that exists in the scope of the object specified by "scope".
		@param delay: The time in milliseconds after the previous call or from the start.
		@param position: <strong>[optional]</strong> Specifies the index of the insertion in the sequence order; defaults to the next position.
	*/
	public function addTask(scope:Object, methodName:String, delay:Number, position:Number):Void {
		this.$createNewTask(scope, methodName, null, delay, position);
	}
	
	private function $triggerEvent():Void {
		super.$triggerEvent();
		this.$startDelay();
	}
	
	private function $addObserverForSequenceItem(position:Number):Void {}
	
	private function $removeObserversForSequenceItem(position:Number):Void {}
}