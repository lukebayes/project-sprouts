
import asunit.framework.TestCase;
import <%=  full_class_name %>;

class <%= full_test_case_name %> extends TestCase {
	private var className:String = "<%= package_name %>.<%= test_case_name %>";
	private var <%= instance_name %>:<%= class_name %>;

	public function <%= test_case_name %>(testMethod:String) {
		super(testMethod);
	}

	public function setUp():Void {
		super.setUp();
		<%= instance_name %> = new <%= class_name %>();
	}

	public function tearDown():Void {
		super.tearDown();
		delete <%= instance_name %>;
	}

	public function testInstantiated():Void {
		assertTrue("<%= instance_name %> instanceof <%= class_name %>", <%= instance_name %> instanceof <%= class_name %>);
	}

	public function testFailure():Void {
		assertTrue("Failing test", false);
	}
}
