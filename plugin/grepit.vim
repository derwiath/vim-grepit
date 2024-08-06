if exists("g:grepit_loaded") && !exists("g:grepit_debug")
  finish
endif
let g:grepit_loaded=1

function! s:CfgHightlightSearch()
  if exists('g:grepit_hlsearch')
    return g:grepit_hlsearch
  endif
  return 1
endfunction

function! s:CfgGotoFirstMatch()
  if exists('g:grepit_goto_first_match')
    return g:grepit_goto_first_match
  endif
  return 1
endfunction

function! s:CfgOpenQuickFix()
  if exists('g:grepit_open_quickfix')
    return g:grepit_open_quickfix
  endif
  return 1
endfunction

function! s:CfgDebug()
  if exists('g:grepit_debug')
    return g:grepit_debug
  endif
  return 0
endfunction

function! s:CfgPretend()
  if exists('g:grepit_pretend')
    return g:grepit_pretend
  endif
  return 0
endfunction

let s:lang_map = {
  \ "cpp" : "h,inl,cpp,cc,c,m,mm" ,
  \ }

function! s:CfgLangeMap()
  let l:lang_map = s:lang_map
  if exists("g:grepit_lang_map")
    call extend(l:lang_map, g:grepit_lang_map)
  endif
  return l:lang_map
endfunction

function! s:GetLanguage(extension, lang_map)
  for [l:language, l:extensions] in items(a:lang_map)
    for l:candidate in split(l:extensions, ",")
      if l:candidate == a:extension
        return l:language
      endif
    endfor
  endfor

  return ""
endfunction

function! s:GetExtensions(languages, lang_map)
  let l:extensions = ""
  for l:lang in a:languages
    let l:lang_extensions = get(a:lang_map, l:lang, "")
    if l:lang_extensions == ""
      let l:extension = tolower(expand("%:e"))
      let l:lang_extensions = l:extension
    endif
    if strlen(l:extensions) > 0
      let l:lang_extensions = "," . l:lang_extensions
    endif
    let l:extensions = l:extensions . l:lang_extensions
  endfor
  return l:extensions
endfunction

function! s:GetGrepParams(needle, extensions)
  let l:commandline = "-R"

  for l:extension in split(a:extensions, ",")
    let l:commandline = l:commandline . " --include=\*." . l:extension
  endfor

  return l:commandline . " " . shellescape(a:needle) . " ."
endfunction

function! s:GetFindStrParams(needle, extensions)
  let l:commandline = "/S " . shellescape(a:needle)
  for l:extension in split(a:extensions, ",")
    let l:commandline = l:commandline . " *." . l:extension
  endfor

  return l:commandline
endfunction

function! s:GetRipgrepParams(needle, extensions)
  let l:commandline = "--vimgrep -uu"

  let l:globs=[]
  for l:extension in split(a:extensions, ",")
    let l:globs += ["-g \*." . l:extension]
  endfor

  return l:commandline . " " . join(l:globs, " ") . " -- " . shellescape(a:needle)
endfunction

function! s:GrepItInExtensions(extensions, needle)
  let l:params = ""
  if stridx(&grepprg, "findstr") == 0
    let l:params = s:GetFindStrParams(a:needle, a:extensions)
  elseif stridx(&grepprg, "rg") == 0
    let l:params = s:GetRipgrepParams(a:needle, a:extensions)
  else
    let l:params = s:GetGrepParams(a:needle, a:extensions)
  endif

  let l:commandline = ""
  if s:CfgGotoFirstMatch()
    let l:commandline = "grep"
  else
    let l:commandline = "grep!"
  endif

  let l:extlist = join(split(a:extensions, ","), "|")
  if s:CfgDebug()
    echo l:commandline . " " . l:params
  else
    echo "Grepping for" shellescape(a:needle) "in *.(" . l:extlist . ") using " . &grepprg
  endif

  if s:CfgPretend()
    return
  endif

  silent execute l:commandline . " " . l:params

  if s:CfgHightlightSearch()
    let @/ = a:needle
    set hlsearch
  endif
  if len(getqflist()) == 0
    echo "Nothing found"
    return
  endif
  if s:CfgOpenQuickFix()
    botright copen " Quickfix always occupies the entire bottom of the window
  endif
endfunction

function! s:GrepItExtCmd(extensions, ...)
  let l:needle = join(a:000)
  if strlen(l:needle) == 0
    echoerr "usage: GrepItExt <extensions> <needle>"
    return
  endif
  call s:GrepItInExtensions(a:extensions, l:needle)
endfunction

function! s:GrepItLangCmd(languages, ...)
  let l:needle = join(a:000)
  if strlen(l:needle) == 0
    echoerr "usage: GrepItLang <langs> <needle>"
    return
  endif
  let l:lang_map = s:CfgLangeMap()
  let l:languages = split(a:languages, ",")
  let l:extensions = s:GetExtensions(l:languages, l:lang_map)
  call s:GrepItInExtensions(l:extensions, l:needle)
endfunction

function! s:GrepItCmd(...)
  let l:needle = join(a:000)
  if strlen(l:needle) == 0
    echoerr "usage: GrepIt <needle>"
    return
  endif
  let l:lang_map = s:CfgLangeMap()
  let l:extension = tolower(expand("%:e"))
  let l:language = s:GetLanguage(l:extension, l:lang_map)
  let l:extensions = s:GetExtensions([l:language], l:lang_map)
  call s:GrepItInExtensions(l:extensions, l:needle)
endfunction

function! GrepItOperator(type)
  let l:old_register_value = @@
  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  else
    return
  endif
  let l:needle = @@
  let @@ = l:old_register_value

  call s:GrepItCmd(l:needle)
endfunction

command! -nargs=+ GrepIt call <SID>GrepItCmd(<f-args>)
command! -nargs=+ GrepItExt call <SID>GrepItExtCmd(<f-args>)
command! -nargs=+ GrepItLang call <SID>GrepItLangCmd(<f-args>)
