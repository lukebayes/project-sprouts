import asunit.textui.TestRunner;

class <%= project_name %>Runner extends TestRunner {

	public function <%= project_name %>Runner() {
		// start(clazz:Class, methodName:String, showTrace:Boolean)
		// NOTE: sending a particular class and method name will
		// execute setUp(), the method and NOT tearDown.
		// This allows you to get visual confirmation while developing
		// visual entities
		start(AllTests, null, TestRunner.SHOW_TRACE);
	}

	public static function main():Void {
		var runner:<%= project_name %>Runner = new <%= project_name %>Runner();
	}
}
