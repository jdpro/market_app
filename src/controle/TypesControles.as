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
	/**
	 * @author joachim
	 */
	public class TypesControles {
		public static const AUCUN : uint = 0;
		public static const TRANSLATION : uint = 1;
		public static const ROTATION : uint = 2;
		public static const PERMUTATION : uint = 3;
		public static const CURSEUR : uint = 4;
		public static const STEPPER_CURSEUR : uint = 5;
		public static const STEPPER_PX_POINT_1 : uint = 6;
		public static const STEPPER_PX_POINT_2 : uint = 7;
		public static const STEPPER_QT_POINT_1 : uint = 8;
		public static const STEPPER_QT_POINT_2 : uint = 9;
		public static const STEPPER_A_FONCTION : uint = 10;
		public static const STEPPER_B_FONCTION : uint = 11;
		public static const STEPPER_A_RECIPROQUE : uint = 12;
		public static const STEPPER_B_RECIPROQUE : uint = 13;
		// 14, 15, 16 et 17 permettent d'établir une correspondance (4 numéros pour 2 contrôles)
		public static const LEGENDE_AXE_PRIX : uint = 14;
		public static const LEGENDE_AXE_QUANTITES : uint = 15;
		public static const LEGENDE_AXE_ABSCISSES : uint = 16;
		public static const LEGENDE_AXE_ORDONNEES : uint = 17;
		public static const STEPPER_MIN_AXE : uint = 18;
		public static const STEPPER_MAX_AXE : uint = 19;
	}
}
