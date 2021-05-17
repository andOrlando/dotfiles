"""""""""""""""""""""""""""""""
" airline theme for suncolors "
"""""""""""""""""""""""""""""""

let g:airline#themes#suncolors#palette = {}

let s:X = airline#themes#get_highlight('Airlinex')
let s:Y = airline#themes#get_highlight('Airliney')
let s:Z = airline#themes#get_highlight('Airlinez')

let s:Na = airline#themes#get_highlight('AirlineNa')
let s:Nb = airline#themes#get_highlight('AirlineNb')
let s:Nc = airline#themes#get_highlight('AirlineNc')
let g:airline#themes#suncolors#palette.normal = airline#themes#generate_color_map(s:Na, s:Nb, s:Nc, s:X, s:Y, s:Z)
let g:airline#themes#suncolors#palette.normal.airline_warning = airline#themes#get_highlight('AirlineWarning')
let g:airline#themes#suncolors#palette.normal.airline_error = airline#themes#get_highlight('AirlineError')
"let g:airline#themes#suncolors#palette.normal_modified = {}
"let g:airline#themes#suncolors#pallete.normal_modified = {
"	\'airline_c' = airline#themes#get_highlight('AirlineNcm')
"	\}
let s:Ia = airline#themes#get_highlight('AirlineIa')
let s:Ib = airline#themes#get_highlight('AirlineIb')
let s:Ic = airline#themes#get_highlight('AirlineIc')
let g:airline#themes#suncolors#palette.insert = airline#themes#generate_color_map(s:Ia, s:Ib, s:Ic, s:X, s:Y, s:Z)
let g:airline#themes#suncolors#palette.insert.airline_warning = airline#themes#get_highlight('AirlineWarning')
let g:airline#themes#suncolors#palette.insert.airline_error = airline#themes#get_highlight('AirlineError')
"let g:airline#themes#suncolors#palette.insert_modified = {}

let s:Ra = airline#themes#get_highlight('AirlineRa')
let s:Rb = airline#themes#get_highlight('AirlineRb')
let s:Rc = airline#themes#get_highlight('AirlineRc')
let g:airline#themes#suncolors#palette.replace = airline#themes#generate_color_map(s:Ra, s:Rb, s:Rc, s:X, s:Y, s:Z)
let g:airline#themes#suncolors#palette.replace.airline_warning = airline#themes#get_highlight('AirlineWarning')
let g:airline#themes#suncolors#palette.replace.airline_error = airline#themes#get_highlight('AirlineError')
"let g:airline#themes#suncolors#palette.insert_modified = {}


let s:Va = airline#themes#get_highlight('AirlineVa')
let s:Vb = airline#themes#get_highlight('AirlineVb')
let s:Vc = airline#themes#get_highlight('AirlineVc')
let g:airline#themes#suncolors#palette.visual = airline#themes#generate_color_map(s:Va, s:Vb, s:Vc, s:X, s:Y, s:Z)
let g:airline#themes#suncolors#palette.visual.airline_warning = airline#themes#get_highlight('AirlineWarning')
let g:airline#themes#suncolors#palette.visual.airline_error = airline#themes#get_highlight('AirlineError')
"let g:airline#themes#suncolors#palette.visual_modified = {}

let s:INa = airline#themes#get_highlight('AirlineINa')
let s:INb = airline#themes#get_highlight('AirlineINb')
let s:INc = airline#themes#get_highlight('AirlineINc')
let g:airline#themes#suncolors#palette.inactive = airline#themes#generate_color_map(s:INa, s:INb, s:INc, s:X, s:Y, s:Z)
let g:airline#themes#suncolors#palette.inactive.airline_warning = airline#themes#get_highlight('AirlineWarning')
let g:airline#themes#suncolors#palette.inactive.airline_error = airline#themes#get_highlight('AirlineError')
"let g:airline#themes#suncolors#palette.inactive_modified = {}

let s:Ca = airline#themes#get_highlight('AirlineCa')
let s:Cb = airline#themes#get_highlight('AirlineCb')
let s:Cc = airline#themes#get_highlight('AirlineCc')
let g:airline#themes#suncolors#palette.commandline = airline#themes#generate_color_map(s:Ca, s:Cb, s:Cc, s:X, s:Y, s:Z)
let g:airline#themes#suncolors#palette.commandline.airline_warning = airline#themes#get_highlight('AirlineWarning')
let g:airline#themes#suncolors#palette.commandline.airline_error = airline#themes#get_highlight('AirlineError')
"let g:airline#themes#suncolors#palette.commandline_modified = {}

let g:airline#themes#suncolors#palette.tabline = {
    \'airline_tab': airline#themes#get_highlight('TabLine'),
    \'airline_tabsel': airline#themes#get_highlight('TabLineSel'),
    \'airline_tabfill': airline#themes#get_highlight('TabLineFill'),
	\'airline_tabtype': airline#themes#get_highlight('AirlineTabType'),
	\'airline_tabhid': airline#themes#get_highlight('AirlineTabHid'),
	\'airline_tabmod': airline#themes#get_highlight('AirlineTabMod'),
	\'airline_tabmod_unsel': airline#themes#get_highlight('AirlineTabModUnsel'),
	\'airline_tablabel': airline#themes#get_highlight('AirlineTabLabel'),
    \}

"symbols
let g:airline_symbols.branch = ''

