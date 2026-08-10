if exists('g:loaded_sage') | finish | endif
let g:loaded_sage = 1

" Lazy-load the Lua module — users who call require('lk').setup() manually
" don't need this autoload, but it provides zero-config defaults.
if !exists('g:sage_no_default_setup')
  autocmd VimEnter * ++once lua if not pcall(require, 'lk') then return end
endif
