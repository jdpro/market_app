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
 package modele.courbes {
	import modele.ValeursParDefaut;

	/**
	 * @author joachim
	 */
	public class Courbe {
		private var a : Number;
		private var b : Number;
		private var _type : uint;
		private var _uid : uint;
		private var _modifiee : Boolean;
		private var _etat : uint;
		private var _pxControleTranslation : Number;
		private var _pxControleRotation : Number;
		private var _pxNom : Number;
		private var _nom : String;
		private var _pxPt1 : Number;
		private var _pxPt2 : Number;

		public function Courbe(a : Number, b : Number, type : uint, uid : uint, nom : String) {
			_uid = uid;
			_type = type;
			this.b = b;
			this.a = a;
			_nom = nom;
			_modifiee = true;
			_etat = EtatsCourbe.REPOS;
			_pxControleTranslation = ValeursParDefaut.PX_CONTROLE_TRANSLATION;
			_pxControleRotation = ValeursParDefaut.PX_CONTROLE_ROTATION;
		}

		public function get modifiee() : Boolean {
			// lecture unique
			var retour : Boolean = _modifiee;
			_modifiee = false;
			return retour;
		}

		public function get uid() : uint {
			return _uid;
		}

		public function image(px : Number) : Number {
			return a * px + b;
		}

		public function origine(qt : Number) : Number {
			return (qt - b) / a;
		}

		public function get etat() : uint {
			return _etat;
		}

		public function set etat(etatCourbe : uint) : void {
			_etat = etatCourbe;
			_modifiee = true;
		}

		public function pxControleTranslation() : Number {
			return _pxControleTranslation;
		}

		public function pxControleRotation() : Number {
			return _pxControleRotation;
		}

		public function rotation(valeurs : Object) : void {
			var qt1 : Number = valeurs.qt;
			var px1 : Number = valeurs.px;
			var qt2 : Number = image(pxControleTranslation());
			var px2 : Number = pxControleTranslation();
			redefinirDApresDeuxPoints(px1, qt1, px2, qt2);
			_pxControleRotation = valeurs.px;
			_modifiee = true;
		}

		public function translation(valeurs : Object) : void {
			var qt : Number = valeurs.qt;
			var px : Number = valeurs.px;
			b = qt - a * px;
			_pxControleTranslation = px;
			_modifiee = true;
		}

		public function marquerCommeModifiee() : void {
			_modifiee = true;
		}

		public function verifierPositionControles(minPrix : Number, maxPrix : Number, minQuantites : Number, maxQuantites : Number, margePrix : Number, margeQt : Number) : void {
			if (_pxControleRotation < minPrix) _pxControleRotation = minPrix;
			if (_pxControleRotation > maxPrix) _pxControleRotation = maxPrix;
			if (image(_pxControleRotation) < minQuantites) _pxControleRotation = origine(minQuantites);
			if (image(_pxControleRotation) > maxQuantites) _pxControleRotation = origine(maxQuantites);
			if (_pxControleTranslation < minPrix) _pxControleTranslation = minPrix;
			if (_pxControleTranslation > maxPrix) _pxControleTranslation = maxPrix;
			if (image(_pxControleTranslation) < minQuantites) _pxControleTranslation = origine(minQuantites);
			if (image(_pxControleTranslation) > maxQuantites) _pxControleTranslation = origine(maxQuantites);
			if (_pxNom < minPrix + margePrix) _pxNom = minPrix + margePrix;
			if (_pxNom > maxPrix - margePrix) _pxNom = maxPrix - margePrix;
			if (image(_pxNom) < minQuantites + margeQt) _pxNom = origine(minQuantites + margeQt);
			if (image(_pxNom) > maxQuantites - margeQt) _pxNom = origine(maxQuantites - margeQt);
		}

		public function get nom() : String {
			return _nom;
		}

		public function get type() : uint {
			return _type;
		}

		public function get pxNom() : Number {
			return _pxNom;
		}

		public function set pxNom(pxNom : Number) : void {
			_pxNom = pxNom;
		}

		public function get pxPt1() : Number {
			return _pxPt1;
		}

		public function set pxPt1(pxPt1 : Number) : void {
			_pxPt1 = pxPt1;
		}

		public function get pxPt2() : Number {
			return _pxPt2;
		}

		public function set pxPt2(pxPt2 : Number) : void {
			_pxPt2 = pxPt2;
		}

		public function modifierPxPt1(value : Number) : void {
			var px1 : Number = value;
			var qt1 : Number = image(_pxPt1);
			var px2 : Number = _pxPt2;
			var qt2 : Number = image(_pxPt2);
			if (redefinirDApresDeuxPoints(px1, qt1, px2, qt2))
				_pxPt1 = value;
		}

		public function modifierPxPt2(value : Number) : void {
			var px1 : Number = value;
			var qt1 : Number = image(_pxPt2);
			var px2 : Number = _pxPt1;
			var qt2 : Number = image(_pxPt1);
			if (redefinirDApresDeuxPoints(px1, qt1, px2, qt2))
				_pxPt2 = value;
		}

		public function modifierQtPt1(value : Number) : void {
			var qt1 : Number = value;
			var px1 : Number = _pxPt1;
			var qt2 : Number = image(_pxPt2);
			var px2 : Number = _pxPt2;

			if (redefinirDApresDeuxPoints(px1, qt1, px2, qt2))
				_pxPt1 = origine(value);
		}

		public function modifierQtPt2(value : Number) : void {
			var qt1 : Number = value;
			var px1 : Number = _pxPt2;
			var qt2 : Number = image(_pxPt1);
			var px2 : Number = _pxPt1;

			if (redefinirDApresDeuxPoints(px1, qt1, px2, qt2))
				_pxPt2 = origine(value);
		}

		private function redefinirDApresDeuxPoints(px1 : Number, qt1 : Number, px2 : Number, qt2 : Number) : Boolean {
			if (px1 - px2 == 0) return false;
			a = (qt1 - qt2) / (px1 - px2);
			b = qt2 - a * px2;
			_modifiee = true;
			return true;
		}

		public function modifierA(valeur : Number) : void {
			a = valeur;
			_modifiee = true;
		}

		public function modifierB(valeur : Number) : void {
			b = valeur;
			_modifiee = true;
		}

		public function modifierAReciproque(valeur : Number) : void {
			if (valeur != 0)
				a = 1 / valeur;
			_modifiee = true;
		}

		public function modifierBReciproque(valeur : Number) : void {
			b = -a * valeur;
			_modifiee = true;
		}

		public function clone(nouvelUid : uint, nouveauNom : String) : Courbe {
			var copie : Courbe = new Courbe(a, b, _type, nouvelUid, nouveauNom);
			return copie;
		}

		public function intersection(courbe : Courbe) : Object {
			var couple : Object = new Object();
			if (courbe._a != a) {
				couple.px = (courbe._b - b) / (a - courbe._a);
				couple.qt = image(couple.px);
			}
			return couple;
		}

		internal function get _a() : Number {
			return a;
		}

		internal function get _b() : Number {
			return b;
		}
	}
}
