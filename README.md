# cmp-bash-history

A [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) completion source for your bash history.

Each history entry is offered as a whole command line, so completion behaves
like `Ctrl-R` in the shell:

```
git pu█
├─ git push origin master
├─ git push --force-with-lease
└─ git pull --rebase
```

Accepting an item replaces the entire partial command you typed, not just the
last word. Duplicates are removed and the most recent commands rank first.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'kloki/cmp-bash-history',
  dependencies = { 'hrsh7th/nvim-cmp' },
}
```

With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'hrsh7th/nvim-cmp'
Plug 'kloki/cmp-bash-history'
```

## Setup

Enable the source only for shell buffers (recommended):

```lua
local cmp = require('cmp')

cmp.setup.filetype({ 'sh', 'bash' }, {
  sources = cmp.config.sources({
    { name = 'bash_history' },
  }, {
    { name = 'buffer' },
  }),
})
```

Or add it to your global sources:

```lua
cmp.setup({
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'bash_history' },
  }),
})
```

## Options

Pass options via the `option` table of the source entry:

```lua
{
  name = 'bash_history',
  option = {
    histfile = '~/.bash_history',
    max_items = 5000,
  },
}
```

| Option      | Default                             | Description                                          |
| ----------- | ----------------------------------- | ---------------------------------------------------- |
| `histfile`  | `$HISTFILE`, else `~/.bash_history` | History file to read.                                |
| `max_items` | `5000`                              | Maximum number of items returned, most recent first. |

Blank lines and `HISTTIMEFORMAT` timestamp lines (`#1719999999`) are skipped.
The parsed history is cached and only re-read when the file changes.

## License

[MIT](LICENSE)
