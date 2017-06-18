let s:save_cpo = &cpo
set cpo&vim

let g:noqalign_format = get(g:, 'noqalign_format', '--align-')

let s:formatted = []

function! s:check_noqalign()
  let noqalign = ''
  if executable('noqalign') == 1
    let noqalign = exepath('noqalign')
  else
    let root_path = finddir('noqalign', expand('%:p') . ';')
    if root_path == ''
      echohl Error | echomsg 'noqalign is not installed.' | echohl None
      return ''
    endif
    let root_path = fnamemodify(root_path, ':p')
    let noqalign = printf('python %snoqalign/noqalign.py', root_path)
  endif

  return noqalign
endfunction

function! s:callback(ch, msg)
  " Handling errors?
  call add(s:formatted, a:msg)
endfunction

function! s:exit_callback(ch, msg, force_write)
  let view = winsaveview()
  if a:force_write == 'file'
    e!
    call winrestview(view)
    return
  endif

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
  let mode = a:0 > 0 ? 'file' : 'buffer'
  let s:formatted = []

  let path = s:check_noqalign()
  if path == ''
    return
  endif
  let file = expand('%:p')
  let cmd = printf('%s %s -', path, g:noqalign_format)
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m)},
        \ 'exit_cb': {c, m -> s:exit_callback(c, m, mode)},
        \ 'in_io': 'buffer',
        \ 'in_name': file,
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
