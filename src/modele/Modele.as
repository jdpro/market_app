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
 package modele {
	import controle.TypesControles;

	import modele.courbes.Courbe;
	import modele.courbes.EtatsCourbe;
	import modele.courbes.TypeCourbe;

	import vue.Dimensions;
	import vue.Orientations;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;

	/**
	 * @author joachim
	 */
	public class Modele extends EventDispatcher {
		private var courbes : Vector.<Courbe>;
		private var _maxQuantites : Number;
		private var _minQuantites : Number;
		private var _intervalleQuantites : Number;
		private var _maxPrix : Number;
		private var _minPrix : Number;
		private var _orientation : uint;
		// mémorise le type de contrôle actuellement en cours d'utilisation
		private var _controleEnCours : uint;
		private var _axeCurseur : uint;
		private var _posCurseur : Number;
		private var _definitionParPoints : Boolean;
		private var compteurCourbesDemande : uint;
		private var compteurCourbesOffre : uint;
		private var _selectionEnCours : uint;
		private static const INTERVALLES_USUELS : Array = [1, 5];

		public function Modele() {
			super();
			this._orientation = Orientations.PRIX_EN_ABSCISSES;
			courbes = new Vector.<Courbe>();
			_minQuantites = ValeursParDefaut.MIN_QUANTITES_PAR_DEFAUT;
			_maxQuantites = ValeursParDefaut.MAX_QUANTITES_PAR_DEFAUT;
			_intervalleQuantites = ValeursParDefaut.INTERVALLES_QUANTITES;
			_minPrix = ValeursParDefaut.MIN_PRIX_PAR_DEFAUT;
			_maxPrix = ValeursParDefaut.MAX_PRIX_PAR_DEFAUT;
			axeCurseur = PositionsCurseur.CURSEUR_SUR_PRIX;
			compteurCourbesDemande = 0;
			compteurCourbesOffre = 0;
			_definitionParPoints = false;
		}

		public function ajouterCourbeIndefinie(type : uint) : void {
			var aParDefaut : Number ;
			var bParDefaut : Number = type == TypeCourbe.DEMANDE ? maxQuantites : 0;
			if (type == TypeCourbe.DEMANDE) {
				aParDefaut = (minQuantites - bParDefaut) / maxPrix;
			} else {
				aParDefaut = (maxQuantites - bParDefaut) / maxPrix;
			}
			bParDefaut += Math.random() * 30 - 15;

			var nom : String = determinerNom(type);
			var nouvelleCourbe : Courbe = new Courbe(aParDefaut, bParDefaut, type, compteurCourbes, nom);

			ajouterCourbe(nouvelleCourbe);
		}

		public function gererDuplication() : void {
			var nom : String = determinerNom(courbeSelectionnee().type);
			var nouvelleCourbe : Courbe = courbeSelectionnee().clone(compteurCourbes, nom);
			ajouterCourbe(nouvelleCourbe);
		}

		private function ajouterCourbe(nouvelleCourbe : Courbe) : void {
			courbes.push(nouvelleCourbe);
			nouvelleCourbe.pxNom = Math.random() * (_maxPrix + _minPrix) + _minPrix;
			nouvelleCourbe.pxPt1 = (maxPrix - minPrix) * 0.25 + minPrix;
			nouvelleCourbe.pxPt2 = (maxPrix - minPrix) * 0.75 + minPrix;
			verifierPositionControles(nouvelleCourbe);
			avertirMiseAJour();
		}

		private function get compteurCourbes() : uint {
			return compteurCourbesDemande + compteurCourbesOffre;
		}

		private function determinerNom(type : uint) : String {
			var nom : String = "";
			switch(type) {
				case TypeCourbe.DEMANDE:
					compteurCourbesDemande++;
					break;
				case TypeCourbe.OFFRE:
					compteurCourbesOffre++;
					break;
			}
			nom = type == TypeCourbe.DEMANDE ? "D" : "O";
			nom += type == TypeCourbe.DEMANDE ? compteurCourbesDemande : compteurCourbesOffre;
			return nom;
		}

		// voir pouruqoi il n'accepte plus SynchroEvent.MISE_A_JOUR
		private function avertirMiseAJour(typeMiseAJour : String = "MISE_A_JOUR_COMPLETE") : void {
			dispatchEvent(new SynchroEvent(typeMiseAJour));
		}

		public function get orientation() : uint {
			return _orientation;
		}

		public function get nbCourbes() : Number {
			return courbes.length;
		}

		public function uidCourbe(index : int) : uint {
			return courbes[index].uid;
		}

		public function nomCourbe(uid : int) : String {
			return courbeParUid(uid).nom;
		}

		public function courbeModifiee(uid : uint) : Boolean {
			return courbeParUid(uid).modifiee;
		}

		public function get maxQuantites() : Number {
			return _maxQuantites;
		}

		public function get minQuantites() : Number {
			return _minQuantites;
		}

		public function get maxPrix() : Number {
			return _maxPrix;
		}

		public function get minPrix() : Number {
			return _minPrix;
		}

		public function image(uid : uint, px : Number) : Number {
			return courbeParUid(uid).image(px);
		}

		public function origine(uid : uint, qt : Number) : Number {
			return courbeParUid(uid).origine(qt);
		}

		public function gererSelectionCourbe(uid : uint) : void {
			// si déja sélectionnee, rien à faire
			if (courbeParUid(uid).etat == EtatsCourbe.SELECTION) return;
			for each (var courbe : Courbe in courbes) {
				if (courbe.uid == uid) {
					courbe.etat = EtatsCourbe.SELECTION;
					verifierPositionControles(courbe);
				} else if (courbe.etat == EtatsCourbe.SELECTION) courbe.etat = EtatsCourbe.REPOS;
			}
			avertirMiseAJour(SynchroEvent.MISE_A_JOUR_COMPLETE);
		}

		private function verifierPositionControles(courbe : Courbe) : void {
			var margePx : Number = (maxPrix - minPrix) * Dimensions.MARGE_SORTIE_CONTROLES ;
			var margeQt : Number = (maxQuantites - minQuantites) * Dimensions.MARGE_SORTIE_CONTROLES ;
			courbe.verifierPositionControles(minPrix, maxPrix, minQuantites, maxQuantites, margePx, margeQt);
		}

		private function courbeParUid(uid : uint) : Courbe {
			for each (var courbe : Courbe in courbes) {
				if (courbe.uid == uid) return courbe;
			}
			throw new IllegalOperationError("cette courbe n'existe pas");
		}

		public function courbeSelectionnee() : Courbe {
			for each (var courbe : Courbe in courbes) {
				if (courbe.etat == EtatsCourbe.SELECTION) return courbe;
			}
			return null;
		}

		public function etatCourbe(uid : uint) : uint {
			return courbeParUid(uid).etat;
		}

		public function gererSurvol(uid : uint) : void {
			// si déja survolee ou sélectionnee, rien à faire
			if (courbeParUid(uid).etat == EtatsCourbe.SURVOL || courbeParUid(uid).etat == EtatsCourbe.SELECTION) return;
			for each (var courbe : Courbe in courbes) {
				if (courbe.uid == uid) courbe.etat = EtatsCourbe.SURVOL;
				else if (courbe.etat == EtatsCourbe.SURVOL) courbe.etat = EtatsCourbe.REPOS;
			}
			avertirMiseAJour();
		}

		public function gererFinSurvol(uid : uint) : void {
			// si non survolee rien = faire
			if (courbeParUid(uid).etat != EtatsCourbe.SURVOL) return;
			courbeParUid(uid).etat = EtatsCourbe.REPOS;
			avertirMiseAJour();
		}

		public function pxControleTranslation(uid : uint) : Number {
			return courbeParUid(uid).pxControleTranslation();
		}

		public function pxControleRotation(uid : uint) : Number {
			return courbeParUid(uid).pxControleRotation();
		}

		public function rotationCourbeSelectionnee(valeurs : Object) : void {
			courbeSelectionnee().rotation(valeurs);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function translationCourbeSelectionnee(valeurs : Object) : void {
			courbeSelectionnee().translation(valeurs);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function get controleEnCours() : uint {
			return _controleEnCours;
		}

		public function set controleEnCours(controleEnCours : uint) : void {
			_controleEnCours = controleEnCours;
			avertirMiseAJour();
		}

		public function get intervalleQuantites() : Number {
			var nbMaxGraduations : uint = _orientation == Orientations.PRIX_EN_ABSCISSES ? Dimensions.NB_MAX_GRADUATIONS_ORDONNEES : Dimensions.NB_MAX_GRADUATIONS_ABSCISSES;
			return intervalleRaisonnable(_maxQuantites - _minQuantites, nbMaxGraduations);
		}

		private function intervalleRaisonnable(amplitude : Number, nbMaxGraduations : uint) : Number {
			var interv : Number;
			var compteur : uint = 0;
			do {
				interv = INTERVALLES_USUELS[compteur % INTERVALLES_USUELS.length] * Math.pow(10, uint(compteur / INTERVALLES_USUELS.length));
				compteur++;
			} while (amplitude / interv > nbMaxGraduations);
			return interv;
		}

		public function get intervallePrix() : Number {
			var nbMaxGraduations : uint = _orientation == Orientations.PRIX_EN_ORDONNEES ? Dimensions.NB_MAX_GRADUATIONS_ORDONNEES : Dimensions.NB_MAX_GRADUATIONS_ABSCISSES;

			return intervalleRaisonnable(_maxPrix - _minPrix, nbMaxGraduations);
		}

		public function permuterAxes() : void {
			if (_orientation == Orientations.PRIX_EN_ABSCISSES)
				_orientation = Orientations.PRIX_EN_ORDONNEES;
			else _orientation = Orientations.PRIX_EN_ABSCISSES;
			marquerToutesCourbes();
			avertirMiseAJour(SynchroEvent.MISE_A_JOUR_COMPLETE);
		}

		private function marquerToutesCourbes() : void {
			for each (var courbe : Courbe in courbes) {
				courbe.marquerCommeModifiee();
			}
		}

		public function pxNom(uid : uint) : Number {
			return courbeParUid(uid).pxNom;
		}

		public function gererSuppression() : void {
			for each (var courbe : Courbe in courbes) {
				if (courbe.etat == EtatsCourbe.SELECTION) {
					courbes.splice(courbes.indexOf(courbe), 1);
				}
			}
			avertirMiseAJour();
		}

		public function gererSuppressionToutesCourbes() : void {
			while (courbes.length > 0) courbes.pop();
			compteurCourbesDemande = compteurCourbesOffre = 0;
			avertirMiseAJour();
		}

		public function get axeCurseur() : uint {
			return _axeCurseur;
		}

		public function set axeCurseur(axeCurseur : uint) : void {
			_axeCurseur = axeCurseur;
			if (_axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX)
				_posCurseur = (_maxPrix - _minPrix) / 2;
			else if (_axeCurseur == PositionsCurseur.CURSEUR_SUR_QUANTITES)
				_posCurseur = (_maxQuantites - _minQuantites) / 2;
			avertirMiseAJour(SynchroEvent.MISE_A_JOUR_CURSEUR);
		}

		public function get posCurseur() : Number {
			return _posCurseur;
		}

		public function deplacementCurseur(valeurs : Object) : void {
			if (_axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX) {
				placerCurseur(valeurs.px);
			} else if (_axeCurseur == PositionsCurseur.CURSEUR_SUR_QUANTITES) {
				placerCurseur(valeurs.qt);
			}
		}

		public function placerCurseur(valeur : Number, avecAimantation : Boolean = true) : void {
			_posCurseur = valeur;
			if (axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX)
				_posCurseur = Math.min(Math.max(_posCurseur, _minPrix), _maxPrix);
			else _posCurseur = Math.min(Math.max(_posCurseur, _minQuantites), _maxQuantites);
			if (avecAimantation)
				aimanterAuxIntersections();
			avertirMiseAJour(SynchroEvent.MISE_A_JOUR_CURSEUR);
		}

		private function aimanterAuxIntersections() : void {
			if (courbes.length < 2) return;
			var intersections : Vector.<Object> = determinerIntersections();
			if (intersections.length < 1) return;
			var distanceMinimum : Number = 1000;
			var intersectionRetenue : Object ;
			var position : Number;
			for each (var intersection : Object in intersections) {
				position = _axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX ? intersection.px : intersection.qt;
				if (Math.abs(position - _posCurseur) < distanceMinimum) {
					distanceMinimum = Math.abs(position - _posCurseur);
					intersectionRetenue = intersection;
				}
			}
			if (distanceMinimum < distanceAimantation())
				_posCurseur = _axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX ? intersectionRetenue.px : intersectionRetenue.qt;
		}

		private function distanceAimantation() : Number {
			var distance : Number;
			if (_axeCurseur == PositionsCurseur.CURSEUR_SUR_PRIX)
				distance = (_maxPrix - _minPrix) * Dimensions.DISTANCE_AIMANTATION;
			else distance = (_maxQuantites - _minQuantites) * Dimensions.DISTANCE_AIMANTATION;
			return distance;
		}

		private function determinerIntersections() : Vector.<Object> {
			var intersections : Vector.<Object> = new Vector.<Object>();
			var couple : Object;
			for each (var courbe1 : Courbe in courbes) {
				for each (var courbe2 : Courbe in courbes) {
					if (courbe1.type == TypeCourbe.DEMANDE && courbe2.type == TypeCourbe.OFFRE && courbe1) {
						couple = courbe1.intersection(courbe2);
						if (couple)
							if (couple.qt > _minQuantites && couple.qt < _maxQuantites && couple.px > _minPrix && couple.px < _maxPrix)
								intersections.push(couple);
					}
				}
			}
			return intersections;
		}

		public function premiereMiseAJour() : void {
			avertirMiseAJour(SynchroEvent.MISE_A_JOUR_COMPLETE)
		}

		public function deselectionnerToutesCourbes() : void {
			if (courbeSelectionnee())
				courbeSelectionnee().etat = EtatsCourbe.REPOS;
			avertirMiseAJour();
		}

		public function pxPt1(uid : uint) : Number {
			return courbeParUid(uid).pxPt1;
		}

		public function pxPt2(uid : uint) : Number {
			return courbeParUid(uid).pxPt2;
		}

		public function modifierPxPt1(value : Number) : void {
			courbeSelectionnee().modifierPxPt1(value);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function modifierPxPt2(value : Number) : void {
			courbeSelectionnee().modifierPxPt2(value);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function modifierQtPt1(value : Number) : void {
			courbeSelectionnee().modifierQtPt1(value);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function modifierQtPt2(value : Number) : void {
			courbeSelectionnee().modifierQtPt2(value);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function modifierAFonction(valeur : Number) : void {
			courbeSelectionnee().modifierA(valeur);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function modifierBFonction(valeur : Number) : void {
			courbeSelectionnee().modifierB(valeur);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function modifierAReciproque(valeur : Number) : void {
			courbeSelectionnee().modifierAReciproque(valeur);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function modifierBReciproque(valeur : Number) : void {
			courbeSelectionnee().modifierBReciproque(valeur);
			verifierPositionControles(courbeSelectionnee());
			avertirMiseAJour();
		}

		public function get definitionParPoints() : Boolean {
			return _definitionParPoints;
		}

		public function set definitionParPoints(definitionParPoints : Boolean) : void {
			_definitionParPoints = definitionParPoints;
			if (null != courbeSelectionnee() )
				courbeSelectionnee().marquerCommeModifiee();
			avertirMiseAJour();
		}

		public function get selectionEnCours() : uint {
			return _selectionEnCours;
		}

		public function set selectionEnCours(selectionEnCours : uint) : void {
			_selectionEnCours = selectionEnCours;
			avertirMiseAJour();
		}

		public function modifierMaxAxe(valeur : Number) : void {
			if (valeur < 0) {
				avertirMiseAJour();
				return;
			}

			if (_selectionEnCours == TypesControles.LEGENDE_AXE_PRIX) {
				if (valeur <= _minPrix) {
					avertirMiseAJour();
					return;
				}
				_maxPrix = valeur;
			} else if (_selectionEnCours == TypesControles.LEGENDE_AXE_QUANTITES) {
				if (valeur <= _minQuantites) {
					avertirMiseAJour();
					return;
				}
				_maxQuantites = valeur;
			}
			marquerToutesCourbes();
			avertirMiseAJour(SynchroEvent.MISE_A_JOUR_COMPLETE);
		}

		public function modifierMinAxe(valeur : Number) : void {
			if (valeur < 0) {
				avertirMiseAJour();
				return;
			}
			if (_selectionEnCours == TypesControles.LEGENDE_AXE_PRIX) {
				if (valeur >= _maxPrix) {
					avertirMiseAJour();
					return;
				}
				_minPrix = valeur;
			} else if (_selectionEnCours == TypesControles.LEGENDE_AXE_QUANTITES) {
				if (valeur >= _maxQuantites) {
					avertirMiseAJour();
					return;
				}
				_minQuantites = valeur;
			}
			marquerToutesCourbes();
			avertirMiseAJour(SynchroEvent.MISE_A_JOUR_COMPLETE);
		}

		public function reinitialiserAxeSelectionne() : void {
			modifierMinAxe(selectionEnCours == TypesControles.LEGENDE_AXE_PRIX ? ValeursParDefaut.MIN_PRIX_PAR_DEFAUT : ValeursParDefaut.MIN_QUANTITES_PAR_DEFAUT);
			modifierMaxAxe(selectionEnCours == TypesControles.LEGENDE_AXE_PRIX ? ValeursParDefaut.MAX_PRIX_PAR_DEFAUT : ValeursParDefaut.MAX_QUANTITES_PAR_DEFAUT);
		}
	}
}
