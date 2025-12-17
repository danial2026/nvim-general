-- Dart/Flutter snippets - Clean and efficient
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- All Dart/Flutter snippets in one efficient call
ls.add_snippets("dart", {
    -- Stateless Widget
    s({ trig = "stless", dscr = "Stateless Widget" }, fmt([[
import 'package:flutter/material.dart';

class {} extends StatelessWidget {{
  const {}({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return {};
  }}
}}
]], { i(1, "MyWidget"), rep(1), i(2, "Container()") })),

    -- Stateful Widget
    s({ trig = "stful", dscr = "Stateful Widget" }, fmt([[
import 'package:flutter/material.dart';

class {} extends StatefulWidget {{
  const {}({{super.key}});

  @override
  State<{}> createState() => _{}State();
}}

class _{}State extends State<{}> {{
  @override
  Widget build(BuildContext context) {{
    return {};
  }}
}}
]], {
        i(1, "MyWidget"), rep(1), rep(1),
        f(function(args) return "_" .. args[1][1] .. "State" end, { 1 }),
        f(function(args) return "_" .. args[1][1] .. "State" end, { 1 }),
        rep(1), i(2, "Container()")
    })),

    -- Stateful Widget with controller
    s({ trig = "stfulc", dscr = "Stateful Widget with controller" }, fmt([[
import 'package:flutter/material.dart';

class {} extends StatefulWidget {{
  const {}({{super.key}});

  @override
  State<{}> createState() => _{}State();
}}

class _{}State extends State<{}> {{
  final {}Controller = {};

  @override
  void dispose() {{
    {}Controller.dispose();
    super.dispose();
  }}

  @override
  Widget build(BuildContext context) {{
    return {};
  }}
}}
]], { i(1, "MyWidget"), rep(1), rep(1),
        f(function(args) return "_" .. args[1][1] .. "State" end, { 1 }),
        f(function(args) return "_" .. args[1][1] .. "State" end, { 1 }),
        rep(1), i(2, "text"), i(3, "TextEditingController()"),
        rep(2), i(4, "Container()") })),

    -- Scaffold
    s({ trig = "scaffold", dscr = "Scaffold" }, fmt([[
Scaffold(
  appBar: AppBar(
    title: Text('{}'),
  ),
  body: {},
)
]], { i(1, "Title"), i(2, "Container()") })),

    -- Container
    s({ trig = "container", dscr = "Container" }, fmt([[
Container(
  {}
)
]], { i(1, "child: Text('Container')") })),

    -- Center
    s({ trig = "center", dscr = "Center" }, fmt([[
Center(
  child: {},
)
]], { i(1, "Text('Center')") })),

    -- Column
    s({ trig = "column", dscr = "Column" }, fmt([[
Column(
  children: [
    {},
  ],
)
]], { i(1, "Text('Item')") })),

    -- Row
    s({ trig = "row", dscr = "Row" }, fmt([[
Row(
  children: [
    {},
  ],
)
]], { i(1, "Text('Item')") })),

    -- Stack
    s({ trig = "stack", dscr = "Stack" }, fmt([[
Stack(
  children: [
    {},
  ],
)
]], { i(1, "Container()") })),

    -- ListView
    s({ trig = "listview", dscr = "ListView" }, fmt([[
ListView(
  children: [
    {},
  ],
)
]], { i(1, "ListTile(title: Text('Item'))") })),

    -- ListView.builder
    s({ trig = "listviewbuilder", dscr = "ListView.builder" }, fmt([[
ListView.builder(
  itemCount: {},
  itemBuilder: (context, index) {{
    return {};
  }},
)
]], { i(1, "10"), i(2, "ListTile(title: Text('Item $index'))") })),

    -- GridView
    s({ trig = "gridview", dscr = "GridView" }, fmt([[
GridView.count(
  crossAxisCount: {},
  children: [
    {},
  ],
)
]], { i(1, "2"), i(2, "Container()") })),

    -- Padding
    s({ trig = "padding", dscr = "Padding" }, fmt([[
Padding(
  padding: const EdgeInsets.all({}),
  child: {},
)
]], { i(1, "8.0"), i(2, "Text('Padded')") })),

    -- Text
    s({ trig = "text", dscr = "Text" }, fmt([[
Text(
  '{}',
  style: TextStyle({}),
)
]], { i(1, "Text"), i(2, "fontSize: 16") })),

    -- TextField
    s({ trig = "textfield", dscr = "TextField" }, fmt([[
TextField(
  controller: {},
  decoration: InputDecoration(
    labelText: '{}',
  ),
)
]], { i(1, "controller"), i(2, "Label") })),

    -- ElevatedButton
    s({ trig = "elevatedbutton", dscr = "ElevatedButton" }, fmt([[
ElevatedButton(
  onPressed: () {{
    {}
  }},
  child: Text('{}'),
)
]], { i(1, "// Action"), i(2, "Button") })),

    -- IconButton
    s({ trig = "iconbutton", dscr = "IconButton" }, fmt([[
IconButton(
  icon: Icon(Icons.{}),
  onPressed: () {{
    {}
  }},
)
]], { i(1, "add"), i(2, "// Action") })),

    -- FloatingActionButton
    s({ trig = "fab", dscr = "FloatingActionButton" }, fmt([[
FloatingActionButton(
  onPressed: () {{
    {}
  }},
  child: Icon(Icons.{}),
)
]], { i(1, "// Action"), i(2, "add") })),

    -- AppBar
    s({ trig = "appbar", dscr = "AppBar" }, fmt([[
AppBar(
  title: Text('{}'),
  actions: [
    {},
  ],
)
]], { i(1, "Title"), i(2, "IconButton(icon: Icon(Icons.search), onPressed: () {})") })),

    -- Card
    s({ trig = "card", dscr = "Card" }, fmt([[
Card(
  child: {},
)
]], { i(1, "ListTile(title: Text('Card'))") })),

    -- ListTile
    s({ trig = "listtile", dscr = "ListTile" }, fmt([[
ListTile(
  title: Text('{}'),
  subtitle: Text('{}'),
  leading: Icon(Icons.{}),
)
]], { i(1, "Title"), i(2, "Subtitle"), i(3, "star") })),

    -- Image.asset
    s({ trig = "imageasset", dscr = "Image.asset" }, fmt([[
Image.asset('{}')
]], { i(1, "assets/image.png") })),

    -- Image.network
    s({ trig = "imagenetwork", dscr = "Image.network" }, fmt([[
Image.network('{}')
]], { i(1, "https://example.com/image.png") })),

    -- SizedBox
    s({ trig = "sizedbox", dscr = "SizedBox" }, fmt([[
SizedBox(
  width: {},
  height: {},
  child: {},
)
]], { i(1, "100"), i(2, "100"), i(3, "Container()") })),

    -- Expanded
    s({ trig = "expanded", dscr = "Expanded" }, fmt([[
Expanded(
  child: {},
)
]], { i(1, "Container()") })),

    -- Flexible
    s({ trig = "flexible", dscr = "Flexible" }, fmt([[
Flexible(
  child: {},
)
]], { i(1, "Container()") })),

    -- Align
    s({ trig = "align", dscr = "Align" }, fmt([[
Align(
  alignment: Alignment.{},
  child: {},
)
]], { i(1, "center"), i(2, "Text('Aligned')") })),

    -- Positioned
    s({ trig = "positioned", dscr = "Positioned" }, fmt([[
Positioned(
  top: {},
  left: {},
  child: {},
)
]], { i(1, "10"), i(2, "10"), i(3, "Container()") })),

    -- AnimatedContainer
    s({ trig = "animatedcontainer", dscr = "AnimatedContainer" }, fmt([[
AnimatedContainer(
  duration: Duration(milliseconds: {}),
  {}
)
]], { i(1, "300"), i(2, "width: 100, height: 100") })),

    -- FutureBuilder
    s({ trig = "futurebuilder", dscr = "FutureBuilder" }, fmt([[
FutureBuilder<{}>(
  future: {},
  builder: (context, snapshot) {{
    if (snapshot.connectionState == ConnectionState.waiting) {{
      return CircularProgressIndicator();
    }}
    if (snapshot.hasError) {{
      return Text('Error: ${{snapshot.error}}');
    }}
    return {};
  }},
)
]], { i(1, "String"), i(2, "fetchData()"), i(3, "Text('Data: ${snapshot.data}')") })),

    -- StreamBuilder
    s({ trig = "streambuilder", dscr = "StreamBuilder" }, fmt([[
StreamBuilder<{}>(
  stream: {},
  builder: (context, snapshot) {{
    if (snapshot.hasError) {{
      return Text('Error: ${{snapshot.error}}');
    }}
    if (!snapshot.hasData) {{
      return CircularProgressIndicator();
    }}
    return {};
  }},
)
]], { i(1, "String"), i(2, "stream"), i(3, "Text('Data: ${snapshot.data}')") })),

    -- GestureDetector
    s({ trig = "gesturedetector", dscr = "GestureDetector" }, fmt([[
GestureDetector(
  onTap: () {{
    {}
  }},
  child: {},
)
]], { i(1, "// Action"), i(2, "Container()") })),

    -- InkWell
    s({ trig = "inkwell", dscr = "InkWell" }, fmt([[
InkWell(
  onTap: () {{
    {}
  }},
  child: {},
)
]], { i(1, "// Action"), i(2, "Container()") })),

    -- showDialog
    s({ trig = "showdialog", dscr = "showDialog" }, fmt([[
showDialog(
  context: context,
  builder: (context) {{
    return AlertDialog(
      title: Text('{}'),
      content: Text('{}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    );
  }},
);
]], { i(1, "Title"), i(2, "Content") })),

    -- showModalBottomSheet
    s({ trig = "showbottomsheet", dscr = "showModalBottomSheet" }, fmt([[
showModalBottomSheet(
  context: context,
  builder: (context) {{
    return Container(
      padding: EdgeInsets.all(16),
      child: {},
    );
  }},
);
]], { i(1, "Text('Bottom Sheet')") })),

    -- Navigator.push
    s({ trig = "navpush", dscr = "Navigator.push" }, fmt([[
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => {}()),
);
]], { i(1, "NextPage") })),

    -- Navigator.pop
    s({ trig = "navpop", dscr = "Navigator.pop" }, fmt([[
Navigator.pop(context);
]], {})),

    -- setState
    s({ trig = "setstate", dscr = "setState" }, fmt([[
setState(() {{
  {}
}});
]], { i(1, "// Update state") })),

    -- initState
    s({ trig = "initstate", dscr = "initState" }, fmt([[
@override
void initState() {{
  super.initState();
  {}
}}
]], { i(1, "// Initialize") })),

    -- dispose
    s({ trig = "dispose", dscr = "dispose" }, fmt([[
@override
void dispose() {{
  {}
  super.dispose();
}}
]], { i(1, "// Cleanup") })),

    -- build method
    s({ trig = "build", dscr = "build method" }, fmt([[
@override
Widget build(BuildContext context) {{
  return {};
}}
]], { i(1, "Container()") })),

    -- MediaQuery
    s({ trig = "mediaquery", dscr = "MediaQuery" }, fmt([[
MediaQuery.of(context).size.{}
]], { i(1, "width") })),

    -- Theme.of
    s({ trig = "theme", dscr = "Theme.of" }, fmt([[
Theme.of(context).{}
]], { i(1, "primaryColor") })),

    -- Material
    s({ trig = "material", dscr = "Material" }, fmt([[
Material(
  child: {},
)
]], { i(1, "Container()") })),

    -- SafeArea
    s({ trig = "safearea", dscr = "SafeArea" }, fmt([[
SafeArea(
  child: {},
)
]], { i(1, "Container()") })),

    -- SingleChildScrollView
    s({ trig = "singlechildscrollview", dscr = "SingleChildScrollView" }, fmt([[
SingleChildScrollView(
  child: {},
)
]], { i(1, "Column()") })),

    -- Form
    s({ trig = "form", dscr = "Form" }, fmt([[
Form(
  key: {},
  child: Column(
    children: [
      {},
    ],
  ),
)
]], { i(1, "_formKey"), i(2, "TextFormField()") })),

    -- TextFormField
    s({ trig = "textformfield", dscr = "TextFormField" }, fmt([[
TextFormField(
  decoration: InputDecoration(labelText: '{}'),
  validator: (value) {{
    if (value == null || value.isEmpty) {{
      return '{}';
    }}
    return null;
  }},
)
]], { i(1, "Label"), i(2, "Please enter some text") })),

    -- SnackBar
    s({ trig = "snackbar", dscr = "SnackBar" }, fmt([[
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('{}')),
);
]], { i(1, "Message") })),

    -- CircularProgressIndicator
    s({ trig = "progress", dscr = "CircularProgressIndicator" }, fmt([[
CircularProgressIndicator()
]], {})),

    -- LinearProgressIndicator
    s({ trig = "linearprogress", dscr = "LinearProgressIndicator" }, fmt([[
LinearProgressIndicator()
]], {})),

    -- Divider
    s({ trig = "divider", dscr = "Divider" }, fmt([[
Divider()
]], {})),

    -- Spacer
    s({ trig = "spacer", dscr = "Spacer" }, fmt([[
Spacer()
]], {})),

    -- TabBar
    s({ trig = "tabbar", dscr = "TabBar" }, fmt([[
TabBar(
  tabs: [
    Tab(text: '{}'),
    {},
  ],
)
]], { i(1, "Tab 1"), i(2, "Tab(text: 'Tab 2')") })),

    -- TabBarView
    s({ trig = "tabbarview", dscr = "TabBarView" }, fmt([[
TabBarView(
  children: [
    {},
  ],
)
]], { i(1, "Center(child: Text('Tab 1'))") })),

    -- Drawer
    s({ trig = "drawer", dscr = "Drawer" }, fmt([[
Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        child: Text('{}'),
      ),
      {},
    ],
  ),
)
]], { i(1, "Header"), i(2, "ListTile(title: Text('Item'))") })),

    -- BottomNavigationBar
    s({ trig = "bottomnavbar", dscr = "BottomNavigationBar" }, fmt([[
BottomNavigationBar(
  currentIndex: {},
  onTap: (index) {{
    {}
  }},
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    {},
  ],
)
]], { i(1, "0"), i(2, "// Handle tap"), i(3, "BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')") })),

    -- Hero
    s({ trig = "hero", dscr = "Hero" }, fmt([[
Hero(
  tag: '{}',
  child: {},
)
]], { i(1, "hero-tag"), i(2, "Image.network('url')") })),

    -- Opacity
    s({ trig = "opacity", dscr = "Opacity" }, fmt([[
Opacity(
  opacity: {},
  child: {},
)
]], { i(1, "0.5"), i(2, "Container()") })),

    -- Transform.rotate
    s({ trig = "rotate", dscr = "Transform.rotate" }, fmt([[
Transform.rotate(
  angle: {},
  child: {},
)
]], { i(1, "0.5"), i(2, "Container()") })),

    -- Transform.scale
    s({ trig = "scale", dscr = "Transform.scale" }, fmt([[
Transform.scale(
  scale: {},
  child: {},
)
]], { i(1, "1.5"), i(2, "Container()") })),

    -- ClipRRect
    s({ trig = "cliprrect", dscr = "ClipRRect" }, fmt([[
ClipRRect(
  borderRadius: BorderRadius.circular({}),
  child: {},
)
]], { i(1, "8.0"), i(2, "Image.network('url')") })),

    -- Wrap
    s({ trig = "wrap", dscr = "Wrap" }, fmt([[
Wrap(
  spacing: {},
  children: [
    {},
  ],
)
]], { i(1, "8.0"), i(2, "Chip(label: Text('Item'))") })),

    -- Chip
    s({ trig = "chip", dscr = "Chip" }, fmt([[
Chip(
  label: Text('{}'),
)
]], { i(1, "Chip") })),

    -- ChoiceChip
    s({ trig = "choicechip", dscr = "ChoiceChip" }, fmt([[
ChoiceChip(
  label: Text('{}'),
  selected: {},
  onSelected: (selected) {{
    {}
  }},
)
]], { i(1, "Choice"), i(2, "false"), i(3, "// Handle selection") })),

    -- Switch
    s({ trig = "switch", dscr = "Switch" }, fmt([[
Switch(
  value: {},
  onChanged: (value) {{
    {}
  }},
)
]], { i(1, "false"), i(2, "// Handle change") })),

    -- Checkbox
    s({ trig = "checkbox", dscr = "Checkbox" }, fmt([[
Checkbox(
  value: {},
  onChanged: (value) {{
    {}
  }},
)
]], { i(1, "false"), i(2, "// Handle change") })),

    -- Radio
    s({ trig = "radio", dscr = "Radio" }, fmt([[
Radio(
  value: {},
  groupValue: {},
  onChanged: (value) {{
    {}
  }},
)
]], { i(1, "1"), i(2, "selectedValue"), i(3, "// Handle change") })),

    -- Slider
    s({ trig = "slider", dscr = "Slider" }, fmt([[
Slider(
  value: {},
  min: {},
  max: {},
  onChanged: (value) {{
    {}
  }},
)
]], { i(1, "0.5"), i(2, "0.0"), i(3, "1.0"), i(4, "// Handle change") })),

    -- DropdownButton
    s({ trig = "dropdown", dscr = "DropdownButton" }, fmt([[
DropdownButton<{}>(
  value: {},
  items: [
    {},
  ],
  onChanged: (value) {{
    {}
  }},
)
]],
        { i(1, "String"), i(2, "selectedValue"), i(3, "DropdownMenuItem(value: 'Item', child: Text('Item'))"), i(4,
            "// Handle change") })),

    -- PopupMenuButton
    s({ trig = "popupmenu", dscr = "PopupMenuButton" }, fmt([[
PopupMenuButton(
  onSelected: (value) {{
    {}
  }},
  itemBuilder: (context) => [
    PopupMenuItem(value: '1', child: Text('{}')),
    {},
  ],
)
]], { i(1, "// Handle selection"), i(2, "Item 1"), i(3, "PopupMenuItem(value: '2', child: Text('Item 2'))") })),

    -- RefreshIndicator
    s({ trig = "refresh", dscr = "RefreshIndicator" }, fmt([[
RefreshIndicator(
  onRefresh: () async {{
    {}
  }},
  child: {},
)
]], { i(1, "// Refresh logic"), i(2, "ListView()") })),

    -- PageView
    s({ trig = "pageview", dscr = "PageView" }, fmt([[
PageView(
  children: [
    {},
  ],
)
]], { i(1, "Container()") })),

    -- PageView.builder
    s({ trig = "pageviewbuilder", dscr = "PageView.builder" }, fmt([[
PageView.builder(
  itemCount: {},
  itemBuilder: (context, index) {{
    return {};
  }},
)
]], { i(1, "3"), i(2, "Container(child: Center(child: Text('Page $index')))") })),

    -- CustomScrollView
    s({ trig = "customscrollview", dscr = "CustomScrollView" }, fmt([[
CustomScrollView(
  slivers: [
    {},
  ],
)
]], { i(1, "SliverAppBar()") })),

    -- SliverAppBar
    s({ trig = "sliverappbar", dscr = "SliverAppBar" }, fmt([[
SliverAppBar(
  title: Text('{}'),
  floating: {},
  expandedHeight: {},
)
]], { i(1, "Title"), i(2, "true"), i(3, "200.0") })),

    -- SliverList
    s({ trig = "sliverlist", dscr = "SliverList" }, fmt([[
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {{
      return {};
    }},
    childCount: {},
  ),
)
]], { i(1, "ListTile(title: Text('Item $index'))"), i(2, "10") })),

    -- SliverGrid
    s({ trig = "slivergrid", dscr = "SliverGrid" }, fmt([[
SliverGrid(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: {},
  ),
  delegate: SliverChildBuilderDelegate(
    (context, index) {{
      return {};
    }},
    childCount: {},
  ),
)
]], { i(1, "2"), i(2, "Container()"), i(3, "10") })),

    -- AnimatedOpacity
    s({ trig = "animatedopacity", dscr = "AnimatedOpacity" }, fmt([[
AnimatedOpacity(
  opacity: {},
  duration: Duration(milliseconds: {}),
  child: {},
)
]], { i(1, "1.0"), i(2, "300"), i(3, "Container()") })),

    -- AnimatedCrossFade
    s({ trig = "animatedcrossfade", dscr = "AnimatedCrossFade" }, fmt([[
AnimatedCrossFade(
  firstChild: {},
  secondChild: {},
  crossFadeState: {},
  duration: Duration(milliseconds: {}),
)
]], { i(1, "Container()"), i(2, "Text('Second')"), i(3, "CrossFadeState.showFirst"), i(4, "300") })),

    -- TweenAnimationBuilder
    s({ trig = "tweenanimation", dscr = "TweenAnimationBuilder" }, fmt([[
TweenAnimationBuilder(
  tween: Tween<double>(begin: {}, end: {}),
  duration: Duration(milliseconds: {}),
  builder: (context, value, child) {{
    return {};
  }},
)
]], { i(1, "0"), i(2, "1"), i(3, "300"), i(4, "Opacity(opacity: value, child: Container())") })),

    -- LayoutBuilder
    s({ trig = "layoutbuilder", dscr = "LayoutBuilder" }, fmt([[
LayoutBuilder(
  builder: (context, constraints) {{
    return {};
  }},
)
]], { i(1, "Container(width: constraints.maxWidth)") })),

    -- Builder
    s({ trig = "builder", dscr = "Builder" }, fmt([[
Builder(
  builder: (context) {{
    return {};
  }},
)
]], { i(1, "Container()") })),

    -- ValueListenableBuilder
    s({ trig = "valuelistenablebuilder", dscr = "ValueListenableBuilder" }, fmt([[
ValueListenableBuilder(
  valueListenable: {},
  builder: (context, value, child) {{
    return {};
  }},
)
]], { i(1, "notifier"), i(2, "Text('Value: $value')") })),

    -- ============================================
    -- Riverpod Snippets
    -- ============================================

    -- Provider
    s({ trig = "provider", dscr = "Riverpod Provider" }, fmt([[
final {}Provider = Provider<{}>((ref) {{
  return {};
}});
]], { i(1, "myData"), i(2, "String"), i(3, "'Hello'") })),

    -- StateProvider
    s({ trig = "stateprovider", dscr = "Riverpod StateProvider" }, fmt([[
final {}Provider = StateProvider<{}>((ref) => {});
]], { i(1, "counter"), i(2, "int"), i(3, "0") })),

    -- StateNotifierProvider
    s({ trig = "statenotifierprovider", dscr = "Riverpod StateNotifierProvider" }, fmt([[
final {}Provider = StateNotifierProvider<{}, {}>((ref) {{
  return {}();
}});
]], { i(1, "counter"), i(2, "CounterNotifier"), i(3, "int"), rep(2) })),

    -- FutureProvider
    s({ trig = "futureprovider", dscr = "Riverpod FutureProvider" }, fmt([[
final {}Provider = FutureProvider<{}>((ref) async {{
  {}
  return {};
}});
]], { i(1, "data"), i(2, "String"), i(3, "// Fetch data"), i(4, "'result'") })),

    -- StreamProvider
    s({ trig = "streamprovider", dscr = "Riverpod StreamProvider" }, fmt([[
final {}Provider = StreamProvider<{}>((ref) {{
  return {};
}});
]], { i(1, "data"), i(2, "int"), i(3, "Stream.periodic(Duration(seconds: 1), (i) => i)") })),

    -- ConsumerWidget
    s({ trig = "consumerwidget", dscr = "Riverpod ConsumerWidget" }, fmt([[
class {} extends ConsumerWidget {{
  const {}({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final {} = ref.watch({}Provider);
    return {};
  }}
}}
]], { i(1, "MyWidget"), rep(1), i(2, "data"), i(3, "myData"), i(4, "Text('$data')") })),

    -- ConsumerStatefulWidget
    s({ trig = "consumerstatefulwidget", dscr = "Riverpod ConsumerStatefulWidget" }, fmt([[
class {} extends ConsumerStatefulWidget {{
  const {}({{super.key}});

  @override
  ConsumerState<{}> createState() => _{}State();
}}

class _{}State extends ConsumerState<{}> {{
  @override
  Widget build(BuildContext context) {{
    final {} = ref.watch({}Provider);
    return {};
  }}
}}
]], { i(1, "MyWidget"), rep(1), rep(1), rep(1), rep(1), rep(1), i(2, "data"), i(3, "myData"), i(4, "Text('$data')") })),

    -- StateNotifier
    s({ trig = "statenotifier", dscr = "Riverpod StateNotifier" }, fmt([[
class {} extends StateNotifier<{}> {{
  {}() : super({});

  void {}({}) {{
    state = {};
  }}
}}
]], { i(1, "CounterNotifier"), i(2, "int"), rep(1), i(3, "0"), i(4, "increment"), i(5, ""), i(6, "state + 1") })),

    -- ============================================
    -- Freezed Snippets
    -- ============================================

    -- Freezed class
    s({ trig = "freezed", dscr = "Freezed data class" }, fmt([[
import 'package:freezed_annotation/freezed_annotation.dart';

part '{}.freezed.dart';
part '{}.g.dart';

@freezed
class {} with _${} {{
  const factory {}.{}({{
    required {} {},
  }}) = _{};

  factory {}.fromJson(Map<String, dynamic> json) => _${}FromJson(json);
}}
]],
        { i(1, "model"), rep(1), i(2, "User"), rep(2), rep(2), i(3, "initial"), i(4, "String"), i(5, "name"), rep(2), rep(2),
            rep(2) })),

    -- Freezed union
    s({ trig = "freezedunion", dscr = "Freezed union/sealed class" }, fmt([[
import 'package:freezed_annotation/freezed_annotation.dart';

part '{}.freezed.dart';

@freezed
class {} with _${} {{
  const factory {}.{}({{required {} {}}}) = _{};
  const factory {}.{}({{required {} {}}}) = _{};
}}
]],
        { i(1, "result"), i(2, "Result"), rep(2), rep(2), i(3, "success"), i(4, "String"), i(5, "data"), i(6, "Success"),
            rep(2), i(7, "error"), i(8, "String"), i(9, "message"), i(10, "Error") })),

    -- ============================================
    -- Go Router Snippets
    -- ============================================

    -- GoRouter setup
    s({ trig = "gorouter", dscr = "GoRouter configuration" }, fmt([[
final _router = GoRouter(
  initialLocation: '{}',
  routes: [
    GoRoute(
      path: '{}',
      builder: (context, state) => const {}(),
    ),
    {},
  ],
);
]], { i(1, "/"), i(2, "/"), i(3, "HomeScreen"), i(4, "// More routes") })),

    -- GoRoute
    s({ trig = "goroute", dscr = "GoRoute definition" }, fmt([[
GoRoute(
  path: '{}',
  name: '{}',
  builder: (context, state) => const {}(),
),
]], { i(1, "/screen"), i(2, "screen"), i(3, "MyScreen") })),

    -- ============================================
    -- Async Patterns
    -- ============================================

    -- Async function
    s({ trig = "asyncfunc", dscr = "Async function" }, fmt([[
Future<{}> {}({}) async {{
  {}
  return {};
}}
]], { i(1, "void"), i(2, "fetchData"), i(3, ""), i(4, "// Async work"), i(5, "") })),

    -- Try-catch async
    s({ trig = "trycatchasync", dscr = "Try-catch async pattern" }, fmt([[
try {{
  final {} = await {};
  {}
}} catch (e) {{
  print('Error: $e');
  {}
}}
]], { i(1, "result"), i(2, "fetchData()"), i(3, "// Success"), i(4, "// Error handling") })),

    -- Stream builder
    s({ trig = "streambuilder", dscr = "StreamBuilder" }, fmt([[
StreamBuilder<{}>(
  stream: {},
  builder: (context, snapshot) {{
    if (snapshot.hasError) {{
      return Text('Error: ${{snapshot.error}}');
    }}

    if (!snapshot.hasData) {{
      return CircularProgressIndicator();
    }}

    final {} = snapshot.data!;
    return {};
  }},
)
]], { i(1, "int"), i(2, "myStream"), i(3, "data"), i(4, "Text('$data')") })),

    -- ============================================
    -- Common Patterns
    -- ============================================

    -- Singleton
    s({ trig = "singleton", dscr = "Singleton pattern" }, fmt([[
class {} {{
  {}.internal();
  static final {} _instance = {}._internal();
  factory {}() => _instance;

  {}
}}
]], { i(1, "MyService"), rep(1), rep(1), rep(1), rep(1), i(2, "// Service methods") })),

    -- Extension
    s({ trig = "extension", dscr = "Extension method" }, fmt([[
extension {} on {} {{
  {} {}({}) {{
    {}
  }}
}}
]],
        { i(1, "StringExtension"), i(2, "String"), i(3, "String"), i(4, "capitalize"), i(5, ""), i(6,
            "return isEmpty ? this : this[0].toUpperCase() + substring(1);") })),

    -- Mixin
    s({ trig = "mixin", dscr = "Mixin definition" }, fmt([[
mixin {} {{
  {} {}({}) {{
    {}
  }}
}}
]], { i(1, "MyMixin"), i(2, "void"), i(3, "myMethod"), i(4, ""), i(5, "// Implementation") })),

    -- Abstract class
    s({ trig = "abstract", dscr = "Abstract class" }, fmt([[
abstract class {} {{
  {} {}({});

  {} {}({}) {{
    {}
  }}
}}
]],
        { i(1, "Shape"), i(2, "double"), i(3, "area"), i(4, ""), i(5, "void"), i(6, "describe"), i(7, ""), i(8,
            "print('Area: $area');") })),

    -- Enum
    s({ trig = "enum", dscr = "Enum definition" }, fmt([[
enum {} {{
  {},
  {};

  const {}();
}}
]], { i(1, "Status"), i(2, "active"), i(3, "inactive"), rep(1) })),

    -- ============================================
    -- Testing Snippets
    -- ============================================

    -- Test group
    s({ trig = "testgroup", dscr = "Test group" }, fmt([[
group('{}', () {{
  {}
}});
]], { i(1, "GroupName"), i(2, "test('test name', () {});") })),

    -- Test
    s({ trig = "test", dscr = "Unit test" }, fmt([[
test('{}', () {{
  {}
}});
]], { i(1, "should do something"), i(2, "expect(actual, expected);") })),

    -- Widget test
    s({ trig = "widgettest", dscr = "Widget test" }, fmt([[
testWidgets('{}', (WidgetTester tester) async {{
  await tester.pumpWidget({});
  {}
}});
]], { i(1, "should render widget"), i(2, "MyWidget()"), i(3, "expect(find.text('Hello'), findsOneWidget);") })),

    -- setUp
    s({ trig = "setup", dscr = "Test setUp" }, fmt([[
setUp(() {{
  {}
}});
]], { i(1, "// Setup code") })),

    -- tearDown
    s({ trig = "teardown", dscr = "Test tearDown" }, fmt([[
tearDown(() {{
  {}
}});
]], { i(1, "// Cleanup code") })),

    -- ============================================
    -- HTTP & API Snippets
    -- ============================================

    -- HTTP GET
    s({ trig = "httpget", dscr = "HTTP GET request" }, fmt([[
final response = await http.get(Uri.parse('{}'));
if (response.statusCode == 200) {{
  final {} = jsonDecode(response.body);
  {}
}} else {{
  throw Exception('Failed to load data');
}}
]], { i(1, "https://api.example.com/data"), i(2, "data"), i(3, "// Process data") })),

    -- HTTP POST
    s({ trig = "httppost", dscr = "HTTP POST request" }, fmt([[
final response = await http.post(
  Uri.parse('{}'),
  headers: {{'Content-Type': 'application/json'}},
  body: jsonEncode({}),
);
if (response.statusCode == 200) {{
  {}
}} else {{
  throw Exception('Failed to post data');
}}
]], { i(1, "https://api.example.com/data"), i(2, "{'key': 'value'}"), i(3, "// Success") })),

    -- Dio GET
    s({ trig = "dioget", dscr = "Dio GET request" }, fmt([[
final dio = Dio();
try {{
  final response = await dio.get('{}');
  final {} = response.data;
  {}
}} catch (e) {{
  print('Error: $e');
}}
]], { i(1, "https://api.example.com/data"), i(2, "data"), i(3, "// Process data") })),

    -- ============================================
    -- State Management Patterns
    -- ============================================

    -- ChangeNotifier
    s({ trig = "changenotifier", dscr = "ChangeNotifier class" }, fmt([[
class {} extends ChangeNotifier {{
  {} _{};

  {} get {} => _{};

  void {}({}) {{
    _{} = {};
    notifyListeners();
  }}
}}
]],
        { i(1, "MyNotifier"), i(2, "int"), i(3, "counter = 0"), rep(2), i(4, "counter"), rep(3), i(5, "increment"), i(6,
            ""), rep(3), i(7, "_counter + 1") })),

    -- ValueNotifier
    s({ trig = "valuenotifier", dscr = "ValueNotifier" }, fmt([[
final {} = ValueNotifier<{}>({});
]], { i(1, "counterNotifier"), i(2, "int"), i(3, "0") })),

    -- ============================================
    -- Database Snippets
    -- ============================================

    -- Drift table
    s({ trig = "drifttable", dscr = "Drift table definition" }, fmt([[
class {} extends Table {{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get {} => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}}
]], { i(1, "Users"), i(2, "name") })),

    -- SharedPreferences
    s({ trig = "sharedprefs", dscr = "SharedPreferences get/set" }, fmt([[
final prefs = await SharedPreferences.getInstance();
await prefs.setString('{}', {});
final {} = prefs.getString('{}');
]], { i(1, "key"), i(2, "value"), i(3, "value"), rep(1) })),
})
