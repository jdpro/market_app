/**
 * Copyright (c) 2012 Joachim DORNBUSCH 
 * Le Marché is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * at your option) any later version.
 * Le Marché is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with Le Marché.  If not, see <http://www.gnu.org/licenses/>.
 **/
 package modele {
	import flash.events.Event;

	/**
	 * @author joachim
	 */
	public class SynchroEvent extends Event {
		public static const MISE_A_JOUR : String = "MISE_A_JOUR";
		public static const MISE_A_JOUR_COMPLETE : String = "MISE_A_JOUR_COMPLETE";
		public static const MISE_A_JOUR_CURSEUR : String = "MISE_A_JOUR_CURSEUR";
		public function SynchroEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}
