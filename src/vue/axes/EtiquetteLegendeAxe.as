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
 package vue.axes {
	import vue.Couleurs;

	import flash.filters.DropShadowFilter;

	import utils.InteractiveSprite;

	import vue.CharteCouleurs;

	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author joachim
	 */
	public class EtiquetteLegendeAxe extends InteractiveSprite {
		private var zoneTexte : TextField;
		private var couleurFond : uint;
		private var filter : DropShadowFilter;
		private var _type : uint;
		private var couleurTexte : uint;

		public function EtiquetteLegendeAxe(format : TextFormat, type : uint) {
			_type = type;
			filter = new DropShadowFilter(2);
			creerZoneTexte(format);
			super();
			buttonMode = true;
			mouseChildren = false;
		}

		private function creerZoneTexte(formatLegendes : TextFormat) : void {
			zoneTexte = new TextField();
			zoneTexte.selectable = false;
			zoneTexte.antiAliasType = AntiAliasType.ADVANCED;
			zoneTexte.autoSize = TextFieldAutoSize.LEFT;
			zoneTexte.multiline = true;
			zoneTexte.background = true;
			zoneTexte.border = false;
			zoneTexte.defaultTextFormat = formatLegendes;
			addChild(zoneTexte);
		}

		public function fixerTexte(string : String) : void {
			zoneTexte.text = string;
			zoneTexte.width = zoneTexte.textWidth + 4;
			actualiserZoneTexte();
		}

		public function getLargeurTexte() : Number {
			return zoneTexte.textWidth;
		}

		override protected function actualiserApparence(redessiner : Boolean) : void {
			switch(_etat) {
				case UP:
					couleurTexte = CharteCouleurs.TEXTE_GENERAL;
					couleurFond = CharteCouleurs.FOND_GENERAL;
					zoneTexte.border = false;
					filters = [];
					break;
				case SELECTED:
					couleurFond = CharteCouleurs.FOND_CONTROLE_SELECTED;
					couleurTexte = CharteCouleurs.TEXTE_CONTROLE_SELECTED;
					filters = [filter];
					zoneTexte.border = true;
					break;
				case HOVER:
					couleurTexte = CharteCouleurs.FOND_GENERAL;
					couleurFond = CharteCouleurs.FOND_LEGENDE_AXE_HOVER;
					filters = [filter];
					zoneTexte.border = true;
					break;
			}
			if (redessiner) {
				actualiserZoneTexte();
			}
		}

		private function actualiserZoneTexte() : void {
			var format : TextFormat = zoneTexte.getTextFormat();
			format.color = couleurTexte;
			zoneTexte.setTextFormat(format);
			zoneTexte.backgroundColor = couleurFond;
		}

		public function get type() : uint {
			return _type;
		}
	}
}
