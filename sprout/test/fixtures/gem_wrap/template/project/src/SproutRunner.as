package {
	import asunit.textui.TestRunner;
	
	public class <%= project_name %>Runner extends TestRunner {
		public static const IMAGE_PATH:String = "../img/";

		public function <%= project_name %>Runner() {
			start(AllTests, null, TestRunner.SHOW_TRACE);
		}
	}
}
