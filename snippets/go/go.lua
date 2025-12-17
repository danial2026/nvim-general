-- Go snippets for error handling, structs, and common patterns
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

-- All Go snippets in one efficient call
ls.add_snippets("go", {
    -- ============================================
    -- Basic Program Structure
    -- ============================================

    -- Main function
    s({ trig = "main", dscr = "Main function with package and imports" }, fmt([[
package main

import "fmt"

func main() {{
    {}
}}
]], {
        i(1, 'fmt.Println("Hello, World!")')
    })),

    -- Package with imports
    s({ trig = "package", dscr = "Package declaration with imports" }, fmt([[
package {}

import (
    {}
)
]], {
        i(1, "main"),
        i(2, '"fmt"')
    })),

    -- ============================================
    -- Function Snippets
    -- ============================================

    -- Basic function
    s({ trig = "func", dscr = "Basic function" }, fmt([[
func {}({}) {} {{
    {}
}}
]], {
        i(1, "functionName"),
        i(2, ""),
        i(3, ""),
        i(4, "// function body")
    })),

    -- Function with return value
    s({ trig = "funcr", dscr = "Function with return value" }, fmt([[
func {}({}) {} {{
    {}
}}
]], {
        i(1, "functionName"),
        i(2, ""),
        i(3, "error"),
        i(4, "return nil")
    })),

    -- Function with multiple return values
    s({ trig = "funcmr", dscr = "Function with multiple return values" }, fmt([[
func {}({}) ({}, error) {{
    {}
}}
]], {
        i(1, "functionName"),
        i(2, ""),
        i(3, "result"),
        i(4, "return nil, nil")
    })),

    -- Variadic function
    s({ trig = "funcv", dscr = "Variadic function" }, fmt([[
func {}({}...{}) {} {{
    {}
}}
]], {
        i(1, "functionName"),
        i(2, "args "),
        i(3, "interface{{}}"),
        i(4, ""),
        i(5, "// function body")
    })),

    -- Method
    s({ trig = "meth", dscr = "Method on a receiver" }, fmt([[
func ({} *{}) {}({}) {} {{
    {}
}}
]], {
        i(1, "receiver"),
        i(2, "Type"),
        i(3, "MethodName"),
        i(4, ""),
        i(5, ""),
        i(6, "// method body")
    })),

    -- ============================================
    -- Struct Snippets
    -- ============================================

    -- Struct definition
    s({ trig = "struct", dscr = "Struct definition" }, fmt([[
type {} struct {{
    {}
}}
]], {
        i(1, "StructName"),
        i(2, "Field string")
    })),

    -- Struct with JSON tags
    s({ trig = "structjson", dscr = "Struct with JSON tags" }, fmt([[
type {} struct {{
    {} {} `json:"{}"`
}}
]], {
        i(1, "StructName"),
        i(2, "Field"),
        i(3, "string"),
        i(4, "field")
    })),

    -- Struct constructor
    s({ trig = "new", dscr = "Struct constructor function" }, fmt([[
func New{}({}) *{} {{
    return &{} {{
        {}
    }}
}}
]], {
        i(1, "StructName"),
        i(2, ""),
        rep(1),
        rep(1),
        i(3, "// field initialization")
    })),

    -- ============================================
    -- Interface Snippets
    -- ============================================

    -- Interface definition
    s({ trig = "interface", dscr = "Interface definition" }, fmt([[
type {} interface {{
    {}({}) {}
}}
]], {
        i(1, "InterfaceName"),
        i(2, "MethodName"),
        i(3, ""),
        i(4, "")
    })),

    -- Empty interface
    s({ trig = "iface", dscr = "Empty interface" }, fmt([[
interface{{}}
]], {})),

    -- ============================================
    -- Error Handling Snippets
    -- ============================================

    -- Error check
    s({ trig = "iferr", dscr = "If error not nil" }, fmt([[
if err != nil {{
    {}
}}
]], {
        i(1, "return err")
    })),

    -- Error check with return
    s({ trig = "iferrr", dscr = "If error with return values" }, fmt([[
if err != nil {{
    return {}, err
}}
]], {
        i(1, "nil")
    })),

    -- Error check with log
    s({ trig = "iferrl", dscr = "If error with log.Fatal" }, fmt([[
if err != nil {{
    log.Fatal(err)
}}
]], {})),

    -- Error check with panic
    s({ trig = "iferrp", dscr = "If error with panic" }, fmt([[
if err != nil {{
    panic(err)
}}
]], {})),

    -- Custom error
    s({ trig = "errnew", dscr = "Create new error" }, fmt([[
errors.New("{}")
]], {
        i(1, "error message")
    })),

    -- Formatted error
    s({ trig = "errf", dscr = "Create formatted error" }, fmt([[
fmt.Errorf("{}: %w", {})
]], {
        i(1, "error message"),
        i(2, "err")
    })),

    -- Custom error type
    s({ trig = "errtype", dscr = "Custom error type" }, fmt([[
type {} struct {{
    {}
}}

func (e *{}) Error() string {{
    return fmt.Sprintf("{}: %v", {})
}}
]], {
        i(1, "CustomError"),
        i(2, "Msg string"),
        rep(1),
        i(3, "error message"),
        i(4, "e.Msg")
    })),

    -- ============================================
    -- Control Flow Snippets
    -- ============================================

    -- If statement
    s({ trig = "if", dscr = "If statement" }, fmt([[
if {} {{
    {}
}}
]], {
        i(1, "condition"),
        i(2, "// if body")
    })),

    -- If-else statement
    s({ trig = "ife", dscr = "If-else statement" }, fmt([[
if {} {{
    {}
}} else {{
    {}
}}
]], {
        i(1, "condition"),
        i(2, "// if body"),
        i(3, "// else body")
    })),

    -- If with short statement
    s({ trig = "ifs", dscr = "If with short statement" }, fmt([[
if {}; {} {{
    {}
}}
]], {
        i(1, "err := someFunc()"),
        i(2, "err != nil"),
        i(3, "return err")
    })),

    -- Switch statement
    s({ trig = "switch", dscr = "Switch statement" }, fmt([[
switch {} {{
case {}:
    {}
default:
    {}
}}
]], {
        i(1, "value"),
        i(2, "case1"),
        i(3, "// case body"),
        i(4, "// default body")
    })),

    -- Type switch
    s({ trig = "tswitch", dscr = "Type switch" }, fmt([[
switch {} := {}.(type) {{
case {}:
    {}
default:
    {}
}}
]], {
        i(1, "v"),
        i(2, "value"),
        i(3, "string"),
        i(4, "// case body"),
        i(5, "// default body")
    })),

    -- Select statement
    s({ trig = "select", dscr = "Select statement for channels" }, fmt([[
select {{
case {} := <-{}:
    {}
case {} <- {}:
    {}
default:
    {}
}}
]], {
        i(1, "msg"),
        i(2, "ch1"),
        i(3, "// case body"),
        i(4, "ch2"),
        i(5, "value"),
        i(6, "// case body"),
        i(7, "// default body")
    })),

    -- ============================================
    -- Loop Snippets
    -- ============================================

    -- For loop
    s({ trig = "for", dscr = "For loop" }, fmt([[
for {} {{
    {}
}}
]], {
        i(1, "condition"),
        i(2, "// loop body")
    })),

    -- For with initialization
    s({ trig = "fori", dscr = "For loop with init and condition" }, fmt([[
for {} := {}; {}; {} {{
    {}
}}
]], {
        i(1, "i"),
        i(2, "0"),
        i(3, "i < 10"),
        i(4, "i++"),
        i(5, "// loop body")
    })),

    -- For range
    s({ trig = "forr", dscr = "For range loop" }, fmt([[
for {}, {} := range {} {{
    {}
}}
]], {
        i(1, "i"),
        i(2, "v"),
        i(3, "slice"),
        i(4, "// loop body")
    })),

    -- For range with blank identifier
    s({ trig = "forr_", dscr = "For range with blank identifier" }, fmt([[
for _, {} := range {} {{
    {}
}}
]], {
        i(1, "v"),
        i(2, "slice"),
        i(3, "// loop body")
    })),

    -- Infinite loop
    s({ trig = "forinf", dscr = "Infinite for loop" }, fmt([[
for {{
    {}
}}
]], {
        i(1, "// loop body")
    })),

    -- ============================================
    -- Concurrency Snippets
    -- ============================================

    -- Goroutine
    s({ trig = "go", dscr = "Start goroutine" }, fmt([[
go func() {{
    {}
}}()
]], {
        i(1, "// goroutine body")
    })),

    -- Channel declaration
    s({ trig = "chan", dscr = "Channel declaration" }, fmt([[
{} := make(chan {})
]], {
        i(1, "ch"),
        i(2, "int")
    })),

    -- Buffered channel
    s({ trig = "chanb", dscr = "Buffered channel" }, fmt([[
{} := make(chan {}, {})
]], {
        i(1, "ch"),
        i(2, "int"),
        i(3, "10")
    })),

    -- Channel send
    s({ trig = "chsend", dscr = "Send to channel" }, fmt([[
{} <- {}
]], {
        i(1, "ch"),
        i(2, "value")
    })),

    -- Channel receive
    s({ trig = "chrecv", dscr = "Receive from channel" }, fmt([[
{} := <-{}
]], {
        i(1, "value"),
        i(2, "ch")
    })),

    -- Close channel
    s({ trig = "chclose", dscr = "Close channel" }, fmt([[
close({})
]], {
        i(1, "ch")
    })),

    -- WaitGroup
    s({ trig = "wg", dscr = "WaitGroup pattern" }, fmt([[
var wg sync.WaitGroup

wg.Add({})
go func() {{
    defer wg.Done()
    {}
}}()

wg.Wait()
]], {
        i(1, "1"),
        i(2, "// goroutine body")
    })),

    -- Mutex
    s({ trig = "mutex", dscr = "Mutex declaration" }, fmt([[
var {} sync.Mutex
]], {
        i(1, "mu")
    })),

    -- Mutex lock/unlock
    s({ trig = "lock", dscr = "Mutex lock pattern" }, fmt([[
{}.Lock()
defer {}.Unlock()

{}
]], {
        i(1, "mu"),
        rep(1),
        i(2, "// critical section")
    })),

    -- RWMutex
    s({ trig = "rwmutex", dscr = "RWMutex declaration" }, fmt([[
var {} sync.RWMutex
]], {
        i(1, "mu")
    })),

    -- Context
    s({ trig = "ctx", dscr = "Context with cancel" }, fmt([[
ctx, cancel := context.WithCancel({})
defer cancel()

{}
]], {
        i(1, "context.Background()"),
        i(2, "// use ctx")
    })),

    -- Context with timeout
    s({ trig = "ctxt", dscr = "Context with timeout" }, fmt([[
ctx, cancel := context.WithTimeout({}, {}*time.Second)
defer cancel()

{}
]], {
        i(1, "context.Background()"),
        i(2, "5"),
        i(3, "// use ctx")
    })),

    -- Context with deadline
    s({ trig = "ctxd", dscr = "Context with deadline" }, fmt([[
ctx, cancel := context.WithDeadline({}, time.Now().Add({}))
defer cancel()

{}
]], {
        i(1, "context.Background()"),
        i(2, "5*time.Second"),
        i(3, "// use ctx")
    })),

    -- ============================================
    -- Testing Snippets
    -- ============================================

    -- Test function
    s({ trig = "test", dscr = "Test function" }, fmt([[
func Test{}(t *testing.T) {{
    {}
}}
]], {
        i(1, "Function"),
        i(2, "// test body")
    })),

    -- Table-driven test
    s({ trig = "testt", dscr = "Table-driven test" }, fmt([[
func Test{}(t *testing.T) {{
    tests := []struct {{
        name string
        {}
        want {}
    }}{{
        {{
            name: "{}",
            {},
            want: {},
        }},
    }}

    for _, tt := range tests {{
        t.Run(tt.name, func(t *testing.T) {{
            got := {}
            if got != tt.want {{
                t.Errorf("{} = %v, want %v", got, tt.want)
            }}
        }})
    }}
}}
]], {
        i(1, "Function"),
        i(2, "input string"),
        i(3, "string"),
        i(4, "test case"),
        i(5, 'input: "value"'),
        i(6, '"expected"'),
        i(7, "FunctionUnderTest(tt.input)"),
        rep(1)
    })),

    -- Benchmark function
    s({ trig = "bench", dscr = "Benchmark function" }, fmt([[
func Benchmark{}(b *testing.B) {{
    for i := 0; i < b.N; i++ {{
        {}
    }}
}}
]], {
        i(1, "Function"),
        i(2, "// benchmark body")
    })),

    -- Test helper
    s({ trig = "testhelper", dscr = "Test helper function" }, fmt([[
func {}(t *testing.T) {{
    t.Helper()
    {}
}}
]], {
        i(1, "helperFunc"),
        i(2, "// helper body")
    })),

    -- ============================================
    -- HTTP Snippets
    -- ============================================

    -- HTTP handler
    s({ trig = "handler", dscr = "HTTP handler function" }, fmt([[
func {}(w http.ResponseWriter, r *http.Request) {{
    {}
}}
]], {
        i(1, "handlerName"),
        i(2, "// handler body")
    })),

    -- HTTP handler with error
    s({ trig = "handlererr", dscr = "HTTP handler with error handling" }, fmt([[
func {}(w http.ResponseWriter, r *http.Request) {{
    if r.Method != http.Method{} {{
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
    }}

    {}
}}
]], {
        i(1, "handlerName"),
        i(2, "Get"),
        i(3, "// handler body")
    })),

    -- HTTP server
    s({ trig = "httpserver", dscr = "Basic HTTP server" }, fmt([[
func main() {{
    http.HandleFunc("{}", {})

    log.Printf("Starting server on :{}")
    if err := http.ListenAndServe(":{}", nil); err != nil {{
        log.Fatal(err)
    }}
}}
]], {
        i(1, "/"),
        i(2, "handlerFunc"),
        i(3, "8080"),
        rep(3)
    })),

    -- HTTP GET request
    s({ trig = "httpget", dscr = "HTTP GET request" }, fmt([[
resp, err := http.Get("{}")
if err != nil {{
    {}
}}
defer resp.Body.Close()

{}
]], {
        i(1, "url"),
        i(2, "return err"),
        i(3, "// process response")
    })),

    -- HTTP POST request
    s({ trig = "httppost", dscr = "HTTP POST request" }, fmt([[
resp, err := http.Post("{}", "{}", {})
if err != nil {{
    {}
}}
defer resp.Body.Close()

{}
]], {
        i(1, "url"),
        i(2, "application/json"),
        i(3, "body"),
        i(4, "return err"),
        i(5, "// process response")
    })),

    -- JSON encode
    s({ trig = "jsonenc", dscr = "JSON encode" }, fmt([[
if err := json.NewEncoder(w).Encode({}); err != nil {{
    {}
}}
]], {
        i(1, "data"),
        i(2, "http.Error(w, err.Error(), http.StatusInternalServerError)")
    })),

    -- JSON decode
    s({ trig = "jsondec", dscr = "JSON decode" }, fmt([[
var {} {}
if err := json.NewDecoder(r.Body).Decode(&{}); err != nil {{
    {}
}}
]], {
        i(1, "data"),
        i(2, "DataType"),
        rep(1),
        i(3, "http.Error(w, err.Error(), http.StatusBadRequest)")
    })),

    -- ============================================
    -- File I/O Snippets
    -- ============================================

    -- Read file
    s({ trig = "readfile", dscr = "Read entire file" }, fmt([[
data, err := os.ReadFile("{}")
if err != nil {{
    {}
}}
{}
]], {
        i(1, "filename.txt"),
        i(2, "return err"),
        i(3, "// process data")
    })),

    -- Write file
    s({ trig = "writefile", dscr = "Write to file" }, fmt([[
if err := os.WriteFile("{}", {}, {}); err != nil {{
    {}
}}
]], {
        i(1, "filename.txt"),
        i(2, "data"),
        i(3, "0644"),
        i(4, "return err")
    })),

    -- Open file
    s({ trig = "openfile", dscr = "Open file for reading/writing" }, fmt([[
file, err := os.Open("{}")
if err != nil {{
    {}
}}
defer file.Close()

{}
]], {
        i(1, "filename.txt"),
        i(2, "return err"),
        i(3, "// work with file")
    })),

    -- Create file
    s({ trig = "createfile", dscr = "Create new file" }, fmt([[
file, err := os.Create("{}")
if err != nil {{
    {}
}}
defer file.Close()

{}
]], {
        i(1, "filename.txt"),
        i(2, "return err"),
        i(3, "// write to file")
    })),

    -- ============================================
    -- Defer, Panic, Recover
    -- ============================================

    -- Defer statement
    s({ trig = "defer", dscr = "Defer statement" }, fmt([[
defer {}
]], {
        i(1, "cleanup()")
    })),

    -- Defer function
    s({ trig = "deferf", dscr = "Defer anonymous function" }, fmt([[
defer func() {{
    {}
}}()
]], {
        i(1, "// cleanup code")
    })),

    -- Panic
    s({ trig = "panic", dscr = "Panic with message" }, fmt([[
panic("{}")
]], {
        i(1, "panic message")
    })),

    -- Recover
    s({ trig = "recover", dscr = "Recover from panic" }, fmt([[
defer func() {{
    if r := recover(); r != nil {{
        {}
    }}
}}()
]], {
        i(1, 'log.Printf("Recovered from panic: %v", r)')
    })),

    -- ============================================
    -- Common Patterns
    -- ============================================

    -- Type assertion
    s({ trig = "assert", dscr = "Type assertion" }, fmt([[
{}, ok := {}.({})
if !ok {{
    {}
}}
]], {
        i(1, "value"),
        i(2, "interface"),
        i(3, "Type"),
        i(4, "// handle type assertion failure")
    })),

    -- String builder
    s({ trig = "builder", dscr = "strings.Builder pattern" }, fmt([[
var builder strings.Builder
{}
result := builder.String()
]], {
        i(1, "// builder.WriteString()")
    })),

    -- Print statements
    s({ trig = "printf", dscr = "fmt.Printf" }, fmt([[
fmt.Printf("{}: %v\n", {})
]], {
        i(1, "debug"),
        i(2, "value")
    })),

    s({ trig = "println", dscr = "fmt.Println" }, fmt([[
fmt.Println({})
]], {
        i(1, "value")
    })),

    -- Log statements
    s({ trig = "logf", dscr = "log.Printf" }, fmt([[
log.Printf("{}: %v", {})
]], {
        i(1, "message"),
        i(2, "value")
    })),

    -- ============================================
    -- Slice and Map Operations
    -- ============================================

    -- Make slice
    s({ trig = "makes", dscr = "Make slice" }, fmt([[
{} := make([]{}, {}, {})
]], {
        i(1, "slice"),
        i(2, "Type"),
        i(3, "0"),
        i(4, "10")
    })),

    -- Make map
    s({ trig = "makem", dscr = "Make map" }, fmt([[
{} := make(map[{}]{})
]], {
        i(1, "myMap"),
        i(2, "string"),
        i(3, "int")
    })),

    -- Append to slice
    s({ trig = "append", dscr = "Append to slice" }, fmt([[
{} = append({}, {})
]], {
        i(1, "slice"),
        rep(1),
        i(2, "value")
    })),

    -- Range over map
    s({ trig = "rangemap", dscr = "Range over map" }, fmt([[
for {}, {} := range {} {{
    {}
}}
]], {
        i(1, "key"),
        i(2, "value"),
        i(3, "myMap"),
        i(4, "// loop body")
    })),

    -- ============================================
    -- Time Operations
    -- ============================================

    -- Time now
    s({ trig = "now", dscr = "Get current time" }, fmt([[
{} := time.Now()
]], {
        i(1, "now")
    })),

    -- Sleep
    s({ trig = "sleep", dscr = "Sleep duration" }, fmt([[
time.Sleep({} * time.{})
]], {
        i(1, "1"),
        i(2, "Second")
    })),

    -- Ticker
    s({ trig = "ticker", dscr = "Time ticker" }, fmt([[
ticker := time.NewTicker({} * time.{})
defer ticker.Stop()

for range ticker.C {{
    {}
}}
]], {
        i(1, "1"),
        i(2, "Second"),
        i(3, "// periodic action")
    })),

    -- Timer
    s({ trig = "timer", dscr = "Time timer" }, fmt([[
timer := time.NewTimer({} * time.{})
<-timer.C
{}
]], {
        i(1, "1"),
        i(2, "Second"),
        i(3, "// action after timeout")
    })),

    -- ============================================
    -- Interface Patterns
    -- ============================================

    -- Interface definition
    s({ trig = "iface", dscr = "Interface definition" }, fmt([[
type {} interface {{
    {}({}) {}
}}
]], {
        i(1, "Reader"),
        i(2, "Read"),
        i(3, "p []byte"),
        i(4, "(n int, err error)")
    })),

    -- Interface implementation check
    s({ trig = "ifacecheck", dscr = "Interface implementation check" }, fmt([[
var _ {} = (*{})({})
]], {
        i(1, "io.Reader"),
        i(2, "MyReader"),
        i(3, "nil")
    })),

    -- Type assertion
    s({ trig = "typeassert", dscr = "Type assertion with check" }, fmt([[
if {}, ok := {}.({}); ok {{
    {}
}}
]], {
        i(1, "value"),
        i(2, "interface"),
        i(3, "ConcreteType"),
        i(4, "// use value")
    })),

    -- ============================================
    -- Generics (Go 1.18+)
    -- ============================================

    -- Generic function
    s({ trig = "genfunc", dscr = "Generic function" }, fmt([[
func {}[{} {}]({} {}) {} {{
    {}
}}
]], {
        i(1, "Map"),
        i(2, "T"),
        i(3, "any"),
        i(4, "slice []T"),
        rep(2),
        i(5, "[]T"),
        i(6, "return slice")
    })),

    -- Generic type
    s({ trig = "gentype", dscr = "Generic type" }, fmt([[
type {}[{} {}] struct {{
    {} {}
}}
]], {
        i(1, "Container"),
        i(2, "T"),
        i(3, "any"),
        i(4, "Value"),
        rep(2)
    })),

    -- Constraint
    s({ trig = "constraint", dscr = "Type constraint" }, fmt([[
type {} interface {{
    {}
}}
]], {
        i(1, "Number"),
        i(2, "int | int64 | float64")
    })),

    -- ============================================
    -- Gin Web Framework
    -- ============================================

    -- Gin handler
    s({ trig = "ginhandler", dscr = "Gin handler function" }, fmt([[
func {}(c *gin.Context) {{
    {}
    c.JSON(http.StatusOK, gin.H{{
        "message": "{}",
    }})
}}
]], {
        i(1, "handlerName"),
        i(2, "// handler logic"),
        i(3, "success")
    })),

    -- Gin route group
    s({ trig = "gingroup", dscr = "Gin route group" }, fmt([[
{} := router.Group("{}")
{{
    {}.GET("{}", {})
    {}.POST("{}", {})
}}
]], {
        i(1, "api"),
        i(2, "/api/v1"),
        rep(1),
        i(3, "/users"),
        i(4, "getUsers"),
        rep(1),
        i(5, "/users"),
        i(6, "createUser")
    })),

    -- Gin middleware
    s({ trig = "ginmiddleware", dscr = "Gin middleware" }, fmt([[
func {}() gin.HandlerFunc {{
    return func(c *gin.Context) {{
        {}
        c.Next()
        {}
    }}
}}
]], {
        i(1, "AuthMiddleware"),
        i(2, "// before request"),
        i(3, "// after request")
    })),

    -- Gin bind JSON
    s({ trig = "ginbind", dscr = "Gin bind JSON" }, fmt([[
var {} {}
if err := c.ShouldBindJSON(&{}); err != nil {{
    c.JSON(http.StatusBadRequest, gin.H{{"error": err.Error()}})
    return
}}
]], {
        i(1, "req"),
        i(2, "RequestType"),
        rep(1)
    })),

    -- Gin server setup
    s({ trig = "ginserver", dscr = "Gin server setup" }, fmt([[
func main() {{
    router := gin.Default()

    {}

    if err := router.Run("{}"); err != nil {{
        log.Fatal(err)
    }}
}}
]], {
        i(1, "router.GET(\"/\", handler)"),
        i(2, ":8080")
    })),

    -- ============================================
    -- GORM Database
    -- ============================================

    -- GORM model
    s({ trig = "gormmodel", dscr = "GORM model" }, fmt([[
type {} struct {{
    gorm.Model
    {} {}
}}
]], {
        i(1, "User"),
        i(2, "Name"),
        i(3, "string")
    })),

    -- GORM create
    s({ trig = "gormcreate", dscr = "GORM create record" }, fmt([[
{} := &{}{{
    {}: {},
}}
result := db.Create({})
if result.Error != nil {{
    return result.Error
}}
]], {
        i(1, "user"),
        i(2, "User"),
        i(3, "Name"),
        i(4, "\"John\""),
        rep(1)
    })),

    -- GORM query
    s({ trig = "gormfind", dscr = "GORM find records" }, fmt([[
var {} []{}
result := db.Where("{} = ?", {}).Find(&{})
if result.Error != nil {{
    return result.Error
}}
]], {
        i(1, "users"),
        i(2, "User"),
        i(3, "name"),
        i(4, "\"John\""),
        rep(1)
    })),

    -- GORM update
    s({ trig = "gormupdate", dscr = "GORM update record" }, fmt([[
result := db.Model(&{}).Where("{} = ?", {}).Update("{}", {})
if result.Error != nil {{
    return result.Error
}}
]], {
        i(1, "User{}"),
        i(2, "id"),
        i(3, "1"),
        i(4, "name"),
        i(5, "\"Updated\"")
    })),

    -- GORM delete
    s({ trig = "gormdelete", dscr = "GORM delete record" }, fmt([[
result := db.Delete(&{}, {})
if result.Error != nil {{
    return result.Error
}}
]], {
        i(1, "User{}"),
        i(2, "1")
    })),

    -- GORM migration
    s({ trig = "gormmigrate", dscr = "GORM auto migrate" }, fmt([[
if err := db.AutoMigrate(&{}{{}}); err != nil {{
    return err
}}
]], {
        i(1, "User")
    })),

    -- ============================================
    -- Testing Patterns
    -- ============================================

    -- Table test helper
    s({ trig = "testhelper", dscr = "Test helper function" }, fmt([[
func {}(t *testing.T) {{
    t.Helper()
    {}
}}
]], {
        i(1, "helperFunc"),
        i(2, "// helper code")
    })),

    -- Mock interface
    s({ trig = "mock", dscr = "Mock interface implementation" }, fmt([[
type Mock{} struct {{
    {}Func func({}) {}
}}

func (m *Mock{}) {}({}) {} {{
    if m.{}Func != nil {{
        return m.{}Func({})
    }}
    return {}
}}
]], {
        i(1, "Reader"),
        i(2, "Read"),
        i(3, "p []byte"),
        i(4, "(n int, err error)"),
        rep(1),
        rep(2),
        rep(3),
        rep(4),
        rep(2),
        rep(2),
        i(5, "args"),
        i(6, "0, nil")
    })),

    -- Subtests
    s({ trig = "subtest", dscr = "Table-driven subtests" }, fmt([[
t.Run("{}", func(t *testing.T) {{
    {}
}})
]], {
        i(1, "test case"),
        i(2, "// test code")
    })),

    -- ============================================
    -- Error Handling Patterns
    -- ============================================

    -- Custom error
    s({ trig = "customerr", dscr = "Custom error type" }, fmt([[
type {}Error struct {{
    {}
    Err error
}}

func (e *{}Error) Error() string {{
    return fmt.Sprintf("{}: %v", {}, e.Err)
}}

func (e *{}Error) Unwrap() error {{
    return e.Err
}}
]], {
        i(1, "My"),
        i(2, "Code int"),
        rep(1),
        i(3, "error"),
        i(4, "e.Code"),
        rep(1)
    })),

    -- Error wrapping
    s({ trig = "errwrap", dscr = "Error wrapping with context" }, fmt([[
if err != nil {{
    return fmt.Errorf("{}: %w", err)
}}
]], {
        i(1, "failed to execute")
    })),

    -- Error is/as
    s({ trig = "erris", dscr = "errors.Is check" }, fmt([[
if errors.Is(err, {}) {{
    {}
}}
]], {
        i(1, "ErrNotFound"),
        i(2, "// handle specific error")
    })),

    s({ trig = "erras", dscr = "errors.As check" }, fmt([[
var {} *{}
if errors.As(err, &{}) {{
    {}
}}
]], {
        i(1, "customErr"),
        i(2, "CustomError"),
        rep(1),
        i(3, "// handle typed error")
    })),

    -- ============================================
    -- Logging Patterns
    -- ============================================

    -- Structured logging
    s({ trig = "logslog", dscr = "Structured logging with slog" }, fmt([[
slog.Info("{}", "{}", {})
]], {
        i(1, "message"),
        i(2, "key"),
        i(3, "value")
    })),

    s({ trig = "logerr", dscr = "Log error" }, fmt([[
slog.Error("{}", "error", err)
]], {
        i(1, "operation failed")
    })),

    -- ============================================
    -- Config & Environment
    -- ============================================

    -- Load env
    s({ trig = "loadenv", dscr = "Load environment variable" }, fmt([[
{} := os.Getenv("{}")
if {} == "" {{
    {} = "{}"
}}
]], {
        i(1, "port"),
        i(2, "PORT"),
        rep(1),
        rep(1),
        i(3, "8080")
    })),

    -- Config struct
    s({ trig = "config", dscr = "Configuration struct" }, fmt([[
type Config struct {{
    Port     string `env:"PORT" envDefault:"{}"`
    Database string `env:"DATABASE_URL"`
    {}
}}

func LoadConfig() (*Config, error) {{
    cfg := &Config{{}}
    if err := env.Parse(cfg); err != nil {{
        return nil, err
    }}
    return cfg, nil
}}
]], {
        i(1, "8080"),
        i(2, "// other fields")
    })),

    -- ============================================
    -- Patterns & Best Practices
    -- ============================================

    -- Options pattern
    s({ trig = "options", dscr = "Functional options pattern" }, fmt([[
type {}Option func(*{})

func With{}({} {}) {}Option {{
    return func(o *{}) {{
        o.{} = {}
    }}
}}

func New{}(opts ...{}Option) *{} {{
    {} := &{}{{
        {}: {},
    }}
    for _, opt := range opts {{
        opt({})
    }}
    return {}
}}
]], {
        i(1, "Server"),
        rep(1),
        i(2, "Port"),
        i(3, "port"),
        i(4, "string"),
        rep(1),
        rep(1),
        rep(2),
        rep(3),
        rep(1),
        rep(1),
        rep(1),
        i(5, "s"),
        rep(1),
        rep(2),
        i(6, "\"8080\""),
        rep(5),
        rep(5)
    })),

    -- Builder pattern
    s({ trig = "builder", dscr = "Builder pattern" }, fmt([[
type {}Builder struct {{
    {} *{}
}}

func New{}Builder() *{}Builder {{
    return &{}Builder{{
        {}: &{}{{
            {}: {},
        }},
    }}
}}

func (b *{}Builder) {}({} {}) *{}Builder {{
    b.{}.{} = {}
    return b
}}

func (b *{}Builder) Build() *{} {{
    return b.{}
}}
]], {
        i(1, "User"),
        i(2, "user"),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(2),
        rep(1),
        i(3, "Name"),
        i(4, "\"\""),
        rep(1),
        i(5, "WithName"),
        i(6, "name"),
        i(7, "string"),
        rep(1),
        rep(2),
        rep(3),
        rep(6),
        rep(1),
        rep(1),
        rep(2)
    })),

    -- Worker pool
    s({ trig = "workerpool", dscr = "Worker pool pattern" }, fmt([[
func {}(jobs <-chan {}, results chan<- {}, wg *sync.WaitGroup) {{
    defer wg.Done()
    for job := range jobs {{
        result := {}
        results <- result
    }}
}}

func main() {{
    numWorkers := {}
    jobs := make(chan {}, {})
    results := make(chan {}, {})

    var wg sync.WaitGroup
    for i := 0; i < numWorkers; i++ {{
        wg.Add(1)
        go {}(jobs, results, &wg)
    }}

    go func() {{
        wg.Wait()
        close(results)
    }}()

    // Send jobs
    for _, job := range {} {{
        jobs <- job
    }}
    close(jobs)

    // Collect results
    for result := range results {{
        {}
    }}
}}
]], {
        i(1, "worker"),
        i(2, "Job"),
        i(3, "Result"),
        i(4, "processJob(job)"),
        i(5, "4"),
        rep(2),
        i(6, "100"),
        rep(3),
        rep(6),
        rep(1),
        i(7, "jobsList"),
        i(8, "fmt.Println(result)")
    })),
})
