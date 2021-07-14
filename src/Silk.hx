package;

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
class SilkCli {
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
  public function new() {}
}