" Runtimepath: {{{
if has('nvim')
	set viminfo+="$XDG_CACHE_HOME/nvim/viminfo"
endif
" }}}
" Helper Functions: {{{
lua << EOF
function _G.get_icon(name, ext) --gets icon from nvim-web-devicons
	local icon = require'nvim-web-devicons'.get_icon(name, ext)
	return icon == nil and '' or icon:sub(1, 4)
end
EOF

"Formats a string based off of its name, mostly just adding the icon
fun! GetIcon(bufname) 
	let l:fname = split(a:bufname, '\.')
	return len(l:fname) == 2 ? v:lua.get_icon(l:fname[0], l:fname[1]) : ''
endfun


" }}}
" Todo: {{{
" make more compatible?
" finish filesearch
" finish statusline
" - inactivity
" - better % things
" - more stuff
" - better colors
" finish terminal
" - fix weirdness where it doesn't work on startup or right after open
" }}}
" Normal Stuff:
" Basic Preferences: {{{
set nocompatible
set backspace=indent,eol,start
set ruler
set number
set showcmd
set incsearch
set hlsearch
set cursorline
set background=dark
set tabstop=4
set shiftwidth=4
set autoindent
set encoding=utf8
"setlocal spell spelllang=en_us

filetype plugin on
filetype indent off
syntax on

" }}}
" Colorschemes: {{{
colorscheme suncolors
"au BufNewFile,BufRead * exec 'AirlineTheme gruvbox'

if exists('+termguicolors')
	let &t_8f='\<Esc>[38;2;%lu;%lu;%lum'
	let &t_8b='\<Esc>[48;2;%lu;%lu;%lum'
	set termguicolors
endif

if &term =~ 'kitty'
	set t_ut=
endif


"function for colors
"syn include syntax/vim-coloresque.vim

"does color highlighting
"fun! Colors()
	"syn include syntax/vim-coloresque.vim
	"syn sync fromstart
"endfun

"gets the syntax and stuff of the thing under the cursor
fun! GetSyn()
	exec 'hi '.synIDattr(synID(line('.'), col('.'), 1), 'name')
endfun

fun! GetSynLine()
	let l:syntax = ['']
	let l:index = 0
	while l:index < 90
		let l:syn = synIDattr(synID(line('.'), l:index, 1), 'name')
		if (l:syn != 'Normal' && l:syntax[-1] != l:syn)
			let l:syntax = l:syntax + [l:syn]
		endif
		let l:index = l:index + 1
	endwhile
	echo l:syntax[1:]
endfun

"sets up faster commands
command! GetSyn call GetSyn()
"command! ColorSyn call Colors()
command! GetSynLine call GetSynLine()

"}}}
" Folding: {{{
setl fdm=marker
"au BufNewFile,BufRead *.c,*.js, setl fdm=syntax
let s:syntax = ["c", "javascript", "lua"]
fun Dothething()
	if index(s:syntax, &filetype) != -1
		setl fdm=syntax 
	endif
endfun

au BufNewFile,BufRead * call Dothething()
" }}}
" Mapping: {{{
inoremap <C-Space> <C-x><C-o>
nmap <C-b> <C-o>:call ToggleTerm()<CR>

" }}}
" Completion: {{{
au FileType c setl ofu=ccomplete#Complete
au BufNewFile,BufRead,BufEnter *.cpp,*.hpp setl ofu=omni#cpp#complete#Main

" }}}
" Tabline: {{{
"the amount you want to dim it by
let s:dim = 0x40

"sets a bunch of constants for ease of use
let s:sel_bg = synIDattr(synIDtrans(hlID('TabLineSel')), 'bg', 'gui')
let s:bg = synIDattr(synIDtrans(hlID('TabLine')), 'bg', 'gui')
let s:mod = synIDattr(synIDtrans(hlID('CursorLineNr')), 'fg', 'gui')
let s:mod_dim = '#'
for i in [str2nr(s:mod[1:2], 16), str2nr(s:mod[3:4], 16), str2nr(s:mod[5:], 16)]
	let s:color = i - s:dim
	let s:mod_dim = s:mod_dim. printf('%02x', 0 <= s:color ? s:color : 0)
endfor
exec 'hi TabLineTrans guifg='.s:sel_bg.' guibg='.s:bg
exec 'hi TabLineMod gui=BOLD guifg='.s:mod_dim.' guibg='.s:bg
exec 'hi TabLineModSel gui=BOLD guifg='.s:mod.' guibg='.s:sel_bg

fun! Bufline()
	let l:lb = '' "left barrier
	let l:rb = '' "right barrier
	"let l:rb = '▒'
	"let l:lb = '▒'
	let l:result = '%#Normal#tabs '
	let l:dog = '%T%= dog' "haha dog yes

	for i in range(1, tabpagenr('$'))
		let l:buflist = tabpagebuflist(i)
		let l:buffer = index(l:buflist, bufnr('%')) >= 0 ? bufnr('%') : l:buflist[-1]
		let l:bufname = fnamemodify(bufname(l:buffer), ':t')
		let l:bufname = l:bufname == '' ? '[No Name]' : l:bufname
		let l:icon = GetIcon(l:bufname)

		let l:m 		= getbufvar(l:buffer, '&modified') "modified
		let l:c		 	= l:buffer == bufnr('%') "current
		let l:left 		= l:c ? '%#TabLineTrans#'.l:lb.'%#TabLineSel#' : '%#TabLine# '
		let l:mod_left 	= l:m ? '%#TabLineMod'.(l:c ? 'Sel#' : '#') : ''
		let l:text		= (l:icon == '' ? '' : l:icon.' ').l:bufname
		let l:mod_right = l:m ? '*' : ''
		let l:right 	= l:c ? '%#TabLineTrans#'.l:rb : '%#TabLine# '

		let l:result = l:result.l:left.l:mod_left.l:text.l:mod_right.l:right

	endfor

	"useful functions:
	"filter			bufnr		buflisted		bufname
	"fnamemodify	getcwd		join

	return l:result.l:dog
