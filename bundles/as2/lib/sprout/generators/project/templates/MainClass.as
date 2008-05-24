
class <%= project_name %> extends MovieClip {
	public static var linkageId:String = "__Packages.<%= project_name %>";
	public static var classRef:Function = <%= project_name %>;
	private static var instance:<%= project_name %>;

	private var image:MovieClip;

	public function <%= project_name %>() {
		trace("<%= project_name %> Instantiated");
		image = attachMovie("ProjectSprouts", "image", 1);
	}

	public static function main():Void {
		instance = <%= project_name %>(_root.attachMovie(<%= project_name %>.linkageId, '<%=instance_name%>', 1));
	}

	public static var serializable:Boolean = Object.registerClass(linkageId, classRef);
}

