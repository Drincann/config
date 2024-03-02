return {
  py = function()
    local dap = require('dap')
    -- get 'which python' output

    local python_path = '/Users/drincanngao/.pyenv/shims/python'
    dap.adapters.python = function(cb, config)
      -- set justMyCode false
      if config.request == 'attach' then
        ---@diagnostic disable-next-line: undefined-field
        local port = (config.connect or config).port
        ---@diagnostic disable-next-line: undefined-field
        local host = (config.connect or config).host or '127.0.0.1'

        cb({
          type = 'server',
          port = assert(port, '`connect.port` is required for a python `attach` configuration'),
          host = host,
          options = {
            source_filetype = 'python',
          },
        })
      else
        cb({
          type = 'executable',
          command = python_path,
          args = { '-m', 'debugpy.adapter' },
          options = {
            source_filetype = 'python',
          },
        })
      end
    end

    dap.configurations.python = {
      {
        -- The first three options are required by nvim-dap
        type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch',
        name = "Launch file",

        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

        program = "${file}", -- This configuration will launch the current file if used.
        pythonPath = function()
          -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
          -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
          -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
          return python_path
        end,
        justMyCode = false,
      },
    }
  end,
  lua = function()
    local dap = require('dap')
    dap.adapters.lua = {
      type = "executable",
      command = "node",
      args = {
        "/Users/drincanngao/lib/local-lua-debugger-vscode/extension/debugAdapter.js"
      },
      enrich_config = function(config, on_config)
        if not config["extensionPath"] then
          local c = vim.deepcopy(config)
          -- 💀 If this is missing or wrong you'll see
          -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
          c.extensionPath = "/Users/drincanngao/lib/local-lua-debugger-vscode/"
          on_config(c)
        else
          on_config(config)
        end
      end,
    }

    dap.configurations.lua = {
      {
        name = 'Current file (local-lua-dbg, lua)',
        type = 'lua',
        request = 'launch',
        cwd = '${workspaceFolder}',
        program = {
          lua = 'lua',
          file = '${file}',
        },
        args = {},
      },
    }
  end
}
