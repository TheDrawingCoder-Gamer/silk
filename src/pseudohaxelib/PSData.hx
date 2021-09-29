package pseudohaxelib;

class PSData {
	public static var alphanum(default, null) = ~/^[A-Za-z0-9_.-]+$/;
    public static function safe(name:String){
        if (!alphanum.match(name))
            throw "Invalid parameter: " + name;
        return name.split(".").join(",");
    }
}