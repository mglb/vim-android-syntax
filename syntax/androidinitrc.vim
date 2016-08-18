" Android init rc file syntax highlight
" Based on /system/core/init/init_parser.cpp from 6.0.1_r10

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syn iskeyword   33-126

" Logical highlight groups used by this syntax
hi default link aircHiPropKey       Identifier
hi default link aircHiPropValue     String
hi default link aircHiKeyword       Keyword
hi default link aircHiOperator      Operator
hi default link aircHiString        String
hi default link aircHiSectionType   Type
hi default link aircHiSectionName   Identifier
hi default link aircHiSectionDef    String
hi default link aircHiEscape        SpecialChar
hi default link aircHiSpecialChar   SpecialChar
hi default link aircHiError         Error
hi default link aircHiWarning       Todo
hi default link aircHiComment       Comment
hi default link aircHiImport        Include

" VARIABLE EXPANSION {{{
""""""""""""""""""""""""

" {{{ Dollar escapes: $$

syn match aircDollar
        \ "\v\$( |$)@="
        \ display

syn region aircDollarDollar
        \ keepend
        \ oneline
        \ matchgroup=aircHiEscape
        \ transparent
        \ concealends
        \ start="\v\$\$@="
        \ end="\v\$\zs"
        \ contains=airc_really_nothing_this_is_a_bug_workaround
        \ display

hi default link aircDollar                  aircHiError

syn cluster aircCommon
        \ add=aircDollar,aircDollarDollar

" }}}
" {{{ ${xx.xx.xx}

syn region aircPropExpansion
        \ keepend
        \ oneline
        \ matchgroup=aircHiOperator
        \ start="\v\$\{([^ \t]+\})@="
        \ end="}"
        \ contains=aircPropExpansionKey
        \ display

syn match aircPropExpansionIncomplete
        \ "\v\$\{[^ \t}]+([ \t]|$)@="
        \ display

syn match aircPropExpansionEmpty
        \ "\v\$\{\}"
        \ display

syn match aircPropExpansionKey
        \ contained
        \ "\%#=1\v(\$\{)@2<=[^ \r\t}]{1,31}"
        \ display

hi default link aircPropExpansion           aircHiError
hi default link aircPropExpansionIncomplete aircHiError
hi default link aircPropExpansionEmpty      aircHiError
hi default link aircPropExpansionKey        aircHiPropKey

syn cluster aircCommon
        \ add=aircPropExpansion,aircPropExpansionIncomplete,aircPropExpansionEmpty

" }}}
" {{{ Obselote version: $xx.xx.xx

syn region aircPropExpansionOld
        \ keepend
        \ oneline
        \ matchgroup=aircHiOperator
        \ start="\v\$[^{ \r\t$]@="
        \ end="\v( |$)@="
        \ contains=aircPropExpansionOldKey
        \ display

syn match aircPropExpansionOldKey
        \ contained
        \ "\%#=1\v\$@1<=[^ \r\t$]{1,31}"
        \ display

hi default link aircPropExpansionOld        aircHiError
hi default link aircPropExpansionOldEmpty   aircHiError
hi default link aircPropExpansionOldKey     aircHiWarning

syn cluster aircCommon
        \ add=aircPropExpansionOld

" }}}
"""""
" }}}

" QUOTED THING {{{
""""""""""""""""""
" "xxxxxx"

syn region aircQuotedThing
        \ keepend
        \ matchgroup=aircHiOperator
        \ start="\""
        \ end="\""

hi default link aircQuotedThing             aircHiString

syn cluster aircCommon
        \ add=aircQuotedThing

"""""
" }}}

" ESCAPED CHARACTER {{{
"""""""""""""""""""""""
" \n \r \t \\ \<CR>

syn region aircEscape
        \ keepend
        \ oneline
        \ matchgroup=aircHiEscape
        \ transparent
        \ concealends
        \ start="\v\\.@2="
        \ end="\v.\zs"
        \ contains=aircEscapeSpecial
        \ display

syn match aircEscapeNL
        \ "\\$"
        \ display

syn match aircEscapeSpecial
        \ contained
        \ "\v[nrt]"
        \ display

hi default link aircEscapeNL                aircHiEscape
hi default link aircEscapeSpecial           aircHiSpecialChar

syn cluster aircCommon
        \ add=aircEscape,aircEscapeNL

"""""
" }}}

