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
	import controle.TypesControles;

	import flash.display.Sprite;
	import flash.geom.Point;

	import modele.Modele;

	import vue.icones.IconeDecorator;
	import vue.icones.IconeFlecheRotation;
	import vue.icones.IconeFlecheTranslation;

	/**
	 * @author joachim
	 */
	public class SupportControles extends Sprite {
		private static const DIST_PX : Number = 50;
		private var controleTranslation : IconeDecorator;
		private var controleRotation : IconeDecorator;
		private var model : Modele;

		public function SupportControles(model : Modele) {
			this.model = model;
			controleTranslation = new IconeDecorator(new IconeFlecheTranslation(), TypesControles.TRANSLATION);
			controleRotation = new IconeDecorator(new IconeFlecheRotation(), TypesControles.ROTATION);
			controleRotation.dimensionner(Dimensions.TAILLE_CONTROLES);
			controleTranslation.dimensionner(Dimensions.TAILLE_CONTROLES);
			addChild(controleRotation);
			addChild(controleTranslation);
			afficherControles(false);
		}

		public function afficherControles(boolean : Boolean) : void {
			controleRotation.visible = controleTranslation.visible = boolean;
		}

		public function placerControles(uid : uint) : void {
			if (!controleRotation.visible) afficherControles(true);
			afficherControleTranslation(uid);
			afficherControleRotation(uid);
		}

		private function afficherControleRotation(uid : uint) : void {
			var pxControleRotation : Number = model.pxControleRotation(uid);
			var qtControleRotation : Number = model.image(uid, pxControleRotation);
			var ptControleRotation : Point = Conversions.instance.coordonneesVersPoint(pxControleRotation, qtControleRotation);
			controleRotation.x = ptControleRotation.x ;
			controleRotation.y = ptControleRotation.y ;
			controleRotation.rotation = calculerAngle(uid);
			
		}

		private function afficherControleTranslation(uid : uint) : void {
			var pxControleTranslation : Number = model.pxControleTranslation(uid);
			var qtControleTranslation : Number = model.image(uid, pxControleTranslation);
			var ptControleTranslation : Point = Conversions.instance.coordonneesVersPoint(pxControleTranslation, qtControleTranslation);
			controleTranslation.x = ptControleTranslation.x ;
			controleTranslation.y = ptControleTranslation.y ;
			controleTranslation.rotation = calculerAngle(uid);

		}

		private function calculerAngle(uid : uint) : Number {
			var pt1 : Point = Conversions.instance.coordonneesVersPoint(0, model.image(uid, 0));
			var pt2 : Point = Conversions.instance.coordonneesVersPoint(DIST_PX, model.image(uid, DIST_PX));
			var rotation : Number;
			if (model.orientation == Orientations.PRIX_EN_ABSCISSES) {
				rotation = Math.acos((pt2.x - pt1.x) / Point.distance(pt1, pt2)) * (Math.abs(pt2.y - pt1.y) / (pt2.y - pt1.y));
			} else {
				rotation = Math.asin((pt2.y - pt1.y) / Point.distance(pt1, pt2)) * (Math.abs(pt2.x - pt1.x) / (pt2.x - pt1.x));
			}
			return rotation * 180 / Math.PI;
		}
	}
}
