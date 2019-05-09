set guifont=Menlo:h16           "Set fontface:size
filetype plugin indent on       "Turns on filetype detection, plugin and indent.  
set clipboard+=unnamed.         "Uses system clipboard for yanking, only works with vim 7.3+

"set number                     "Set line numbering. set nu, set nonu
set relativenumber              "Set relative line numbering. set renu, set norenu

"--- Set TAB to 4 spaces -----------------------------------------------------------------------
set tabstop=4                   "The width of the TAB is set to 4. Still it is a \t. 
                                "It is just that Vim will interpret it to be having 
                                "a width of 4.
set softtabstop=4               "Sets the number of columns for a TAB.
set expandtab                   "Expand TABs to spaces.
set shiftwidth=4                "Indents will have a width of 4.
"-----------------------------------------------------------------------------------------------
"--- Visual help stuff -------------------------------------------------------------------------
set incsearch                   "Set incremental search
set hlsearch                    "Highlight search results
set smartcase                   "Ignore case if search pattern is lowercase, else case-sensitive
"-----------------------------------------------------------------------------------------------

