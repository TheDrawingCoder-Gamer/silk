package;

class Silk {
    public static function main() {
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
				var gitRegex = ~/([A-Za-z0-9_-.]+)@([a-zA-Z0-9-._~:\/?#\[\]@!$&'\(\)*+,;%=]+)/;
				var versionRegex = ~/([A-Za-z0-9_-.]+)@((?:[0-9]+)\.(?:[0-9]+)\.(?:[0-9]+)(?:-(?:[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?)/;
				var githubRegex = ~/([A-Za-z0-9_-.]+)@(?:github:)?([a-z0-9\-]+\/[a-z0-9\-]+)(?:#([a-z0-9]+))?/;
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
        }
        
    }
}