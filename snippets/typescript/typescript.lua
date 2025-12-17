-- TypeScript snippets for React/Next.js and general TypeScript
-- Organized and consistent snippet definitions
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- Helper function to add snippets to multiple filetypes
local function add_to_filetypes(filetypes, snippets)
    for _, ft in ipairs(filetypes) do ls.add_snippets(ft, snippets) end
end

-- All TypeScript snippets in one efficient call
local ts_snippets = {
    -- ============================================
    -- Type Definition Snippets
    -- ============================================

    -- TypeScript interface
    s({trig = "interface", dscr = "Interface definition"}, fmt([[
interface {} {{
    {}
}}
]], {i(1, "InterfaceName"), i(2, "property: type")})), -- TypeScript type alias
    s({trig = "type", dscr = "Type alias"}, fmt([[
type {} = {}
]], {i(1, "TypeName"), i(2, "string")})), -- TypeScript generic type
    s({trig = "generic", dscr = "Generic type"}, fmt([[
type {}<{}> = {}
]], {i(1, "TypeName"), i(2, "T"), i(3, "T[]")})), -- TypeScript enum
    s({trig = "enum", dscr = "Enum definition"}, fmt([[
enum {} {{
    {} = '{}',
}}
]], {i(1, "EnumName"), i(2, "VALUE"), i(3, "value")})),

    -- TypeScript union type
    s({trig = "union", dscr = "Union type"}, fmt([[
type {} = {} | {};
]], {i(1, "UnionType"), i(2, "string"), i(3, "number")})),

    -- TypeScript intersection type
    s({trig = "intersection", dscr = "Intersection type"}, fmt([[
type {} = {} & {};
]], {i(1, "IntersectionType"), i(2, "Type1"), i(3, "Type2")})),

    -- ============================================
    -- Function Snippets
    -- ============================================

    -- TypeScript function with types
    s({trig = "tfunc", dscr = "Typed function"}, fmt([[
function {}({}): {} {{
    {}
}}
]], {
        i(1, "functionName"), i(2, "arg: type"), i(3, "returnType"),
        i(4, "return value")
    })), -- TypeScript arrow function with types
    s({trig = "tarrow", dscr = "Typed arrow function"}, fmt([[
const {} = ({}): {} => {{
    {}
}}
]], {
        i(1, "functionName"), i(2, "arg: type"), i(3, "returnType"),
        i(4, "return value")
    })), -- TypeScript async function
    s({trig = "tasync", dscr = "Async function with Promise return"}, fmt([[
const {} = async ({}): Promise<{}> => {{
    {}
}}
]], {
        i(1, "functionName"), i(2, "arg: type"), i(3, "ReturnType"),
        i(4, "// async body")
    })), -- TypeScript generic function
    s({trig = "tgenfunc", dscr = "Generic function"}, fmt([[
function {}<{}>({}): {} {{
    {}
}}
]], {
        i(1, "functionName"), i(2, "T"), i(3, "arg: T"), i(4, "T"),
        i(5, "return arg")
    })), -- ============================================
    -- Class Snippets
    -- ============================================
    -- TypeScript class
    s({trig = "class", dscr = "Class definition"}, fmt([[
class {} {{
    {};

    constructor({}) {{
        {}
    }}

    {}({}): {} {{
        {}
    }}
}}
]], {
        i(1, "ClassName"), i(2, "private property: type"), i(3, "args"),
        i(4, "// constructor body"), i(5, "methodName"), i(6, "arg: type"),
        i(7, "returnType"), i(8, "// method body")
    })), -- TypeScript abstract class
    s({trig = "abstract", dscr = "Abstract class"}, fmt([[
abstract class {} {{
    abstract {}({}): {};

    {}({}): {} {{
        {}
    }}
}}
]], {
        i(1, "ClassName"), i(2, "methodName"), i(3, "arg: type"),
        i(4, "returnType"), i(5, "concreteMethod"), i(6, "arg: type"),
        i(7, "returnType"), i(8, "// method body")
    })), -- TypeScript interface implementation
    s({trig = "implements", dscr = "Class implementing interface"}, fmt([[
class {} implements {} {{
    {};

    constructor({}) {{
        {}
    }}

    {}({}): {} {{
        {}
    }}
}}
]], {
        i(1, "ClassName"), i(2, "InterfaceName"), i(3, "property: type"),
        i(4, "args"), i(5, "// constructor body"), i(6, "methodName"),
        i(7, "arg: type"), i(8, "returnType"), i(9, "// method body")
    })), -- ============================================
    -- Utility Type Snippets
    -- ============================================
    -- TypeScript Partial
    s({trig = "partial", dscr = "Partial<T> utility type"}, fmt([[
Partial<{}>
]], {i(1, "Type")})), -- TypeScript Readonly
    s({trig = "readonly", dscr = "Readonly<T> utility type"}, fmt([[
Readonly<{}>
]], {i(1, "Type")})), -- TypeScript Record
    s({trig = "record", dscr = "Record<K, V> utility type"}, fmt([[
Record<{}, {}>
]], {i(1, "KeyType"), i(2, "ValueType")})), -- TypeScript Pick
    s({trig = "pick", dscr = "Pick<T, K> utility type"}, fmt([[
Pick<{}, {}>
]], {i(1, "Type"), i(2, "'key1' | 'key2'")})), -- TypeScript Omit
    s({trig = "omit", dscr = "Omit<T, K> utility type"}, fmt([[
Omit<{}, {}>
]], {i(1, "Type"), i(2, "'key1' | 'key2'")})), -- TypeScript Exclude
    s({trig = "exclude", dscr = "Exclude<T, U> utility type"}, fmt([[
Exclude<{}, {}>
]], {i(1, "Type"), i(2, "ExcludedType")})), -- TypeScript Extract
    s({trig = "extract", dscr = "Extract<T, U> utility type"}, fmt([[
Extract<{}, {}>
]], {i(1, "Type"), i(2, "ExtractedType")})), -- TypeScript NonNullable
    s({trig = "nonnullable", dscr = "NonNullable<T> utility type"}, fmt([[
NonNullable<{}>
]], {i(1, "Type")})), -- TypeScript ReturnType
    s({trig = "returntype", dscr = "ReturnType<T> utility type"}, fmt([[
ReturnType<typeof {}>
]], {i(1, "functionName")})), -- TypeScript Parameters
    s({trig = "parameters", dscr = "Parameters<T> utility type"}, fmt([[
Parameters<typeof {}>
]], {i(1, "functionName")})), -- ============================================
    -- Advanced Type Snippets
    -- ============================================
    -- TypeScript type guard
    s({trig = "guard", dscr = "Type guard function"}, fmt([[
function is{}(value: {}): value is {} {{
    return {};
}}
]], {i(1, "Type"), i(2, "unknown"), rep(1), i(3, "'property' in value")})),

    -- TypeScript keyof
    s({trig = "keyof", dscr = "keyof operator"}, fmt([[
keyof {}
]], {i(1, "Type")})), -- TypeScript typeof
    s({trig = "typeof", dscr = "typeof operator"}, fmt([[
typeof {}
]], {i(1, "variable")})), -- TypeScript conditional type
    s({trig = "conditional", dscr = "Conditional type"}, fmt([[
type {}<{}> = {} extends {} ? {} : {};
]], {
        i(1, "ConditionalType"), i(2, "T"), i(3, "T"), i(4, "Condition"),
        i(5, "TrueType"), i(6, "FalseType")
    })), -- TypeScript mapped type
    s({trig = "mapped", dscr = "Mapped type"}, fmt([[
type {} = {{
    [K in keyof {}]: {};
}}
]], {i(1, "MappedType"), i(2, "OriginalType"), i(3, "NewType")})),

    -- TypeScript template literal type
    s({trig = "templateliteral", dscr = "Template literal type"}, fmt([[
type {} = `${{{}}}{}${{{}}}`;
]], {i(1, "TemplateType"), i(2, "string"), i(3, "-separator-"), i(4, "string")})),

    -- TypeScript infer keyword
    s({trig = "infer", dscr = "Infer keyword in conditional type"}, fmt([[
type {}<{}> = {} extends ({}: infer {}) => {} ? {} : never;
]], {
        i(1, "InferType"), i(2, "T"), i(3, "T"), i(4, "arg"), i(5, "P"),
        i(6, "any"), i(7, "P")
    })), -- TypeScript satisfies operator
    s({trig = "satisfies", dscr = "Satisfies operator"}, fmt([[
{} satisfies {}
]], {i(1, "value"), i(2, "Type")})), -- TypeScript as const assertion
    s({trig = "asconst", dscr = "As const assertion"}, fmt([[
{} as const
]], {i(1, "value")})), -- ============================================
    -- API and Response Type Snippets
    -- ============================================
    -- TypeScript API response type
    s({trig = "apiresponse", dscr = "API response type"}, fmt([[
interface {}Response {{
    data: {};
    message: string;
    success: boolean;
    timestamp: string;
}}
]], {i(1, "Api"), i(2, "DataType")})), -- TypeScript error type
    s({trig = "errortype", dscr = "Error type definition"}, fmt([[
interface {}Error {{
    message: string;
    code: string;
    details?: {};
}}
]], {i(1, "Api"), i(2, "any")})), -- TypeScript promise return type
    s({trig = "promise", dscr = "Promise return type"}, fmt([[
const {} = async ({}): Promise<{}> => {{
    {}
}};
]], {
        i(1, "functionName"), i(2, "arg: type"), i(3, "ReturnType"),
        i(4, "// async body")
    })), -- ============================================
    -- Module and Import Snippets
    -- ============================================
    -- TypeScript import type
    s({trig = "importtype", dscr = "Import type statement"}, fmt([[
import type {{ {} }} from '{}';
]], {i(1, "TypeName"), i(2, "./types")})), -- TypeScript export type
    s({trig = "exporttype", dscr = "Export type statement"}, fmt([[
export type {{ {} }};
]], {i(1, "TypeName")})), -- TypeScript module declaration
    s({trig = "module", dscr = "Module declaration"}, fmt([[
declare module '{}' {{
    {}
}}
]], {i(1, "module-name"), i(2, "export const value: string;")})),

    -- TypeScript namespace
    s({trig = "namespace", dscr = "Namespace declaration"}, fmt([[
namespace {} {{
    {}
}}
]], {i(1, "Namespace"), i(2, "export const value = 1;")})),

    -- ============================================
    -- Error Handling Snippets
    -- ============================================

    -- TypeScript try-catch with error typing
    s({trig = "try", dscr = "Try-catch with typed error"}, fmt([[
try {{
    {}
}} catch (error) {{
    const err = error as {};
    {}
}}
]], {i(1, "// try block"), i(2, "Error"), i(3, "// error handling")})),

    -- TypeScript custom error class
    s({trig = "errorclass", dscr = "Custom error class"}, fmt([[
class {} extends Error {{
    constructor(message: string, public code: {}) {{
        super(message);
        this.name = '{}';
    }}
}}
]], {i(1, "CustomError"), i(2, "string"), rep(1)})),

    -- ============================================
    -- Operator Snippets
    -- ============================================

    -- TypeScript optional chaining
    s({trig = "optional", dscr = "Optional chaining"}, fmt([[
{}?.{}
]], {i(1, "object"), i(2, "property")})), -- TypeScript nullish coalescing
    s({trig = "nullish", dscr = "Nullish coalescing"}, fmt([[
{} ?? {}
]], {i(1, "value"), i(2, "defaultValue")})), -- TypeScript non-null assertion
    s({trig = "nonnull", dscr = "Non-null assertion"}, fmt([[
{}!
]], {i(1, "value")})), -- ============================================
    -- Decorator Snippets
    -- ============================================
    -- TypeScript decorator
    s({trig = "decorator", dscr = "Decorator function"}, fmt([[
function {}(target: {}, propertyKey: string, descriptor: PropertyDescriptor) {{
    {}
}}
]], {i(1, "decoratorName"), i(2, "any"), i(3, "// decorator logic")})),

    -- TypeScript class decorator
    s({trig = "classdecorator", dscr = "Class decorator"}, fmt([[
function {}<T extends {{ new(...args: any[]): {{}} }}>(constructor: T) {{
    return class extends constructor {{
        {}
    }};
}}
]], {i(1, "decoratorName"), i(2, "// extended functionality")})),

    -- ============================================
    -- JSDoc Comment Snippets
    -- ============================================

    -- TypeScript comment with JSDoc
    s({trig = "jsdoc", dscr = "JSDoc comment"}, fmt([[
/**
 * {}
 * @param {{{}}} {} {}
 * @returns {{{}}} {}
 */
]], {
        i(1, "Function description"), i(2, "paramType"), i(3, "paramName"),
        i(4, "param description"), i(5, "returnType"),
        i(6, "return description")
    })), -- TypeScript TODO comment
    s({trig = "todo", dscr = "TODO comment"}, fmt([[
// TODO({}): {}
]], {i(1, "username"), i(2, "description")})), -- TypeScript FIXME comment
    s({trig = "fixme", dscr = "FIXME comment"}, fmt([[
// FIXME({}): {}
]], {i(1, "username"), i(2, "description")})), -- TypeScript NOTE comment
    s({trig = "note", dscr = "NOTE comment"}, fmt([[
// NOTE: {}
]], {i(1, "note text")})), -- ============================================
    -- Generic Utility Snippets
    -- ============================================
    -- TypeScript extends constraint
    s({trig = "extends", dscr = "Extends constraint"}, fmt([[
{} extends {} ? {} : {}
]], {i(1, "T"), i(2, "U"), i(3, "true"), i(4, "false")})),

    -- TypeScript readonly array
    s({trig = "readonlyarray", dscr = "ReadonlyArray<T>"}, fmt([[
ReadonlyArray<{}>
]], {i(1, "Type")})), -- TypeScript tuple type
    s({trig = "tuple", dscr = "Tuple type"}, fmt([[
type {} = [{}, {}];
]], {i(1, "TupleType"), i(2, "string"), i(3, "number")})),

    -- TypeScript literal type
    s({trig = "literal", dscr = "Literal type"}, fmt([[
type {} = '{}' | '{}';
]], {i(1, "LiteralType"), i(2, "value1"), i(3, "value2")})), -- Console log
    s({trig = "log", dscr = "console.log"}, fmt([[
console.log('{}:', {});
]], {i(1, "debug"), i(2, "variable")}))
}

