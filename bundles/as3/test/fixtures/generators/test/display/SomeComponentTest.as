package display {

	import asunit.framework.TestCase;

	public class SomeComponentTest extends TestCase {
		private var someComponent:SomeComponent;

		public function SomeComponentTest(methodName:String=null) {
			super(methodName)
		}

		override protected function setUp():void {
			super.setUp();
			someComponent = new SomeComponent();
		}

		override protected function tearDown():void {
			super.tearDown();
			someComponent = null;
		}

		public function testInstantiated():void {
			assertTrue("someComponent is SomeComponent", someComponent is SomeComponent);
		}

		public function testFailure():void {
			assertTrue("Failing test", false);
		}
	}
}