
class SomeProject extends MovieClip {
	public static var linkageId:String = "__Packages.SomeProject";
	public static var classRef:Function = SomeProject;
	private static var instance:SomeProject;

	public function SomeProject() {
		trace("SomeProject Instantiated");
	}

	public static function main():Void {
		instance = SomeProject(_root.attachMovie(SomeProject.linkageId, 'someProject', 1));
	}

	public static var serializable:Boolean = Object.registerClass(linkageId, classRef);
}
