" mongoquery.nvim - MongoDB query development tool
" Maintainer: tcm

if exists('g:loaded_mongoquery')
  finish
endif
let g:loaded_mongoquery = 1

" User commands
command! MongoSelectConnection lua require('mongoquery').select_connection()
command! MongoCreateConnection lua require('mongoquery').create_connection()
command! MongoDeleteConnection lua require('mongoquery').delete_connection()
command! -range MongoRunQuery lua require('mongoquery').run_query(<range> > 0)
command! MongoQueryList lua require('mongoquery').query_list()
command! MongoCreateQuery lua require('mongoquery').create_query()
command! MongoReload lua require('mongoquery').reload()
