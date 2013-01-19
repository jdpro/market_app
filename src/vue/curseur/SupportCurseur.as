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
	import modele.Modele;
	import modele.PositionsCurseur;
	import modele.SynchroEvent;

	import vue.CharteCouleurs;
	import vue.Conversions;
	import vue.Dimensions;
	import vue.FormatsTexte;
	import vue.Orientations;
	import vue.SupportPointilles;

	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author joachim
	 */
	public class SupportCurseur extends Sprite {
		private static const VERTICALE : uint = 0;
		private static const HORIZONTALE : uint = 1;
		private var model : Modele;
		private var curseur : Curseur;
		private var valeurProjetee : Number;
		private var position : Point;
		private var supportPointilles : SupportPointilles;
		private var boiteValeurProjetee : TextField;

		public function SupportCurseur(model : Modele) {
			this.model = model;
			creerCurseur();
			model.addEventListener(SynchroEvent.MISE_A_JOUR_CURSEUR, mettreAJour);
			model.addEventListener(SynchroEvent.MISE_A_JOUR_COMPLETE, mettreAJour);
			supportPointilles = new SupportPointilles();
			addChild(supportPointilles);
		}

		private function creerCurseur() : void {
			curseur = new Curseur();
			addChild(curseur);
			creerBoiteValeurProjetee();
		}

		private function creerBoiteValeurProjetee() : void {
			boiteValeurProjetee = new TextField();
			boiteValeurProjetee.selectable = false;
			boiteValeurProjetee.wordWrap = false;
			boiteValeurProjetee.antiAliasType = AntiAliasType.ADVANCED;
			boiteValeurProjetee.autoSize = TextFieldAutoSize.LEFT;
			boiteValeurProjetee.multiline = false;
			boiteValeurProjetee.background = false;
			boiteValeurProjetee.defaultTextFormat = FormatsTexte.donnerFormat(FormatsTexte.VALEUR_PROJETEE);
			addChild(boiteValeurProjetee);
		}

		private function mettreAJour(event : SynchroEvent) : void {
			if (model.axeCurseur == PositionsCurseur.AUCUN_CURSEUR) {
				afficherCurseur(false);
				supportPointilles.effacerTout();
				afficherValeurProjetee(false);
				return;
			} else afficherCurseur(true);
			if (model.orientation == Orientations.PRIX_EN_ABSCISSES) {
				if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX) {
					orientationCurseur(VERTICALE);
					position = Conversions.instance.coordonneesVersPoint(model.posCurseur, model.minQuantites);
				} else if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_QUANTITES) {
					orientationCurseur(HORIZONTALE);
					position = Conversions.instance.coordonneesVersPoint(model.minPrix, model.posCurseur);
				}
			} else if (model.orientation == Orientations.PRIX_EN_ORDONNEES) {
				if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX) {
					orientationCurseur(HORIZONTALE);
					position = Conversions.instance.coordonneesVersPoint(model.posCurseur, model.minQuantites);
				} else if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_QUANTITES) {
					orientationCurseur(VERTICALE);
					position = Conversions.instance.coordonneesVersPoint(model.minPrix, model.posCurseur);
				}
			}
			curseur.x = position.x;
			curseur.y = position.y;
			mettreAJourPointilles();
		}

		private function mettreAJourPointilles() : void {
			supportPointilles.effacerTout();
			var pointCurseur : Point = new Point(curseur.x, curseur.y);
			var debutProjectionCourbe : Point;
			var finProjectionCourbe : Point ;
			var maxQt : Number = 0;
			var maxPx : Number = 0;
			for (var i : int = 0; i < model.nbCourbes; i++) {
				var uid : uint = model.uidCourbe(i);
				if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX)
					maxQt = Math.max(maxQt, model.image(uid, model.posCurseur));
				else
					maxPx = Math.max(maxPx, model.origine(uid, model.posCurseur));
				debutProjectionCourbe = null;

				if (model.courbeSelectionnee() && model.courbeSelectionnee().uid == uid ) {
					if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX)
						valeurProjetee = model.image(uid, model.posCurseur);
					else valeurProjetee = model.origine(uid, model.posCurseur);
				}
				if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX) {
					if (model.image(uid, model.posCurseur) > model.minQuantites && model.image(uid, model.posCurseur) < model.maxQuantites) {
						debutProjectionCourbe = Conversions.instance.coordonneesVersPoint(model.posCurseur, model.image(uid, model.posCurseur));
					}
					finProjectionCourbe = Conversions.instance.coordonneesVersPoint(model.minPrix, model.image(uid, model.posCurseur));
				} else if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_QUANTITES) {
					if (model.origine(uid, model.posCurseur) > model.minPrix && model.origine(uid, model.posCurseur) < model.maxPrix) {
						debutProjectionCourbe = Conversions.instance.coordonneesVersPoint(model.origine(uid, model.posCurseur), model.posCurseur);
					}
					finProjectionCourbe = Conversions.instance.coordonneesVersPoint(model.origine(uid, model.posCurseur), model.minQuantites);
				}
				var couleurProjection : uint = (model.courbeSelectionnee() && model.courbeSelectionnee().uid == uid) ? CharteCouleurs.PROJECTION_COURBE_SELECTIONNEE : CharteCouleurs.PROJECTION_CURSEUR;
				var epaisseurProjection : Number = (model.courbeSelectionnee() && model.courbeSelectionnee().uid == uid) ? Dimensions.EPAISSEUR_PROJECTION_COURBE_SELECTIONNEE : Dimensions.EPAISSEUR_PROJECTION_CURSEUR;
				if (debutProjectionCourbe)
					supportPointilles.pointilles(debutProjectionCourbe, finProjectionCourbe, epaisseurProjection, couleurProjection);
			}
			var finProjectionCurseur : Point;
			if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX) {
				if (maxQt > model.minQuantites)
					finProjectionCurseur = Conversions.instance.coordonneesVersPoint(model.posCurseur, Math.min(maxQt, model.maxQuantites));
			} else if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_QUANTITES) {
				if (maxPx > model.minPrix)
					finProjectionCurseur = Conversions.instance.coordonneesVersPoint(Math.min(maxPx, model.maxPrix), model.posCurseur);
			}
			if (finProjectionCurseur)
				supportPointilles.pointilles(pointCurseur, finProjectionCurseur, Dimensions.EPAISSEUR_PROJECTION_CURSEUR, CharteCouleurs.PROJECTION_CURSEUR);
			afficherValeurProjetee(model.courbeSelectionnee() != null);
		}

		private function afficherValeurProjetee(bool : Boolean) : void {
			boiteValeurProjetee.visible = bool;
			if (!bool) return;
			boiteValeurProjetee.text = String(Math.round(valeurProjetee * 10) / 10);
			var positionBoite : Point;
			if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX) {
				if (valeurProjetee > model.minQuantites && valeurProjetee < model.maxQuantites)
					positionBoite = Conversions.instance.coordonneesVersPoint(model.minPrix, valeurProjetee);
			} else {
				if (valeurProjetee > model.minPrix && valeurProjetee < model.maxPrix)
					positionBoite = Conversions.instance.coordonneesVersPoint(valeurProjetee, model.minQuantites);
			}

			if (!positionBoite) {
				boiteValeurProjetee.visible = false;
				return;
			} else boiteValeurProjetee.visible = true;
			boiteValeurProjetee.x = positionBoite.x;
			boiteValeurProjetee.y = positionBoite.y;
			if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX && model.orientation == Orientations.PRIX_EN_ORDONNEES )
				boiteValeurProjetee.y -= boiteValeurProjetee.height;
			if (model.axeCurseur == PositionsCurseur.CURSEUR_SUR_QUANTITES && model.orientation == Orientations.PRIX_EN_ABSCISSES )
				boiteValeurProjetee.y -= boiteValeurProjetee.height;
		}

		private function afficherCurseur(boolean : Boolean) : void {
			curseur.visible = boolean;
			if (!boolean) return;
		}

		private function orientationCurseur(orientation : uint) : void {
			curseur.rotation = orientation == VERTICALE ? 0 : 90;
		}
	}
}
