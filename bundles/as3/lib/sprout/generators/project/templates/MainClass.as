package {
	import flash.display.Sprite;
	import skins.<%= project_name %>Skin;
	
	public class <%= project_name %> extends Sprite {

		public function <%= project_name %>() {
			addChild(new <%= project_name %>Skin.ProjectSprouts());
			trace("<%= project_name %> instantiated!");
		}
	}
}
