package pseudohaxelib;

import sys.FileSystem;
import haxe.io.Path;

// Pseudohaxelib is custom libraries that will try to circumvent the requirement of haxelib
// as a dependency, as nobody likes having 2 installs of basically the same thing.

class PSHaxelib {
    public static var cwd:Null<String> = null;
    private static var REPODIR:String = ".haxelib";
    public static function getRepository(?cwdarg:String, global:Bool=false) {
        if (cwdarg == null && cwd == null) {
            throw "Expected cwd to be specified for the first time.";
        }
        if (!global) {
            return switch (getLocalRepository()) {
                case null: getGlobalRepository();
                // filesystem.fullpath uses the "cwd" which is wrong for run.n/haxelib libs
				case repo: Path.addTrailingSlash(Path.isAbsolute(repo) ? repo : Path.normalize(Path.join([cwd, repo])) );
            }
        } else 
            return getGlobalRepository();
    }
    static function getLocalRepository():Null<String> {
        var dir = Path.removeTrailingSlashes(cwd);
        while (dir != null) {
            var repo = Path.addTrailingSlash(dir) + REPODIR;
            if (FileSystem.exists(repo) && FileSystem.isDirectory(repo)) {
                return repo;
            } else {
                dir = new Path(dir).dir;
            }
        }
        return null;
    }

    static function getGlobalRepository():String {
        var rep = Sys.getEnv("HAXELIB_PATH");
        if (!FileSystem.exists(rep)) {
            throw 'haxelib Repository ${rep} does not exist. Make sure haxelib is setup properly.';
        } else if (!FileSystem.isDirectory(rep)) {
            throw 'haxelib Repository ${rep} exists, but it is a file. Please remove it and set up haxelib again.';
        }
        return rep;
    }
}