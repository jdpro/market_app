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
 package vue.widgets {
	import vue.FormatsTexte;

	import com.bit101.components.RadioButton;

	import flash.display.DisplayObjectContainer;

	/**
	 * @author joachim
	 */
	public class CustomRadioButton extends RadioButton {
		private var _id : int;

		public function CustomRadioButton(id : int, parent : DisplayObjectContainer = null, xpos : Number = 0, ypos : Number = 0, label : String = "", checked : Boolean = false, defaultHandler : Function = null) {
			_id = id;
			super(parent, xpos, ypos, label, checked, defaultHandler);
			personnaliser();
		}

		protected function personnaliser() : void {
			_label.textField.setTextFormat(FormatsTexte.donnerFormat(FormatsTexte.BOUTON_RADIO));
			_label.textField.text = _label.textField.text ;
		}

		public function get id() : int {
			return _id;
		}

	}
}
