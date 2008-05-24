
import asunit.framework.TestCase;

class sometest.SomeTest extends TestCase {
	private var className:String = "sometest.SomeTest";

	public function SomeTest(testMethod:String) {
		super(testMethod);
	}

	public function testInstantiated():Void {
		var arr:Array = new Array();
		assertTrue("SomeTest instantiated", arr instanceof Array);
	}
}
