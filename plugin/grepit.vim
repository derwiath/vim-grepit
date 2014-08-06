if exists("g:grepit_loaded")
	finish
endif
let g:grepit_loaded=1

let s:lang_map = {
	\ "cpp" : "h,inl,cpp,cc,c,m,mm" ,
	\ }

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

function! s:GetGrepCmd(word, extensions)
	let l:commandline = "grep -R"
	for l:extension in split(a:extensions, ",")
		let l:commandline = l:commandline . " --include=*." . l:extension
	endfor

	return l:commandline . " \"" . a:word . "\" ."
endfunction

function! s:GetFindStrCmd(word, extensions)
	let l:commandline = "grep /S \"" . a:word . "\""
	for l:extension in split(a:extensions, ",")
		let l:commandline = l:commandline . " *." . l:extension
	endfor

	return l:commandline
endfunction

function! s:GetLanguageMap()
	let l:lang_map = s:lang_map
	if exists("g:grepit_lang_map")
		extend(l:lang_map, g:grepit_lang_map)
	endif
	return l:lang_map
endfunction

function! s:GetHightlightSearch()
	if exists('g:grepit_hlsearch')
		return g:grepit_highligt_search
	endif
	return 1
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

function! s:GrepItInExtensions(word, extensions)
	let l:commandline = ""
	if has('win32')
		let l:commandline = s:GetFindStrCmd(a:word, a:extensions)
	else
		let l:commandline = s:GetGrepCmd(a:word, a:extensions)
	endif

	execute(l:commandline)

	if s:GetHightlightSearch()
		let @/ = a:word
		set hlsearch
	endif
endfunction

function! s:GrepItInLanguages(word, languages)
	let l:lang_map = s:GetLanguageMap()
	let l:languages = split(a:languages, ",")
	let l:extensions = s:GetExtensions(l:languages, l:lang_map)
	call s:GrepItInExtensions(a:word, l:extensions)
endfunction

function! s:GrepItInCurrentLanguage(word)
	let l:lang_map = s:GetLanguageMap()
	let l:extension = tolower(expand("%:e"))
	let l:language = s:GetLanguage(l:extension, l:lang_map)
	let l:extensions = s:GetExtensions([l:language], l:lang_map)
	call s:GrepItInExtensions(a:word, l:extensions)
endfunction

command! -nargs=1 GrepIt call <SID>GrepItInCurrentLanguage(<f-args>)
command! -nargs=1 GrepItQuote call <SID>GrepItInCurrentLanguage(<args>)
command! -nargs=+ GrepItInExts call <SID>GrepItInExtensions(<f-args>)
command! -nargs=+ GrepItInLangs call <SID>GrepItInLanguages(<f-args>)
