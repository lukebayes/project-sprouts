package display {

	import asunit.framework.TestCase;

	public class OtherComponentTest extends TestCase {
		private var otherComponent:OtherComponent;

		public function OtherComponentTest(methodName:String=null) {
			super(methodName)
		}

		override protected function setUp():void {
			super.setUp();
			otherComponent = new OtherComponent();
		}

		override protected function tearDown():void {
			super.tearDown();
			otherComponent = null;
		}

		public function testInstantiated():void {
			assertTrue("otherComponent is OtherComponent", otherComponent is OtherComponent);
		}

		public function testFailure():void {
			assertTrue("Failing test", false);
		}
	}
}