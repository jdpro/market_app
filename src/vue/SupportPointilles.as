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
 package vue {
	import flash.display.CapsStyle;
	import flash.display.Sprite;
	import flash.geom.Point;

	/**
	 * @author joachim
	 */
	public class SupportPointilles extends Sprite {
		private static const LONGUEUR_POINTILLES : Number = 5;

		public function effacerTout() : void {
			graphics.clear();
		}

		public function pointilles(point1 : Point, point2 : Point, epaisseur : Number, couleur : uint) : void {
			graphics.lineStyle(epaisseur, couleur, 0.7, true, "normal", CapsStyle.SQUARE);
			var nbTirets : uint = Point.distance(point1, point2) / LONGUEUR_POINTILLES;
			var dx : Number = (point2.x - point1.x) / nbTirets;
			var dy : Number = (point2.y - point1.y) / nbTirets;
			point2 = point1.clone();
			point2.offset(dx, dy);
			var compteur : uint = 0;
			while (compteur < nbTirets / 2) {
				compteur++;
				graphics.moveTo(point1.x, point1.y);
				graphics.lineTo(point2.x, point2.y);
				point1.offset(dx * 2, dy * 2);
				point2.offset(dx * 2, dy * 2);
			}
		}
	}
}
