
if version < 700
    echo "~/.vimrc: Vim 7.0+ is required!, you should upgrade your vim to latest version."
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" common settings section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=","
set nocompatible
syntax on
filetype plugin on
filetype plugin indent on
set t_Co=256
" backup settings
set backup
set backupdir=~/.vimbackup

if !isdirectory(expand(&backupdir))
    if exists("*mkdir")
        call mkdir(expand(&backupdir), "p")
    endif
endif

" input settings
set backspace=2
set tabstop=4
set shiftwidth=4
set smarttab
" set softtabstop=4
set expandtab " expand tab to spaces
set hidden
" indent settiongs
set autoindent
set smartindent
set cindent
set cinoptions=:0,g0,t0,(0,Ws,m1

" search settings
set hlsearch
set incsearch
set smartcase
set foldmethod=marker
" quickfix settings
if version >= 700
    compiler gcc
endif
"cursorline
set cursorline
set mps+=<:>
"hi CursorLine   cterm=NONE ctermbg=darkred ctermfg=white
"highlight  CursorColumn cterm=NONE ctermbg=darkred ctermfg=white

let g:NeoComplCache_EnableAtStartup = 1 " Old neocomplcache
let g:neocomplcache_enable_at_startup = 1 " New neocomplcache

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Display settings section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ruler
set showmatch
set showmode
set wildmenu
set wildmode=longest:full,full
if version >= 703
     set colorcolumn=81,101
     "hi ColorColumn gui=reverse cterm=reverse
     hi ColorColumn ctermbg=darkgrey ctermfg=NONE
endif

" status line
set statusline=%<%f\ %h%m%r%=%k[%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")}]\ %-14.(%l,%c%V%)\ %P


if has("mswin")
    set diffexpr=MyDiff()
    function MyDiff()
        let opt = '-a --binary '
        if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
        if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
        let arg1 = v:fname_in
        if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
        let arg2 = v:fname_new
        if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
        let arg3 = v:fname_out
        if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
        let eq = ''
        if $VIMRUNTIME =~ ' '
            if &sh =~ '\<cmd'
                let cmd = '""' . $VIMRUNTIME . '\diff"'
                let eq = '"'
            else
                let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
            endif
        else
            let cmd = $VIMRUNTIME . '\diff'
        endif
        silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
    endfunction
endif

" auto encoding detecting
set fileencodings=ucs-bom,utf-8-bom,utf-8,cp936,big5,gb18030,ucs
let g:fencview_autodetect = 1

" set term encoding according to system locale
let &termencoding = substitute($LANG, "[a-zA-Z_-]*\.", "", "")

" support gnu syntaxt
let c_gnu = 1

" show error for mixed tab-space
let c_space_errors = 1
"let c_no_tab_space_error = 1

" don't show gcc statement expression ({x, y;}) as error
let c_no_curly_error = 1

" hilight characters over 100 columns
" match DiffAdd '\%>100v.*'

" hilight extra spaces at end of line
" match Error '\s\+$'

let g:load_doxygen_syntax=1

" show tab as --->
" show trailing space as -
set listchars=tab:>-,trail:-
set list

" fix vim quick fix
set errorformat^=%-GIn\ file\ included\ %.%#

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key mappings section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" F2 to search high lights
map <F2> :silent! nohlsearch<CR>

" jump to previous building error
map <F3> :cp<CR>

" jump to next building error
map <F4> :cn<CR>

" run make command
map <F5> :Blade build<CR>

" run make clean command
map <F6> :Blade clean<CR>

" alt .h .cpp
map <F7> :A<CR>

nnoremap <silent> <F8> :TlistToggle<CR>

" QUICKFIX WINDOW
" @see http://c9s.blogspot.com/2007/10/vim-quickfix-windows.html
command -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
    if exists("g:qfix_win") && a:forced == 0
        cclose
        unlet g:qfix_win
    else
        copen
        let g:qfix_win = bufnr("$")
    endif
endfunction
" toggle quickfix window
nmap <F9> :QFix<CR>

map <F10> :NERDTreeToggle<CR>
imap <F10> <ESC> :NERDTreeToggle<CR>

" F11 toggle paste mode
set pastetoggle=<F11>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" auto commands section
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" remove trailing spaces
function! RemoveTrailingSpace()
    if $VIM_HATE_SPACE_ERRORS != '0'
        normal m`
        silent! :%s/\s\+$//e
        normal ``
    endif
endfunction

" apply gnu indent rule for system headers
function! GnuIndent()
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal tabstop=8
endfunction

" fix inconsist line ending
function! FixInconsistFileFormat()
    if &fileformat == 'unix'
        silent! :%s/\r$//e
    endif
endfunction
autocmd BufWritePre * nested call FixInconsistFileFormat()

" custom indent: no namespace indent, fix template indent errors
function! CppNoNamespaceAndTemplateIndent()
    let l:cline_num = line('.')
    let l:cline = getline(l:cline_num)
    let l:pline_num = prevnonblank(l:cline_num - 1)
    let l:pline = getline(l:pline_num)
    while l:pline =~# '\(^\s*{\s*\|^\s*//\|^\s*/\*\|\*/\s*$\)'
        let l:pline_num = prevnonblank(l:pline_num - 1)
        let l:pline = getline(l:pline_num)
    endwhile
    let l:retv = cindent('.')
    let l:pindent = indent(l:pline_num)
    if l:pline =~# '^\s*template\s*<\s*$'
        let l:retv = l:pindent + &shiftwidth
    elseif l:pline =~# '^\s*template\s*<.*>\s*$'
        let l:retv = l:pindent
    elseif l:pline =~# '\s*typename\s*.*,\s*$'
        let l:retv = l:pindent
    elseif l:pline =~# '\s*typename\s*.*>\s*$'
        let l:retv = l:pindent - &shiftwidth
    elseif l:cline =~# '^\s*>\s*$'
        let l:retv = l:pindent - &shiftwidth
    elseif l:pline =~# '^\s\+: \S.*' " C++ initialize list
        let l:retv = l:pindent + 2
    elseif l:pline =~# '^\s*namespace.*'
        let l:retv = 0
    endif
    return l:retv
endfunction
autocmd FileType cpp nested setlocal indentexpr=CppNoNamespaceAndTemplateIndent()

augroup filetype
    autocmd! BufRead,BufNewFile *.proto set filetype=proto
    autocmd! BufRead,BufNewFile *.thrift set filetype=thrift
    autocmd! BufRead,BufNewFile *.pump set filetype=pump
    autocmd! BufRead,BufNewFile BUILD set filetype=blade
augroup end

" When editing a file, always jump to the last cursor position
autocmd BufReadPost * nested
            \ if line("'\"") > 0 && line ("'\"") <= line("$") |
            \ exe "normal g'\"" |
            \ endif

autocmd BufEnter /*/include/c++/* nested setfiletype cpp
" autocmd BufEnter /usr/include/* nested call GnuIndent()
autocmd BufEnter */include/c++/*.*.*/* nested call GnuIndent()
autocmd BufWritePre * nested call RemoveTrailingSpace()
autocmd FileType make nested colorscheme murphy |

function SetLogHighLight()
    highlight LogFatal ctermbg=red guifg=red
    highlight LogError ctermfg=red guifg=red
    highlight LogWarning ctermfg=yellow guifg=yellow
    highlight LogInfo ctermfg=green guifg=green
    syntax match LogFatal "^F\d\+ .*$"
    syntax match LogError "^E\d\+ .*$"
    syntax match LogWarning "^W\d\+ .*$"
    " syntax match LogInfo "^I\d\+ .*$"
endfunction
autocmd BufEnter *.{INFO,WARNING,ERROR,FATAL},*.log.{INFO,WARNING,ERROR,FATAL}.* nested call SetLogHighLight()

"autocmd BufEnter *.log match DiffAdd '\%>1024v.*'

" auto insert gtest header inclusion for test source file
autocmd BufNewFile *_test.{cpp,cxx,cc} nested :normal i#include "thirdparty/gtest/gtest.h"

" locate project dir by BLADE_ROOT file
functio! FindProjectRootDir()
    let rootfile = findfile("BLADE_ROOT", ".;")
    " in project root dir
    if rootfile == "BLADE_ROOT"
        return ""
    endif
    return substitute(rootfile, "/BLADE_ROOT$", "", "")
endfunction

" set path automatically
function! AutoSetPath()
    let project_root = FindProjectRootDir()
    if project_root != ""
        exec "setlocal path+=" . project_root
    endif
endfunction
autocmd FileType {c,cpp} nested call AutoSetPath()

function! s:InsertCopyright()
    let time = strftime("20%y%m%d-%H:%M")
    exec 'norm O/* ==============================================='
    exec 'norm o#     Copyright(c) All rights reserved'
    exec 'norm o#     Author: xiaochao@oppo.com'
    exec 'norm o#     Time: ' . time
    exec 'norm o==================================================*/'
endfunction
autocmd BufNewFile *.{cc,cpp,py} nested call <SID>InsertCopyright()


" auto insert gtest header inclusion for test source file
function! s:InsertHeaderGuard()
    let fullname = expand("%:p")
    let rootdir = FindProjectRootDir()
    if rootdir != ""
        let path = substitute(fullname, "^" . rootdir . "/", "", "")
    else
        let path = expand("%")
    endif
    call <SID>InsertCopyright()
    let varname = toupper(substitute(path, "[^a-zA-Z0-9]", "_", "g")) . "_"
    exec 'norm o#ifndef ' . varname
    exec 'norm o#define ' . varname
    exec 'norm o#pragma once'
    exec '$norm o#endif  // ' . varname
endfunction
autocmd BufNewFile *.{h,hh.hxx,hpp} nested call <SID>InsertHeaderGuard()

if version >= 700
    autocmd QuickFixCmdPost * :QFix
endif

autocmd FileType python syn keyword Function self

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Custom commands sections
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" integrate blade into vim
function! Blade(...)
    let l:old_makeprg = &makeprg
    setlocal makeprg=blade
    execute "make " . join(a:000)
    let &makeprg=old_makeprg
endfunction
command! -complete=dir -nargs=* Blade call Blade('<args>')

" integrate cpplint into vim
function! CppLint(...)
    let l:args = join(a:000)
    if l:args == ""
        let l:args = expand("%")
        if l:args == ""
            let l:args = '*'
        endif
    endif
    let l:old_makeprg = &makeprg
    setlocal makeprg=cpplint.py
    execute "make " . l:args
    let &makeprg=old_makeprg
endfunction
command! -complete=file -nargs=* CppLint call CppLint('<args>')

" integrate pychecker into vim
function! PyCheck(...)
    let l:old_makeprg = &makeprg
    setlocal makeprg=pychecker
    execute "make -q " . join(a:000)
    let &makeprg=old_makeprg
endfunction
command! -complete=file -nargs=* PyCheck call PyCheck('<args>')

" playback build log for vim quickfix
function! PlaybackBuildLog(...)
    let l:old_makeprg = &makeprg
    setlocal makeprg=cat
    execute "make " . join(a:000)
    let &makeprg=old_makeprg
endfunction
command! -complete=file -nargs=1 PlaybackBuildLog call PlaybackBuildLog('<args>')

" see codereview comments in vim
function! ViewComments(...)
    let l:old_makeprg = &makeprg
    setlocal makeprg=curl
    execute "make -s http://codereview.oa.com/" . join(a:000) . "/comments"
    let &makeprg=old_makeprg
endfunction
command! -nargs=1 ViewComments call ViewComments('<args>')
"==================================add by markxiao=============================
" NERD tree
let NERDChristmasTree=0
let NERDTreeWinSize=35
let NERDTreeChDirMode=2
let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$']
let NERDTreeShowBookmarks=1
let NERDTreeWinPos="left"
" Automatically open a NERDTree if no files where specified
autocmd vimenter * if !argc() | NERDTree | endif
" Close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif


" ctrap
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.png,*.jpg,*.jpeg,*.gif " MacOSX/Linux
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'

" search word under cursor, the pattern is treated as regex, and enter normal mode directly
noremap <C-F> :<C-U><C-R>=printf("Leaderf! --stayOpen rg -e %s ", expand("<cword>"))<CR>
" search word under cursor, the pattern is treated as regex,
" append the result to previous search results.
"noremap <C-G> :<C-U><C-R>=printf("Leaderf! --stayOpen rg --append -e %s ", expand("<cword>"))<CR>
" search word under cursor literally only in current buffer
"noremap <C-B> :<C-U><C-R>=printf("Leaderf! --stayOpen rg -F --current-buffer -e %s ", expand("<cword>"))<CR>
" search visually selected text literally, don't quit LeaderF after accepting an entry
"xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F --stayOpen -e %s ", leaderf#Rg#visual())<CR>
" recall last search. If the result window is closed, reopen it.
"noremap go :<C-U>Leaderf! rg --stayOpen --recall<CR>
noremap <C-N> :Leaderf  --stayOpen file<CR>

"vim-cpp-enhanced-highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1
let g:cpp_no_function_highlight = 1
let c_no_curly_error=1


let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'


"set background=dark
call plug#begin('~/.vim/plugged')
Plug 'mhinz/vim-startify'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/bufexplorer.zip'
Plug 'w0ng/vim-hybrid'
Plug 'scrooloose/nerdtree'
Plug 'majutsushi/tagbar'
Plug 'octol/vim-cpp-enhanced-highlight'
"require vim version newer than 7.4.3
Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
Plug 'majutsushi/tagbar'
"Plug 'Valloric/YouCompleteMe', {'do': './install.sh --clang-completer'}
call plug#end()
colorscheme molokai


"call plug#begin('~/.vim/plugged')
"Plug 'scrooloose/nerdtree'
"Plug 'jistr/vim-nerdtree-tabs'
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
"" Initialize plugin system
"call plug#end()
"
""===================nerdtree config  begin ==================================
"
""自动打开NERDTree
"autocmd vimenter * NERDTree
"
"
""退出vim时，如果只有NERDtree窗口时，自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"
map <F9> :NERDTreeToggle<CR>
nmap <F10> :TagbarToggle<CR>
"
""=================nerdtree config end=========================================
"
""=================airline config begin========================================
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='bubblegum'
"let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#formatter = 'jsformatter'
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
"let g:airline#extensions#tabline#buffer_nr_show = 0
"let g:airline#extensions#tabline#fnametruncate = 16
"let g:airline#extensions#tabline#fnamecollapse = 2
"let g:airline#extensions#tabline#buffer_idx_mode = 1
""
""=================airline config end==========================================
" buffer 配置
"
"======================copy right==============================================
let g:file_copyright_name = "xiaochao"
let g:file_copyright_email = "xiaochao@oppo.com"
let g:file_copyright_auto_filetypes = ['sh', 'plx', 'pl', 'pm', 'py', 'python', 'h', 'hpp', 'c', 'cc', 'cpp']
nnoremap <C-h> :bp<CR>
nnoremap <C-l> :bn<CR>
hi ColorColumn ctermbg=darkgrey ctermfg=NONE

