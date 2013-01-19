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
	import modele.Modele;
	import modele.SynchroEvent;
	import modele.courbes.EtatsCourbe;

	import vue.Conversions;
	import vue.Orientations;
	import vue.SupportControles;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	import flash.ui.ContextMenu;

	/**
	 * @author joachim
	 */
	public class SupportCourbes extends Sprite {
		private var model : Modele;
		private var courbes : Vector.<TraceCourbe> ;
		private var supportControles : SupportControles;
		private var affichageControles : Boolean;
		private var cache : Shape;
		private var menuCourbe : ContextMenu;

		public function SupportCourbes(model : Modele, supportControles : SupportControles) {
			this.supportControles = supportControles;
			this.model = model;
			// il écoute les 2 mis à jour, les axes seulement la complète
			model.addEventListener(SynchroEvent.MISE_A_JOUR, mettreAJour);
			model.addEventListener(SynchroEvent.MISE_A_JOUR_COMPLETE, mettreAJour);
			courbes = new Vector.<TraceCourbe>();
			mettreCache();
			creerMenuCourbe();
		}

		private function creerMenuCourbe() : void {
			menuCourbe = new ContextMenu();
			menuCourbe.hideBuiltInItems();
		}

		private function mettreCache() : void {
			cache = new Shape();
			addChild(cache);
			cache.graphics.beginFill(0);
			cache.graphics.drawRect(0, 0, Conversions.instance.largeur, Conversions.instance.hauteur);
			cache.graphics.endFill();
			mask = cache;
		}

		private function mettreAJour(event : SynchroEvent) : void {
			affichageControles = false;
			for (var i : int = 0; i < model.nbCourbes; i++) {
				var uid : uint = model.uidCourbe(i);

				if (!courbePresente(uid))
					creerCourbe(uid);
				marquerCourbe(uid);
				if (model.courbeModifiee(uid))
					mettreAJourCourbe(uid);
				if (model.etatCourbe(uid) == EtatsCourbe.SELECTION) {
					supportControles.placerControles(uid);
					affichageControles = true;
				}
			}
			if (affichageControles == false) supportControles.afficherControles(false);
			effacerCourbesNonMarquees();
		}

		private function marquerCourbe(uid : uint) : void {
			for each (var courbe : TraceCourbe in courbes) {
				if (courbe.uid == uid)
					courbe.marquee = true;
			}
		}

		private function effacerCourbesNonMarquees() : void {
			while (!courbes.every(courbeMarquee)) {
				for each (var courbe : TraceCourbe in courbes) {
					if (!courbe.marquee) {
						removeChild(courbe);
						courbes.splice(courbes.indexOf(courbe), 1);
					}
				}
			}
			for each (courbe  in courbes) {
				courbe.marquee = false;
			}
		}

		private function courbeMarquee(courbe : TraceCourbe, index : int, v : Vector.<TraceCourbe>) : Boolean {
			return courbe.marquee;
		}

		private function mettreAJourCourbe(uid : uint) : void {
			var courbe : TraceCourbe = courbeParUid(uid);
			var px1 : Number = model.minPrix;
			var px2 : Number = model.maxPrix;
			var qt1 : Number;
			var qt2 : Number ;
			qt1 = model.image(uid, px1);
			qt2 = model.image(uid, px2);
			var pt1 : Point = Conversions.instance.coordonneesVersPoint(px1, qt1);
			var pt2 : Point = Conversions.instance.coordonneesVersPoint(px2, qt2);
			var debordement : Boolean ;
			if (model.orientation == Orientations.PRIX_EN_ORDONNEES) {
				debordement = (pt1.x < 0 || pt1.x > Conversions.instance.largeur);
				if (pt1.x < 0) {
					px1 = model.origine(uid, model.minQuantites);
					px2 = model.origine(uid, model.maxQuantites);
				} else if (pt1.x > Conversions.instance.largeur) {
					px1 = model.origine(uid, model.maxQuantites);
					px2 = model.origine(uid, model.minQuantites);
				}
				if (debordement) {
					qt1 = model.image(uid, px1);
					qt2 = model.image(uid, px2);
					pt1 = Conversions.instance.coordonneesVersPoint(px1, qt1);
					pt2 = Conversions.instance.coordonneesVersPoint(px2, qt2);
				}
			} else if (model.orientation == Orientations.PRIX_EN_ABSCISSES) {
				debordement = (pt1.y < 0 || pt1.y > Conversions.instance.hauteur);
				if (pt1.y < 0) {
					px1 = model.origine(uid, model.minQuantites);
					px2 = model.origine(uid, model.maxQuantites);
				} else if (pt1.y > Conversions.instance.hauteur) {
					px1 = model.origine(uid, model.maxQuantites);
					px2 = model.origine(uid, model.minQuantites);
				}
				if (debordement) {
					qt1 = model.image(uid, px1);
					qt2 = model.image(uid, px2);
					pt1 = Conversions.instance.coordonneesVersPoint(px1, qt1);
					pt2 = Conversions.instance.coordonneesVersPoint(px2, qt2);
				}
			}

			courbe.tracer(pt1, pt2, model.etatCourbe(uid));
			if (model.etatCourbe(uid) == EtatsCourbe.SELECTION && model.definitionParPoints) {
				var pxPt1 : Number = model.pxPt1(uid);
				courbe.placerPoint(Conversions.instance.coordonneesVersPoint(pxPt1, model.image(uid, pxPt1)));
				var pxPt2 : Number = model.pxPt2(uid);
				courbe.placerPoint(Conversions.instance.coordonneesVersPoint(pxPt2, model.image(uid, pxPt2)));
			}
			var pxNom : Number = model.pxNom(uid);
			var  qtNom : Number = model.image(uid, pxNom);
			var ptNom : Point = Conversions.instance.coordonneesVersPoint(pxNom, qtNom);

			courbe.replacerEtiquette(ptNom);
		}

		private	function courbeParUid(uid : uint) : TraceCourbe {
			for each (var courbe : TraceCourbe in courbes) {
				if (courbe.uid == uid) return courbe;
			}
			throw new IllegalOperationError("uid inexistante");
		}

		private	function creerCourbe(uid : uint) : void {
			var nom : String = model.nomCourbe(uid);
			var nouvelleCourbe : TraceCourbe = new TraceCourbe(uid, nom);
			nouvelleCourbe.contextMenu = menuCourbe;
			courbes.push(nouvelleCourbe);
			addChild(nouvelleCourbe);
		}

		private function courbePresente(uid : uint) : Boolean {
			for each (var courbe : TraceCourbe in courbes) {
				if (courbe.uid == uid) {
					return true;
				}
			}
			return false;
		}
	}
}
