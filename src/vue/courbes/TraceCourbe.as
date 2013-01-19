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
	import vue.Couleurs;
	import flash.text.TextFormat;

	import modele.courbes.EtatsCourbe;

	import vue.CharteCouleurs;
	import vue.Dimensions;
	import vue.FormatsTexte;

	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author joachim
	 */
	public class TraceCourbe extends Sprite {
		private var _uid : uint;
		private var formatEtiquettes : TextFormat;
		private var nom : String;
		// algorithe de mark and sweep
		private var _marquee : Boolean;
		private var couleurFondEtiquette : uint;
		private var couleurTexteEtiquette : uint;
		private var etiquette : EtiquetteCourbe;

		public function TraceCourbe(uid : uint, nom : String) {
			this.nom = nom;
			_uid = uid;

			creerEtiquette();
		}

		public function get uid() : uint {
			return _uid;
		}

		public function tracer(pt1 : Point, pt2 : Point, etat : uint) : void {
			graphics.clear();
			var epaisseur : uint;
			var couleur : uint;
			switch(etat) {
				case EtatsCourbe.REPOS:
					epaisseur = Dimensions.TRAIT_COURBE_FIN;
					couleur = CharteCouleurs.COURBE_REPOS;
					couleurFondEtiquette = CharteCouleurs.ETIQUETTE_COURBE_REPOS;
					couleurTexteEtiquette = CharteCouleurs.TEXTE_GENERAL;
					break;
				case EtatsCourbe.SURVOL:
					epaisseur = Dimensions.TRAIT_COURBE_EPAIS;
					couleur = CharteCouleurs.COURBE_SURVOL;
					couleurFondEtiquette = CharteCouleurs.ETIQUETTE_COURBE_SURVOL;
					couleurTexteEtiquette = CharteCouleurs.FOND_GENERAL;
					break;
				case EtatsCourbe.SELECTION:
					epaisseur = Dimensions.TRAIT_COURBE_EPAIS;
					couleur = CharteCouleurs.COURBE_SELECTION;
					couleurFondEtiquette = CharteCouleurs.ETIQUETTE_COURBE_SELECTION;
					couleurTexteEtiquette =  CharteCouleurs.TEXTE_ETIQUETTE_COURBE_SELECTION;
					break;
			}
			graphics.lineStyle(epaisseur, couleur);
			graphics.moveTo(pt1.x, pt1.y);
			graphics.lineTo(pt2.x, pt2.y);
			mettreAJourEtiquette();
		}

		private function mettreAJourEtiquette() : void {
			etiquette.colorier(couleurFondEtiquette, couleurTexteEtiquette);
		}

		private function creerEtiquette() : void {
			if (!formatEtiquettes)
				formatEtiquettes = FormatsTexte.donnerFormat(FormatsTexte.ETIQUETTES_COURBES);
			etiquette = new EtiquetteCourbe(nom, formatEtiquettes);

			addChild(etiquette);
		}

		public function replacerEtiquette(ptNom : Point) : void {
			etiquette.x = ptNom.x;
			etiquette.y = ptNom.y;
		}

		public function get marquee() : Boolean {
			return _marquee;
		}

		public function set marquee(marquee : Boolean) : void {
			_marquee = marquee;
		}

		public function placerPoint(point : Point) : void {
			graphics.lineStyle(0, 0, 0);
			graphics.beginFill(CharteCouleurs.POINT_SUR_COURBE);
			graphics.drawCircle(point.x, point.y, Dimensions.RAYON_POINT);
		}
	}
}
