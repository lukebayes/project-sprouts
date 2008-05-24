package display {
	import flash.display.Sprite;

	/**
	 * This class will create a 200x200 pixel Orange box
	 * that cannot be configured in any other way.
	 */
	public class OrangeBox extends Sprite {
		
		public function OrangeBox() {
			draw();
		}
		
		/**
		 * The drawMethod is called to draw the orange box.
		 */
		public function draw():void {
			graphics.beginFill(0xFFCC00);
			graphics.drawRect(0, 0, 200, 200);
			graphics.endFill();
		}
	}
}