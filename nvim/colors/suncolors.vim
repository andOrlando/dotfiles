"""""""""""""""""""""""""""""""
" suncolors                   "
" made for that one wallpaper "
"""""""""""""""""""""""""""""""


" Initial Stuff: totally copying gruvbox but whatever
" Init: {{{
if exists("syntax_on")
	hi clear
	syntax reset
endif

let g:colors_name='suncolors'

if !(has('termguicolors') && &termguicolors) && !has('gui_running') && &t_Co != 256
	finish
endif

" }}}
" Colors: {{{
let fg1 = '#E9EBF3'
let fg2 = '#BFC0C7'
let fg3 = '#7A7C85' "TODO: fix maybe?

let bg1 = '#252935' "TODO: add more
let bg2 = '#373D4F'
let bg3 = '#495169'
let bg4 = '#5B6582'
let red1 = '#BF0F04' "TODO: fix
let red2 = '#ED1205' "TODO: fix
let red3 = '#ED4053'
let red4 = '#FF7080'

let vio1 = '#BA3FAC' "TODO: fix maybe?
let vio2 = '#EB65DC'
let vio3 = '#E480D9' "TODO: fix
let vio4 = '#FC97F1'

"Really Goddamn Blue:
let bbb1 = '#1D2FDA' "TODO: make bluer?
let bbb2 = '#4755DC'

let blue1 = '#5E38C9'
let blue2 = '#7753DD'
let blue3 = '#9B7FF0'
let blue4 = '#AC93F6'
let blue5 = '#CCBAFF'

let cyan1 = '#2B8DCC'
let cyan2 = '#3D9BD7'
let cyan3 = '#6DBCED'
let cyan4 = '#97D6FC'

let ylw1 = '#FFDF3B'
let ylw2 = '#F8F583'

let grn1 = '#38845E'
let grn2 = '#3AF196'

let prp1 = '#793376'
let prp2 = '#B45BBC'

let s:bold = 'bold,'
let s:underline = 'underline,'
let s:italic = 'italic,'
let s:inverse = 'inverse,'
let s:none = 'NONE'

" }}}
" Highlight Function: {{{

function! HL(type, fg, bg, ...)
	execute 'hi clear '.a:type
	let l:final = 'hi '.a:type.' guifg='.a:fg.' guibg='.a:bg
	let l:gui 	= has('nvim') ? ' gui=' : ' cterm='
	let l:guisp = has('nvim') ? ' guisp=' : ' ctermul='
	let l:final = l:final . (a:0 >= 1 ? l:gui.a:1 : '')
	let l:final = l:final . (a:0 >= 2 ? l:guisp.a:2 : '')
	execute l:final
endfunction

" }}}


" Normal Stuff:
" General UI: {{{

"normal text
call HL('Normal', fg1, bg1)

"screen line
call HL('CursorLine', s:none, bg2)
call HL('CursorLineNr', vio4, bg2, s:bold)
hi! link CursorColumn CursorLine

"tabs I imagine
call HL('TabLineFill', bg4, bg1) "these two were inverse
call HL('TabLineSel', fg1, bg3)
hi! link TabLine TabLineFill

"stuff like {} in vimtex when you hover
"TODO: make it more similar to the {}s themselves
call HL('MatchParen', cyan3, s:none, s:bold)

"don't realy know what this does
"TODO: find out what the hell this even does
call HL('ColorColumn', s:none, s:none)

"concealed elemnts, look this one up also. '\lambda -> <lambda symbol>'?
call HL('Conceal', bbb1, s:none, s:bold)

call HL('NonText', red1, s:none)
call HL('SpecialKey', bg3, s:none)

call HL('Visual', s:none, bg3) "this was inverse
hi! link VisualNOS Visual

call HL('Search', grn2, bg2) "this was inverse
hi! link IncSearch Search

"call HL('Underlined', bbb1, s:none, 'underline')

call HL('StatusLine', bg2, fg1) "this was inverse
call HL('StatusLineNc', bg1, fg3)

call HL('VertSplit', bg4, bg1)

"match in the wildmenu completion
"TODO: learn what the wildmenu completion is
call HL('WildMenu', blue3, bg2, s:bold)

"directory names, special names in listing
"TODO: find example of this?
call HL('Directory', vio2, s:none, s:bold)

"titles for output from :set all, :autocmd, etc.
call HL('Title', vio2, s:none, s:bold)

"error messages on the command line
call HL('ErrorMsg', bg1, red3, s:bold)
call HL('WarningMsg', red2, s:none, s:bold)
call HL('MoreMsg', red2, s:none, s:bold)
call HL('ModeMsg', fg2, s:none, s:bold)

