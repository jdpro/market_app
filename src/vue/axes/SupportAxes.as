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
 package vue.axes {
	import flashx.textLayout.utils.CharacterUtil;

	import controle.TypesControles;

	import modele.Modele;
	import modele.SynchroEvent;

	import vue.CharteCouleurs;
	import vue.Conversions;
	import vue.Dimensions;
	import vue.FormatsTexte;
	import vue.Orientations;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author joachim
	 */
	public class SupportAxes extends Sprite {
		private var model : Modele;
		private var etiquettes : Vector.<TextField> ;
		private var poolEtiquettes : Vector.<TextField>;
		private var formatEtiquettes : TextFormat;
		private var formatLegendes : TextFormat;
		private var legendeAbscisses : EtiquetteLegendeAxe;
		private var legendeOrdonnees : EtiquetteLegendeAxe;

		public function SupportAxes(modele : Modele) {
			this.model = modele;
			addEventListener(Event.ADDED_TO_STAGE, construire);
			etiquettes = new Vector.<TextField>();
			poolEtiquettes = new Vector.<TextField>();
			creerLegendes();
			model.addEventListener(SynchroEvent.MISE_A_JOUR_COMPLETE, recontruire);
			model.addEventListener(SynchroEvent.MISE_A_JOUR, miseAJour);
		}

		private function miseAJour(event : SynchroEvent) : void {
			var ordonneesSelectionnees : Boolean = model.selectionEnCours == TypesControles.LEGENDE_AXE_QUANTITES && model.orientation == Orientations.PRIX_EN_ABSCISSES;
			ordonneesSelectionnees ||= model.selectionEnCours == TypesControles.LEGENDE_AXE_PRIX && model.orientation == Orientations.PRIX_EN_ORDONNEES;
			var abscissesSelectionnees : Boolean = model.selectionEnCours == TypesControles.LEGENDE_AXE_PRIX && model.orientation == Orientations.PRIX_EN_ABSCISSES;
			abscissesSelectionnees ||= model.selectionEnCours == TypesControles.LEGENDE_AXE_QUANTITES && model.orientation == Orientations.PRIX_EN_ORDONNEES;
			if (ordonneesSelectionnees) legendeOrdonnees.selectionner();
			else if (legendeOrdonnees.selectionne) legendeOrdonnees.deselectionner();
			if (abscissesSelectionnees) legendeAbscisses.selectionner();
			else if (legendeAbscisses.selectionne) legendeAbscisses.deselectionner();
		}

		private function recontruire(event : SynchroEvent) : void {
			construire(null);
			miseAJour(null);
		}

		private function construire(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, construire);
			graphics.clear();
			recupererEtiquettes();
			tracerAbscisses();
			graduerAbscisses();
			tracerOrdonnees();
			graduerOrdonnees();
			actualiserLegendes();
		}

		private function actualiserLegendes() : void {
			legendeAbscisses.fixerTexte(model.orientation == Orientations.PRIX_EN_ABSCISSES ? "Prix" : "Quantités");
			legendeOrdonnees.fixerTexte(model.orientation == Orientations.PRIX_EN_ORDONNEES ? "Prix" : "Quantités");
			legendeOrdonnees.x = -legendeOrdonnees.getLargeurTexte();
			legendeOrdonnees.y = -legendeOrdonnees.height;
		}

		private function creerLegendes() : void {
			if (legendeAbscisses) return;
			legendeAbscisses = creerLegende(TypesControles.LEGENDE_AXE_ABSCISSES);
			legendeOrdonnees = creerLegende(TypesControles.LEGENDE_AXE_ORDONNEES);
			addChild(legendeAbscisses);
			addChild(legendeOrdonnees);
			legendeAbscisses.x = Conversions.instance.largeur;
			legendeAbscisses.y = Conversions.instance.hauteur;
		}

		private function recupererEtiquettes() : void {
			while (etiquettes.length > 0) {
				var etiquette : TextField = etiquettes.pop();
				removeChild(etiquette);
				poolEtiquettes.push(etiquette);
			}
		}

		private function graduerAbscisses() : void {
			var min : Number;
			var max : Number;
			var pos : Number;
			var intervalle : Number;
			if (model.orientation == Orientations.PRIX_EN_ABSCISSES) {
				intervalle = model.intervallePrix;
				pos = model.minQuantites;
				min = (Math.ceil(model.minPrix / intervalle) + 1) * intervalle;

				max = model.maxPrix;
			} else {
				intervalle = model.intervalleQuantites;
				pos = model.minPrix;
				min = (Math.ceil(model.minQuantites / intervalle) + 1) * intervalle;
				max = model.maxQuantites;
			}
			graphics.lineStyle(1, CharteCouleurs.GRADUATIONS);
			var origineTrait : Point;
			var etiquette : TextField;
			for (var i : int = min; i < max; i += intervalle) {
				if (model.orientation == Orientations.PRIX_EN_ABSCISSES)
					origineTrait = Conversions.instance.coordonneesVersPoint(i, pos);
				else
					origineTrait = Conversions.instance.coordonneesVersPoint(pos, i);
				graphics.moveTo(origineTrait.x, origineTrait.y);
				graphics.lineTo(origineTrait.x, origineTrait.y + Dimensions.LONGUEUR_GRADUATIONS);
				etiquette = donnerEtiquette();
				parametrerEtiquette(etiquette, true, origineTrait.x, origineTrait.y + Dimensions.LONGUEUR_GRADUATIONS, String(i));
			}
		}

		private function donnerEtiquette() : TextField {
			var etiquette : TextField;
			if (poolEtiquettes.length == 0) etiquette = creerEtiquette();
			else etiquette = poolEtiquettes.pop();
			etiquettes.push(etiquette);
			return etiquette;
		}

		private function tracerAbscisses() : void {
			graphics.lineStyle(1, CharteCouleurs.GRADUATIONS);
			graphics.moveTo(0, Conversions.instance.hauteur);
			graphics.lineTo(Conversions.instance.largeur, Conversions.instance.hauteur);
		}

		private function graduerOrdonnees() : void {
			var min : Number;
			var max : Number;
			var pos : Number;
			var intervalle : Number;
			if (model.orientation == Orientations.PRIX_EN_ORDONNEES) {
				pos = model.minQuantites;
				intervalle = model.intervallePrix;
				min = (Math.ceil(model.minPrix / intervalle) + 1) * intervalle;
				max = model.maxPrix;
			} else {
				pos = model.minPrix;
				intervalle = model.intervalleQuantites;
				min = (Math.ceil(model.minQuantites / intervalle) + 1) * intervalle;
				max = model.maxQuantites;
			}
			graphics.lineStyle(1, CharteCouleurs.GRADUATIONS);
			var origineTrait : Point;
			var etiquette : TextField;
			for (var i : int = min; i < max; i += intervalle) {
				if (model.orientation == Orientations.PRIX_EN_ORDONNEES)
					origineTrait = Conversions.instance.coordonneesVersPoint(i, pos);
				else
					origineTrait = Conversions.instance.coordonneesVersPoint(pos, i);
				graphics.moveTo(origineTrait.x, origineTrait.y);
				graphics.lineTo(origineTrait.x - Dimensions.LONGUEUR_GRADUATIONS, origineTrait.y);
				etiquette = donnerEtiquette();
				parametrerEtiquette(etiquette, false, origineTrait.x - Dimensions.LONGUEUR_GRADUATIONS, origineTrait.y, String(i));
			}
		}

		private function tracerOrdonnees() : void {
			graphics.lineStyle(1, CharteCouleurs.GRADUATIONS);
			graphics.moveTo(0, Conversions.instance.hauteur);
			graphics.lineTo(0, 0);
		}

		private function creerEtiquette() : TextField {
			var etiquetteGraduation : TextField = new TextField();
			etiquetteGraduation.selectable = false;
			etiquetteGraduation.wordWrap = false;
			etiquetteGraduation.antiAliasType = AntiAliasType.ADVANCED;
			etiquetteGraduation.autoSize = TextFieldAutoSize.LEFT;
			etiquetteGraduation.multiline = false;
			etiquetteGraduation.background = false;
			if (!formatEtiquettes)
				formatEtiquettes = FormatsTexte.donnerFormat(FormatsTexte.ETIQUETTES_AXES);
			etiquetteGraduation.defaultTextFormat = formatEtiquettes;
			return etiquetteGraduation;
		}

		private function creerLegende(type : uint) : EtiquetteLegendeAxe {
			if (!formatLegendes)
				formatLegendes = FormatsTexte.donnerFormat(FormatsTexte.LEGENDES_AXES);
			var etiquette : EtiquetteLegendeAxe = new EtiquetteLegendeAxe(formatLegendes, type);
			return etiquette;
		}

		private function parametrerEtiquette(etiquetteGraduation : TextField, verticale : Boolean, x : int, y : Number, texteEtiquette : String) : void {
			etiquetteGraduation.text = texteEtiquette;
			addChild(etiquetteGraduation);
			if (verticale)
				etiquetteGraduation.x = x - etiquetteGraduation.width / 2;
			else etiquetteGraduation.x = x - etiquetteGraduation.width - Dimensions.DISTANCE_ETIQUETTES_AXES_H;
			if (verticale)
				etiquetteGraduation.y = y + Dimensions.DISTANCE_ETIQUETTES_AXES_V;
			else
				etiquetteGraduation.y = y - (etiquetteGraduation.height / 2) ;
		}
	}
}
