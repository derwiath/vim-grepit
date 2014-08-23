# GrepIt - Yet another grep wrapper

Author: Andreas Andersson

GrepIt is a simple wrapper around grep and findstr that helps
you grep in all files for a language. For example if the current
file is a .h file, and you execute:

	:GrepIt hello

All files ending in h,cpp,cc,c,mm will be grepped for the string "hello". This
saves you typing a lot of '--include=*.X' for each search for something.

But, the real magic happens when you make a keyboard short to search for
the word under the cursor. See Configuration section

##Installation

Just copy plugin/grepit.vim to your own vim plugin directory (~/.vim/plugin).

Using [pathogen.vim](https://github.com/tpope/vim-pathogen), GrepIt is
installed like so:

    cd ~/.vim/bundle
    git clone git://github.com/derwiath/vim-grepit.git

## Configuration

GrepIt is preconfigured with a language map for C, C++ and Objetive C/C++.

You custom language language map should be named 'g:grepit_lang_map'. It's a
simple mapping of language to string with comma separated extensions.

This is how the default lang_map looks:

    let g:grepit_lang_map = {
        \ "cpp" : "h,inl,cpp,cc,c,m,mm" ,
        \ }

I recommend that you connect GrepItOperator function to a keyboard
shortcut in your .vimrc:

  nnoremap <silent> <Leader>f :set operatorfunc=GrepItOperator<CR>g@
  vnoremap <silent> <Leader>f :<c-u>call GrepItOperator(visualmode())<CR>

In visual mode this maps <Leader>f to GrepIt so that you can search for whatever
you have selected.
In normal mode you search for whatever movement operator you pass it, for
instance press '<Leader>fiw' to search for the word the cursor are on.

The searched for needle is highligted, just like if you were to press '*' with
the cursor placed over a word. This can be disabled with 'g:grepit_hlsearch'
in your .vimrc

    let g:grepit_hlsearch = 0


# Undocumented configs
g:grepit_open_quickfix = 0 or 1
g:grepit_goto_first_match = 0 or 1

GrepIt comes with a few built in commands. Here follows a brief description
of each.

### GrepIt

    Usage: GrepIt <needle>

Searches recursively for needle in files mapping to the language of current
file. If no language for current file is defined, files with the same extension
is searched.

Example, to search for 'hello world' in the current language:

    :GrepIt hello world

You can also pass regexp down to grep:
    :GrepIt \bhello\b

### GrepItExts

    Usage: GrepItExts <extensions> <needle>

Searches recursively for needle in files with specified extensions.
The extensions parameter is a comma separated list of extensions (excluding dots)

Example, to search for 'hello' in all .lua and .py files:

    :GrepItExts py,lua hello

### GrepItLangs

    Usage: GrepItLangs <languages> <needle>

Searches recursively for needle in files mapping to the specified languages. The languages parameter
is a comma separated list of language names. If a specified language fails to match any in the current
lang_map, the language is interpreted as an extension instead.

Example, to search for 'hello' in all C++ related AND .py files:

    :GrepItLangs 'hello' cpp,py

Note that by default, 'cpp' matches the cpp language (h,inl,cpp,cc,c,m,mm) and 'py' maps the extension
py only. This is, of course, because the lang_map contains no 'py' language.
