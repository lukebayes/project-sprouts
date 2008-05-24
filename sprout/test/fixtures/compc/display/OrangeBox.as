package display {
	import flash.display.Sprite;

	public class OrangeBox extends Sprite {
		
		public function OrangeBox() {
			graphics.beginFill(0xFFCC00);
			graphics.drawRect(0, 0, 200, 200);
			graphics.endFill();
		}
	}
}