"'Press enter' prompt and yes/no questions
call HL('Question', cyan3, s:none, s:bold)

call HL('EndOfBuffer', bg2, bg1)
" }}}
" Gutter: {{{

"line number TODO: maybe change background?
call HL('LineNr', fg3, s:none)

"sign column? no clue TODO: actually know what this is
call HL('SignColumn', s:none, 'NONE')

"fold stuff TODO: make a little darker?
call HL('Folded', fg1, bg1)
hi! link FoldColumn Fold

" }}}
" Cursor: {{{

" Character under cursor
call HL('Cursor ', s:none, s:none) "this was inverse
hi! link vCursor Cursor
hi! link iCursor Cursor
hi! link lCursor Cursor

" }}}
" Syntax Highlighting: {{{

"special characters I imagine
call HL('Special', fg1, s:none)

call HL('Comment', fg3, s:none)
call HL('Todo', fg1, s:none, s:bold)
hi! link Error ErrorMsg

call HL('Statement', blue3, s:none, s:bold)		"???
call HL('Conditional', red4, s:none) 	"if or something
call HL('Repeat', red4, s:none)		"loops and stuff
call HL('Label', bbb1, s:none)			"case or something
call HL('Exception', red2, s:none, s:bold)		"try/catch, exception
call HL('Keyword', blue2, s:none)		"other keywords?

"sizeof, "+", "*", etc.
call HL('Operator', blue3, s:none)

call HL('Identifier', vio4, s:none)
call HL('Function', bg4, s:none, s:bold)
call HL('Constant', prp1, s:none, s:bold)

"preprocessor/import/macro/define stuff
call HL('PreProc', grn1, s:none, s:bold)
call HL('Include', grn1, s:none, s:bold)
call HL('Define', grn1, s:none)
call HL('Macro', grn1, s:none)
"#if, #else, #endif, etc.
call HL('PreCondit', grn2, s:none)

call HL('String', blue5, s:none)
call HL('Character', bbb2, s:none, s:bold)
call HL('Boolean', grn2, s:none, s:bold)
call HL('Number', grn2, s:none)
hi! link Float Number

call HL('Type', vio2, s:none)
call HL('StorageClass', vio2, s:none)
call HL('Structure', bbb2, s:none, s:bold)
call HL('Typedef', grn1, s:none, s:bold)

" }}}
" Completion Menu: {{{

call HL('Pmenu', fg1, bg4)
call HL('PMenuSel', vio4, bg4, s:bold)

call HL('PmenuSbar', bg4, bg4)
call HL('PmenuThumb', bg2, bg2)

" }}}
" Diffs: {{{

call HL('DiffDelete', red4, s:none, 'inverse')
call HL('DiffAdd', grn2, s:none, 'inverse')
call HL('DiffChange', blue1, s:none, 'inverse')
call HL('DiffText', bbb2, s:none, 'inverse')

" }}}
" Spelling: {{{

if has("spell")
	call HL('SpellCap', s:none, s:none)
	call HL('SpellBad', s:none, s:none, 'undercurl')
	call HL('SpellLocal', s:none, s:none, 'undercurl')
	call HL('SpellRare', vio4, s:none, 'undercurl')
endif

" }}}

" Plugin Specific:
" Airline: {{{
call HL('AirlineNa', fg1, blue1, s:bold)
call HL('AirlineNb', fg1, blue2, s:bold)
call HL('AirlineNc', fg1, bg2)

call HL('AirlineIa', fg1, grn1, s:bold)
call HL('AirlineIb', fg1, grn2, s:bold)
call HL('AirlineIc', fg1, bg2)

call HL('AirlineRa', fg1, bbb1, s:bold)
call HL('AirlineRb', fg1, bbb2, s:bold)
call HL('AirlineRc', fg1, bg2)

call HL('AirlineVa', fg1, red2, s:bold)
call HL('AirlineVb', fg1, red4, s:bold)
call HL('AirlineVc', fg1, bg2)

call HL('AirlineINa', fg1, bg4, s:bold)
call HL('AirlineINb', fg1, bg3, s:bold)
call HL('AirlineINc', fg1, bg2)

call HL('AirlineCa', fg1, vio2, s:bold)
call HL('AirlineCb', fg1, vio4, s:bold)
call HL('AirlineCc', fg1, bg2)

call HL('Airlinex', fg1, bg2)
call HL('Airliney', fg1, blue3)
call HL('Airlinez', fg1, blue2)

call HL('AirlineWarning', fg1, blue1)
call HL('AirlineError', fg1, blue1)

