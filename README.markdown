# GrepIt - Yet another grep wrapper

Author: Andreas Andersson

GrepIt is a simple wrapper around grep and findstr that helps
you grep in all files for a language. For example if the current
file is a .h file, and you execute:

	:GrepIt hello

All files ending in h,cpp,cc,c,mm will be grepped for the string "hello". This
saves you typing a lot of '--include=*.X' each time you want to search for something.

But, the real magic happens when you make a keyboard short to search for
the word under the cursor. See Configuration section

##Installation

Just copy plugin/grepit.vim to your own vim plugin directory (~/.vim/plugin).

Using [pathogen.vim](https://github.com/tpope/vim-pathogen), GrepIt is installed like so:

    cd ~/.vim/bundle
    git clone git://github.com/derwiath/vim-grepit.git

## Configuration

GrepIt is preconfigured with a language map for C, C++ and Objetive C/C++.

You custom language language map should be named 'g:grepit_lang_map'. It's a simple mappint 
of language to a string with comma separated extensions.

This is how the default lang_map looks:

    let g:grepit_lang_map = {
        \ "cpp" : "h,inl,cpp,cc,c,m,mm" ,
        \ }

I recomend that you connect GrepIt to a keyboard shortcut in your .vimrc, like so:

	noremap <silent> <Leader>g :GrepIt (expand("<cword>"))<CR>

The searched word is highligted, just like if you were to press '*' on it. This behaviour can be disabled
by with 'g:grepit_hlsearch' in your .vimrc

    let g:grepit_hlsearch = 0

## Commands

GrepIt comes with three built in commands, GrepIt, GrepItInExts and GrepItInLangs. Here follows
a brief description of each.

### GrepIt

    Usage: GrepIt <needle>

Searches recursively for needle in files mapping to the language of current file. If no language
for current file is defined, files with the same extension is searched.

Example, to search for 'hello' in the current language:

    :GrepIt hello

### GrepItInExts

    Usage: GrepItInExts <needle> <extensions>

Searches recursively for needle in files with specified extensions. The extensions parameter is a 
comma separated list of extensions (excluding the dots)

Example, to search for 'hello' in all .lua and .py files:

    :GrepItInExts hello py,lua

### GrepItInLangs

    Usage: GrepItInLangs <needle> <languages>

Searches recursively for needle in files mapping to the specified languages. The languages parameter
is a comma separated list of language names. If a specified language fails to match any in the current
lang_map, the language is interpreted as an extension instead.

Example, to search for 'hello' in all C++ related AND .py files:

    :GrepItInLangs 'hello' cpp,py

Note that by default, 'cpp' matches the cpp language (h,inl,cpp,cc,c,m,mm) and 'py' maps the extension
py only. This is, of course, because the lang_map contains no 'py' language.
