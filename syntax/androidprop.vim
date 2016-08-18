" Android *.prop file syn highlight

if version < 600
    syn clear
elseif exists("b:current_syn")
    finish
endif

syn match propError
        \ "\v^.*$"
        \ contains=propPair

syn match propComment
        \ "\v(\s*)#.*"

syn match propPair
        \ "\v^.+\=.*$"
        \ contained
        \ transparent
        \ contains=propKey,propValue,propEq

syn match propKey
        \ "\v(^\s*)@<=[^= \t]{1,31}(.*\=)@="
        \ contained
        \ nextgroup=propEq

syn match propEq
        \ "="
        \ contained
        \ nextgroup=propValue

syn match propValue
        \ "\v\=@<=.{1,91}"
        \ contained

hi default link propError   Error
hi default link propComment Comment
hi default link propKey     Identifier
hi default link propEq      Operator
hi default link propValue   String

let b:current_syn = "androidprop"

