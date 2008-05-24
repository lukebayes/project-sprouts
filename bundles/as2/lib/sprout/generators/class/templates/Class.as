
class <%= full_class_name %> {
	public static var linkageId:String = "__Packages.<%= full_class_name %>";
	public static var classRef:Function = <%= class_name %>;

	public function <%= class_name %>() {
	}
	
	public static var serializable:Boolean = Object.registerClass(linkageId, classRef);
}
