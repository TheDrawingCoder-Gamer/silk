package;

import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import haxelib.Data;
import haxelib.client.Main as HaxelibMain;
import haxe.remoting.Proxy;
import tink.Cli;
import tink.cli.Rest;

class Silk {
    public static function main() {
      /*
        var arguments = Sys.args();
        if (arguments.length == 0 || arguments[0] == 'help') {
            Sys.println('Welcome to silk, a thin little wrapper around haxelib that gives some convienence with alternate names. 
Usage: silk [command] [options]
  Basic
    install or i                   : install a given library, or all libraries from a hxml file
    update                         : update a single library (if given) or all installed libraries
    remove                         : remove a given library/version
    list                           : list all installed libraries
    set                            : set the current version for a library
  Information
    search                         : list libraries matching a word
    info or about                  : list information on a given library
    user                           : list information on a given user
    config                         : print the repository path
    path                           : give paths to libraries\' sources and necessary build definitions
    libpath                        : returns the root path of a library
    version                        : print the currently used haxelib version
    help                           : display this list of options
  Development
    submit                         : submit or update a library package
    register                       : register a new user
    dev                            : set the development directory for a given library
    git                            : use Git repository as library
    hg                             : use Mercurial (hg) repository as library
  Miscellaneous
    setup                          : set the haxelib repository path
    newrepo                        : create a new local repository
    deleterepo                     : delete the local repository
    convertxml                     : convert haxelib.xml file to haxelib.json
    run                            : run the specified library with parameters
    proxy                          : setup the Http proxy
  Available switches
    --flat                         : do not use --recursive cloning for git
    --always or -y                 : answer all questions with yes
    --debug                        : run in debug mode, imply not --quiet
    --quiet                        : print less messages, imply not --debug
    --system                       : run bundled haxelib version instead of latest update
    --skip-dependencies or --no-dep: do not install dependencies
    --never or -n                  : answer all questions with no
    --global or -g                 : force global repo if a local one exists');
        } else {
			for (i in 0...arguments.length) {
        // all valid characters in a url :sparkles:
				var gitRegex = ~/([A-Za-z0-9_\-.]+)@([a-zA-Z0-9-._~:\/?#\[\]@!$&'\(\)*+,;%=]+)/;
				var versionRegex = ~/([A-Za-z0-9_\-.]+)@((?:[0-9]+)\.(?:[0-9]+)\.(?:[0-9]+)(?:-(?:[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?)/;
				var githubRegex = ~/([A-Za-z0-9_\-.]+)@(?:github:)?([a-z0-9\-]+\/[a-z0-9\-]+)(?:#([a-z0-9]+))?/;
				switch (arguments[i]) {
					case '-y':
						arguments[i] = '--always';
					case '-n':
						arguments[i] = '--never';
					case '--no-dep':
						arguments[i] = '--skip-dependencies';
					case 'i' | 'add':
						arguments[i] = 'install';
					case 'about':
						arguments[i] = 'info';
					case '-g':
						arguments[i] = '--global';
          case 'up':
            arguments[i] = 'upgrade';
          
          case _ if (versionRegex.match(arguments[i])):
            arguments[0] = 'install';
            arguments[i] = versionRegex.matched(2);
            arguments.insert(i, versionRegex.matched(1));
          case _ if (githubRegex.match(arguments[i])):
            arguments[0] = 'git';
						var aUrl = 'https://github.com/';
            aUrl = aUrl + githubRegex.matched(2);
            if (githubRegex.matched(3) != null) {
              aUrl += '/tree/' + githubRegex.matched(3);
            }
            arguments[i] = aUrl;
            arguments.insert(i, githubRegex.matched(1));
          case _ if (gitRegex.match(arguments[i]) && arguments[0] == 'install'):
            // we have to reconfigure :sparkles: the whole thing :sparkles:
            arguments[0] = 'git';
            arguments[i] = gitRegex.matched(2);
            arguments.insert(i, gitRegex.matched(1));
				}
			}
			Sys.exit(Sys.command('haxelib', arguments));
      */
      Cli.process(Sys.args(), new SilkCli()).handle(Cli.exit);
        }
        
}
enum Categories {
  Basic;
  Information;
  Development;
  Misc;
}
class SiteProxy extends Proxy<haxelib.SiteApi> {}
@:access(haxelib.client.Main)
class SilkCli {
	var hecks:HaxelibMain;
	@:optional
  	@:alias('y')
	public var always:Bool;
	@:optional
	@:alias('n')
	public var never:Bool;
	@:optional
	@:alias(false)
	public var flat:Bool;
	@:optional
	@:alias(false)
	public var debug:Bool;
	@:alias(false)
	@:optional
	public var quiet:Bool;
	@:alias(false)
	@:optional
	public var system:Bool;
	@:optional
	@:flag('skip-dependencies', 'no-dep')
	@:alias(false)
	public var skipdeps:Bool;
	@:optional
	@:alias('g')
	public var global:Bool;
	@:defaultCommand
	public function help(rest:Rest<String>) {
			Sys.command('haxelib', ['help']);
	}
	@:command('install', 'i', 'add')
	public function install(rest:Rest<String>) {
		var args = cast (rest : Array<String>);
			var gitRegex = ~/([A-Za-z0-9_\-.]+)@([a-zA-Z0-9-._~:\/?#\[\]@!$&'\(\)*+,;%=]+)/;
			var versionRegex = ~/([A-Za-z0-9_\-.]+)@((?:[0-9]+)\.(?:[0-9]+)\.(?:[0-9]+)(?:-(?:[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?)/;
			var githubRegex = ~/([A-Za-z0-9_\-.]+)@(?:github:)?([a-z0-9\-]+\/[a-z0-9\-]+)(?:#([a-z0-9]+))?/;
			var mercuryRegex = ~/([A-Za-z0-9_\-.]+)@(?:mercury|hg):([a-zA-Z0-9-._~:\/?#\[\]@!$&'\(\)*+,;%=]+)/;
		var argFlags = getArgsForhaxe();
		var argumentsToPass = ['install'];
		if (args[0] != null) {
		if (versionRegex.match(args[0])) {
					argumentsToPass.push(versionRegex.matched(1));
					argumentsToPass.push(versionRegex.matched(2));
		} else if (mercuryRegex.match(args[0])) {
			argumentsToPass[0] = 'hg';
			argumentsToPass.push(mercuryRegex.matched(1));
			argumentsToPass.push(mercuryRegex.matched(2));
		} else if (githubRegex.match(args[0])) {
			argumentsToPass[0] = 'git';
					var aUrl = 'https://github.com/';
					aUrl = aUrl + githubRegex.matched(2);
					if (githubRegex.matched(3) != null) {
						aUrl += '/tree/' + githubRegex.matched(3);
					}
			argumentsToPass.push(githubRegex.matched(1));
			argumentsToPass.push(aUrl);
		} else if (gitRegex.match(args[0])) {
			argumentsToPass[0] = 'git';
			argumentsToPass.push(gitRegex.matched(1));
			argumentsToPass.push(gitRegex.matched(2));
		} else {
			argumentsToPass.concat(args);
		}

		}
		argumentsToPass.concat(argFlags);
		trace(argumentsToPass);
		Sys.command('haxelib', argumentsToPass);
	}
	@:command('update')
	public function update(rest:Rest<String>) {
			Sys.command('haxelib', ['update'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('remove', 'rm', 'uninstall')
	public function remove(rest:Rest<String>) {
			Sys.command('haxelib', ['remove'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('list', 'ls')
	public function list(rest:Rest<String>) {
			Sys.command('haxelib', ['list'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('set')
	public function set(rest:Rest<String>) {
		Sys.command('haxelib', ['set'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('search', 'find')
	public function search(rest:Rest<String>) {
		Sys.command('haxelib', ['search'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('info', 'about')
	public function info(rest:Rest<String>) {
		Sys.command('haxelib', ['info'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('config')
	public function config(rest:Rest<String>) {
		Sys.command('haxelib', ['config'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('path')
	public function path(rest:Rest<String>) {
		Sys.command('haxelib', ['path'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('libpath')
	public function libpath(rest:Rest<String>) {
		Sys.command('haxelib', ['libpath'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('version')
	public function version(rest:Rest<String>) {
		Sys.command('haxelib', ['version'].concat(cast rest).concat(getArgsForhaxe()));
	Sys.println('Silk Version: 0.0.1');
	}
	@:command('submit')
	public function submit(rest:Rest<String>) {
		Sys.command('haxelib', ['submit'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('register')
	public function register(rest:Rest<String>) {
		Sys.command('haxelib', ['register'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('dev')
	public function dev(rest:Rest<String>) {
		Sys.command('haxelib', ['dev'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('setup')
	public function setup(rest:Rest<String>) {
		Sys.command('haxelib', ['setup'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('newrepo')
	public function newrepo(rest:Rest<String>) {
		Sys.command('haxelib', ['newrepo'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('deleterepo')
	public function delrepo(rest:Rest<String>) {
		Sys.command('haxelib', ['deleterepo'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('convertxml')
	public function convertxml(rest:Rest<String>) {
		Sys.command('haxelib', ['convertxml'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('run')
	public function run(rest:Rest<String>) {
		Sys.command('haxelib', ['run'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('proxy')
	public function proxy(rest:Rest<String>) {
		Sys.command('haxelib', ['proxy'].concat(cast rest).concat(getArgsForhaxe()));
	}
	@:command('why')
	public function why(rest:Rest<String>) {
		
		// idk why i need to declare type here... isn't that what the cast is supposed to do? 
		var goodArgs:Array<String> = cast (rest : Array<String>);
		if (goodArgs[0] == null) 
			throw 'Library must be specified';
		if (goodArgs[1] == null)
			throw 'Hxml file must be specified.';
		var myHaxelib = File.getContent(goodArgs[1]);

		var pathThing = scanForDep(myHaxelib, goodArgs[0]);
		
		
		if (pathThing[0] == '~this') {
			Sys.println('This is directly required by your project.');
		} else if (pathThing.length == 0){
			Sys.println("Couldn't find a reason (either silk couldn't find a reason or the project doesn't use "+ goodArgs[0] + " as a dependency.)");
		} else {
			var smellyName:String = 'Dependency structure:';
			for (i in 0...pathThing.length) {
				var thing = pathThing[i];
				if (i != 0) {
					smellyName += ',';
				}
				smellyName += ' ${thing}';
			}
			Sys.println(smellyName);
		}

	}
	function scanForDep(hxml:String, lib:String) {
		var rep = hecks.getRepository();
		for (l in hxml.split('\n')) {
			var funnyRegex = ~/(?:-L|--library) ([A-Za-z0-9_\-.]+)(?::(git|(?:(?:[0-9]+)\.(?:[0-9]+)\.(?:[0-9]+)(?:-(?:[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?)))?/;
			if (funnyRegex.match(l)) {
				if (funnyRegex.matched(1) == lib) {
					// wait a minute
					return ['~this'];
				}
				var results = new List();
				hecks.checkRec(rep, funnyRegex.matched(1), funnyRegex.matched(2), results, false);
				var path = '';
				if (!results.isEmpty())
					path = results.first().dir;
				if (path == '')
					continue;
				var haxelibData = Data.readData(File.getContent(path + '/haxelib.json'), CheckData);
				var coolThingies = scanForDepFromLib(haxelibData, lib, [funnyRegex.matched(1)]);
				// trace(coolThingies);
				// note to self [] != [] because objects
				if (coolThingies.length != 0)
					return coolThingies;
			}
		}
		return [];
	}
	function scanForDepFromLib(libData:Infos, scanFor:String, path:Array<String>):Array<String> {
		var rep = hecks.getRepository();
		for (dep in libData.dependencies) {
			var nuPath = path.copy();
			nuPath.push(dep.name);
			if (dep.name == scanFor) {
				return nuPath;
			}
			var results = new List();
			hecks.checkRec(rep, dep.name, null, results, false);
			var pathe = '';
			if (!results.isEmpty())
				pathe = results.first().dir;
			if (pathe == '')
				continue;
			var haxelibData = Data.readData(File.getContent(pathe + '/haxelib.json'), CheckData);
			var scanResult = scanForDepFromLib(haxelibData, scanFor, nuPath);
			if (scanResult != [])
				return scanResult;
		}
		return [];
	}
	function getArgsForhaxe():Array<String> {
			var flagsAsArgs = [];
			if (always) {
				flagsAsArgs.push('--always');
			}
			if (never) {
				flagsAsArgs.push('--never');
			}
			if (flat) {
				flagsAsArgs.push('--flat');
			}
			if (debug) {
				flagsAsArgs.push('--debug');
			}
			if (quiet) {
				flagsAsArgs.push('--quiet');
			}
			if (system) {
				flagsAsArgs.push('--system');
			}
			if (skipdeps)
				flagsAsArgs.push('--skip-dependencies');
			if (global)
				flagsAsArgs.push('--global');
		return flagsAsArgs;
	}
	public function new() {
		hecks = new HaxelibMain();
		hecks.settings = {
			debug: debug,
			quiet: quiet,
			always: always,
			never: never,
			flat: flat,
			global: global,
			system: system,
			skipDependencies: skipdeps,
		};
	}
}