" SERVICE SECTION {{{
"""""""""""""""""""""
" service xxxx yy  ... {{{

syn region aircServiceSection
        \ keepend
        \ matchgroup=aircHiSectionType
        \ transparent
        \ start="\v^\s*\zsservice>"
        \ end="\v(\n\s*on>)@="
        \ end="\v(\n\s*service>)@="
        \ contains=@aircCommon,@aircService


" }}}
" Section's definition (first line) {{{

syn region aircServiceDef
        \ keepend
        \ contained
        \ start="\v(<service(\s|\\\r?\n)*)@<="
        \ end="\v\\@1<!$"
        \ contains=aircServiceName,@aircCommon

syn match aircServiceName
        \ keepend
        \ oneline
        \ contained
        \ "\v(<service(\s|\\\r?\n)*)@<=(\\\n|\S)+>"
        \ display
        \ contains=aircSectionNameInvalidChar,aircEscape,aircEscapeNL

hi default link aircServiceDef              aircHiSectionDef
hi default link aircServiceName             aircHiSectionName

syn cluster aircService add=aircServiceDef

" }}}
" Service options {{{

syn keyword aircServiceOptionKw
        \ class console critical disabled group ioprio keycodes oneshot
        \ onrestart seclabel setenv socket user writepid
        \ contained skipempty

hi default link aircServiceOptionKw         aircHiKeyword

syn cluster aircService add=aircServiceOptionKw

" }}}
"""""
" }}}

" ACTION SECTION {{{
"""""""""""""""""""""
" Section's definition (first line) {{{

syn region aircActionDef
        \ keepend
        \ matchgroup=aircHiSectionType
        \ start="\v^\s*\zson>"
        \ skip="\\$"
        \ end="$"
        \ contains=aircActionName,aircActionProp,aircEscape,aircEscapeNL

syn match aircActionName
        \ keepend
        \ contained
        \ "\v(<on(\s|\\\r?\n)+)@<=[^= \r\t](\\\r?\n|[^=])+[^\\]$"
        \ display
        \ contains=aircSectionNameInvalidChar,aircEscape,aircEscapeNL

syn region aircActionProp 
        \ keepend
        \ contained
        \ matchgroup=aircHiSectionType
        \ start='\v<@1<=property:(((\\\r?\n\s*)|[^ \r\t=])+\=)@='
        \ skip="\\$"
        \ end="$"
        \ contains=aircActionPropKey,aircActionPropEq,aircActionPropValue

syn match aircActionPropKey
        \ keepend
        \ contained
        \ "\%#=1\v:@1<=(\\.|(\\\r?\n\s*)?[^ \r\t=]){1,31}(\\\n|[ \r\t])*\=@="
        \ display
        \ contains=aircPropKeyInvalidEsc,aircEscape,aircEscapeNL
        \ nextgroup=aircActionPropEq

syn match aircPropKeyInvalidEsc
        \ contained
        \ "\v(\\[nrt])+"
        \ display

syn match aircActionPropEq
        \ contained
        \ "="
        \ display
        \ nextgroup=aircActionPropValueSpecial,aircActionPropValue

syn match aircActionPropValue
        \ keepend
        \ contained
        \ "\v\=@1<=(\\\r?\n|.)*"
        \ contains=@aircCommon

syn match aircActionPropValueSpecial
        \ contained
        \ "\*$"
        \ display

hi default link aircActionDef               aircHiSectionDef
hi default link aircActionName              aircHiSectionName
hi default link aircActionProp              aircHiError
hi default link aircActionPropKey           aircHiPropKey
hi default link aircPropKeyInvalidEsc       aircHiError
hi default link aircActionPropEq            aircHiOperator
hi default link aircActionPropValueSpecial  aircHiSpecialChar
hi default link aircActionPropValue         aircHiPropValue

" }}}
" Action commands {{{

syn keyword aircActionCmdKw
        \ bootchart_init chmod chown class_reset class_start class_stop copy
        \ domainname enable exec export hostname ifup insmod installkey
        \ load_system_props load_persist_props loglevel mkdir mount_all mount
        \ powerctl restart restorecon restorecon_recursive rm rmdir setprop
        \ setrlimit setusercryptopolicies start stop swapon_all symlink
        \ sysclktz trigger verity_load_state verity_update_state wait write

hi default link aircActionCmdKw         aircHiKeyword

syn cluster aircAction add=aircActionCmdKw

" }}}
"""""
" }}}

" SECTION COMMON {{{
""""""""""""""""""""

syn match aircSectionNameInvalidChar
        \ contained
        \ "\v(\\[nrt]|[^-a-zA-Z0-9_\\])+"
        \ display

hi default link aircSectionNameInvalidChar  aircHiError

"""""
" }}}

" COMMENT {{{
"""""""""""""
" # xxx

syn match aircComment
        \ "\v(^|[ \t])@1<=#.*"
        \ display

hi default link aircComment         aircHiComment

syn cluster aircCommon 
        \ add=aircComment

" IMPORT {{{
""""""""""""
" import /xxx.xxx.rc {{{

syn region aircImport
        \ keepend
        \ oneline
        \ matchgroup=aircHiSectionType
        \ start='\v^\s*\zsimport\ze>'
        \ end='$'
        \ contains=@aircCommon
        \ display

hi default link aircImport          aircHiImport

" }}}
"""""
" }}}

let b:current_syntax = "androidinitrc"

