package net.http {

	import asunit.framework.TestCase;

	public class YamlTest extends TestCase {
		private var yaml:Yaml;

		public function YamlTest(methodName:String=null) {
			super(methodName)
		}

		override protected function setUp():void {
			super.setUp();
			yaml = new Yaml();
		}

		override protected function tearDown():void {
			super.tearDown();
			yaml = null;
		}

		public function testInstantiated():void {
			assertTrue("yaml is Yaml", yaml is Yaml);
		}

		public function testFailure():void {
			assertTrue("Failing test", false);
		}
	}
}