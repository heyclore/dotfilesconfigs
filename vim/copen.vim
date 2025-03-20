let g:copen_popup_id = -1
let g:copen_list = map(getqflist(), 'bufname(v:val.bufnr) . ":" . v:val.lnum . "|" . v:val.text')
let g:copen_selected = 0

function! ShowCopenPopup()
    let content = copy(g:copen_list)
    let g:copen_selected = 0  " Start at the first item
    let g:copen_popup_id = popup_create(content, {
        \ 'pos': 'center',
        \ 'line': 5,
        \ 'col': 10,
        \ 'minwidth': 20,
        \ 'minheight': 6,
        \ 'border': [],
        \ 'wrap': v:false,
        \ 'filter': 'CopenPopupFilter'
    \ })
    call UpdateCopenPopup()
endfunction

function! CopenPopupFilter(id, key)
    if a:key == "\<Esc>"
        call popup_close(a:id)
        return 1
    elseif a:key == "\<CR>" || a:key == "l"
        call popup_close(a:id)
        "echo 'You selected: ' . g:copen_list[g:copen_selected]
        execute 'cc ' . (g:copen_selected + 1)
        return 1
    elseif a:key == "k" || a:key == "\<Up>"
        let g:copen_selected = (g:copen_selected - 1 + len(g:copen_list)) % len(g:copen_list)
    elseif a:key == "j" || a:key == "\<Down>"
        let g:copen_selected = (g:copen_selected + 1) % len(g:copen_list)
    else
        return 0
    endif
    call UpdateCopenPopup()
    return 1
endfunction

function! UpdateCopenPopup()
    if g:copen_popup_id > 0
        let new_content = copy(g:copen_list)
        let new_content[g:copen_selected] = '=>' . new_content[g:copen_selected]
        call popup_settext(g:copen_popup_id, new_content)
    endif
endfunction

command! C call ShowCopenPopup()

