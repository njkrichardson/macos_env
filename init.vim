" Nick's vim run commands (rc) 
"
" Generally speaking, the rc file is comprised of plugin management, 
" custom keymaps, visuals, and application configuration (e.g., LaTeX). 
"
" Author: njkr 

" keyboard 
set timeoutlen=1000
set ttimeoutlen=5
inoremap <expr><tab> pumvisible()? "\<c-n>" : "\<tab>"

" set python3 executable location 
function! s:show_warning_message(hlgroup, msg)
    execute 'echohl ' . a:hlgroup
    echom a:msg | echohl None
endfunction

" Specify python host (preferrably system default) for neovim.
" The 'neovim' package must be installed in that python:
" e.g. /usr/bin/pip install neovim
"  (or /usr/bin/pip3, /usr/local/bin/pip, depending environments)
" The locally installed python (e.g. homebrew) at /usr/local/bin precedes.

let g:python_host_prog  = '/usr/local/bin/python2'
if !filereadable(g:python_host_prog)
    " Fallback if not exists
    let g:python_host_prog = '/usr/bin/python2'
endif

let g:python3_host_prog = ''

if executable("python3")
  " get local python from $PATH (virtualenv/anaconda or system python)
  let s:python3_local = substitute(system("which python3"), '\n\+$', '', '')

  function! Python3_determine_pip_options()
    if system("python3 -c 'import sys; print(sys.prefix != getattr(sys, \"base_prefix\", sys.prefix))' 2>/dev/null") =~ "True"
      " This is probably a user-namespace virtualenv python. `pip` won't accept --user option.
      " See pip._internal.utils.virtualenv._running_under_venv()
      let l:pip_options = '--upgrade --ignore-installed'
    else
      " Probably system(global) or anaconda python.
      let l:pip_options = '--user --upgrade --ignore-installed'
    endif
    " mac: Force greenlet to be compiled from source due to potential architecture mismatch (pynvim#473)
    if has('mac')
      let l:pip_options = l:pip_options . ' --no-binary greenlet'
    endif
    return l:pip_options
  endfunction

  " Detect whether neovim package is installed; if not, automatically install it
  " Since checking pynvim is slow (~200ms), it should be executed after vim init is done.
  call timer_start(0, { -> s:autoinstall_pynvim() })
  function! s:autoinstall_pynvim()
    if empty(g:python3_host_prog) | return | endif
    let s:python3_neovim_path = substitute(system(g:python3_host_prog . " -c 'import pynvim; print(pynvim.__path__)' 2>/dev/null"), '\n\+$', '', '')
    if empty(s:python3_neovim_path)
      " auto-install 'neovim' python package for the current python3 (virtualenv, anaconda, or system-wide)
      let s:pip_options = Python3_determine_pip_options()
      execute ("!" . g:python3_host_prog . " -m pip install " . s:pip_options . " pynvim")
      if v:shell_error != 0
        call s:show_warning_message('ErrorMsg', "Installation of pynvim failed. Python-based features may not work.")
      endif
    endif
  endfunction

  " Assuming that pynvim package is available (or will be installed later), use it as a host python3
  let g:python3_host_prog = s:python3_local
else
  echoerr "python3 is not found on your system: Check $PATH or $SHELL. Most features are disabled."
  let s:python3_local = ''
endif

" Fallback to system python3 (if not exists)
if !filereadable(g:python3_host_prog) | let g:python3_host_prog = '/usr/local/bin/python3' | endif
if !filereadable(g:python3_host_prog) | let g:python3_host_prog = '/usr/bin/python3'       | endif
if !filereadable(g:python3_host_prog) | let g:python3_host_prog = s:python3_local          | endif

" Get and validate python version
try
  if executable('python3')
    let g:python3_host_version = split(system("python3 --version 2>&1"))[1]   " e.g. Python 3.7.0 :: Anaconda, Inc.
  else | let g:python3_host_version = ''
  endif
catch
  let g:python3_host_version = ''
endtry

" Warn users if modern python3 is not found.
" (with timer, make it shown frontmost over other warning messages)
if empty(g:python3_host_version)
  call timer_start(0, { -> s:show_warning_message('ErrorMsg',
        \ "ERROR: You don't have python3 on your $PATH. Check $PATH or $SHELL. Most features are disabled.")
        \ })
elseif g:python3_host_version < '3.6.1'
  call timer_start(0, { -> s:show_warning_message('WarningMsg',
        \ printf("Warning: Please use python 3.6.1+ to enable intellisense features. (Current: %s)", g:python3_host_version))
        \ })
endif

" link vimrc 
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

" Preview window workaround (nice for jedi docstrings)
set previewheight=50
au BufEnter ?* call PreviewHeightWorkAround()
func PreviewHeightWorkAround()
    if &previewwindow
        exec 'setlocal winheight='.&previewheight
    endif
endfunc

" Plugin management
"
call plug#begin('~/.local/share/nvim/plugged')

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'rhysd/vim-clang-format'
Plug 'deoplete-plugins/deoplete-jedi'
Plug 'deoplete-plugins/deoplete-clang'
Plug 'jiangmiao/auto-pairs'
Plug 'davidhalter/jedi-vim'
Plug 'scrooloose/nerdtree'
Plug 'gruvbox-community/gruvbox'
Plug 'vim-scripts/c.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'lervag/vimtex'
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install', 'for': 'python' }

call plug#end()

" NERDTree configuration 
function! StartUp()
    if 0 == argc()
        NERDTree
    end
endfunction

autocmd VimEnter * call StartUp()

" UltiSnips configuration 
let g:UltiSnipsExpandTrigger="<c-l>"
let g:UltiSnipsJumpForwardTrigger="<c-k>"
let g:UltiSnipsJumpBackwardTrigger="<c-j>"
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#jedi#show_docstring = 1
"let g:deoplete#sources#clang#libclang_path = "/usr/local/opt/llvm/lib/libclang.dylib"
let g:jedi#completions_enabled = 1
let g:jedi#use_splits_not_buffers = "right"
" --- docstring autocompletion 
let g:pydocstring_formatter = "numpy"
"let g:pydocstring_doq_path = "/Users/nickrichardson/opt/miniconda3/bin/doq"

" Configure deoplete to use LaTeX
call deoplete#custom#var('omni', 'input_patterns', {'tex': g:vimtex#re#deoplete})

" visuals
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
set splitbelow
colorscheme gruvbox
highlight Normal guibg=none
