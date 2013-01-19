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
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author dornbusch
	 */
	public class FormatsTexte {
		public static const ETIQUETTES_AXES : String = "ETIQUETTES_AXES";
		public static const LEGENDES_AXES : String = "LEGENDES_AXES";
		public static const ETIQUETTES_COURBES : String = "ETIQUETTES_COURBES";
		public static const BOUTON_RADIO : String = "BOUTON_RADIO";
		public static const VALEUR_PROJETEE : String = "VALEUR_PROJETEE";

		public static function donnerFormat(identifiant : String) : TextFormat {
			var format : TextFormat;
			switch(identifiant) {
				case ETIQUETTES_AXES:
					format = new TextFormat("arial", 16, CharteCouleurs.TEXTE_GENERAL, null, null, null, null, null, TextFormatAlign.CENTER, 0, 0);
					break;
				case VALEUR_PROJETEE:
					format = new TextFormat("arial", 14, CharteCouleurs.VALEUR_PROJETEE, null, null, null, null, null, TextFormatAlign.CENTER, 0, 0);
					break;
				case ETIQUETTES_COURBES:
					format = new TextFormat("arial", 16, CharteCouleurs.TEXTE_GENERAL, true, null, null, null, null, TextFormatAlign.CENTER, 0, 0);
					break;
				case LEGENDES_AXES:
					format = new TextFormat("arial", 14, CharteCouleurs.TEXTE_GENERAL, true, null, null, null, null, TextFormatAlign.LEFT, 0, 0);
					break;
				case BOUTON_RADIO:
					format = new TextFormat("arial", 14, CharteCouleurs.FOND_GENERAL, true, null, null, null, null, TextFormatAlign.LEFT, 0, 0);
					break;
			}

			return format;
		}
	}
}
