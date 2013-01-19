package {
	import flash.events.Event;
	import controle.Controleur;

	import modele.Modele;
	import modele.courbes.TypeCourbe;

	import vue.Vue;

	import flash.display.Sprite;

	/**
	 * @author joachim
	 */
	
	[SWF(backgroundColor="#333333", frameRate="24", width="900", height="600")]
	public class Main extends Sprite {
		public static const LARGEUR : Number=900;
		public static const HAUTEUR : Number=650;
		private var model : Modele;
		private var vue : Vue;
		private var controleur : Controleur;

		public function Main() {
			//if (!valide()) return;
			addEventListener(Event.ADDED_TO_STAGE, construire);
		}

		private function construire(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, construire);
			creerModele();
			creerControleur();
			creerVue();
			model.premiereMiseAJour();
			model.ajouterCourbeIndefinie(TypeCourbe.OFFRE);
			model.ajouterCourbeIndefinie(TypeCourbe.DEMANDE);
		}

		private function valide() : Boolean {
			var date : Date = new Date();
			if (date.fullYear==2011) return date.month < 8;
			return  date.fullYear < 2012;
		}

		private function creerControleur() : void {
			controleur = new Controleur(model);
		}

		private function creerModele() : void {
			model = new Modele();
		}

		private function creerVue() : void {
			vue = new Vue(model, controleur);
			addChild(vue);
		}
	}
}
