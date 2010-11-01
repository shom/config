"显示行号
set number
"开启高亮
syntax enable
filetype on
"开启鼠标
set mouse=a
"编码自动识别
set fileencodings=utf-8,gbk
set ambiwidth=double
"搜索高亮
set hlsearch
"输入字符串就显示匹配
set incsearch
"打开当前目录文件列表
map <F2> :e .<CR>
nnoremap <silent> <F3> :Grep<CR>