-- All React TypeScript snippets
local react_ts_snippets = {
    -- ============================================
    -- React TypeScript Component Snippets
    -- ============================================

    -- TypeScript React component with props interface
    s({trig = "trfc", dscr = "React FC with typed props"}, fmt([[
import React from 'react';

interface {}Props {{
    {}
}}

const {}: React.FC<{}Props> = ({{ {} }}) => {{
    return (
        {}
    );
}};

export default {};
]], {
        i(1, "ComponentName"), i(2, "// props"), rep(1), rep(1), i(3, ""),
        i(4, "<div></div>"), rep(1)
    })), -- TypeScript useState with type
    s({trig = "tstate", dscr = "useState with type"}, fmt([[
const [{}, set{}] = useState<{}>({});
]], {
        i(1, "state"), f(function(args)
            local name = args[1][1]
            return name:gsub("^%l", string.upper)
        end, {1}), i(2, "type"), i(3, "initialValue")
    })), -- TypeScript useEffect with dependencies array
    s({trig = "teffect", dscr = "useEffect with cleanup"}, fmt([[
useEffect(() => {{
    {}

    return () => {{
        {}
    }};
}}, [{}]);
]], {i(1, "// effect"), i(2, "// cleanup"), i(3, "dependencies")})),

    -- TypeScript useContext with type
    s({trig = "tcontext", dscr = "useContext with type"}, fmt([[
const {} = useContext<{}>({}Context);
]], {i(1, "contextValue"), i(2, "ContextType"), i(3, "My")})),

    -- TypeScript useRef with type
    s({trig = "tref", dscr = "useRef with type"}, fmt([[
const {}Ref = useRef<{}>(null);
]], {i(1, "element"), i(2, "HTMLDivElement")})),

    -- TypeScript useReducer with types
    s({trig = "treducer", dscr = "useReducer with full types"}, fmt([[
type {}Action =
    | {{ type: '{}'; payload: {} }}
    | {{ type: '{}'; payload: {} }};

interface {}State {{
    {}
}}

const initialState: {}State = {{
    {}
}};

const reducer = (state: {}State, action: {}Action): {}State => {{
    switch (action.type) {{
        case '{}':
            return {{ ...state, {}: action.payload }};
        case '{}':
            return {{ ...state, {}: action.payload }};
        default:
            return state;
    }}
}};

const [{}, dispatch] = useReducer(reducer, initialState);
]], {
        i(1, "My"), i(2, "ACTION_1"), i(3, "PayloadType1"), i(4, "ACTION_2"),
        i(5, "PayloadType2"), rep(1), i(6, "property: type"), rep(1),
        i(7, "// initial values"), rep(1), rep(1), rep(1), rep(2),
        i(8, "property1"), rep(4), i(9, "property2"), i(10, "state")
    })), -- TypeScript useCallback with type
    s({trig = "tcallback", dscr = "useCallback with types"}, fmt([[
const {} = useCallback<({}) => {}>(() => {{
    {}
}}, [{}]);
]], {
        i(1, "callback"), i(2, "arg: type"), i(3, "returnType"),
        i(4, "// callback body"), i(5, "dependencies")
    })), -- TypeScript useMemo with type
    s({trig = "tmemo", dscr = "useMemo with type"}, fmt([[
const {} = useMemo<{}>(() => {{
    {}
    return {};
}}, [{}]);
]], {
        i(1, "memoized"), i(2, "Type"), i(3, "// computation"), i(4, "value"),
        i(5, "dependencies")
    })), -- Event handler type
    s({trig = "tevent", dscr = "Event handler type"}, fmt([[
const {} = (event: React.{}Event<HTML{}Element>) => {{
    {}
}};
]], {
        i(1, "handleEvent"), i(2, "Mouse"), i(3, "Button"),
        i(4, "// handler body")
    })), -- Props with children
    s({trig = "tprops", dscr = "Props interface with children"}, fmt([[
interface {}Props {{
    children: React.ReactNode;
    {}
}}
]], {i(1, "Component"), i(2, "// other props")}))
}

-- Apply TypeScript snippets to typescript filetype
ls.add_snippets("typescript", ts_snippets)

-- Apply React TypeScript snippets to typescriptreact filetype
add_to_filetypes({"typescript", "typescriptreact"}, react_ts_snippets)
