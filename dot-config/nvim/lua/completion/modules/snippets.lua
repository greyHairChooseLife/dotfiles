local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node -- 걍 써지고 그만
local i = ls.insert_node -- Tab 및 S-Tab으로 순회하며 입력
local extras = require("luasnip.extras")
local rep = extras.rep

ls.add_snippets("c", {
	-- MEMO:: main func
	s("main", {
		t({ "#include <stdio.h>", "", "int main() {", "    " }),
		i(1, "// code here"),
		t({ "", "    return 0;", "}" }),
	}),
	-- MEMO:: printf
	s("printf", {
		t('printf("'),
		i(1, "%s"),
		t('\\n", '),
		i(2, "variable"),
		t(");"),
	}),
	-- MEMO:: for
	s("for", {
		t("for (int "),
		i(1, "i"),
		t(" = 0; "),
		rep(1),
		t(" < "),
		i(2, "n"),
		t("; "),
		rep(1),
		t({ ") {", "    " }),
		i(3, "// loop body"),
		t({ "", "}" }),
	}),
	-- MEMO:: if cond else
	s("if", {
		t("if ("),
		i(1, "condition"),
		t({ ") {", "    " }),
		i(2, "// code"),
		t({ "", "}" }),
	}),
})
