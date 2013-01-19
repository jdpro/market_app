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
	import flash.geom.Point;

	import modele.Modele;

	/**
	 * @author joachim
	 */
	public class Conversions {
		private static var _instance : Conversions;
		private var _largeur : Number;
		private var _hauteur : Number;
		private var model : Modele;

		public function Conversions(verrou : Verrou) {
			verrou;
		}

		public function parametrer(largeurScene : Number, hauteurScene : Number, modele : Modele) : void {
			this.model = modele;
			this._hauteur = hauteurScene - Dimensions.HAUTEUR_BANDEAU - Dimensions.MARGE_INF - Dimensions.MARGE_SUP;
			this._largeur = largeurScene - Dimensions.MARGE_DROITE - Dimensions.MARGE_GAUCHE;
		}

		public function coordonneesVersPoint(px : Number, qt : Number) : Point {
			var x : Number;

			var y : Number;

			var positionPx : Number = (px - model.minPrix) / (model.maxPrix - model.minPrix);
			var positionQt : Number = (qt - model.minQuantites) / (model.maxQuantites - model.minQuantites);
			x = _largeur * (model.orientation == Orientations.PRIX_EN_ABSCISSES ? positionPx : positionQt);
			y = _hauteur - _hauteur * (model.orientation == Orientations.PRIX_EN_ABSCISSES ? positionQt : positionPx);
			return new Point(x, y);
		}

		public static function get instance() : Conversions {
			if (!_instance) _instance = new Conversions(new Verrou());
			return _instance;
		}

		public function coordonneesVersValeurs(x : Number, y : Number) : Object {
			var valeurs : Object = new Object();
			if (model.orientation == Orientations.PRIX_EN_ABSCISSES) {
				valeurs.px = x / _largeur * (model.maxPrix - model.minPrix) + model.minPrix;
				valeurs.qt = (_hauteur - y) / _hauteur * (model.maxQuantites - model.minQuantites) + model.minQuantites;
			} else {
				valeurs.qt = x / _largeur * (model.maxQuantites - model.minQuantites) + model.minQuantites;
				valeurs.px = (_hauteur - y) / _hauteur * (model.maxPrix - model.minPrix) + model.minPrix;
			}
			return valeurs;
		}

		public function get largeur() : Number {
			return _largeur;
		}

		public function get hauteur() : Number {
			return _hauteur;
		}
	}
}
class Verrou {
}