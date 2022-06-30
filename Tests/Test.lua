local luaunit = require("luaunit")

require("Tests.Internal.QueryMatcher")
require("Tests.Internal.SearchContext")
require("Tests.Internal.SearchProviderCollection")
require("Tests.Internal.SearchProviderRegistry")

os.exit(luaunit.LuaUnit.run())
