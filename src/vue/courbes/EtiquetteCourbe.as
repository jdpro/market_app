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
 package vue.courbes {
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author joachim
	 */
	public class EtiquetteCourbe extends Sprite {
		private var nom : String;
		private var zoneTexte : TextField;
		private var formatEtiquettes : TextFormat;

		public function EtiquetteCourbe(nom : String, formatEtiquettes : TextFormat) {
			this.formatEtiquettes = formatEtiquettes;
			this.nom = nom;
			creerZoneTexte();
			buttonMode = true;
			mouseChildren = false;
			
		}

		private function creerZoneTexte() : void {
			zoneTexte = new TextField();
			zoneTexte.selectable = false;
			zoneTexte.wordWrap = false;
			zoneTexte.antiAliasType = AntiAliasType.ADVANCED;
			zoneTexte.autoSize = TextFieldAutoSize.LEFT;
			zoneTexte.multiline = false;

			zoneTexte.defaultTextFormat = formatEtiquettes;
			zoneTexte.text = nom;
			zoneTexte.border = true;
			zoneTexte.background = true;
			addChild(zoneTexte);
		}

		public function colorier(couleurFond : uint, couleurTexte : uint) : void {
			zoneTexte.backgroundColor = couleurFond;
			var format : TextFormat = zoneTexte.getTextFormat();
			format.color = couleurTexte;
			zoneTexte.setTextFormat(format);
		}
	}
}
