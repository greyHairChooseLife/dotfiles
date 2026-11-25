-- ref - run: so /usr/share/nvim/runtime/syntax/hitest.vim
-- ref - run: so $VIMRUNTIME/syntax/hitest.vim
-- ref - https://www.youtube.com/watch?v=CXVDfg3W9Jk
--
-- Every color below is a `$token` resolved from UI/palette.lua. `apply()`
-- renders the block against the palette of the current 'background', so
-- switching day/night re-uses this one file (see UI/theme.lua).
--
-- Only 'Normal' and 'NormalNC' are set outside day/night tuning on purpose:
-- they must follow the palette background (white in day mode).

local M = {}

local template = [[
  " MEMO:: Basic
  highlight Normal guifg=$fg_body guibg=$bg
  highlight NormalNC guifg=$fg_body guibg=$bg
  highlight LineNr guifg=$line_nr ctermfg=red
  highlight TabLine guifg=$fg gui=bold guibg=$bg_panel
  highlight TabLineFill guibg=$bg_bar
  highlight TabLineNotSel guibg=$bg_tab
  highlight TabLineSelBg guibg=$green guifg=$fg_on_chip
  highlight TabLineSelBorder guifg=$green guifg=$fg_on_chip
  highlight TabLineGVBg guibg=$orange guifg=$fg_on_chip
  highlight TabLineGVBorder guifg=$orange guifg=$fg_on_chip
  highlight TabLineOilBg guibg=$oil_tag guifg=$fg_on_chip
  highlight TabLineOilBorder guifg=$oil_tag guifg=$fg_on_chip
  highlight TabLineTempBg guibg=$bg_chip_pale guifg=$fg_on_pale
  highlight TabLineTempBorder guifg=$bg_chip_pale guifg=$fg_on_pale
  highlight Search guibg=$search_bg guifg=$search_fg
  highlight IncSearch guibg=$search_bg guifg=$search_fg gui=bold
  highlight CurSearch gui=bold guibg=$blue_flag guifg=$on_accent
  highlight Visual guibg=$bg_visual guifg=NONE
  highlight CursorLine guibg=$bg_cursorline guifg=NONE
  highlight Folded guibg=$bg_soft guifg=$folded_fg gui=NONE
  highlight StatusLine guifg=$bar_fg guibg=$bg_bar
  highlight StatusLineNC guifg=$bar_fg_nc guibg=$bg_bar
  highlight FoldColumn guifg=$bg
  highlight WinSeparator guifg=$border gui=bold
  highlight VertSplit guifg=$border
  highlight NonText guifg=$faint
  highlight SpecialKey guifg=$faint
  highlight Whitespace guifg=$faint_soft


  " MEMO:: Outline
  highlight OutlineNormal guifg=$fg_note guibg=$bg_outline
  highlight OutlineCurrent guifg=$fg_on_chip guibg=$green
  highlight MyOutlineNormal guibg=$bg_float2


  " MEMO:: Fugitive
  highlight fugitiveUntrackedHeading guifg=$git_untracked gui=bold
  highlight fugitiveUnstagedHeading guifg=$warp gui=bold
  highlight fugitiveStagedHeading guifg=$git_add2 gui=bold
  highlight FugitiveNormal guibg=$bg_note
  highlight FugitiveEOB guifg=$bg_note
  highlight FugitiveFoldColumn guifg=$bg_note


  " MEMO:: NvimTree
  highlight NvimTreeNormal guibg=$bg_tree guifg=NONE
  highlight NvimTreeNormalNC guibg=$bg_tree guifg=NONE
  highlight NvimTreeCursorLine guibg=$bg_note guifg=NONE
  highlight NvimTreeFolderIcon guifg=$tree_blue
  highlight NvimTreeFolderArrowOpen guifg=$git_change
  highlight NvimTreeFolderName guifg=$tree_blue gui=bold
  highlight NvimTreeOpenedFolderName guifg=$tree_blue gui=bold
  highlight NvimTreeEmptyFolderName guifg=$tree_blue
  highlight NvimTreeSymlink guifg=$cyan2
  highlight NvimTreeRootFolder guifg=$purple
  highlight NvimTreeGitDirty guifg=$yellow " $warp
  highlight NvimTreeGitStagedIcon guifg=$git_add2
  " highlight NvimTreeGitMerge guifg=$beige2
  highlight NvimTreeGitRenamedIcon guifg=$git_add2 " $blue3
  " highlight NvimTreeGitNew guifg=$orange2
  highlight NvimTreeGitNew guifg=$git_untracked
  highlight NvimTreeGitDeleted guifg=$warp
  highlight NvimTreeGitIgnoredIcon guifg=$icon_dim
  highlight NvimTreeModifiedIcon guifg=$red_hot
  highlight NvimTreeOpenedHL guifg=$orange gui=italic,underline
  highlight NvimTreeIndentMarker guifg=$tree_blue
  highlight NvimTreeEOB guifg=$bg_tree


  " MEMO:: Vimwiki
  "
  " 헤더 색상 설정
  highlight VimwikiHeader1 guifg=$markdown_h1 guibg=$teal gui=bold
  highlight VimwikiHeader2 guifg=$heading_text gui=bold
  highlight VimwikiHeader3 guifg=$heading_text gui=bold
  highlight VimwikiHeader4 guifg=$heading_text
  highlight VimwikiHeader5 guifg=$heading_text
  " highlight VimwikiHeader6
  " 링크 색상 설정
  highlight VimwikiLink guifg=$yellow
  " 리스트 항목 색상 설정
  highlight VimwikiList gui=italic
  " 코드 블록 색상 설정
  highlight VimwikiCode guibg=$bg_tree guifg=$fg_markup gui=italic
  " 강조 텍스트 색상 설정
  highlight VimwikiBold gui=bold,underline
  highlight VimwikiItalic guifg=$beige gui=italic
  " ToDo 항목 색상 설정
  highlight VimwikiTodo guifg=$fg_on_chip guibg=$lightblue gui=bold
  highlight VimwikiFoldColumn guifg=$bg

  " MEMO:: Warp aka. harpoon
  highlight WarpFloatBorder guifg=$warp guibg=NONE
  highlight WarpAdded guifg=$git_add guibg=NONE



  " MEMO:: GitSigns
  highlight GitSignsAdd guifg=$git_add
  highlight GitSignsStagedAdd guifg=$git_add
  highlight GitSignsAddNr guifg=$git_add
  highlight GitSignsAddLn guibg=$diff_add guifg=NONE
  highlight GitSignsChange guifg=$git_change
  highlight GitSignsStagedChange guifg=$git_change
  highlight GitSignsChangeNr guifg=$git_change
  highlight GitSignsChangeLn guibg=$inline_add guifg=NONE
  highlight GitSignsChangedelete guifg=$warp
  highlight GitSignsDelete guifg=$warp
  highlight GitSignsStagedDelete guifg=$warp
  highlight GitSignsTopdelete guifg=$warp
  highlight GitSignsStagedTopdelete guifg=$warp
  highlight GitSignsChangedeleteNr guifg=$warp
  highlight GitSignsDeleteNr guifg=$warp
  highlight GitSignsTopdeleteNr guifg=$warp
  highlight GitSignsUntracked guifg=$git_untracked
  highlight GitSignsStagedUntracked guifg=$git_untracked

  highlight GitSignsAddInline guibg=$inline_add guifg=NONE gui=italic
  highlight GitSignsChangeInline guibg=$inline_change guifg=NONE " useless?
  highlight GitSignsDeleteInline guibg=$inline_delete guifg=NONE
  highlight GitSignsAddLnInline guibg=$green_bright guifg=NONE
  highlight GitSignsChangeLnInline guibg=$inline_change guifg=NONE
  highlight GitSignsDeleteLnInline guibg=$inline_delete guifg=NONE


  " MEMO:: Gvdiff, diffview
  highlight DiffAdd guibg=$diff_add guifg=NONE " $green_dark
  highlight DiffChange guibg=$diff_change guifg=NONE
  highlight DiffText guibg=$diff_text guifg=NONE gui=italic
  highlight DiffDelete guibg=$diff_delete guifg=NONE
  highlight DiffviewFilePanelInsertions guifg=$dv_insert guibg=NONE
  highlight DiffviewFilePanelDeletions guifg=$dv_delete guibg=NONE
  highlight DiffviewStatusModified guifg=$dv_modified guibg=NONE
  highlight DiffviewStatusAdded guifg=$dv_added guibg=NONE
  highlight DiffviewStatusUntracked guifg=$dv_added guibg=NONE
  highlight DiffviewStatusBroken guifg=$dv_broken guibg=NONE
  highlight DiffviewStatusDeleted guifg=$dv_broken guibg=NONE
  highlight DiffviewStatusRenamed guifg=$dv_modified guibg=NONE
  highlight DiffviewStatusModified guifg=$dv_modified guibg=NONE
  highlight DiffviewCursorLine guifg=NONE guibg=$bg_diffcur
  highlight DiffviewMessageSignColumn guifg=NONE guibg=$bg_panel

  " MEMO:: render-markdown
  highlight RenderMarkdownCode guibg=$bg_code guifg=NONE
  highlight RenderMarkdownCodeInline guibg=$bg_code guifg=NONE
  highlight RenderMarkdownCodeNofile guibg=$bg_code guifg=NONE
  highlight RenderMarkdownCodeCodeCompanion guibg=$bg_panel guifg=NONE
  highlight RenderMarkdownDash guifg=$fg_markup
  highlight RenderMarkdownQuote guifg=$fg_markup
  highlight RenderMarkdownBullet guifg=$teal gui=bold
  highlight RenderMarkdownBulletItem guifg=$cream
  highlight RenderMarkdownMath guifg=$cyan gui=italic,bold
  highlight RenderMarkdownUnchecked guifg=$markdown_todo
  highlight RenderMarkdownUncheckedScope guifg=$pinkish
  highlight RenderMarkdownChecked guifg=$green_bright
  highlight RenderMarkdownCheckedScope guifg=$green
  highlight RenderMarkdownCancel guifg=$fg_muted
  highlight RenderMarkdownCancelScope guifg=$fg_muted gui=strikethrough

  highlight RenderMarkdownMyTodoHeader guifg=$markdown_todo guibg=$bg gui=bold,italic
  highlight RenderMarkdownMyTodoFinHeader guifg=$markdown_done guibg=$bg gui=bold,italic
  highlight RenderMarkdownMyReferenceHeader guifg=$purple guibg=$bg gui=bold,italic

  highlight RenderMarkdownMyTodo guifg=$markdown_todo gui=bold,italic
  highlight RenderMarkdownMyTodoFin guifg=$green_dark gui=bold,italic
  highlight RenderMarkdownMySimpleTodo guifg=$on_accent guibg=$markdown_todo gui=bold,italic
  highlight RenderMarkdownMySimpleDone guifg=$on_accent guibg=$markdown_done gui=bold,italic
  highlight RenderMarkdownMySimpleCancel guifg=$fg_on_code guibg=$bg_code gui=italic
  highlight RenderMarkdownResult guifg=$on_accent guibg=$bg_result gui=bold,italic
  highlight RenderMarkdownMyQuestion guifg=$yellow gui=italic
  highlight RenderMarkdownMyTest guifg=$lavender gui=bold,italic
  highlight RenderMarkdownMyReference guifg=$purple gui=bold,italic
  highlight RenderMarkdownMyLog guifg=$fg_on_chip guibg=$lavender gui=bold,italic
  highlight RenderMarkdownMyNote guifg=$green_bright gui=bold

  highlight RenderMarkdownRed  guifg=$red_hot gui=bold
  highlight RenderMarkdownBlue   guifg=$link gui=bold
  highlight RenderMarkdownGreen  guifg=$green_bright gui=bold
  highlight RenderMarkdownYellow guifg=$orange_light gui=bold

  highlight RenderMarkdownHtmlBUF guifg=$markdown_todo
  " `<i>text</i>` HTML tag content, see html.tag.i in render-markdown.lua
  highlight RenderMarkdownItalic guifg=$beige gui=italic

  " MEMO:: no guibg on purpose. render-markdown draws this group as a full line
  " highlight at priority 4096, so any guibg here paints over inline code (x)
  " inside a heading. Same color as Normal bg for H2-H6, so no visual loss.
  highlight RenderMarkdownH1Bg guifg=$orange_light guibg=NONE gui=bold,italic
  highlight RenderMarkdownH2Bg guibg=NONE guifg=$blue
  highlight RenderMarkdownH3Bg guibg=NONE guifg=$tan
  highlight RenderMarkdownH4Bg guibg=NONE guifg=$beige
  highlight RenderMarkdownH5Bg guibg=NONE guifg=$fg_muted
  highlight RenderMarkdownH6Bg guibg=NONE guifg=$fg_slate

  highlight RenderMarkdownH1 guifg=$bg guibg=$bg
  highlight RenderMarkdownH2 guifg=$bg guibg=$bg
  highlight RenderMarkdownH3 guifg=$bg guibg=$bg
  highlight RenderMarkdownH4 guifg=$bg guibg=$bg
  highlight RenderMarkdownH5 guifg=$bg guibg=$bg    gui=bold
  highlight RenderMarkdownH6 guifg=$bg guibg=$bg    gui=bold

  highlight RenderMarkdownDocLink guifg=$orange_light gui=bold
  highlight RenderMarkdownWebLink guifg=$link gui=bold
  highlight RenderMarkdownFileLink guifg=$orange_light gui=bold
  highlight RenderMarkdownYoutubeLink guifg=$red_hot gui=bold
  highlight RenderMarkdownDiaryLink guifg=$beige gui=bold

  " markup highlight for TreeSitter
  highlight @markup.link guifg=$link
  highlight @markup.link.label guifg=$beige "FFF500
  highlight @markup.strong guifg=$tan gui=bold
  highlight @markup.italic guifg=$beige gui=italic
  highlight @markup guifg=$fg_markup
  " tokyonight sets @markup.heading.N.markdown with a blended guibg per level.
  " guibg=NONE removes it, so only the heading text color remains.
  highlight @markup.heading.1.markdown guifg=$markdown_h1 guibg=NONE
  highlight @markup.heading.2.markdown guifg=$heading_text guibg=NONE
  highlight @markup.heading.3.markdown guifg=$heading_text guibg=NONE
  highlight @markup.heading.4.markdown guifg=$heading_text guibg=NONE
  highlight @markup.heading.5.markdown guifg=$heading_text guibg=NONE
  highlight @markup.heading.6.markdown guifg=$heading_text guibg=NONE

  " @markup.raw.markdown_inline
  " @markup.heading.6.markdown
  " @markup.heading.5.markdown
  " @markup.heading.4.markdown
  " @markup.heading.3.markdown
  " @markup.heading.2.markdown
  " @markup.heading.1.markdown
  " @markup.link.label.symbol
  " @markup.environment.name
  " @markup.list.unchecked
  " @markup.strikethrough
  " @markup.list.markdown
  " @markup.list.checked
  " @markup.environment
  " @markup.link.label
  " @markup.underline
  " @markup.link.url
  " @markup.emphasis
  " @markup.heading
  " @markup.strong
  " @markup.italic
  " @markup.math
  " @markup.list
  " @markup.link
  " @markup.raw
  " @markup

  "MEMO:: Fold Text
  highlight FoldIndent guifg=NONE guibg=NONE
  highlight MDFoldBlock guifg=$bg_fold guibg=NONE
  highlight MDFoldHeaderInfo guifg=$purple guibg=$bg_fold
  highlight FoldText guifg=$purple
  highlight FoldTextCodeblock guifg=$purple guibg=$bg_code
  highlight FoldTextCodeblockReverse guifg=$bg_code
  highlight FoldTextMDTable guifg=$purple guibg=$bg_fold
  highlight FoldTextMDTableSuffix guifg=$bg_fold

  " MEMO:: QuickFix
  highlight Delimiter guifg=$green
  highlight QFBufferBG guibg=$bg_qf
  highlight QFBufferEOB guifg=$bg_qf


  " MEMO:: Oil
  highlight OilDirIcon guifg=$git_change
  highlight OilNormal guibg=$bg_oil
  highlight OilEOB guifg=$bg_oil
  highlight OilSignColumn guibg=$bg_oil


  " MEMO:: Aerial
  highlight AerialGuide1 guifg=$match
  highlight AerialGuide2 guifg=$fg_soft
  highlight AerialGuide3 guifg=$fg_soft
  highlight AerialFunction guifg=$blue2 gui=bold
  highlight AerialVariable guifg=$beige gui=italic
  highlight AerialVariableIcon guifg=$beige
  highlight AerialLine guibg=$bg_visual
  highlight AerialNormal guibg=$bg_tree
  highlight AerialEOB guifg=$bg_tree
  highlight AerialFoldColumn guifg=$bg_tree


  " MEMO:: Pmenu for completion
  highlight Pmenu guibg=$bg_panel guifg=$fg
  highlight PmenuSel guibg=$bg_select gui=bold
  highlight PmenuSbar guibg=$bg_panel " scrollbar bg
  highlight PmenuThumb guibg=$bg_visual
  highlight PmenuThumbSel guibg=$bg_visual
  highlight PmenuMatch guifg=$match
  highlight PmenuMatchSel guifg=$match

  highlight BlinkCmpMenu guibg=$bg_panel guifg=$fg
  highlight BlinkCmpLabelMatch guifg=$match gui=bold
  highlight BlinkCmpSource guifg=$fg_dim gui=italic

  highlight BlinkCmpDoc guibg=$bg_panel guifg=$fg
  highlight BlinkCmpDocSeparator guifg=$float_blue guibg=$bg_panel
  highlight BlinkCmpDocBorder guifg=$float_blue guibg=$bg_panel
  highlight BlinkCmpSignatureHelp guibg=$bg_panel guifg=$fg


  " MEMO:: Borders
  highlight FloatBorder guifg=$bg_panel guibg=$bg_panel
  highlight NormalFloat guifg=NONE guibg=$bg_panel
  highlight DiagnosticsBorder guifg=$match guibg=$bg_panel
  highlight BlinkCmpSignatureHelpBorder guifg=$yellow guibg=$bg_panel
  highlight GitSignsPreviewBorder guifg=NONE guibg=$bg_panel


  " MEMO:: Lualine
  highlight CustomSeparator guifg=$green guibg=NONE


  " MEMO:: Indent Blank Line
  highlight @ibl.scope.underline.1 guifg=$red_pure guibg=$green_flag " not working
  highlight IblScope guifg=$git_untracked guibg=NONE
  highlight IblIndent guifg=NONE guibg=NONE
  " highlight IblIndent guifg=$fg_dim guibg=NONE


  " MEMO:: Noice
  highlight NoiceMini guifg=$tag_info guibg=NONE
  highlight NoiceVirtualText guifg=$yellow guibg=NONE gui=italic " highlight search


  " MEMO:: WhichKey
  highlight WhichKeyNormal guibg=$bg_panel guifg=$fg
  highlight WhichKeyDesc gui=italic


  " MEMO:: global-note
  highlight NoteBackground guibg=$bg guifg=NONE
  highlight NoteBorder guibg=$bg guifg=$red_pure
  highlight NoteTitle guibg=$red_pure guifg=$fg_on_chip gui=bold
  highlight LocalNoteBorder guibg=$bg guifg=$green
  highlight LocalNoteTitle guibg=$green guifg=$fg_on_chip gui=bold
  highlight LocalTodoBorder guibg=$bg guifg=$blue
  highlight LocalTodoTitle guibg=$blue guifg=$fg_on_chip gui=bold
  highlight NoteEOB guifg=$bg
  highlight NoteFoldColumn guifg=$bg


  " MEMO:: markdown
  highlight MDFoldColumn guifg=$bg
  " highlight MDLineNrAbove guifg=$bg
  " highlight MDLineNrBelow guifg=$bg


  " MEMO:: Terminal
  highlight TerminalNormal guibg=$bg_term
  highlight TerminalEOB guifg=$bg_term
  highlight TerminalSignColumn guibg=$bg_term


  " MEMO:: CodeCompanion
  highlight CodeCompanionMeHeader guibg=$bg_cc_me guifg=$fg_on_chip
  highlight CodeCompanionCopilotHeader guibg=$bg_cc_copilot guifg=$fg_soft
  highlight CodeCompanionNormal guibg=$bg_note guifg=NONE
  highlight CodeCompanionSignColumn guibg=$bg_note  guifg=NONE
  highlight CodeCompanionEOB  guibg=NONE guifg=$bg_note
  highlight CodeCompanionFolded guibg=$bg_note guifg=$fg_muted gui=italic
  highlight CodeCompanionH1Bg guibg=$bg_note guifg=$fg_markup gui=italic,bold
  highlight CodeCompanionH2Bg guibg=$bg_note guifg=$yellow_hi gui=bold,italic
  highlight CodeCompanionH3Bg guibg=$bg_note guifg=$blue gui=bold
  highlight CodeCompanionH4Bg guibg=$bg_note guifg=$tan gui=bold
  highlight CodeCompanionH5Bg guibg=$bg_note guifg=$fg_muted gui=bold
  highlight CodeCompanionH6Bg guibg=$bg_note guifg=$lavender gui=bold
  highlight CodeCompanionDiffBanner guibg=$bg_panel guifg=$violet gui=italic

  " MEMO:: Snacks
  highlight SnacksPickerInputTitle guibg=$bg_panel guifg=$sage
  " highlight SnacksPickerListCursorLine guibg=$bg_note guifg=NONE
  highlight SnacksPickerListCursorLine guibg=$bg_select guifg=NONE
  " highlight SnacksPickerPreviewCursorLine guibg=NONE
  highlight SnacksPickerInputBorder guibg=$bg_panel guifg=$bg_panel
  highlight SnacksPickerPreviewBorder guibg=NONE guifg=$teal
  highlight SnacksPickerCursorLine guibg=$bg guifg=NONE
  highlight SnacksPickerMatch guifg=$match
  highlight SnacksPickerPreview guibg=$bg guifg=NONE
  highlight SnacksPickerDropdownPreview guibg=$bg_panel guifg=NONE

  highlight SnacksGhNormal guibg=$bg_panel guifg=NONE
  highlight SnacksGhNormalFloat guibg=$bg_panel guifg=NONE
  highlight SnacksGhBorder guibg=$bg_panel guifg=$match
  highlight SnacksGhTitle guibg=$bg_panel guifg=NONE
  highlight SnacksGhFooter guibg=$bg_panel guifg=NONE


  highlight MarkSignHL guifg=$match guibg=NONE gui=italic

  " MEMO:: Snacks
  highlight DebugBreakPointText guifg=$match guibg=NONE
  highlight DebugBreakPointRejectedText guifg=$violet2 guibg=NONE
  highlight DebugStoppedText guifg=$green_bright guibg=NONE
  highlight DebugStoppedLine guifg=NONE guibg=$bg_panel

  " MEMO:: Atone(undotree)
  highlight AtoneCurrentNode guifg=$green_bright gui=NONE

]]

