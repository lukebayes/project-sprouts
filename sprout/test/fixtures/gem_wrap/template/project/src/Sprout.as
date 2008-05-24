package {
	import flash.display.Sprite;
	import skins.DefaultSkin;
	
	public class <%= project_name %> extends Sprite {

		public function <%= project_name %>() {
			addChild(new DefaultSkin.PatternPark());
			trace("<%= project_name %> instantiated!");
		}
	}
}
