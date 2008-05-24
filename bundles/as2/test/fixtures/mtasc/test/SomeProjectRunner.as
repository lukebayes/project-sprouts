import asunit.textui.TestRunner;
import sometest.SomeTest;

class SomeProjectRunner extends TestRunner {
	
	public function SomeProjectRunner() {
		// start(clazz:Class, methodName:String, showTrace:Boolean)
		// NOTE: sending a particular class and method name will
		// execute setUp(), the method and NOT tearDown.
		// This allows you to get visual confirmation while developing
		// visual entities
		start(SomeTest, null, TestRunner.SHOW_TRACE);
	}

	public static function main():Void {
		var runner:SomeProjectRunner = new SomeProjectRunner();
	}
}
