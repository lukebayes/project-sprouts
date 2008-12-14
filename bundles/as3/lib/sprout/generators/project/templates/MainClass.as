package {
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import skins.<%= project_name %>Skin;
	
	public class <%= project_name %> extends Sprite {

		public function <%= project_name %>() {
			addChild(new <%= project_name %>Skin.ProjectSprouts() as DisplayObject);
			trace("<%= project_name %> instantiated!");
		}
	}
}
