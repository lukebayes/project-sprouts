
class OtherProject extends MovieClip {
	public static var linkageId:String = "__Packages.OtherProject";
	public static var classRef:Function = OtherProject;
	private static var instance:OtherProject;

	public function OtherProject() {
		trace("OtherProject Instantiated");
	}

	public static function main():Void {
		instance = OtherProject(_root.attachMovie(OtherProject.linkageId, 'someProject', 1));
	}

	public static var serializable:Boolean = Object.registerClass(linkageId, classRef);
}