endfun

set tabline=%!Bufline()
set showtabline=2

"does tabs
for i in range(1, 9)
	exec 'nmap <leader>'.i.' '.i.'gt'
endfor

" }}}
" Statusline: {{{
if hlID('csNormal') == 0
	"highlight things manually
	hi! link csNormal Normal
	hi csNormal gui=BOLD guibg=#878787
	hi! link csNormal2 Normal
	hi csNormal2 gui=BOLD guifg=#B9B9B9

	for i in ['Insert', 'Replace', 'Command', 'Visual', 'Inactive']
		exec 'hi! link cs'.i.' csNormal'
		exec 'hi! link cs'.i.'2 csNormal2'
	endfor
	
endif

for i in ['Normal', 'Insert', 'Replace', 'Command', 'Visual', 'Inactive']
	let s:c1 = synIDattr(synIDtrans(hlID('cs'.i)), 'bg', 'gui')
	let s:c2 = synIDattr(synIDtrans(hlID('cs'.i.'2')), 'bg', 'gui')
	let s:c3 = synIDattr(synIDtrans(hlID('Normal')), 'bg', 'gui')
	exec 'hi cs'.i.'Trans guifg='.s:c1.' guibg='.s:c2
	exec 'hi cs'.i.'Trans2 guifg='.s:c2.' guibg='.s:c3

endfor
hi! link StatusLine Normal
let s:bg = synIDattr(synIDtrans(hlID('Normal')), 'bg', 'gui') 
exec 'hi StatusLineNC guifg='.s:bg.' guibg='.s:bg

let s:stringmap = {
	\ 'n': ['nml', 'Normal'],
	\ 'i': ['ins', 'Insert'],
	\ 'R': ['rep', 'Replace'],
	\ 'c': ['cmd', 'Command'],
	\ 'v': ['vis', 'Visual'],
	\ 'V': ['VIS', 'Visual'],
	\ 's': ['wat', 'Visual'],
	\ 't': ['trm', 'Normal']
\}

let s:lastbufnr = 0
fun! StatusLine()
	
	if &filetype == 'NvimTree' | return 'Tree' | endif

	let l:lb = '' "left barrier
	let l:rb = '' "right barrier
	if (has_key(s:stringmap, mode()))
		let l:mode = s:stringmap[mode()]
	else
		let l:mode = ['wat', 'Normal']
	endif
	let l:start = '%#cs'.l:mode[1].'# '
	let l:b1 = '%#cs'.l:mode[1].'Trans#'.l:rb.'%#cs'.l:mode[1].'2# '
	let l:b2 = '%#cs'.l:mode[1].'Trans2#'.l:rb.'%#Normal#'
	let l:dog = ''
	
	if s:lastbufnr != bufnr()
		let l:dog = s:lastbufnr.' -> '.bufnr()
	endif
	let s:lastbufnr = bufnr()


	let l:loc = (line('.') == line('$') ? 'eof' : '%2p%%').' :%2v '
	let l:file = ' %f'

	return l:start.l:mode[0].l:b1.l:loc.l:b2.l:file.l:dog

endfun


set statusline=%!StatusLine()
set laststatus=2

"autocmd Filetype qf setlocal statusline=\ %n\ \ %f%=%L\ lines\
" }}}
" File Search: {{{ UNFINISHED
fun Dog(dog2)
	redir => dog
	silent exec '!grep -R "'.a:dog2'" **/*'
	redir END
	let l:dog = split(dog, '\n')
	echo l:dog
	if l:dog == ['', 'shell returned 1']
		echoerr 'Pattern not found'
	endif
	
endfun

" }}}
" Open Terminal: {{{ UNFINISHED
fun! ToggleTerm()
	let l:index = index(map(tabpagebuflist(), 'bufname(v:val)[0:3]'), 'term')
	echom l:index.' '.tabpagebuflist()[l:index]
	if l:index <= 0
		set splitright
		vsplit term://bash
		vertical resize 50
		setl winfixwidth
	else
		exec 'bdelete! '.tabpagebuflist()[l:index]
	endif

endfun

" }}}

" Plugin Stuff:
" vim-plug: {{{
call plug#begin()
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'lervag/vimtex'
Plug 'vim-airline/vim-airline'
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdcommenter'
Plug 'tbastos/vim-lua'
Plug 'gko/vim-coloresque'
call plug#end()
" }}}
" Vimtex: {{{
let g:vimtex_view_general_viewer= 'evince'
let g:vimtex_fold_enabled = 1
let g:vimtex_compiler_progname = 'nvr'
au BufNewFile,BufRead *.tex exec 'setl indentexpr= | setl tw=80'
"}}}
" Airline: {{{

let g:airline_disable_statusline = 1

let g:airline_left_sep = ''
let g:airline_right_sep = ''

" Sections
let g:airline_section_b = '%{airline#util#wrap(airline#extensions#branch#get_head(),80)}'
let g:airline_section_y = '%{airline#util#wrap(airline#extensions#languageclient#get_warning(),0)}%{airline#util#wrap(airline#extensions#whitespace#check(),0)}%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
let g:airline_section_z = '%{airline#util#wrap(airline#parts#ffenc(),0)}'
let g:airline_section_warning = '%p%% %#__accent_bold#:%v'

" }}}
" Nvim Tree: {{{
nnoremap <C-n> :NvimTreeToggle<CR>
"au FileType NvimTree setl guicursor=n:hor10 "does it for both window s
" }}}

