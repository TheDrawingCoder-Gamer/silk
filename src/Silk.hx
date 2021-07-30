package;

import yaml.Parser.ParserOptions;
import yaml.Yaml;
import yaml.util.ObjectMap;
import haxe.Json;

import haxelib.client.Vcs.VcsID;
import haxe.Exception;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import haxelib.Data;
import haxelib.client.Main as HaxelibMain;
import haxe.remoting.Proxy;
import tink.Cli;
import tink.cli.Rest;
import hxp.*;
import haxe.DynamicAccess;
using StringTools;
using ArrayTools;

typedef HaxelibSilky = {
	var name:String;
	var ?url:String;
	var license:String;
	var ?tags:Array<String>;
	var ?description:String;
	var ?classPath:String;
	var version:String;
	var releasenote:String;
	var contributors:Array<String>;
};

typedef HaxeBuildSilky = {
	var classPath:String; 
	var hxml:Dynamic;
};
typedef SilkyYaml = {
	var ?dependencies:Dynamic;
	var ?devDependencies:Dynamic;
	var ?haxelib:HaxelibSilky;
	var ?haxe:HaxeBuildSilky;
};

@:access(haxelib.client.Main)
class Silk {
    public static function main() {
		if (Sys.args()[0] == 'run') {
			var hecks = new HaxelibMain();
			hecks.args = Sys.args();
			// haha. not cool > : (
			hecks.settings = {
				debug: false,
				quiet: false,
				always: false,
				never: false,
				flat: false,
				global: false,
				system: false,
				skipDependencies: false,
			};
			hecks.process();
		} else 
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
// Technically you don't have to have haxelib installed but like
// if you are using haxe it basically _needs_ to be installed
// I'm all for tink but i hate that i have to put optional on all of these goddamn switches
class SilkCli {
	static var parseOptions:ParserOptions = new ParserOptions().useObjects();
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
	@:optional
	public var silky:Bool;
	@:defaultCommand
	public function help(rest:Rest<String>) {
		hecks.usage();
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
		trace(args);
		var doing = 'install';
		if (args[0] != null) {
			var nameThing = args.shift();
			if (versionRegex.match(nameThing)) {
				argumentsToPass.push(versionRegex.matched(1));
				argumentsToPass.push(versionRegex.matched(2));
			} else if (mercuryRegex.match(nameThing)) {
				doing = 'hg';
				argumentsToPass.push(mercuryRegex.matched(1));
				argumentsToPass.push(mercuryRegex.matched(2));
			} else if (githubRegex.match(nameThing)) {
				doing = 'git';
				var aUrl = 'https://github.com/';
				aUrl = aUrl + githubRegex.matched(2);
				if (githubRegex.matched(3) != null) {
					aUrl += '/tree/' + githubRegex.matched(3);
				}
				argumentsToPass.push(githubRegex.matched(1));
				argumentsToPass.push(aUrl);
			} else if (gitRegex.match(nameThing)) {
				doing = 'git';
				argumentsToPass.push(gitRegex.matched(1));
				argumentsToPass.push(gitRegex.matched(2));
			} else {
				// concat destructive
				argumentsToPass.push(nameThing);
				argumentsToPass = argumentsToPass.concat(args);
			}

		}
		argumentsToPass[0] = doing;
		argumentsToPass = argumentsToPass.concat(argFlags);
		trace(argumentsToPass);
		hecks.args = argumentsToPass;
		// fuck it, haxelib take the wheel
		hecks.process();
		
	}
	@:command('update')
	public function update(rest:Rest<String>) {
		process('update', cast rest);
	}
	@:command('remove', 'rm', 'uninstall')
	public function remove(rest:Rest<String>) {
		process('remove', cast rest);
	}
	@:command('list', 'ls')
	public function list(rest:Rest<String>) {
		process('list', cast rest);
	}
	@:command('set')
	public function set(rest:Rest<String>) {
		process('set', cast rest);
	}
	@:command('search', 'find')
	public function search(rest:Rest<String>) {
		process('search', cast rest);
	}
	@:command('info', 'about')
	public function info(rest:Rest<String>) {
		process('info', cast rest);
	}
	@:command('config')
	public function config(rest:Rest<String>) {
		process('config', cast rest);
	}
	@:command('path')
	public function path(rest:Rest<String>) {
		process('path', cast rest);
	}
	@:command('libpath')
	public function libpath(rest:Rest<String>) {
		process('libpath', cast rest);
	}
	@:command('version')
	public function version(rest:Rest<String>) {
		process('version', cast rest);
		Sys.println('Silk Version: 0.0.1');
	}
	@:command('submit')
	public function submit(rest:Rest<String>) {
		updateHaxelibJson();
		process('submit', cast rest);
	}
	@:command('register')
	public function register(rest:Rest<String>) {
		process('register', cast rest);
	}
	@:command('dev')
	public function dev(rest:Rest<String>) {
		updateHaxelibJson();
		process('dev', cast rest);
	}
	@:command('setup')
	public function setup(rest:Rest<String>) {
		process('setup', cast rest);
	}
	@:command('newrepo')
	public function newrepo(rest:Rest<String>) {
		process('newrepo', cast rest);
	}
	@:command('deleterepo')
	public function delrepo(rest:Rest<String>) {
		process('deleterepo', cast rest);
	}
	@:command('convertxml')
	public function convertxml(rest:Rest<String>) {
		process('convertxml', cast rest);
	}
	@:command('haxelib')
	public function genHaxelib(rest:Rest<String>) {
		updateHaxelibJson();
		Sys.println('Updated haxelib.json.');
	}
	@:command('silksetup')
	public function silksetup(rest:Rest<String>) {
		var haxePath:Null<String> = Sys.getEnv('HAXEPATH');
		// :neutral_face:
		if (System.hostPlatform == WINDOWS) {
			if (haxePath == null || haxePath == "") {
				haxePath = "C:\\HaxeToolkit\\haxe\\";
			}
			try {
				File.copy(hxp.Haxelib.getPath(new hxp.Haxelib("silk")) + "\\templates\\bin\\silk.bat", haxePath + "\\silk.bat");
			} catch (e) {}
			try {
				File.copy(hxp.Haxelib.getPath(new hxp.Haxelib("silk")) + "\\templates\\bin\\silk.sh", haxePath + "\\silk.sh");
			} catch (e) {}
			try {
				File.copy(hxp.Haxelib.getPath(new hxp.Haxelib("silk")) + "\\templates\\bin\\spx.bat", haxePath + "\\spx.bat");
			} catch (e) {}
			try {
				File.copy(hxp.Haxelib.getPath(new hxp.Haxelib("silk")) + "\\templates\\bin\\spx.sh", haxePath + "\\spx.sh");
			} catch (e) {}

		} else {
			if (haxePath == null || haxePath == "") {
				haxePath = "/usr/lib/haxe";
			}
			var installed = false;

			try {
				System.runCommand("", "sudo", ["cp", "-f", hxp.Haxelib.getPath(new hxp.Haxelib("silk")) + '/templates/bin/silk.sh', "usr/local/bin/silk"], false);
				System.runCommand("", "sudo", ["chmod", "755", "usr/local/bin/silk"], false);
				System.runCommand("", "sudo", [
					"cp",
					"-f",
					hxp.Haxelib.getPath(new hxp.Haxelib("silk")) + '/templates/bin/spx.sh',
					"usr/local/bin/spx"
				], false);
				System.runCommand("", "sudo", ["chmod", "755", "usr/local/bin/spx"], false);
				installed = true;
			} catch (e) {}
			if (!installed) {
				try {
					System.runCommand("", "sudo", [
						"cp",
						"-f",
						hxp.Haxelib.getPath(new hxp.Haxelib("silk")) + '/templates/bin/silk.sh',
						"usr/local/bin/silk"
					], false);
					System.runCommand("", "sudo", ["chmod", "755", "usr/local/bin/silk"], false);
					System.runCommand("", "sudo", [
						"cp",
						"-f",
						hxp.Haxelib.getPath(new hxp.Haxelib("silk")) + '/templates/bin/spx.sh',
						"usr/local/bin/spx"
					], false);
					System.runCommand("", "sudo", ["chmod", "755", "usr/local/bin/spx"], false);
					installed = true;
				} catch (e) {}

			}
			if (!installed) {
				Sys.println("Was unable to install alias. Try setting it up manually.");
			}
		}
	}
	@:command('proxy')
	public function proxy(rest:Rest<String>) {
		process('proxy', cast rest);
	}
	@:command('haxe')
	public function haxecmd(rest:Rest<String>) {
		var sleep:Array<String> = cast rest;
		if (!FileSystem.exists('.silk.yml')) {
			Sys.command('haxe', [sleep[0] + '.hxml']);
			return;
		}
		var ymlData = parseSilkyJson(File.getContent('.silk.yml'));
		var coolDep:DynamicAccess<String> = cast(merge(ymlData.dependencies, ymlData.devDependencies) : DynamicAccess<String>);
		trace(ymlData);
		var lines:Array<String> = [];
		lines.push('-cp ' + ymlData.haxe.classPath);
		for (key in coolDep.keys()) {
			lines.push('-L ' + key);
		}
		var paragraph = lines.join("\n");
		paragraph += '\n' + Reflect.field(ymlData.haxe.hxml, sleep[0]);
		File.saveContent('${sleep[0]}.hxml', paragraph);
		Sys.command('haxe', ['${sleep[0]}.hxml']);

	}
	@:command('makehxmls')
	public function makehxmls(rest:Rest<String>) {
		var ymlData = parseSilkyJson(File.getContent('.silk.yml'));
		var coolDep:DynamicAccess<String> = cast(merge(ymlData.dependencies, ymlData.devDependencies) : DynamicAccess<String>);
		var lines:Array<String> = [];
		lines.push('-cp ' + ymlData.haxe.classPath);
		for (key in coolDep.keys()) {
			lines.push('-L ' + key);
		}
		var paragraph = lines.join("\n");
		var hxml:DynamicAccess<String> = cast (ymlData.haxe.hxml : DynamicAccess<String>);
		for (key => value in hxml.keyValueIterator()) {
			var coool = paragraph + '\n' + value;
			File.saveContent(key + '.hxml', coool);
		}
	}
	@:command('why')
	public function why(rest:Rest<String>) {
		// idk why i need to declare type here... isn't that what the cast is supposed to do? 
		var goodArgs:Array<String> = cast (rest : Array<String>);
		if (goodArgs[0] == null) 
			throw new Exception('Library must be specified');
		var pathThing:Array<String> = [];
		if (goodArgs[1] != null) {
			var myHaxelib = File.getContent(goodArgs[1]);

			pathThing = scanForDep(myHaxelib, goodArgs[0]);

			
		} else {
			// try to find the file
			if (FileSystem.exists('.silk.yml')) {
				
				var myYml = File.getContent('.silk.yml');
				pathThing = scanForDepFromYml(parseSilkyJson(myYml), goodArgs[0], []);
			}
			else if (FileSystem.exists('haxelib.json')) {
				var myJson = File.getContent('haxelib.json');
				pathThing = scanForDepFromLib(Data.readData(myJson, CheckData), goodArgs[0], [], true);
			} else {
				throw new Exception("If no hxml is specified there must be a .silk.yml or a haxelib.json.");
			}
			
			
		}
		if (pathThing[0] == '~this') {
			Sys.println('This is directly required by your project.');
		} else if (pathThing.length == 0) {
			Sys.println("Couldn't find a reason (either silk couldn't find a reason or the project doesn't use " + goodArgs[0] + " as a dependency.)");
		} else {
			var smellyName:String = 'Dependency structure: ' + pathThing.join(', ');
			Sys.println(smellyName);
		}
			
		

	}
	function updateHaxelibJson() {
		if (FileSystem.exists('.silk.yml')) {
			var dataYml = parseSilkyJson(File.getContent('.silk.yml'));
			if (dataYml.haxelib == null)
				throw "Error, can't use as a haxelib project if there is no haxelib section of .silk.yml.";
			var coolHaxelib = {
				dependencies: dataYml.dependencies,
				name: dataYml.haxelib.name,
				url: dataYml.haxelib.url,
				license: dataYml.haxelib.license,
				tags: dataYml.haxelib.tags,
				description: dataYml.haxelib.description,
				classPath: dataYml.haxelib.classPath,
				version: dataYml.haxelib.version,
				releasenote: dataYml.haxelib.releasenote,
				contributors: dataYml.haxelib.contributors
			};
			File.saveContent('haxelib.json', Json.stringify(coolHaxelib));
		}
		
	}
	function process(cmd:String, rest:Array<String>) {
		var stinkyArgs = [cmd];
		if (cmd != 'run')
			stinkyArgs = stinkyArgs.concat(rest).concat(getArgsForhaxe());
		else 
			stinkyArgs = Sys.args();
		hecks.args = stinkyArgs;
		trace(hecks.args);
		hecks.process();
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
			} else if (l.endsWith('.hxml')) {
				var output = scanForDep(File.getContent(l.trim()), lib);
				if (output.length != 0) {
					return output;
				}
			}
		}
		return [];
	}
	function scanForDepFromLib(libData:Infos, scanFor:String, path:Array<String>, ?direct:Bool = false):Array<String> {
		var rep = hecks.getRepository();
		for (dep in libData.dependencies) {
			// trace(dep);
			var nuPath = path.copy();
			nuPath.push(dep.name);
			if (dep.name == scanFor) {

				return direct ? ['~this'] : nuPath;
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
			if (scanResult.length != 0)
				return scanResult;
		}
		return [];
	}
	function scanForDepFromYml(ymlData:SilkyYaml, scanFor:String, path:Array<String>):Array<String> {
		var rep = hecks.getRepository();
		var coolDep:DynamicAccess<String> = cast (merge(ymlData.dependencies, ymlData.devDependencies) : DynamicAccess<String>);
		for (dep => version in coolDep.keyValueIterator()) {
			version = parseVersion(version, dep);
			trace(version);
			trace(dep);
			// trace(dep);
			var nuPath = path.copy();
			nuPath.push(dep);
			if (dep == scanFor) {
				return ['~this'];
			}
			var results = new List();
			hecks.checkRec(rep, dep, version, results, false);
			var pathe = '';
			if (!results.isEmpty())
				pathe = results.first().dir;
			if (pathe == '')
				continue;
			var haxelibData = Data.readData(File.getContent(pathe + '/haxelib.json'), CheckData);
			var scanResult = scanForDepFromLib(haxelibData, scanFor, nuPath);
			if (scanResult.length != 0)
				return scanResult;
		}
		return [];
	}
	function parseVersion(version:String, lib:String):String {
		var versionRegex = ~/((?:[0-9]+)\.(?:[0-9]+)\.(?:[0-9]+)(?:-(?:[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?)/;
		var gitRegex = ~/((?:git:)[a-zA-Z0-9-._~:\/?#\[\]@!$&'\(\)*+,;%=]+)/;
		var githubRegex = ~/(?:github:)([a-z0-9\-]+\/[a-z0-9\-]+)(?:#([a-z0-9]+))?/;
		var mercuryRegex = ~/(?:mercury|hg):([a-zA-Z0-9-._~:\/?#\[\]@!$&'\(\)*+,;%=]+)/;
		var rep = hecks.getRepository();
		try {
			var pdir = rep + '/' + Data.safe(lib) + '/' + Data.safe(version);
			// we don't need to check for dev as explicit version should always exist
			if (FileSystem.exists(pdir) || version == "dev") {
				return version;
			}
		} catch (e:Any) {}
		
		if (versionRegex.match(version)) {
			return version;
		} else if (mercuryRegex.match(version)) {
			// TODO find out how it works
			/*
			Sys.println('Currently, silk doesn\'t know how to get versions of mercuriral projects.');
			Sys.exit(-1);
			return '';
			*/
			return 'hg';
		} else if (githubRegex.match(version)) {
			// i don't know how to use vcs. 
			/*
			Sys.println('Currently, silk doesn\'t know how to get versions of git projects.');
			Sys.exit(-1);
			return '';
			*/
			return 'git';
		} else if (gitRegex.match(version)) {
			/*
			var gitUrl = gitRegex.matched(1);
			var pdir = rep + '/' + Data.safe(lib) + '/' + Data.safe(projectName());
			if (FileSystem.exists(pdir))
				return projectName();
			// tink has an api for this but i'm not in the mood to deal with async
			if (!never && !always)
				Sys.println('Install git of $lib for this project? [y/n]');
			if (!never && (always || Sys.stdin().readLine().trim() == 'y')) {
				hecks.doVcsInstall(rep, new CustomGitVcs(projectName(), hecks.settings), lib, gitUrl, null, null, null);
				return projectName();
			}
			throw new Exception("Wasn't allowed to download version and it didn't exist.");
			*/
			return 'git';
			
		} else {
			switch (version) {
				case 'git' | 'hg': 
					// non specific i'm sure it's fine
					return version;
			}
		}
		throw new Exception("Version doesn't exist");
		return '';
	}
	function projectName() {
		if (FileSystem.exists('haxelib.json')) {
			var info = Data.readData(File.getContent('haxelib.json'), CheckData);
			return cast (info.name: String);
		} else if (FileSystem.exists('.silk.yml')) {
			var silkYml:SilkyYaml = parseSilkyJson(File.getContent('.silk.yml'));
			if (silkYml.haxelib != null) {
				return silkYml.haxelib.name;
			}
		} 
		var cwdArray = Sys.getCwd().split('/');

		return cwdArray[cwdArray.length - 1];
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
	function parseSilkyJson(json:String):SilkyYaml {
		// oop
		return Yaml.parse(json, parseOptions);
	}
	public function new() {
		hecks = new HaxelibMain();
		hecks.args = Sys.args();
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
	function merge(base:Dynamic, ext:Dynamic) {
		var res = Reflect.copy(base);
		for (f in Reflect.fields(ext))
			Reflect.setField(res, f, Reflect.field(res, f));
		return res;
	}
}