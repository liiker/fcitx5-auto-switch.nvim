# fcitx5-auto-switch

本插件主要用于在`Linux` 平台上根据输入内容自动切换输入法（目前只支持 `fcitx5`）

## :sparkles: 特性
`fcitx5-auto-switch` 会根据光标当前所在位置自动判断是否需要切换到中文输入法状态，如果光标所在位置以及光标所在位置前后存在中文则自动切换至中文输入状态，反之则使用英文输入。

> 注：从插入模式进入一般模式后会自动切换为英文输入法

## :lock: 依赖

- 目前只支持 `Linux` 操作系统
- 目前只支持 `fcitx5` 输入法框架
- 输入法切换依赖 `fcitx5-remote` 请确认可以正常调用

## :package: 安装

### Lazy

``` lua
{
  "liiker/fcitx5-auto-switch.nvim",
  config = function()
    require('fcitx5-auto-switch').setup()
  end,
  enabled = function()
    return vim.fn.executable('fcitx5-remote') == 1
  end
}
```

