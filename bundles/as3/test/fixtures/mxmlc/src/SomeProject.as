package {
	import flash.display.Sprite;
	import display.OrangeBox;
	
	/**
	 * The SomeProject class is the main class for the SomeProject application
	 */
	public class SomeProject extends Sprite {
		
		public function SomeProject() {
			var box:OrangeBox = new OrangeBox();
			addChild(box);
		}
	}
}