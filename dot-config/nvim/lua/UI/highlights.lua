vim.cmd([[
  " MEMO:: Basic
  highlight LineNr guifg=#9ece6a ctermfg=red
  highlight TabLine guifg=lightgrey gui=bold guibg=black
  highlight TabLineFill guibg=#24283b
  highlight TabLineNotSel guibg=#4e4451
  highlight TabLineSelBg guibg=#98c379 guifg=#24283b
  highlight TabLineSelBorder guifg=#98c379 guifg=#24283b
  highlight TabLineGVBg guibg=#FF8C00 guifg=#24283b
  highlight TabLineGVBorder guifg=#FF8C00 guifg=#24283b
  highlight TabLineOilBg guibg=#BDB80B guifg=#24283b
  highlight TabLineOilBorder guifg=#BDB80B guifg=#24283b
  highlight TabLineTempBg guibg=#FFFFFF guifg=#24283b
  highlight TabLineTempBorder guifg=#FFFFFF guifg=#24283b
  highlight Search guibg=#FFFF00 guifg=#1d202f
  highlight CurSearch gui=bold guibg=#0000FF guifg=white
  highlight Visual guibg=#4d6652 guifg=NONE
  highlight CursorLine guibg=#242024 guifg=NONE
  highlight Folded guibg=#24283b guifg=#4d6652 gui=italic
  highlight StatusLine guibg=#24283b
  highlight StatusLineNC guibg=#24283b
  highlight FoldColumn guifg=#24283b


  " MEMO:: Outline
  highlight OutlineNormal guifg=#a9b1d6 guibg=#1f2335
  highlight OutlineCurrent guifg=#1d202f guibg=#9ece6a
  highlight MyOutlineNormal guibg=#2e2e2e


  " MEMO:: Fugitive
  highlight fugitiveUntrackedHeading guifg=#7f52ff gui=bold
  highlight fugitiveUnstagedHeading guifg=#f1502f gui=bold
  highlight fugitiveStagedHeading guifg=#50cd5a gui=bold
  highlight FugitiveNormal guibg=#242024
  highlight FugitiveEOB guifg=#242024
  highlight FugitiveFoldColumn guifg=#242024


  " MEMO:: NvimTree
  highlight NvimTreeNormal guibg=#333342 guifg=NONE
  highlight NvimTreeNormalNC guibg=#333342 guifg=NONE
  highlight NvimTreeCursorLine guibg=#242024 guifg=NONE
  highlight NvimTreeFolderIcon guifg=#569CD6
  highlight NvimTreeFolderArrowOpen guifg=#ffcc00
  highlight NvimTreeFolderName guifg=#569CD6 gui=bold
  highlight NvimTreeOpenedFolderName guifg=#569CD6 gui=bold
  highlight NvimTreeEmptyFolderName guifg=#569CD6
  highlight NvimTreeSymlink guifg=#56B6C2
  highlight NvimTreeRootFolder guifg=#C678DD
  highlight NvimTreeGitDirty guifg=#FFFF00 " #f1502f
  highlight NvimTreeGitStagedIcon guifg=#50cd5a
  " highlight NvimTreeGitMerge guifg=#E5C07B
  highlight NvimTreeGitRenamedIcon guifg=#50cd5a " #61AFEF
  " highlight NvimTreeGitNew guifg=#D19A66
  highlight NvimTreeGitNew guifg=#7f52ff
  highlight NvimTreeGitDeleted guifg=#f1502f
  highlight NvimTreeGitIgnoredIcon guifg=#ffffff
  highlight NvimTreeModifiedIcon guifg=#FF3000
  highlight NvimTreeOpenedHL guifg=#FF8C00 gui=italic,underline
  highlight NvimTreeIndentMarker guifg=#569CD6
  highlight NvimTreeEOB guifg=#333342


  " MEMO:: Vimwiki
  "
  " 헤더 색상 설정
  highlight VimwikiHeader1 guifg=#AF4500 guibg=#007F7F gui=bold
  highlight VimwikiHeader2 guifg=#ffffff gui=bold
  highlight VimwikiHeader3 guifg=#ffffff gui=bold
  highlight VimwikiHeader4 guifg=#ffffff
  highlight VimwikiHeader5 guifg=#ffffff
  " highlight VimwikiHeader6
  " 링크 색상 설정
  highlight VimwikiLink guifg=#FFFF00
  " 리스트 항목 색상 설정
  highlight VimwikiList gui=italic
  " 코드 블록 색상 설정
  highlight VimwikiCode guibg=#333342 guifg=#ffffff gui=italic
  " 강조 텍스트 색상 설정
  highlight VimwikiBold gui=bold,underline
  highlight VimwikiItalic guifg=#DCDCAA gui=italic
  " ToDo 항목 색상 설정
  highlight VimwikiTodo guifg=#000000 guibg=#87CEFA gui=bold
  highlight VimwikiFoldColumn guifg=#24283B


  " MEMO:: GitSigns
  highlight GitSignsAdd guifg=#40cd52
  highlight GitSignsStagedAdd guifg=#40cd52
  highlight GitSignsAddNr guifg=#40cd52
  highlight GitSignsAddLn guibg=#1a472a guifg=NONE
  highlight GitSignsChange guifg=#ffcc00
  highlight GitSignsStagedChange guifg=#ffcc00
  highlight GitSignsChangeNr guifg=#ffcc00
  highlight GitSignsChangeLn guibg=#867300 guifg=NONE
  highlight GitSignsChangedelete guifg=#f1502f
  highlight GitSignsDelete guifg=#f1502f
  highlight GitSignsStagedDelete guifg=#f1502f
  highlight GitSignsTopdelete guifg=#f1502f
  highlight GitSignsStagedTopdelete guifg=#f1502f
  highlight GitSignsChangedeleteNr guifg=#f1502f
  highlight GitSignsDeleteNr guifg=#f1502f
  highlight GitSignsTopdeleteNr guifg=#f1502f
  highlight GitSignsUntracked guifg=#7f52ff
  highlight GitSignsStagedUntracked guifg=#7f52ff

  highlight GitSignsAddInline guibg=#867300 guifg=NONE gui=italic
  highlight GitSignsChangeInline guibg=#FFFF00 guifg=NONE " useless?
  highlight GitSignsDeleteInline guibg=#800000 guifg=NONE
  highlight GitSignsAddLnInline guibg=#32CD32 guifg=NONE
  highlight GitSignsChangeLnInline guibg=#FFFF00 guifg=NONE
  highlight GitSignsDeleteLnInline guibg=#800000 guifg=NONE


  " MEMO:: Gvdiff, diffview
  highlight DiffAdd guibg=#1a472a guifg=NONE " #1e6e40
  highlight DiffChange guibg=#312E03 guifg=NONE
  highlight DiffText guibg=#605D08 guifg=NONE gui=italic
  highlight DiffDelete guibg=#4f2d3d guifg=NONE
  highlight DiffviewFilePanelInsertions guifg=#117e40 guibg=NONE
  highlight DiffviewFilePanelDeletions guifg=#aa3000 guibg=NONE
  highlight DiffviewStatusModified guifg=#6183BB guibg=NONE
  highlight DiffviewStatusAdded guifg=#449DAB guibg=NONE
  highlight DiffviewStatusUntracked guifg=#449DAB guibg=NONE
  highlight DiffviewStatusBroken guifg=#914C54 guibg=NONE
  highlight DiffviewStatusDeleted guifg=#914C54 guibg=NONE
  highlight DiffviewStatusRenamed guifg=#6183BB guibg=NONE
  highlight DiffviewStatusModified guifg=#6183BB guibg=NONE
  highlight DiffviewCursorLine guifg=NONE guibg=#14283B

  " MEMO:: render-markdown
  highlight RenderMarkdownCode guibg=#181818 guifg=NONE
  highlight RenderMarkdownCodeInline guibg=#181818 guifg=NONE
  highlight RenderMarkdownCodeNofile guibg=#181818 guifg=NONE
  highlight RenderMarkdownCodeCodeCompanion guibg=#000000 guifg=NONE
  highlight RenderMarkdownDash guifg=#FFFFFF
  highlight RenderMarkdownQuote guifg=#5F5F5F
  highlight RenderMarkdownBullet guifg=#007F7F gui=bold
  highlight RenderMarkdownUnchecked guifg=#CA4500
  highlight RenderMarkdownUncheckedScope guifg=#f08080
  highlight RenderMarkdownChecked guifg=#32CD32
  highlight RenderMarkdownCheckedScope guifg=#98C379
  highlight RenderMarkdownCancel guifg=#8b8378
  highlight RenderMarkdownCancelScope guifg=#8b8378 gui=strikethrough

  highlight RenderMarkdownMyTodoHeader guibg=#954C54 guifg=#FFFFFF gui=bold,italic
  highlight RenderMarkdownMyReferenceHeader guibg=#C678DD guifg=#FFFFFF gui=bold,italic

  highlight RenderMarkdownMyTodo guifg=#CA4500 gui=bold,italic
  highlight RenderMarkdownMyTodoFin guifg=#1e6e40 gui=bold,italic
  highlight RenderMarkdownMySimpleTodo guifg=#ffffff guibg=#CA4500 gui=bold,italic
  highlight RenderMarkdownMySimpleDone guifg=#ffffff guibg=#004F4F gui=bold,italic
  highlight RenderMarkdownMySimpleCancel guifg=#ffffff guibg=#000000 gui=italic
  highlight RenderMarkdownResult guifg=#ffffff guibg=#3a0ff9 gui=bold,italic
  highlight RenderMarkdownMyQuestion guifg=#e0af68 gui=bold,italic
  highlight RenderMarkdownMyTest guifg=#B0C4DE gui=bold,italic
  highlight RenderMarkdownMyReference guifg=#C678DD gui=bold,italic
  highlight RenderMarkdownMyLog guifg=#000000 guibg=#B0C4DE gui=bold,italic

  highlight RenderMarkdownRed  guifg=#FF3000 gui=bold
  highlight RenderMarkdownBlue   guifg=#4169E1 gui=bold
  highlight RenderMarkdownGreen  guifg=#32CD32 gui=bold
  highlight RenderMarkdownYellow guifg=#FFBF00 gui=bold

  highlight RenderMarkdownHtmlBUF guifg=#CA4500

  highlight RenderMarkdownH1Bg guibg=#DCDCAA gui=bold,italic
  highlight RenderMarkdownH2Bg guibg=#1c2d5f guifg=#FFFF00 gui=bold
  " highlight RenderMarkdownH3Bg guibg=#404000 gui=bold
  highlight RenderMarkdownH3Bg guibg=NONE guifg=#1e90ff gui=italic
  highlight RenderMarkdownH4Bg guibg=NONE guifg=#e0af68 gui=italic
  highlight RenderMarkdownH5Bg guibg=NONE guifg=#8b8378 gui=italic
  " highlight RenderMarkdownH5Bg guibg=#AF4500
  " highlight RenderMarkdownH6Bg guibg=#4e4451

  highlight RenderMarkdownH1 guifg=#FFFFFF
  highlight RenderMarkdownH2 guifg=#4169E1
  highlight RenderMarkdownH3 guifg=#867300
  highlight RenderMarkdownH4 guifg=#4169E1
  " highlight RenderMarkdownH5 guifg=#FFFFFF gui=bold
  " highlight RenderMarkdownH6 guifg=#FFFFFF gui=bold

  highlight RenderMarkdownDocLink guifg=#FFBF00 gui=bold
  highlight RenderMarkdownWebLink guifg=#4169E1 gui=bold
  highlight RenderMarkdownFileLink guifg=#FFBF00 gui=bold
  highlight RenderMarkdownYoutubeLink guifg=#FF3000 gui=bold
  highlight RenderMarkdownDiaryLink guifg=#DCDCAA gui=bold

  " markup highlight for TreeSitter
  highlight @markup.link guifg=#4169E1
  highlight @markup.link.label guifg=#DCDCAA "FFF500
  highlight @markup.strong guifg=#e0af68 gui=bold
  highlight @markup.italic guifg=#DCDCAA gui=italic
  highlight @markup guifg=#FFFFFF
  highlight @markup.heading.1.markdown guifg=#AF4500
  highlight @markup.heading.2.markdown guifg=#FFFFFF
  highlight @markup.heading.3.markdown guifg=#FFFFFF
  highlight @markup.heading.4.markdown guifg=#FFFFFF
  highlight @markup.heading.5.markdown guifg=#FFFFFF
  highlight @markup.heading.6.markdown guifg=#FFFFFF

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


  " MEMO:: QuickFix
  highlight Delimiter guifg=#9ece6a
  highlight QFBufferBG guibg=#201010
  highlight QFBufferEOB guifg=#201010


  " MEMO:: Oil
  highlight OilDirIcon guifg=#ffcc00
  highlight OilNormal guibg=#1A1601
  highlight OilEOB guifg=#1A1601
  highlight OilSignColumn guibg=#1A1601


  " MEMO:: Telescope
  highlight TelescopeSelectionCaret guifg=#FF4500 guibg=#000080
  highlight TelescopeSelection guibg=#000080
  highlight TelescopeMultiSelection guibg=#000060  "bookmark한 것들
  highlight TelescopeMatching guifg=#FF4500
  " highlight TelescopePreviewMessageFillchar guibg=#FF4500 "preview에서 빈칸 채우기, 솔직히 뭔 용도인지 모르곘다.
  highlight TelescopePreviewLine guibg=#181d5f
  highlight TelescopePreviewTitle guifg=#000000 guibg=#000000
  highlight TelescopePreviewBorder guifg=#181818 guibg=#000000
  highlight TelescopePreviewNormal guifg=NONE guibg=#181818
  highlight TelescopeResultsBorder guifg=#000000 guibg=#000000
  highlight TelescopeResultsTitle guifg=#000000 guibg=#000000
  highlight TelescopeResultsNormal guifg=#E0E0E0 guibg=#000000
  highlight TelescopeResultsComment guifg=#FF4500 "버퍼의 a, h, # 등 부가 정보
  highlight TelescopePromptNormal guibg=#181d5f
  highlight TelescopePromptBorder guifg=#181d5f
  highlight TelescopePromptTitle guibg=#181d5f


  " MEMO:: Aerial
  highlight AerialGuide1 guifg=#FF4500
  highlight AerialGuide2 guifg=#E0E0E0
  highlight AerialGuide3 guifg=#E0E0E0
  highlight AerialFunction guifg=#67b3ff gui=bold
  highlight AerialVariable guifg=#DCDCAA gui=italic
  highlight AerialVariableIcon guifg=#DCDCAA
  highlight AerialLine guibg=#4d6652
  highlight AerialNormal guibg=#333342
  highlight AerialEOB guifg=#333342
  highlight AerialFoldColumn guifg=#333342


  " MEMO:: Pmenu for completion
  highlight Pmenu guibg=#000000 guifg=#c8ccd4
  highlight PmenuSel guibg=#000080 gui=bold
  highlight PmenuSbar guibg=#000000 " scrollbar bg
  highlight PmenuThumb guibg=#4d6652
  highlight PmenuThumbSel guibg=#4d6652
  highlight PmenuMatch guifg=#FF4500
  highlight PmenuMatchSel guifg=#FF4500

  highlight BlinkCmpMenu guibg=#000000 guifg=#c8ccd4
  highlight BlinkCmpLabelMatch guifg=#FF4500 gui=bold
  highlight BlinkCmpSource guifg=#5f5f5f gui=italic

  highlight BlinkCmpDoc guibg=#000000 guifg=#c8ccd4
  highlight BlinkCmpDocSeparator guifg=#5f52ff guibg=#000000
  highlight BlinkCmpDocBorder guifg=#5f52ff guibg=#000000
  highlight BlinkCmpSignatureHelp guibg=#000000 guifg=#c8ccd4


  " MEMO:: Borders
  highlight FloatBorder guifg=#000000 guibg=#000000
  highlight NormalFloat guifg=NONE guibg=#000000
  highlight DiagnosticsBorder guifg=#FF4500 guibg=#000000
  highlight BlinkCmpSignatureHelpBorder guifg=#ffff00 guibg=#000000
  highlight GitSignsPreviewBorder guifg=NONE guibg=#000000


  " MEMO:: Lualine
  " highlight CustomSeparator guifg=#98c379 guibg=NONE
  highlight CustomSeparator guifg=#24283b guibg=NONE


  " MEMO:: Indent Blank Line
  highlight @ibl.scope.underline.1 guifg=#Ff0000 guibg=#00ff00 " not working
  highlight IblScope guifg=#7f52ff guibg=NONE
  highlight IblIndent guifg=#5f5f5f guibg=NONE


  " MEMO:: Indent Blank Line
  highlight NoiceMini guifg=#BDB76B guibg=NONE
  highlight NoiceVirtualText guifg=#FFFF00 guibg=NONE gui=italic " highlight search


  " MEMO:: WhichKey
  highlight WhichKeyNormal guibg=#000000 guifg=#c8ccd4
  highlight WhichKeyDesc gui=italic


  " MEMO:: global-note
  highlight NoteBackground guibg=#24283b guifg=NONE
  highlight NoteBorder guibg=#24283b guifg=#ff0000
  highlight NoteTitle guibg=#ff0000 guifg=#000000 gui=bold
  highlight LocalNoteBorder guibg=#24283b guifg=#98c379
  highlight LocalNoteTitle guibg=#98c379 guifg=#000000 gui=bold
  highlight LocalTodoBorder guibg=#24283b guifg=#1e90ff
  highlight LocalTodoTitle guibg=#1e90ff guifg=#000000 gui=bold
  highlight NoteEOB guifg=#24283b
  highlight NoteFoldColumn guifg=#24283b


  " MEMO:: markdown
  highlight MDFoldColumn guifg=#24283B
  " highlight MDLineNrAbove guifg=#24283B
  " highlight MDLineNrBelow guifg=#24283B


  " MEMO:: Terminal
  highlight TerminalNormal guibg=#0c0c0c
  highlight TerminalEOB guifg=#0c0c0c
  highlight TerminalSignColumn guibg=#0c0c0c


  " MEMO:: CodeCompanion
  highlight CodeCompanionMeHeader guibg=#1E5631 guifg=#000000
  highlight CodeCompanionCopilotHeader guibg=#181d5f guifg=#E0E0E0
  highlight CodeCompanionNormal guibg=#242024 guifg=NONE
  highlight CodeCompanionSignColumn guibg=#242024  guifg=NONE
  highlight CodeCompanionEOB  guibg=NONE guifg=#242024
  highlight CodeCompanionFolded guibg=#242024 guifg=#8b8378 gui=italic
  highlight CodeCompanionH1Bg guibg=NONE guifg=#FFFFFF gui=italic,bold
  highlight CodeCompanionH2Bg guibg=#FF3000 guifg=#FFFF0a gui=bold,italic
  highlight CodeCompanionH3Bg guibg=NONE guifg=#1e90ff gui=bold
  highlight CodeCompanionH4Bg guibg=NONE guifg=#e0af68 gui=bold
  highlight CodeCompanionH5Bg guibg=NONE guifg=#8b8378 gui=bold
  highlight CodeCompanionH6Bg guibg=NONE guifg=#B0C4DE gui=bold

  " MEMO:: Snacks
  highlight SnacksPickerInputTitle guibg=#000000 guifg=#A1C98A
  " highlight SnacksPickerListCursorLine guibg=#242024 guifg=NONE
  highlight SnacksPickerListCursorLine guibg=#000080 guifg=NONE
  " highlight SnacksPickerPreviewCursorLine guibg=NONE
  highlight SnacksPickerInputBorder guibg=#000000 guifg=#000000
  highlight SnacksPickerPreviewBorder guibg=#24283B guifg=#24283B
  highlight SnacksPickerCursorLine guibg=#24283B guifg=NONE
  highlight SnacksPickerMatch guifg=#FF4500
]])

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
