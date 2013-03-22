if exists('g:loaded_ctrlp_google') && g:loaded_ctrlp_google
  finish
endif
let g:loaded_ctrlp_google = 1

let s:google_var = {
\  'init':   'ctrlp#google#init()',
\  'exit':   'ctrlp#google#exit()',
\  'accept': 'ctrlp#google#accept',
\  'lname':  'google',
\  'sname':  'google',
\  'type':   'path',
\  'sort':   0,
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:google_var)
else
  let g:ctrlp_ext_vars = [s:google_var]
endif

function! ctrlp#google#init()
  let res = webapi#http#get('https://ajax.googleapis.com/ajax/services/search/web', {
  \ 'v': '1.0',
  \ 'q': s:word,
	\})
  let s:results = webapi#json#decode(res.content).responseData.results
  return map(copy(s:results), 'v:val.titleNoFormatting . "\t" . v:val.url')
endfunc

function! ctrlp#google#accept(mode, str)
  let url = filter(copy(s:results), 'stridx(v:val.titleNoFormatting, split(a:str, "\t")[0]) == 0')[0].url
  call ctrlp#exit()
  call openbrowser#open(url)
endfunction

function! ctrlp#google#exit()
  if exists('s:results')
    unlet! s:results
  endif
endfunction

function! ctrlp#google#start(word)
  let s:word = a:word
  call ctrlp#init(ctrlp#google#id())
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#google#id()
  return s:id
endfunction

" vim:fen:fdl=0:ts=2:sw=2:sts=2
