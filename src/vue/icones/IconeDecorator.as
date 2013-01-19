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
 package vue.icones {
	import utils.InteractiveSprite;

	import vue.CharteCouleurs;

	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;

	/**
	 * @author joachim
	 */
	public class IconeDecorator extends InteractiveSprite {
		private var iconeSVG : Sprite;
		private var _type : uint;
		private var filter : DropShadowFilter;
		private var couleurIcone : uint;
		private var couleurFond : uint;
		private var dimension : Number;

		public function IconeDecorator(iconeSVG : Sprite, type : uint) {
			_type = type;
			this.iconeSVG = iconeSVG;
			addChild(iconeSVG);
			mouseChildren = false;
			buttonMode = true;
			filter = new DropShadowFilter();
			etat = UP;
			couleurIcone = CharteCouleurs.CONTROLE_REPOS;
			couleurFond = 0xFFFFFF;
		
			recolorierIcone();
		}

		public function recolorierIcone() : void {
			var ct : ColorTransform = new ColorTransform();
			ct.color = couleurIcone;
			iconeSVG.transform.colorTransform = ct;
		}

		public function dimensionner(dimension : Number) : void {
			this.dimension = dimension;
			var coeff : Number = dimension * 3 / 4;
			coeff /= Math.max(iconeSVG.width, iconeSVG.height);
			iconeSVG.width *= coeff;
			iconeSVG.x = -iconeSVG.width / 2;
			iconeSVG.height *= coeff;
			iconeSVG.y = -iconeSVG.height / 2;
			dessinerFond()
		}

		private function dessinerFond() : void {
			graphics.clear();
			graphics.lineStyle(1);
			graphics.beginFill(couleurFond);
			graphics.drawEllipse(-dimension / 2, -dimension / 2, dimension, dimension);
		}

		public function get type() : uint {
			return _type;
		}

		override protected function actualiserApparence(redessiner : Boolean) : void {
			switch(_etat) {
				case UP:
					couleurIcone = CharteCouleurs.CURSEUR_UP;
					couleurFond = CharteCouleurs.FOND_GENERAL;
					filters = []
					break;
				case HOVER:
					couleurIcone = CharteCouleurs.CURSEUR_HOVER;
					couleurFond = CharteCouleurs.FOND_CONTROLE_HOVER;
					filters = [filter]
					break;
				case DOWN:
					couleurIcone = CharteCouleurs.CURSEUR_DOWN;
					couleurFond = CharteCouleurs.FOND_CONTROLE_SELECTED;
					filters = [filter]
					break;
			}
			if (redessiner) {
				recolorierIcone();
				dessinerFond()
			}
		}
	}
}