"tab stuff
call HL('AirlineTabType', fg1, bg3)
call HL('AirlineTabHid', bg4, bg1)
call HL('AirlineTabMod', vio4, bg3, s:bold)
call HL('AirlineTabModUnsel', fg2, bg1, s:underline)

call HL('AirlineTabLabel', fg1, s:none)

" }}}
" NERDTree: {{{

call HL('NERDTreeDir', fg3, s:none)
call HL('NERDTreeDirSlash', blue3, s:none)

call HL('NERDTreeOpenable', fg2, s:none)
call HL('NERDTreeClosable', fg2, s:none)

call HL('NERDTreeFile', fg1, s:none)
call HL('NERDTreeExecFile', grn2, s:none)

call HL('NERDTreeUp', fg3, s:none)
call HL('NERDTreeCWD', blue1, s:none)
call HL('NERDTreeHelp', fg3, s:none)

"hi! link NERDTreeToggleOn GruvboxGreen
"hi! link NERDTreeToggleOff GruvboxRed

" }}}
" NvimTree: {{{
call HL('NvimTreeSymlink', vio4, s:none)
call HL('NvimTreeRootFolder', fg3, s:none)
call HL('NvimTreeFolderIcon', fg1, s:none)
call HL('NvimTreeFolderName', fg1, s:none)
call HL('NvimTreeEmptyFolderName', fg2, s:none)
call HL('NvimTreeExecFile', blue4, s:none)
call HL('NvimTreeSpecialFile', blue3, s:none)
call HL('NvimTreeImageFile', grn2, s:none)
call HL('NvimTreeMarkdownFile', vio3, s:none)
call HL('NvimTreeIndentMarker', bg3, s:none)

"NvimTreeLicenseIcon
"NvimTreeYamlIcon
"NvimTreeTomlIcon
call HL('NvimTreeGitignoreIcon', fg2, s:none)
call HL('NvimTreeJsonIcon', ylw2, s:none) "TODO: fix to orange

call HL('NvimTreeLuaIcon', ylw2, s:none)
call HL('NvimTreePythonIcon', ylw2, s:none)
call HL('NvimTreeShellIcon', ylw2, s:none)
call HL('NvimTreeJavascriptIcon', red4, s:none)
call HL('NvimTreeCIcon', grn2, s:none)
"NvimTreeReactIcon
call HL('NvimTreeHtmlIcon', grn2, s:none)
"NvimTreeRustIcon
call HL('NvimTreeVimIcon', grn2, s:none) "TODO: fix to orange
call HL('NvimTreeTypescriptIcon', fg1, s:none)

call HL('NvimTreeGitDirty', red4, s:none)
call HL('NvimTreeGitStaged', s:none, s:none, s:underline)
"NvimTreeGitMerge
"NvimTreeGitRenamed
call HL('NvimTreeGitNew', grn2, s:none)

" }}}

" Language Specific:
" Vim: {{{

call HL('vimCommentTitle', fg1, s:none, s:bold)
call HL('vimUserFunc', fg1, s:none)
call HL('vimOption', cyan4, s:none)

"hi! link vimNotation GruvboxOrange
"hi! link vimBracket GruvboxOrange
"hi! link vimMapModKey GruvboxOrange
"hi! link vimFuncSID GruvboxFg3
"hi! link vimSetSep GruvboxFg3
"hi! link vimSep GruvboxFg3
"hi! link vimContinue GruvboxFg3

" }}}
" JS TS: {{{
call HL('javaScriptBraces', cyan4, s:none)
hi! link javaScriptFunction Function
hi! link javaScriptIdentifier Identifier
call HL('javaScriptMember', vio4, s:none)
hi! link javaScriptNumber Number
call HL('javaScriptNull', bg4, s:none)
call HL('javaScriptParens', fg1, s:none)

call HL('typeScriptParens', fg1, s:none)
" }}}
" C: {{{
call HL('cFormat', red4, s:none)
call HL('cIncluded', grn2, s:none)

" }}}
" JSON: {{{
call HL('jsonQuote', blue1, s:none)

" }}}
" Lua: {{{
call HL("luaFuncCall", cyan3, s:none)
call HL("luaFuncName", cyan3, s:bold)

" }}}

" Other: {{{
hi! link csNormal AirlineNa
hi! link csNormal2 AirlineNb

hi! link csInsert AirlineIa
hi! link csInsert2 AirlineIb

hi! link csReplace AirlineRa
hi! link csReplace2 AirlineRb

hi! link csVisual AirlineVa
hi! link csVisual2 AirlineVb

hi! link csInactive AirlineINa
hi! link csInactive2 AirlineINb

hi! link csCommand AirlineCa
hi! link csCommand2 AirlineCb

