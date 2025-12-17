-- React/Next.js snippets for JavaScript/TypeScript
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- Helper: Add same snippets to multiple filetypes
local function add_to_filetypes(filetypes, snippets)
    for _, ft in ipairs(filetypes) do ls.add_snippets(ft, snippets) end
end

local react_fts = {
    "javascript", "javascriptreact", "typescript", "typescriptreact"
}

-- React Functional Component
add_to_filetypes(react_fts, {
    s({trig = "rfc", dscr = "React Functional Component"}, fmt([[
import React from 'react';

const {} = ({}) => {{
  return (
    {}
  );
}};

export default {};
]], {i(1, "ComponentName"), i(2, "props"), i(3, "<div></div>"), rep(1)}))
})

-- useState Hook
add_to_filetypes(react_fts, {
    s({trig = "useState", dscr = "useState Hook"}, fmt([[
const [{}, set{}] = useState({});
]], {
        i(1, "state"),
        f(function(args) return args[1][1]:gsub("^%l", string.upper) end, {1}),
        i(2, "initialValue")
    }))
})

-- useEffect Hook
add_to_filetypes(react_fts, {
    s({trig = "useEffect", dscr = "useEffect Hook"}, fmt([[
useEffect(() => {{
  {}

  return () => {{
    {}
  }};
}}, [{}]);
]], {i(1, "// effect"), i(2, "// cleanup"), i(3, "dependencies")}))
})

-- useContext Hook
add_to_filetypes(react_fts, {
    s({trig = "useContext", dscr = "useContext Hook"}, fmt([[
const {} = useContext({}Context);
]], {i(1, "contextValue"), i(2, "My")}))
})

-- useReducer Hook
add_to_filetypes(react_fts, {
    s({trig = "useReducer", dscr = "useReducer Hook"}, fmt([[
const [{}, dispatch] = useReducer({}Reducer, {});
]], {i(1, "state"), i(2, "my"), i(3, "initialState")}))
})

-- useCallback Hook
add_to_filetypes(react_fts, {
    s({trig = "useCallback", dscr = "useCallback Hook"}, fmt([[
const {} = useCallback(() => {{
  {}
}}, [{}]);
]], {i(1, "callback"), i(2, "// callback body"), i(3, "dependencies")}))
})

-- useMemo Hook
add_to_filetypes(react_fts, {
    s({trig = "useMemo", dscr = "useMemo Hook"}, fmt([[
const {} = useMemo(() => {{
  {}
  return {};
}}, [{}]);
]], {
        i(1, "memoized"), i(2, "// computation"), i(3, "value"),
        i(4, "dependencies")
    }))
})

-- useRef Hook
add_to_filetypes(react_fts, {
    s({trig = "useRef", dscr = "useRef Hook"}, fmt([[
const {}Ref = useRef({});
]], {i(1, "element"), i(2, "null")}))
})

-- Next.js Page
add_to_filetypes(react_fts, {
    s({trig = "nextpage", dscr = "Next.js Page"}, fmt([[
export default function {}() {{
  return (
    {}
  );
}}
]], {i(1, "PageName"), i(2, "<main></main>")}))
})

-- Next.js API Route
add_to_filetypes(react_fts, {
    s({trig = "nextapi", dscr = "Next.js API Route"}, fmt([[
export default function handler(req, res) {{
  const {{ method }} = req;

  switch (method) {{
    case 'GET':
      {}
      break;
    case 'POST':
      {}
      break;
    default:
      res.status(405).end(`Method ${{method}} Not Allowed`);
  }}
}}
]], {i(1, "// GET handler"), i(2, "// POST handler")}))
})

-- Console log
add_to_filetypes(react_fts, {
    s({trig = "log", dscr = "console.log"}, fmt([[
console.log('{}:', {});
]], {i(1, "debug"), i(2, "variable")}))
})

-- Async function
add_to_filetypes(react_fts, {
    s({trig = "afn", dscr = "Async function"}, fmt([[
const {} = async ({}) => {{
  {}
}};
]], {i(1, "functionName"), i(2, "params"), i(3, "// async logic")}))
})

-- Try-catch
add_to_filetypes(react_fts, {
    s({trig = "try", dscr = "Try-catch block"}, fmt([[
try {{
  {}
}} catch (error) {{
  console.error('{}:', error);
  {}
}}
]], {i(1, "// try block"), i(2, "Error"), i(3, "// error handling")}))
})
