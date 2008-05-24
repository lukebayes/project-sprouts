package someproject {
	import asunit.framework.TestCase;

	public class SomeTest extends TestCase {
		
		public function SomeTest(methodName:String=null) {
			super(methodName);
		}

		public function testNothing():void {
			assertTrue("Some test can be executed", true);
			assertTrue("Broken!", false);
		}

	}
}
