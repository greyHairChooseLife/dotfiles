## 유용한 아이콘

```txt
#좌측
▏ ▎ ▍ ▌ ▋ ▊ ▉ █

#우측
▕

#중앙
┃│┆

#상하
▔ ▁

#명도
░ ▒ ▓

#특수
▖ ▗ ▘ ▙ ▚ ▛ ▜ ▝ ▞ ▟
```


## 짤막 커맨드


- 현재 윈도우의 highlight 알아내기
  `lua print(vim.inspect(vim.api.nvim_get_hl(0, { name = "FoldColumn" })))`
