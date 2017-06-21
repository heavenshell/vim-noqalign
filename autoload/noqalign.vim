let s:save_cpo = &cpo
set cpo&vim

let g:noqalign_format = get(g:, 'noqalign_format', '--align-')
let g:noqalign_strict = get(g:, 'noqalign_strict', 1)

let s:formatted = []
let s:script_path = fnameescape(expand('<sfile>:p:h:h'))

function! s:check_noqalign()
  let noqalign = ''
  if executable('noqalign') == 1
    let noqalign = exepath('noqalign')
  else
    " let root_path = finddir('noqalign', expand('<sfile>:p:h:h') . ';')
    if isdirectory(s:script_path . '/noqalign') == 0
      echohl Error | echomsg 'noqalign is not installed.' | echohl None
      return ''
    endif
    let path = printf('%s/noqalign/noqalign/noqalign.py', s:script_path)
    if filereadable(path) == 0
      return ''
    endif
    let noqalign = printf('python %s', path)
  endif

  return noqalign
endfunction

function! s:callback(ch, msg)
  " Handling errors?
  call add(s:formatted, a:msg)
endfunction

function! s:exit_callback(ch, msg)
  let view = winsaveview()

  if len(s:formatted) == 0
    return
  endif

  silent execute '% delete'

  call setline(1, s:formatted)
  call winrestview(view)
endfunction

function! s:error_callback(ch, msg)
  echomsg printf('fmt err: %s', a:msg)
endfunction

function! noqalign#run(...)
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif

  if g:noqalign_strict == 1
    if expand('%') != '__init__.py'
      echohl Error | echomsg 'noqalign can run only __init__.py.' | echohl None
      return
    endif
  endif

  let s:formatted = []

  let path = s:check_noqalign()
  if path == ''
    return
  endif
  let file = expand('%:p')
  let cmd = printf('%s %s -', path, g:noqalign_format)
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m)},
        \ 'exit_cb': {c, m -> s:exit_callback(c, m)},
        \ 'in_io': 'buffer',
        \ 'in_name': file,
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
