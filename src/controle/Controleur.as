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
 package controle {
	import vue.Orientations;
	import vue.axes.EtiquetteLegendeAxe;
	import vue.courbes.EtiquetteCourbe;

	import modele.Modele;
	import modele.courbes.TypeCourbe;

	import vue.Conversions;
	import vue.Dimensions;
	import vue.courbes.TraceCourbe;
	import vue.curseur.Curseur;
	import vue.icones.IconeDecorator;

	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;

	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	/**
	 * @author joachim
	 */
	public class Controleur {
		private var model : Modele;

		public function Controleur(model : Modele) {
			this.model = model;
			model.controleEnCours = TypesControles.AUCUN;
		}

		public function transmettre(event : MouseEvent) : void {
			switch(event.type) {
				case MouseEvent.CLICK:
					if (model.controleEnCours != TypesControles.AUCUN) break;
					if (event.target is OffrePlus)
						gererAjoutCourbeOffre();
					else if (event.target is DemandePlus)
						gererAjoutCourbeDemande();
					else if (event.target is Supprimer)
						model.gererSuppression();
					else if (event.target is Dupliquer)
						model.gererDuplication();
					else if (event.target is SupprimerTout)
						model.gererSuppressionToutesCourbes();
					else if (event.target is Reinitialiser)
						model.reinitialiserAxeSelectionne();
					break;
				case MouseEvent.MOUSE_DOWN:
					if (model.controleEnCours != TypesControles.AUCUN) break;
					if (event.target is EtiquetteCourbe) {
						gererSelection((event.target as EtiquetteCourbe).parent as TraceCourbe);
					} else if (event.target is IconeDecorator)
						gererMouseDownIcone(event.target as IconeDecorator);
					else if (event.target is Curseur)
						gererSelectionCurseur();
					else if (event.target is EtiquetteLegendeAxe)
						gererSelectionEtiquetteLegendeAxe((event.target as EtiquetteLegendeAxe).type);
					else if (event.target is Stage)
						gererClicScene();
					else if (event.target is PushButton)
						if (DisplayObject(event.target).parent is NumericStepper)
							gererMDBoutonStepper(DisplayObject(event.target).parent as NumericStepper);
					break;
				case MouseEvent.MOUSE_OVER:
					if (model.controleEnCours != TypesControles.AUCUN) break;
					if (event.target is EtiquetteCourbe) {
						gererSurvol((event.target as EtiquetteCourbe).parent as TraceCourbe);
					}
					break;
				case MouseEvent.MOUSE_UP:
					if (model.controleEnCours != TypesControles.AUCUN && !(event.target is EtiquetteLegendeAxe))
						model.controleEnCours = TypesControles.AUCUN;
					if (event.target is PushButton)
						if (DisplayObject(event.target).parent is NumericStepper)
							gererMDBoutonStepper(DisplayObject(event.target).parent as NumericStepper);
					break;
				case MouseEvent.MOUSE_OUT:
					if (model.controleEnCours != TypesControles.AUCUN) break;
					if (event.target is EtiquetteCourbe) {
						gererFinSurvol((event.target as EtiquetteCourbe).parent as TraceCourbe);
					}
					break;
				case MouseEvent.MOUSE_MOVE:
					if (model.controleEnCours == TypesControles.AUCUN) break;
					var cible : DisplayObject = event.target as DisplayObject;
					if (model.controleEnCours == TypesControles.ROTATION) gererDragControleRotation(cible.root.mouseX, cible.root.mouseY);
					else if (model.controleEnCours == TypesControles.TRANSLATION) gererDragControleTranslation(cible.root.mouseX, cible.root.mouseY);
					else if (model.controleEnCours == TypesControles.CURSEUR) gererDragCurseur(cible.root.mouseX, cible.root.mouseY);
					break;
			}
		}

		private function gererSelectionEtiquetteLegendeAxe(type : uint) : void {
			if (type == TypesControles.LEGENDE_AXE_ABSCISSES) {
				if (model.orientation== Orientations.PRIX_EN_ABSCISSES)
					model.selectionEnCours=TypesControles.LEGENDE_AXE_PRIX;
				else model.selectionEnCours=TypesControles.LEGENDE_AXE_QUANTITES;
			} else if (type ==TypesControles.LEGENDE_AXE_ORDONNEES) {
				if (model.orientation== Orientations.PRIX_EN_ABSCISSES)
					model.selectionEnCours=TypesControles.LEGENDE_AXE_QUANTITES;
				else model.selectionEnCours=TypesControles.LEGENDE_AXE_PRIX;
			}
			model.deselectionnerToutesCourbes();
		}

		private function gererMDBoutonStepper(numericStepper : NumericStepper) : void {
			gererEvenementStepper(numericStepper);
		}

		private function gererClicScene() : void {
			model.deselectionnerToutesCourbes();
			model.selectionEnCours = TypesControles.AUCUN;
		}

		private function gererAjoutCourbeDemande() : void {
			model.ajouterCourbeIndefinie(TypeCourbe.DEMANDE);
		}

		private function gererAjoutCourbeOffre() : void {
			model.ajouterCourbeIndefinie(TypeCourbe.OFFRE);
		}

		private function gererDragCurseur(mouseX : Number, mouseY : Number) : void {
			model.deplacementCurseur(convertirEnValeurs(mouseX, mouseY));
		}

		private function convertirEnValeurs(mouseX : Number, mouseY : Number) : Object {
			var x : Number = mouseX - Dimensions.MARGE_GAUCHE;
			var y : Number = mouseY - Dimensions.MARGE_SUP - Dimensions.HAUTEUR_BANDEAU;
			var valeurs : Object = Conversions.instance.coordonneesVersValeurs(x, y);
			return valeurs;
		}

		private function gererSelectionCurseur() : void {
			model.controleEnCours = TypesControles.CURSEUR;
			model.selectionEnCours = TypesControles.AUCUN;
			model.deselectionnerToutesCourbes();
		}

		private function gererDragControleTranslation(mouseX : Number, mouseY : Number) : void {
			model.translationCourbeSelectionnee(convertirEnValeurs(mouseX, mouseY));
		}

		private function gererDragControleRotation(mouseX : Number, mouseY : Number) : void {
			model.rotationCourbeSelectionnee(convertirEnValeurs(mouseX, mouseY));
		}

		private function gererMouseDownIcone(icone : IconeDecorator) : void {
			if (icone.type == TypesControles.PERMUTATION) model.permuterAxes();
			else // il s'agit d'un controle de  courbe
				model.controleEnCours = icone.type;
		}

		private function gererFinSurvol(traceCourbe : TraceCourbe) : void {
			model.gererFinSurvol(traceCourbe.uid);
		}

		private function gererSurvol(traceCourbe : TraceCourbe) : void {
			model.gererSurvol(traceCourbe.uid);
		}

		private function gererSelection(traceCourbe : TraceCourbe) : void {
			model.selectionEnCours = TypesControles.AUCUN;
			model.gererSelectionCourbe(traceCourbe.uid);
		}

		public function transmettreTouche(event : KeyboardEvent) : void {
			if (event.keyCode == Keyboard.DELETE)
				model.gererSuppression();
			if (event.keyCode == Keyboard.ENTER)
				if (event.target.parent.parent is NumericStepper) {
					gererEvenementStepper(event.target.parent.parent as NumericStepper);
				}
		}

		public function transmettreChangementStepper(event : Event) : void {
			if (event.target is NumericStepper) {
				gererEvenementStepper(event.target as NumericStepper);
			}
		}

		private function gererEvenementStepper(numericStepper : NumericStepper) : void {
			var idStepper : uint = numericStepper.id;
			var valeurStepper : Number = numericStepper.value;
			switch(idStepper) {
				case TypesControles.STEPPER_CURSEUR:
					model.placerCurseur(valeurStepper, false);
					break;
				case TypesControles.STEPPER_PX_POINT_1:
					model.modifierPxPt1(valeurStepper);
					break;
				case TypesControles.STEPPER_PX_POINT_2:
					model.modifierPxPt2(valeurStepper);
					break;
				case TypesControles.STEPPER_QT_POINT_1:
					model.modifierQtPt1(valeurStepper);
					break;
				case TypesControles.STEPPER_QT_POINT_2:
					model.modifierQtPt2(valeurStepper);
					break;
				case TypesControles.STEPPER_A_FONCTION:
					model.modifierAFonction(valeurStepper);
					break;
				case TypesControles.STEPPER_B_FONCTION:
					model.modifierBFonction(valeurStepper);
					break;
				case TypesControles.STEPPER_A_RECIPROQUE:
					model.modifierAReciproque(valeurStepper);
					break;
				case TypesControles.STEPPER_B_RECIPROQUE:
					model.modifierBReciproque(valeurStepper);
					break;
				case TypesControles.STEPPER_MAX_AXE:
					model.modifierMaxAxe(valeurStepper);
					break;
				case TypesControles.STEPPER_MIN_AXE:
					model.modifierMinAxe(valeurStepper);
					break;
			}
		}

		public function gererChoixDefinitionParPoint(boolean : Boolean) : void {
			model.definitionParPoints = boolean;
		}

		public function gererChoixMenuCurseur(axeChoisi : uint) : void {
			model.axeCurseur = axeChoisi;
		}
	}
}
