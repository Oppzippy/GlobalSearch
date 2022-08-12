local luaunit = require("luaunit")

require("Tests.Internal.ShortTextQueryMatcher")
require("Tests.Internal.ShortTextSearchContext")
require("Tests.Internal.SearchProviderCollection")
require("Tests.Internal.SearchProviderRegistry")
require("Tests.Internal.Util")

os.exit(luaunit.LuaUnit.run())
