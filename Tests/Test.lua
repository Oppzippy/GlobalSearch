local luaunit = require("luaunit")

require("Tests.Internal.QueryMatcher")
require("Tests.Internal.SearchContext")
require("Tests.Internal.SearchProviderCollection")
require("Tests.Internal.SearchProviderRegistry")
require("Tests.Internal.Util")

os.exit(luaunit.LuaUnit.run())
