package;
import haxe.Json;
import haxe.io.Path;
import yy.*;
import sys.FileSystem;
import sys.io.File;
import tools.SfGmx;
import vit.*;
import yy.YyProject;

/**
 * ...
 * @author YellowAfterlife
 */
class VitProject {
	public static var current:VitProject;
	var isOK = false;
	public var objectNames:Map<YyGUID, String> = new Map();
	public var spriteNames:Map<YyGUID, String> = new Map();
	var folders:Map<YyGUID, YyView> = new Map();
	var assets:Map<YyGUID, YyProjectResource> = new Map();
	var rootView:YyView = null;
	var project:YyProject;
	var projectDir:String;
	public function new(from:String) {
		var dir = Path.directory(from);
		projectDir = dir;
		Sys.println("Indexing project...");
		project = try {
			Json.parse(File.getContent(from));
		} catch (x:Dynamic) {
			Sys.println("Either this is a 2.3 project or JSON is malformed: " + x);
			return;
		};
		//
		for (pair in project.resources) {
			var id = pair.Key;
			if (pair.Value.resourceType == "GMFolder") {
				var fd:YyView = Json.parse(File.getContent(Path.join([dir, "views", '$id.yy'])));
				folders[id] = fd;
				if (fd.isDefaultView) rootView = fd;
			} else {
				assets[id] = pair;
				var tstore = switch (pair.Value.resourceType) {
					case "GMObject": 1;
					case "GMSprite": 2;
					default: 0;
				};
				if (tstore > 0) {
					var path = pair.Value.resourcePath;
					var name = Path.withoutDirectory(Path.withoutExtension(path));
					switch (tstore) {
						case 1: objectNames[id] = name;
						case 2: spriteNames[id] = name;
					}
				}
			}
		}
		//
		Sys.println("Alright.");
		isOK = true;
	}
	public function print(to:String) {
		current = this;
		Sys.println("Printing...");
		var gmx = new SfGmx("assets"), q:SfGmx;
		//{ prepare GMX
		q = gmx.addEmptyChild("Configs");
		q.set("name", "configs");
		q.addTextChild("Config", "Configs\\Default");
		q = gmx.addEmptyChild("datafiles");
		q.set("name", "datafiles");
		q.setInt("number", 0);
		gmx.addEmptyChild("NewExtensions");
		function addCat(kind:String, label:String):SfGmx {
			var q = gmx.addEmptyChild(kind);
			q.set("name", label);
			return q;
		}
		addCat("sounds", "sound");
		addCat("sprites", "sprites");
		addCat("backgrounds", "background");
		addCat("paths", "paths");
		addCat("scripts", "scripts");
		addCat("shaders", "shaders");
		addCat("fonts", "fonts");
		addCat("objects", "objects");
		addCat("timelines", "timelines");
		addCat("rooms", "rooms");
		var macros = gmx.addEmptyChild("constants");
		macros.setInt("number", 0);
		gmx.addEmptyChild("help");
		q = gmx.addEmptyChild("TutorialState");
		q.addTextChild("IsTutorial", "0");
		q.addTextChild("TutorialName", "");
		q.addTextChild("TutorialPage", "0");
		//}
		//{ prepare directories
		var dir = Path.directory(to);
		function ensureDir(path:String) {
			if (!FileSystem.exists(path)) FileSystem.createDirectory(path);
		}
		ensureDir(dir);
		ensureDir('$dir/sprites');
		ensureDir('$dir/sprites/images');
		ensureDir('$dir/sound');
		ensureDir('$dir/sound/audio');
		ensureDir('$dir/background');
		ensureDir('$dir/background/images');
		ensureDir('$dir/paths');
		ensureDir('$dir/scripts');
		ensureDir('$dir/shaders');
		ensureDir('$dir/fonts');
		ensureDir('$dir/timelines');
		ensureDir('$dir/objects');
		ensureDir('$dir/rooms');
		ensureDir('$dir/datafiles');
		ensureDir('$dir/extensions');
		//}
		function addAssetNode(chain:Array<String>, gmxItem:SfGmx, plural:String, before:Bool = false):Void {
			var gmxDir = gmx;
			for (part in chain) {
				var gmxNext:SfGmx = null;
				for (gmxChild in gmxDir.children) {
					if (gmxChild.get("name") == part) {
						gmxNext = gmxChild;
						break;
					}
				}
				if (gmxNext == null) {
					gmxNext = new SfGmx(plural);
					gmxNext.set("name", part);
					if (before) {
						gmxDir.insertBefore(gmxNext, gmxDir.children[0]);
					} else gmxDir.addChild(gmxNext);
				}
				gmxDir = gmxNext;
			}
			//
			gmxDir.addChild(gmxItem);
		}
		function printAsset(pair:YyProjectResource, chain:Array<String>):Void {
			var yyType = pair.Value.resourceType;
			var single = yyType.substring(2).toLowerCase();
			var plural = single + "s";
			var path = pair.Value.resourcePath;
			var name = Path.withoutDirectory(Path.withoutExtension(path));
			//
			var gmxPath = switch (single) {
				case "sound", "background": '$single\\$name';
				default: '$plural\\$name';
			};
			switch (single) {
				case "script": gmxPath += ".gml";
				case "shader": gmxPath += ".shader";
			};
			//
			var yyPath = pair.Value.resourcePath;
			var yyFull = Path.join([projectDir, yyPath]);
			var yy:Dynamic = try {
				Json.parse(File.getContent(yyFull));
			} catch (x:Dynamic) {
				Sys.println('Error loading $yyPath: $x');
				return;
			};
			var outPath = Path.join([dir, gmxPath]);
			var gmxItem = new SfGmx(single, gmxPath);
			//
			switch (single) {
				case "script": {
					var scr:YyScript = yy;
					if (scr.IsCompatibility) return;
					Sys.println('Converting $name...');
					var gml = try {
						File.getContent(Path.withExtension(yyFull, "gml"));
					} catch (x:Dynamic) {
						Sys.println('Failed to read $yyFull: $x');
						"";
					}
					File.saveContent(outPath, VitGML.proc(gml, name));
				};
				case "sprite": VitSprite.proc(yy, yyFull, outPath, name);
				case "font":   VitFont.proc(name, yy, yyFull, outPath);
				case "path":   VitPointPath.proc(name, yy, yyFull, outPath);
				case "sound":  VitSound.proc(name, yy, yyFull, outPath);
				case "object": VitObject.proc(name, yy, yyFull, outPath);
				case "shader": {
					var sh:YyShader = yy;
					var fsh = File.getContent(Path.withExtension(yyFull, "fsh"));
					var vsh = File.getContent(Path.withExtension(yyFull, "vsh"));
					var m = "\r\n//######################_==_YOYO_SHADER_MARKER_==_######################@~";
					File.saveContent(outPath, vsh + m + fsh);
					gmxItem.set("type", switch (sh.type) {
						case 1: "GLSLES";
						case 4: "HLSL11";
						default: "GLSL";
					});
				};
				default: return;
			}
			//
			addAssetNode(chain, gmxItem, plural);
			//trace(pair.Value.resourcePath, single, chain);
		}
		function printFolder(fd:YyView, chain:Array<String>):Void {
			for (id in fd.children) {
				var fd1 = folders[id];
				if (fd1 != null) {
					var next:Array<String>;
					if (chain != null) {
						next = chain.copy();
						next.push(fd1.folderName);
					} else next = [];
					printFolder(fd1, next);
					continue;
				}
				var pair = assets[id];
				if (pair != null) {
					printAsset(pair, chain);
					continue;
				}
				// ..?
			}
		}
		printFolder(rootView, []);
		//
		//trace(Ruleset.importList.length); Sys.getChar(true);
		for (imp in Ruleset.importList) {
			var name = imp.name;
			Sys.println('Importing $name...');
			switch (imp.kind) {
				case "script": {
					File.copy(imp.path, '$dir\\scripts\\$name.gml');
					addAssetNode(
						["scripts", "GMS2 compatibility"],
						new SfGmx("script", 'scripts\\$name.gml'),
						"scripts", true);
				};
				case "object": {
					File.copy(imp.path, '$dir\\objects\\$name.object.gmx');
					addAssetNode(
						["objects", "GMS2 compatibility"],
						new SfGmx("object", 'objects\\$name'),
						"objects", true);
				};
				default: Sys.println('Can\'t import ${imp.kind} yet (for $name)');
			}
		}
		//
		var defaultMacros = 0;
		for (m in VitGML.macroList) {
			if (m.config != null) continue;
			var c = macros.addTextChild("constant", m.value);
			c.set("name", m.name);
			defaultMacros++;
		}
		macros.setInt("number", defaultMacros);
		//
		Sys.println("Saving project...");
		File.saveContent(to, gmx.toGmxString());
	}
	public static function proc(from:String, to:String) {
		var pj = new VitProject(from);
		if (pj.isOK) pj.print(to);
	}
}