---@param palette table<string, string>
local function render(palette)
    return (template:gsub("%$([%w_]+)", function(token)
        local color = palette[token]
        if not color then error("[UI.highlights] unknown palette token: $" .. token, 2) end
        return color
    end))
end

--- Apply the UI overrides for the current 'background'.
function M.apply() vim.cmd(render(require("UI.palette").get())) end

return M


--
--
--
--
--
--
--
--
--
-- MEMO:: 내가 주워 모은것들...
--
-- #24283b   #333342 이건 nvim-tree의 배경색
-- #2CB67D   #98C379   #A1C98A
-- #569CD6   #D16969   #2E2E2E
-- #DCDCAA   #6A9955   #FF4500   #7f52ff
-- #FF8C00   #32CD32   #FEAEAE
-- #1E5631   #2F8132   #37D060   #98C379   #2CB67D   #A1C98A
-- #004F4F   #007F7F   #00FFFF   #8FBC8F   #5F9EA0   #A0D9D9
-- #2F2F2F   #5F5F5F   #9F9F9F   #D3D3D3   #FFFFFF   #E0E0E0   #a6b0a1
-- #800000   #FF0000   #FF3000   #FFA500   #FFFF00   #808000   #BDB76B
-- #000080   #0000FF   #3a0ff9   #4169E1   #87CEFA   #ADD8E6   #B0C4DE
-- #1c2d5f   #404000   #242024  #60603a  #181d5f
-- #a43838  #3a1f1f  #6A6709  #4E733F  #0d0d0d
-- #db4b4b  #442424  #605D08  #435F36  #111111
-- #e05f5f  #4d2929  #565306  #374C2D  #121212
-- #e57373  #573030  #4C4A05  #2C3924  #141414
-- #ea8686  #603636  #424104  #21261B  #1a1a1a
-- #efa0a0  #6a3d3d  #393704  #311b1b  #101010
-- #f3b3b3  #744444  #312E03  #2b1717  #0f0f0f
-- #f6c4c4  #7d4a4a  #292502  #251313  #151515
-- #f8d2d2  #875151  #211D02  #201010  #181818
-- #f9dddd  #925858  #1A1601  #1b0d0d  #0c0c0c
-- #fbe8e8
-- #fdf2f2
--
--

