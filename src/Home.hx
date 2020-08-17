import hxd.Key;

class Home extends Page {
	public static var ME : Home;

	var jPage(get,never) : js.jquery.JQuery; inline function get_jPage() return App.ME.jPage;

	public function new() {
		super();

		ME = this;
		App.ME.loadPage("home");
		App.ME.setWindowTitle();

		// Version
		var ver = jPage.find(".version");
		ver.text( Lang.t._("Version ::v::, project file version ::pv::", {
			v: Const.getAppVersion(),
			pv: Const.DATA_VERSION,
		}) );

		// Buttons
		jPage.find(".load").click( function(ev) {
			onLoad();
		});

		jPage.find(".new").click( function(ev) {
			onNew();
		});

		jPage.find(".exit").click( function(ev) {
			App.ME.exit(true);
		});

		updateRecents();
	}

	function updateRecents() {
		var jRecentList = jPage.find("ul.recents");
		jRecentList.empty();

		var recents = App.ME.session.recentProjects;
		if( recents.length==0 )
			jRecentList.hide();
		else {
			var i = recents.length-1;
			while( i>=0 ) {
				var p = recents[i];
				var li = new J('<li/>');
				li.appendTo(jRecentList);
				li.append( JsTools.makePath(p) );
				li.click( function(ev) loadProject(p) );
				i--;
			}
		}
	}


	public function onLoad() {
		JsTools.loadDialog([".json"], App.ME.getDefaultDir(), function(filePath) {
			loadProject(filePath);
		});
	}

	function loadProject(filePath:String) {
		if( !JsTools.fileExists(filePath) ) {
			N.error("File not found: "+filePath);
			App.ME.unregisterRecentProject(filePath);
			updateRecents();
			return false;
		}

		// Parse
		var json = null;
		var p = try {
			var raw = JsTools.readFileString(filePath);
			json = haxe.Json.parse(raw);
			led.Project.fromJson(json);
		}
		catch(e:Dynamic) {
			N.error( Std.string(e) );
			null;
		}

		if( p==null ) {
			N.error("Couldn't read project file!");
			return false;
		}

		// Open it
		App.ME.openEditor(p, filePath);
		N.msg("Loaded project: "+filePath);
		return true;
	}

	public function onNew() {
		JsTools.saveAsDialog([".json"], App.ME.getDefaultDir(), function(filePath) {
			var fp = dn.FilePath.fromFile(filePath);
			fp.extension = "json";

			var p = led.Project.createEmpty();
			p.name = fp.fileName;
			var data = JsTools.prepareProjectFile(p);
			JsTools.writeFileBytes(fp.full, data.bytes);

			N.msg("New project created: "+fp.full);
			App.ME.openEditor(p, fp.full);
		});
	}

}
