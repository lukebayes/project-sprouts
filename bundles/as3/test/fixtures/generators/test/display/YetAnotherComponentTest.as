package display {

	import asunit.framework.TestCase;

	public class YetAnotherComponentTest extends TestCase {
		private var yetAnotherComponent:YetAnotherComponent;

		public function YetAnotherComponentTest(methodName:String=null) {
			super(methodName)
		}

		override protected function setUp():void {
			super.setUp();
			yetAnotherComponent = new YetAnotherComponent();
		}

		override protected function tearDown():void {
			super.tearDown();
			yetAnotherComponent = null;
		}

		public function testInstantiated():void {
			assertTrue("yetAnotherComponent is YetAnotherComponent", yetAnotherComponent is YetAnotherComponent);
		}

		public function testFailure():void {
			assertTrue("Failing test", false);
		}
	}
}