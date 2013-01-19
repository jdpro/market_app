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
 package vue.bandeau {
	import controle.Controleur;
	import controle.TypesControles;

	import modele.Modele;
	import modele.PositionsCurseur;
	import modele.SynchroEvent;
	import modele.courbes.Courbe;
	import modele.courbes.TypeCourbe;

	import vue.CharteCouleurs;
	import vue.Dimensions;
	import vue.icones.Bandeau;

	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author joachim
	 */
	public class SupportBandeau extends Sprite {
		private var bandeau : Bandeau;
		private var model : Modele;
		private var offrePlus : SimpleButton;
		private var demandePlus : SimpleButton;
		private var stepperCurseur : NumericStepper;
		private var groupesControles : Vector.<IGroupeControles>;
		private var idGroupeControleVisible : String;
		private var labelNomCourbe : Label;
		private var labelPrix : Label;
		private var labelPoint1 : Label;
		private var labelPoint2 : Label;
		private var labelQuantite : Label;
		private var stepperPxPt1 : NumericStepper;
		private var stepperPxPt2 : NumericStepper;
		private var stepperQtPt1 : NumericStepper;
		private var stepperQtPt2 : NumericStepper;
		private var menuDefinir : ComboBox;
		private var itemFonction : Object;
		private var itemPoints : Object;
		private var controleur : Controleur;
		private var stepperAFonction : NumericStepper;
		private var stepperBFonction : NumericStepper;
		private var stepperAReciproque : NumericStepper;
		private var stepperBReciproque : NumericStepper;
		private var labelFoisPrix : Label;
		private var labelFoisQuantite : Label;
		private var labelQuantiteEgal : Label;
		private var labelPrixEgal : Label;
		private var boutonSupprimer : Supprimer;
		private var boutonDupliquer : Dupliquer;
		private var supprimerTout : SupprimerTout;
		private var menuCurseur : ComboBox;
		private var itemCurseurPrix : Object;
		private var itemCurseurQuantites : Object;
		private var itemSansCurseur : Object;
		private var labelValeurCurseur : Label;
		private var labelNomAxe : Label;
		private var labelMinAxe : Label;
		private var labelMaxAxe : Label;
		private var stepperMinAxe : NumericStepper;
		private var stepperMaxAxe : NumericStepper;
		private var boutonReinitAxes : Reinitialiser;

		public function SupportBandeau(model : Modele, controleur : Controleur) {
			this.controleur = controleur;
			this.model = model;
			groupesControles = new Vector.<IGroupeControles>();
			addEventListener(Event.ADDED_TO_STAGE, construire);
			model.addEventListener(SynchroEvent.MISE_A_JOUR, mettreAJour);
			model.addEventListener(SynchroEvent.MISE_A_JOUR_COMPLETE, mettreAJour);
			model.addEventListener(SynchroEvent.MISE_A_JOUR_CURSEUR, mettreAJour);
		}

		private function mettreAJour(event : SynchroEvent) : void {
			choisirControlesVisibles();
			stepperCurseur.value = model.posCurseur;
			actualiserGroupeControlesCourbe();
			actualiserGroupeControlesAxes();
		}

		private function actualiserGroupeControlesAxes() : void {
			if (!labelNomAxe) return;
			var nomAxe : String = "Axe des ";
			if (model.selectionEnCours == TypesControles.LEGENDE_AXE_PRIX) {
				nomAxe += "prix";
				stepperMinAxe.value = model.minPrix;
				stepperMaxAxe.value = model.maxPrix;
			} else if (model.selectionEnCours == TypesControles.LEGENDE_AXE_QUANTITES) {
				nomAxe += "quantités";
				stepperMinAxe.value = model.minQuantites;
				stepperMaxAxe.value = model.maxQuantites;
			}
			labelNomAxe.text = nomAxe;
			labelNomAxe.draw();
			labelNomAxe.x = labelMinAxe.getBounds(this).right;
			labelNomAxe.x -= labelNomAxe.width / 2;
		}

		private function actualiserGroupeControlesCourbe() : void {
			var courbe : Courbe = model.courbeSelectionnee();
			if (!courbe) return;
			var titre : String = "Courbe ";
			titre += courbe.type == TypeCourbe.DEMANDE ? "de demande " : "d'offre ";
			titre += courbe.nom;
			labelNomCourbe.text = titre;
			stepperPxPt1.value = courbe.pxPt1;
			stepperPxPt2.value = courbe.pxPt2;
			stepperQtPt1.value = courbe.image(courbe.pxPt1);
			stepperQtPt2.value = courbe.image(courbe.pxPt2);
			stepperAFonction.value = courbe.image(1) - courbe.image(0);
			stepperBFonction.value = courbe.image(0);
			stepperBReciproque.value = courbe.origine(0);
			stepperAReciproque.value = courbe.origine(1) - courbe.origine(0);
		}

		private function choisirControlesVisibles() : void {
			if (model.selectionEnCours != TypesControles.AUCUN)
				idGroupeControleVisible = GroupeControles.LEGENDES_AXES;
			else if (model.courbeSelectionnee())
				idGroupeControleVisible = GroupeControles.COURBES;
			else idGroupeControleVisible = GroupeControles.DEFAULT;
			actualiserVisibiliteControles();
			labelValeurCurseur.visible = stepperCurseur.visible = model.axeCurseur != PositionsCurseur.AUCUN_CURSEUR && idGroupeControleVisible == GroupeControles.DEFAULT;
			// tenir compte du menu definir
			actualiserVisibiliteControlesCourbe();
		}

		private function actualiserVisibiliteControles() : void {
			for each (var groupe : IGroupeControles in groupesControles) {
				groupe.afficher(groupe.id == idGroupeControleVisible);
			}
		}

		private function construire(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, construire);
			mettreFond();
			creerControlesParDefaut();
			creerControlesCourbes();
			creerControlesAxes();
		}

		private function creerControlesAxes() : void {
			groupesControles.push(new GroupeControles(GroupeControles.LEGENDES_AXES, this));
			labelNomAxe = new Label(this, Dimensions.POS_H_CONTROLE_BANDEAU, Dimensions.MARGE_SUP_TITRE_COURBE, "xxxxx", CharteCouleurs.NOM_COURBE_BANDEAU, 18);
			labelMinAxe = new Label(this, Dimensions.POS_H_STEPPERS_AXES, labelNomAxe.getBounds(this).bottom, "Minimum");
			labelMinAxe.x -= labelMinAxe.width;

			labelMaxAxe = new Label(this, Dimensions.POS_H_STEPPERS_AXES, labelMinAxe.getBounds(this).bottom, "Maximum");
			labelMaxAxe.x -= labelMaxAxe.width;

			stepperMinAxe = new NumericStepper(this, Dimensions.POS_H_STEPPERS_AXES, labelMinAxe.y, TypesControles.STEPPER_MIN_AXE, 1);
			stepperMaxAxe = new NumericStepper(this, Dimensions.POS_H_STEPPERS_AXES, labelMaxAxe.y, TypesControles.STEPPER_MAX_AXE, 1);
			stepperMinAxe.addEventListener(Event.CHANGE, diffuserChangementStepper);
			stepperMaxAxe.addEventListener(Event.CHANGE, diffuserChangementStepper);

			boutonReinitAxes = new Reinitialiser();
			boutonReinitAxes.y = Dimensions.MARGE_SUP_TITRE_COURBE + 5;
			boutonReinitAxes.x = Main.LARGEUR - boutonReinitAxes.width - Dimensions.MARGE_DROITE_BOUTON_REINIT_AXES;
			addChild(boutonReinitAxes);
			groupeControleParId(GroupeControles.LEGENDES_AXES).ajouter(labelNomAxe, labelMinAxe, labelMaxAxe, stepperMinAxe, stepperMaxAxe, boutonReinitAxes);
		}

		private function creerControlesCourbes() : void {
			groupesControles.push(new GroupeControles(GroupeControles.COURBES, this));

			labelNomCourbe = new Label(this, Dimensions.POS_H_CONTROLE_BANDEAU, Dimensions.MARGE_SUP_TITRE_COURBE, "xxxxx", CharteCouleurs.NOM_COURBE_BANDEAU, 18);
			menuDefinir = new ComboBox(this, 0, labelNomCourbe.y, 2, 200);
			menuDefinir.x = Main.LARGEUR - Dimensions.MARGE_DROITE_MENU_DEFINIR - menuDefinir.width;
			menuDefinir.addEventListener(Event.SELECT, gererChoixMenuDefinir);
			itemPoints = new Object();
			itemPoints.label = "Définir par des points";
			itemFonction = new Object();
			itemFonction.label = "Définir par une fonction";

			menuDefinir.addItem(itemPoints);
			menuDefinir.addItem(itemFonction);
			menuDefinir.selectedItem = itemFonction;
			// définition par points
			labelPoint1 = new Label(this, Dimensions.POS_H_STEPPERS_POINT_COURBE, labelNomCourbe.getBounds(this).bottom - 2, "Point 1");
			labelPoint2 = new Label(this, labelPoint1.getBounds(this).right + Dimensions.MARGE_ENTRE_LABELS_PT1_PT2, labelPoint1.y, "Point 2");
			labelPrix = new Label(this, Dimensions.POS_H_STEPPERS_POINT_COURBE, labelPoint1.getBounds(this).bottom, "Prix");
			labelQuantite = new Label(this, Dimensions.POS_H_STEPPERS_POINT_COURBE, labelPrix.getBounds(this).bottom, "Quantite");
			labelPrix.x -= labelPrix.width;
			labelQuantite.x -= labelQuantite.width;
			stepperPxPt1 = new NumericStepper(this, labelPoint1.x, labelPrix.y, TypesControles.STEPPER_PX_POINT_1);
			stepperPxPt2 = new NumericStepper(this, labelPoint2.x, labelPrix.y, TypesControles.STEPPER_PX_POINT_2);
			stepperQtPt1 = new NumericStepper(this, labelPoint1.x, labelQuantite.y, TypesControles.STEPPER_QT_POINT_1);
			stepperQtPt2 = new NumericStepper(this, labelPoint2.x, labelQuantite.y, TypesControles.STEPPER_QT_POINT_2);
			stepperPxPt1.addEventListener(Event.CHANGE, diffuserChangementStepper);
			stepperPxPt2.addEventListener(Event.CHANGE, diffuserChangementStepper);
			stepperQtPt1.addEventListener(Event.CHANGE, diffuserChangementStepper);
			stepperQtPt2.addEventListener(Event.CHANGE, diffuserChangementStepper);
			groupeControleParId(GroupeControles.COURBES).ajouter(labelNomCourbe, labelPrix, labelQuantite, labelPoint1, labelPoint2);
			groupeControleParId(GroupeControles.COURBES).ajouter(stepperPxPt1, stepperPxPt2, stepperQtPt1, stepperQtPt2, menuDefinir);

			// définition par fonction
			stepperAFonction = new NumericStepper(this, Dimensions.POS_H_STEPPERS_FONCTION_COURBE, labelPrix.y, TypesControles.STEPPER_A_FONCTION);
			stepperAReciproque = new NumericStepper(this, Dimensions.POS_H_STEPPERS_FONCTION_COURBE, labelQuantite.y, TypesControles.STEPPER_A_RECIPROQUE);
			labelFoisPrix = new Label(this, stepperAFonction.getBounds(this).right - 20, stepperAFonction.y, "  x   Prix   +  ");
			labelFoisQuantite = new Label(this, labelFoisPrix.x, stepperAReciproque.y, "x Quantité +");

			stepperBReciproque = new NumericStepper(this, labelFoisQuantite.getBounds(this).right, stepperAReciproque.y, TypesControles.STEPPER_B_RECIPROQUE);
			stepperBFonction = new NumericStepper(this, stepperBReciproque.x, stepperAFonction.y, TypesControles.STEPPER_B_FONCTION);
			labelPrixEgal = new Label(this, stepperAFonction.x, stepperAReciproque.y, "Prix = ");
			labelQuantiteEgal = new Label(this, stepperAReciproque.x, stepperAFonction.y, "Quantite = ");
			labelPrixEgal.x -= labelPrixEgal.width;
			labelQuantiteEgal.x -= labelQuantiteEgal.width;

			stepperAFonction.addEventListener(Event.CHANGE, diffuserChangementStepper);
			stepperAReciproque.addEventListener(Event.CHANGE, diffuserChangementStepper);
			stepperBFonction.addEventListener(Event.CHANGE, diffuserChangementStepper);
			stepperBReciproque.addEventListener(Event.CHANGE, diffuserChangementStepper);

			boutonSupprimer = new Supprimer();
			boutonSupprimer.x = Dimensions.POS_H_CONTROLE_BANDEAU;
			boutonSupprimer.y = labelPrix.y + 2;
			boutonDupliquer = new Dupliquer();
			boutonDupliquer.y = labelQuantite.y + 2;
			boutonDupliquer.x = boutonSupprimer.x;
			boutonSupprimer.scaleX = boutonSupprimer.scaleY = 0.8;
			boutonDupliquer.scaleX = boutonDupliquer.scaleY = 0.8;
			addChild(boutonDupliquer);
			addChild(boutonSupprimer);

			groupeControleParId(GroupeControles.COURBES).ajouter(stepperAFonction, stepperAReciproque, stepperBFonction, stepperBReciproque);
			groupeControleParId(GroupeControles.COURBES).ajouter(labelFoisPrix, labelFoisQuantite, labelPrixEgal, labelQuantiteEgal, boutonSupprimer, boutonDupliquer);
		}

		private function gererChoixMenuDefinir(event : Event) : void {
			controleur.gererChoixDefinitionParPoint(menuDefinir.selectedItem == itemPoints);
		}

		private function actualiserVisibiliteControlesCourbe() : void {
			if (!model.courbeSelectionnee()) return;
			labelPrix.visible = labelQuantite.visible = labelPoint1.visible = labelPoint2.visible = menuDefinir.selectedItem == itemPoints;
			stepperPxPt1.visible = stepperPxPt2.visible = stepperQtPt1.visible = stepperQtPt2.visible = menuDefinir.selectedItem == itemPoints;
			stepperAFonction.visible = stepperAReciproque.visible = menuDefinir.selectedItem == itemFonction;
			labelFoisPrix.visible = labelFoisQuantite.visible = stepperBFonction.visible = stepperBReciproque.visible = menuDefinir.selectedItem == itemFonction;
			labelPrixEgal.visible = labelQuantiteEgal.visible = menuDefinir.selectedItem == itemFonction;
		}

		private function creerControlesParDefaut() : void {
			groupesControles.push(new GroupeControles(GroupeControles.DEFAULT, this));
			mettreBoutonsCourbes();
			mettreControlesCurseur();
		}

		private function mettreControlesCurseur() : void {
			menuCurseur = new ComboBox(this, 0, offrePlus.getBounds(this).bottom + Dimensions.MARGE_ENTRE_RADIO_BOUTONS, 3, 250);
			menuCurseur.x = offrePlus.x - 3;
			menuCurseur.addEventListener(Event.SELECT, gererChoixMenuCurseur);
			itemCurseurPrix = new Object();
			itemCurseurPrix.label = "Curseur sur l'axe des prix";
			itemCurseurQuantites = new Object();
			itemCurseurQuantites.label = "Curseur sur l'axe des quantités";
			itemSansCurseur = new Object();
			itemSansCurseur.label = "Masquer le curseur";
			menuCurseur.addItem(itemCurseurPrix);
			menuCurseur.addItem(itemCurseurQuantites);
			menuCurseur.addItem(itemSansCurseur);

			stepperCurseur = new NumericStepper(this, 0, menuCurseur.y + 2, TypesControles.STEPPER_CURSEUR);
			stepperCurseur.x = Main.LARGEUR - Dimensions.MARGE_DROITE_BOUTON_SUPPRIMER_TOUT - stepperCurseur.width;
			stepperCurseur.addEventListener(Event.CHANGE, diffuserChangementStepper);
			labelValeurCurseur = new Label(this, stepperCurseur.x, stepperCurseur.y, "Curseur :", 0xFFFFFF, 12);
			labelValeurCurseur.x -= labelValeurCurseur.width;
			menuCurseur.selectedItem = itemCurseurPrix;
			groupeControleParId(GroupeControles.DEFAULT).ajouter(menuCurseur, stepperCurseur, labelValeurCurseur);
		}

		private function gererChoixMenuCurseur(event : Event) : void {
			var axeChoisi : uint;
			switch(menuCurseur.selectedItem) {
				case itemCurseurPrix:
					axeChoisi = PositionsCurseur.CURSEUR_SUR_PRIX
					break;
				case itemCurseurQuantites:
					axeChoisi = PositionsCurseur.CURSEUR_SUR_QUANTITES
					break;
				case itemSansCurseur:
					axeChoisi = PositionsCurseur.AUCUN_CURSEUR
					break;
			}
			controleur.gererChoixMenuCurseur(axeChoisi);
		}

		private function diffuserChangementStepper(event : Event) : void {
			controleur.transmettreChangementStepper(event);
		}

		private function mettreBoutonsCourbes() : void {
			offrePlus = new OffrePlus();
			demandePlus = new DemandePlus();
			addChild(offrePlus);
			addChild(demandePlus);
			offrePlus.y = demandePlus.y = Dimensions.MARGE_SUP_BOUTONS_PERMANENTS;
			demandePlus.x = Main.LARGEUR - Dimensions.MARGE_DROITE_BOUTONS_PERMANENTS - demandePlus.width;
			offrePlus.x = demandePlus.x - offrePlus.width - Dimensions.MARGE_ENTRE_BOUTONS_PERMANENTS;
			supprimerTout = new SupprimerTout();
			supprimerTout.x = Main.LARGEUR - Dimensions.MARGE_DROITE_BOUTON_SUPPRIMER_TOUT - supprimerTout.width;
			supprimerTout.y = Dimensions.HAUTEUR_BANDEAU - Dimensions.MARGE_INF_BOUTON_SUPPRIMER_TOUT - supprimerTout.height;
			addChild(supprimerTout);
			groupeControleParId(GroupeControles.DEFAULT).ajouter(offrePlus, demandePlus, supprimerTout);
		}

		private function mettreFond() : void {
			bandeau = new Bandeau();
			addChild(bandeau);
		}

		private function groupeControleParId(id : String) : IGroupeControles {
			for each (var groupe : IGroupeControles in groupesControles) {
				if (groupe.id == id) return groupe;
			}
			return null;
		}
	}
}
