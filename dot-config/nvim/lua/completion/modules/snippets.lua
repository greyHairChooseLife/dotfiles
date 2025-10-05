local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep

ls.add_snippets("c", {
	s("main", {
		t("#include <stdio.h>\n\nint main() {\n    "),
		i(1, "// code here"),
		t("\n    return 0;\n}"),
	}),
	s("printf", {
		t('printf("'),
		i(1, "%s"),
		t('\\n", '),
		i(2, "variable"),
		t(");"),
	}),
	s("for", {
		t("for (int "),
		i(1, "i"),
		t(" = 0; "),
		rep(1), -- repeat the first insert node
		t(" < "),
		i(2, "n"),
		t("; "),
		rep(1),
		t("++) {\n    "),
		i(3, "// loop body"),
		t("\n}"),
	}),
	s("if", {
		t("if ("),
		i(1, "condition"),
		t(") {\n    "),
		i(2, "// code"),
		t("\n}"),
	}),
})