--
--
-- MEMO:: from tmux:
-- https://github.com/tmux/tmux/blob/e809c2ec359b0fd6151cf33929244b7a7d637119/colour.c#L366C8-L366C8
--
-- #f0f8ff #faebd7 #ffefdb #eedfcc #cdc0b0 #8b8378 #ffebcd #8a2be2 #5f9ea0 #98f5ff #8ee5ee #7ac5cd #53868b #6495ed #00008b #008b8b #b8860b #ffb90f #eead0e #cd950c
-- #8b6508 #a9a9a9 #006400 #a9a9a9 #bdb76b #8b008b #556b2f #caff70 #bcee68 #a2cd5a #6e8b3d #ff8c00 #ff7f00 #ee7600 #cd6600 #8b4500 #9932cc #bf3eff #b23aee #9a32cd
-- #68228b #8b0000 #e9967a #8fbc8f #c1ffc1 #b4eeb4 #9bcd9b #698b69 #483d8b #2f4f4f #97ffff #8deeee #79cdcd #528b8b #2f4f4f #00ced1 #9400d3 #ff1493 #ff1493 #ee1289
-- #cd1076 #8b0a50 #00bfff #00bfff #00b2ee #009acd #00688b #696969 #696969 #1e90ff #1e90ff #1c86ee #1874cd #104e8b #fffaf0 #228b22 #f8f8ff #adff2f #ff69b4 #ff6eb4
-- #ee6aa7 #cd6090 #8b3a62 #cd5c5c #ff6a6a #ee6363 #cd5555 #8b3a3a #fff0f5 #fff0f5 #eee0e5 #cdc1c5 #8b8386 #7cfc00 #fffacd #fffacd #eee9bf #cdc9a5 #8b8970 #add8e6
-- #bfefff #b2dfee #9ac0cd #68838b #f08080 #e0ffff #e0ffff #d1eeee #b4cdcd #7a8b8b #eedd82 #ffec8b #eedc82 #cdbe70 #8b814c #fafad2 #d3d3d3 #90ee90 #d3d3d3 #ffb6c1
-- #ffaeb9 #eea2ad #cd8c95 #8b5f65 #ffa07a #ffa07a #ee9572 #cd8162 #8b5742 #20b2aa #87cefa #b0e2ff #a4d3ee #8db6cd #607b8b #8470ff #778899 #778899 #b0c4de #cae1ff
-- #bcd2ee #a2b5cd #6e7b8b #ffffe0 #ffffe0 #eeeed1 #cdcdb4 #8b8b7a #32cd32 #66cdaa #0000cd #ba55d3 #e066ff #d15fee #b452cd #7a378b #9370db #ab82ff #9f79ee #8968cd
-- #5d478b #3cb371 #7b68ee #00fa9a #48d1cc #c71585 #191970 #f5fffa #ffe4e1 #ffe4e1 #eed5d2 #cdb7b5 #8b7d7b #ffdead #ffdead #eecfa1 #cdb38b #8b795e #000080 #fdf5e6
-- #6b8e23 #c0ff3e #b3ee3a #9acd32 #698b22 #ff4500 #ff4500 #ee4000 #cd3700 #8b2500 #eee8aa #98fb98 #9aff9a #90ee90 #7ccd7c #548b54 #afeeee #bbffff #aeeeee #96cdcd
-- #668b8b #db7093 #ff82ab #ee799f #cd6889 #8b475d #ffefd5 #ffdab9 #ffdab9 #eecbad #cdaf95 #8b7765 #b0e0e6 #663399 #bc8f8f #ffc1c1 #eeb4b4 #cd9b9b #8b6969 #4169e1
-- #4876ff #436eee #3a5fcd #27408b #8b4513 #f4a460 #2e8b57 #54ff9f #4eee94 #43cd80 #2e8b57 #87ceeb #87ceff #7ec0ee #6ca6cd #4a708b #6a5acd #836fff #7a67ee #6959cd
-- #473c8b #708090 #c6e2ff #b9d3ee #9fb6cd #6c7b8b #708090 #00ff7f #00ff7f #00ee76 #00cd66 #008b45 #4682b4 #63b8ff #5cacee #4f94cd #36648b #d02090 #ff3e96 #ee3a8c
-- #cd3278 #8b2252 #808080 #008000 #808080 #800000 #800080 #f5f5f5 #bebebe #00ff00 #bebebe #b03060 #a020f0 #9acd32 #f0f8ff #faebd7 #00ffff #7fffd4 #7fffd4 #76eec6
-- #66cdaa #458b74 #f0ffff #f0ffff #e0eeee #c1cdcd #838b8b #f5f5dc #ffe4c4 #ffe4c4 #eed5b7 #cdb79e #8b7d6b #000000 #ffebcd #8a2be2 #0000ff #0000ff #0000ee #0000cd
-- #00008b #a52a2a #ff4040 #ee3b3b #cd3333 #8b2323 #deb887 #ffd39b #eec591 #cdaa7d #8b7355 #5f9ea0 #7fff00 #7fff00 #76ee00 #66cd00 #458b00 #d2691e #ff7f24 #ee7621
-- #cd661d #8b4513 #ff7f50 #ff7256 #ee6a50 #cd5b45 #8b3e2f #6495ed #fff8dc #fff8dc #eee8cd #cdc8b1 #8b8878 #dc143c #00ffff #00ffff #00eeee #00cdcd #008b8b #00008b
-- #008b8b #b8860b #a9a9a9 #006400 #a9a9a9 #bdb76b #8b008b #556b2f #ff8c00 #9932cc #8b0000 #e9967a #8fbc8f #483d8b #2f4f4f #2f4f4f #00ced1 #9400d3 #ff1493 #00bfff
-- #696969 #696969 #1e90ff #b22222 #ff3030 #ee2c2c #cd2626 #8b1a1a #fffaf0 #228b22 #ff00ff #dcdcdc #f8f8ff #ffd700 #ffd700 #eec900 #cdad00 #8b7500 #daa520 #ffc125
-- #eeb422 #cd9b1d #8b6914 #adff2f #00ff00 #00ff00 #00ee00 #00cd00 #008b00 #f0fff0 #f0fff0 #e0eee0 #c1cdc1 #838b83 #ff69b4 #cd5c5c #4b0082 #fffff0 #fffff0 #eeeee0
-- #cdcdc1 #8b8b83 #f0e68c #fff68f #eee685 #cdc673 #8b864e #fff0f5 #e6e6fa #7cfc00 #fffacd #add8e6 #f08080 #e0ffff #fafad2 #eedd82 #d3d3d3 #90ee90 #d3d3d3 #ffb6c1
-- #ffa07a #20b2aa #87cefa #8470ff #778899 #778899 #b0c4de #ffffe0 #32cd32 #00ff00 #faf0e6 #ff00ff #ff00ff #ee00ee #cd00cd #8b008b #b03060 #ff34b3 #ee30a7 #cd2990
-- #8b1c62 #66cdaa #0000cd #ba55d3 #9370db #3cb371 #7b68ee #00fa9a #48d1cc #c71585 #191970 #f5fffa #ffe4e1 #ffe4b5 #ffdead #000080 #000080 #fdf5e6 #6b8e23 #808000
-- #ff4500 #ffa500 #ffa500 #ee9a00 #cd8500 #8b5a00 #da70d6 #ff83fa #ee7ae9 #cd69c9 #8b4789 #eee8aa #98fb98 #afeeee #db7093 #ffefd5 #ffdab9 #cd853f #ffc0cb #ffb5c5
-- #eea9b8 #cd919e #8b636c #dda0dd #ffbbff #eeaeee #cd96cd #8b668b #b0e0e6 #a020f0 #9b30ff #912cee #7d26cd #551a8b #663399 #ff0000 #ff0000 #ee0000 #cd0000 #8b0000
-- #bc8f8f #4169e1 #8b4513 #fa8072 #ff8c69 #ee8262 #cd7054 #8b4c39 #f4a460 #2e8b57 #fff5ee #fff5ee #eee5de #cdc5bf #8b8682 #a0522d #ff8247 #ee7942 #cd6839 #8b4726
-- #c0c0c0 #87ceeb #6a5acd #708090 #708090 #fffafa #fffafa #eee9e9 #cdc9c9 #8b8989 #00ff7f #4682b4 #d2b48c #ffa54f #ee9a49 #cd853f #8b5a2b #008080 #d8bfd8 #ffe1ff
-- #eed2ee #cdb5cd #8b7b8b #ff6347 #ff6347 #ee5c42 #cd4f39 #8b3626 #40e0d0 #00f5ff #00e5ee #00c5cd #00868b #d02090 #ee82ee #808080 #008000 #808080 #800000 #800080
-- #f5deb3 #ffe7ba #eed8ae #cdba96 #8b7e66 #f5f5f5 #ffffff #bebebe #00ff00 #bebebe #b03060 #a020f0 #9acd32 #ffff00 #ffff00 #eeee00 #cdcd00 #8b8b00
