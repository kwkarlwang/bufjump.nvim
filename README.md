# bufjump.nvim

https://user-images.githubusercontent.com/38927155/132891665-88f70573-c1d8-462d-8a76-9786ba115f7d.mov

Have you ever had to temporarily go to another file, perhaps previewing some changes with lsp go to refrenece, fiddle a bit, and have to jump back to the main file that you were working with? Instead of aimlessly smashing `CTRL-o` and `CTRL-i`, bufjump.nvim allows you to jump to previous or next buffer in the vim native jumplist with one single command.


## Prerequistes

- Neovim 0.5 or higher

## Installing

with [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'kwkarlwang/bufjump.nvim'
```

with [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "kwkarlwang/bufjump.nvim",
    config = function
        require("bufjump").setup()
    end
}
```

## Configuration

bufjump.nvim provides two options, `forward` and `backward` which are the keymappings to jump to the next and previous buffer in the jumplist respectively. The default keymappings for `forward` and `backward` are `CTRL-n` and `CTRL-p` respectively.

Default configuration:

```lua
use({
    "kwkarlwang/bufjump.nvim",
    config = function()
        require("bufjump").setup({
            forward = "<C-n>",
            backward = "<C-p>",
        })
    end,
})

```

## How it works

This command uses native `CTRL-o` and `CTRL-i` to jump until the buffer is different from the current buffer. If there are no previous or next buffer, then the command does not jump at all.

When jumping to the previous buffer, it will jump to the last occurance in the jumplist that is different from the current buffer. Below is a simple illustration of the before and after position in the jumplist stack.

### Before

```
Buffer 1    line 1
Buffer 1    line 2
Buffer 1    line 3
Buffer 2    line 10
Buffer 2    line 20     <--
Buffer 2    line 30
```

### After

```
Buffer 1    line 1
Buffer 1    line 2
Buffer 1    line 3      <--
Buffer 2    line 10
Buffer 2    line 20
Buffer 2    line 30
```

When jumping to the next buffer, it will jump to the last occurance in the jumplist that is different from the current buffer. Below is a simple illustration of the before and after position in the jumplist stack.

### Before

```
Buffer 1    line 1      <--
Buffer 1    line 2
Buffer 1    line 3
Buffer 2    line 10
Buffer 2    line 20
Buffer 2    line 30
```

### After

```
Buffer 1    line 1
Buffer 1    line 2
Buffer 1    line 3
Buffer 2    line 10
Buffer 2    line 20
Buffer 2    line 30     <--
```
