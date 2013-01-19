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
 package vue.curseur {
	import flash.filters.DropShadowFilter;
	import vue.Dimensions;

	import utils.InteractiveSprite;

	import vue.CharteCouleurs;

	/**
	 * @author joachim
	 */
	public class Curseur extends InteractiveSprite {
		private var couleurFond : uint;
		private var filter : DropShadowFilter;

		public function Curseur() {
			super();
			dessiner();
			filter=new DropShadowFilter();
			
		}

		override protected function actualiserApparence(redessiner : Boolean) : void {
			switch(_etat) {
				case UP:
					couleurFond = CharteCouleurs.CURSEUR_UP;
					filters=[]
					break;
				case HOVER:
					couleurFond = CharteCouleurs.CURSEUR_HOVER;
					filters=[filter]
					break;
				case DOWN:
					couleurFond = CharteCouleurs.CURSEUR_DOWN;
					filters=[filter]
					break;
			}
			if (redessiner) {
				dessiner();
			}
		}

		private function dessiner() : void {
			graphics.clear();
			graphics.beginFill(couleurFond);
			graphics.moveTo(0, -Dimensions.LARGEUR_CURSEUR / 2);
			graphics.lineTo(Dimensions.LARGEUR_CURSEUR / 2, Dimensions.LARGEUR_CURSEUR / 2);
			graphics.lineTo(-Dimensions.LARGEUR_CURSEUR / 2, Dimensions.LARGEUR_CURSEUR / 2);
			graphics.lineTo(0, -Dimensions.LARGEUR_CURSEUR / 2);
			graphics.endFill();
		}
	}
}
