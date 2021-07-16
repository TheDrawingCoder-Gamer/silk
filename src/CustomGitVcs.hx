import haxelib.client.Vcs.Settings;
import haxelib.client.Vcs.Git;

class CustomGitVcs extends Git {
    public function new(directory:String, settings:Settings) {
        super(settings);
        this.directory = directory;
    }
}