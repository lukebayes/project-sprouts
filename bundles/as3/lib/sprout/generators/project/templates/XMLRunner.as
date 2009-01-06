package {
	import asunit.textui.TestRunner;
	import asunit.textui.XMLResultPrinter;
	
	public class <%= project_name %>XMLRunner extends TestRunner {

		public function <%= project_name %>XMLRunner() {
			// start(clazz:Class, methodName:String, showTrace:Boolean)
			// NOTE: sending a particular class and method name will
			// execute setUp(), the method and NOT tearDown.
			// This allows you to get visual confirmation while developing
			// visual entities
			setPrinter(new XMLResultPrinter());
			start(AllTests, null, TestRunner.SHOW_TRACE);
		}
	}
}
