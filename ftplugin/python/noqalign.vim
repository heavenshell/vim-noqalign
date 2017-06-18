" File: noqalign.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:  http://github.com/heavenshell/vim-noqalign/
" Description: noqalign for Vim
" License: BSD, see LICENSE for more details.
"
" Async format was inspiered from haya14busa's vim-gofmt.
" see https://github.com/haya14busa/vim-gofmt
"
" Copyright 2017 haya14busa. All rights reserved.
" Copyright 2017 Shinya Ohyanagi. All rights reserved.

let s:save_cpo = &cpo
set cpo&vim

" version check
if !has('channel') || !has('job')
  echoerr '+channel and +job are required for prettier.vim'
  finish
endif

command! -buffer Noqalign :call noqalign#run()

noremap <silent> <buffer> <Plug>(Noqalign)  :Noqalign<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
