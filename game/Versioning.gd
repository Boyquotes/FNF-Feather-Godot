class_name Versioning

enum VersionType {STABLE, NIGHTLY, BLEEDING}

const GAME_VERSION:String = "0.01"
const FNF_VERSION:String = "0.2.8"
const VER_TYPE:VersionType = VersionType.BLEEDING

static func grab_schema_name() -> String:
	match VER_TYPE:
		# VersionType.STABLE: return "[Stable]"
		VersionType.NIGHTLY: return "[Nightly]"
		VersionType.BLEEDING: return "[Bleeding]"
		_: return ""
