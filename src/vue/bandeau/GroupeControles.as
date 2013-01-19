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
 package vue.bandeau {
	import flash.display.InteractiveObject;
	import flash.display.Sprite;

	/**
	 * @author joachim
	 */
	internal class GroupeControles implements IGroupeControles {
		public static const DEFAULT : String = "CURSEUR";
		public static const COURBES : String = "COURBES";
		public static const LEGENDES_AXES : String = "LEGENDES_AXES";
		private var controles : Vector.<InteractiveObject>;
		private var _id : String;
		private var support : Sprite;

		public function GroupeControles(id : String, support : Sprite) {
			this.support = support;
			_id = id;
			controles = new Vector.<InteractiveObject>();
		}

		public function afficher(bool : Boolean) : void {
			for each (var controle : InteractiveObject in controles) {
				controle.visible = bool;
			}
		}

		public function ajouter(...listeControles) : void {
			for each (var controle : InteractiveObject in listeControles) {
				controles.push(controle);
			}
		}

		public function get id() : String {
			return _id;
		}
	}
}
