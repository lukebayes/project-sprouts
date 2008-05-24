package utils {

	import asunit.framework.TestCase;

	public class MathUtilTest extends TestCase {
		private var mathUtil:MathUtil;

		public function MathUtilTest(methodName:String=null) {
			super(methodName)
		}

		override protected function setUp():void {
			super.setUp();
			mathUtil = new MathUtil();
		}

		override protected function tearDown():void {
			super.tearDown();
			mathUtil = null;
		}

		public function testInstantiated():void {
			assertTrue("mathUtil is MathUtil", mathUtil is MathUtil);
		}

		public function testFailure():void {
			assertTrue("Failing test", true);
		}
	}
}