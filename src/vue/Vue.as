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
	import controle.Controleur;
	import controle.TypesControles;

	import modele.Modele;
	import modele.SynchroEvent;

	import vue.axes.SupportAxes;
	import vue.bandeau.SupportBandeau;
	import vue.courbes.SupportCourbes;
	import vue.curseur.SupportCurseur;
	import vue.icones.IconeDecorator;
	import vue.icones.IconeFlechePermutation;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	/**
	 * @author joachim
	 */
	[SWF(width="900", height="650", frameRate="24", backgroundColor="#333333")]
	public class Vue extends Sprite {
		private var model : Modele;
		private var supportAxes : SupportAxes;
		private var supportCourbes : SupportCourbes;
		private var supportControles : SupportControles;
		private var supportCurseur : SupportCurseur;
		private var controleur : Controleur;
		private var controlePermutation : IconeDecorator;
		private var supportBandeau : SupportBandeau;

		public function Vue(model : Modele, controleur : Controleur) {
			dessinerFauxFond();
			this.controleur = controleur;
			this.model = model;
			addEventListener(Event.ADDED_TO_STAGE, construire);
		}

		private function dessinerFauxFond() : void {
			graphics.beginFill(0x333333, 1);
			graphics.drawRect(0, 0, Main.LARGEUR, Main.HAUTEUR);
			graphics.endFill();
		}

		private function ecouter() : void {
			addEventListener(MouseEvent.CLICK, transmettre);
			addEventListener(MouseEvent.MOUSE_DOWN, transmettre);
			addEventListener(MouseEvent.MOUSE_OVER, transmettre);
			addEventListener(MouseEvent.MOUSE_MOVE, transmettre);
			addEventListener(MouseEvent.MOUSE_OUT, transmettre);
			addEventListener(MouseEvent.MOUSE_UP, transmettre);
			addEventListener(KeyboardEvent.KEY_DOWN, transmettreTouche);
		}

		private function transmettreTouche(event : KeyboardEvent) : void {
			controleur.transmettreTouche(event);
		}

		private function transmettre(event : MouseEvent) : void {
			controleur.transmettre(event);
		}

		private function construire(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, construire);
			Conversions.instance.parametrer(Main.LARGEUR, Main.HAUTEUR, model);
			mettreSupportBandeau();
			mettreSupportAxes();
			mettreSupportControles();
			mettreSupportCourbes();
			mettreSupportCurseur();
			mettreControlePermutation();
			ecouter();
			model.addEventListener(SynchroEvent.MISE_A_JOUR_COMPLETE, mettreAJour);
		}

		private function mettreSupportBandeau() : void {
			supportBandeau = new SupportBandeau(model, controleur);
			addChild(supportBandeau);
		}

		private function mettreSupportCurseur() : void {
			supportCurseur = new SupportCurseur(model);
			positionStandard(supportCurseur);
		}

		private function mettreAJour(event : SynchroEvent) : void {
			controlePermutation.scaleX = model.orientation == Orientations.PRIX_EN_ABSCISSES ? 1 : -1;
			controlePermutation.rotation = model.orientation == Orientations.PRIX_EN_ABSCISSES ? 0 : 90;
		}

		private function mettreControlePermutation() : void {
			controlePermutation = new IconeDecorator(new IconeFlechePermutation(), TypesControles.PERMUTATION);
			controlePermutation.dimensionner(Dimensions.CONTROLE_PERMUTATION);
			addChild(controlePermutation);
			controlePermutation.x = Dimensions.MARGE_GAUCHE - controlePermutation.width;
			// son origine est en son centre
			controlePermutation.y = Main.HAUTEUR - Dimensions.MARGE_INF + controlePermutation.height;
			;
		}

		private function mettreSupportAxes() : void {
			supportAxes = new SupportAxes(model);
			positionStandard(supportAxes);
		}

		private function mettreSupportCourbes() : void {
			supportCourbes = new SupportCourbes(model, supportControles);
			positionStandard(supportCourbes);
			// on le remet par dessus
			setChildIndex(supportControles, numChildren - 1);
		}

		private function mettreSupportControles() : void {
			supportControles = new SupportControles(model);
			positionStandard(supportControles);
		}

		private function positionStandard(support : Sprite) : void {
			support.x = Dimensions.MARGE_GAUCHE;
			support.y = Dimensions.HAUTEUR_BANDEAU + Dimensions.MARGE_SUP;
			addChild(support);
		}
	}
}
