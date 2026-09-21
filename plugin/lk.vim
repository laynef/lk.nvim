if exists('g:loaded_sage') | finish | endif
let g:loaded_sage = 1

" Zero-config defaults: the commands only register inside setup(), so merely
" requiring the module gave a user without config=true no commands at all.
" Call setup() with defaults here; a later manual require('lk').setup(opts)
" simply re-registers the commands with the user's options.
if !exists('g:sage_no_default_setup')
  autocmd VimEnter * ++once lua local ok, lk = pcall(require, 'lk'); if ok then pcall(lk.setup) end
endif
