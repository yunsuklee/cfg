-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  keys = {
    -- Visual Studio style debugging keymaps
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F6>',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug: Stop',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: Toggle UI',
    },
    {
      '<F8>',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Conditional Breakpoint',
    },
    {
      '<F9>',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<F10>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F11>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>bc',
      function()
        require('dap').clear_breakpoints()
      end,
      desc = 'Debug: Clear All Breakpoints',
    },
    {
      '<leader>dw',
      function()
        local expr = vim.fn.input 'Watch expression: '
        if expr ~= '' then
          require('dapui').elements.watches.add(expr)
        end
      end,
      desc = 'Debug: Add to watches',
    },
    {
      '<leader>de',
      function()
        require('dapui').eval(nil, { enter = true })
      end,
      desc = 'Debug: Evaluate expression',
    },
    {
      '<leader>dh',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'Debug: Hover variable',
    },
    {
      '<leader>da',
      function()
        local dap = require('dap')
        if not dap.session() then
          print('No active debug session')
          return
        end
        
        -- Create or reuse disassembly buffer
        local buf_name = 'DAP Disassembly'
        local existing_buf = nil
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_get_name(buf):match(buf_name) then
            existing_buf = buf
            break
          end
        end
        
        local buf = existing_buf or vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, buf_name)
        vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(buf, 'filetype', 'asm')
        
        -- Open in vertical split
        vim.cmd('vsplit')
        vim.api.nvim_win_set_buf(0, buf)
        
        -- Get disassembly using evaluate request
        local session = dap.session()
        if session then
          session:evaluate('-exec disas', function(err, response)
            if err then
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, {'Error getting disassembly: ' .. tostring(err)})
            elseif response and response.result then
              local lines = vim.split(response.result, '\n')
              vim.api.nvim_buf_set_option(buf, 'modifiable', true)
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
              vim.api.nvim_buf_set_option(buf, 'modifiable', false)
            else
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, {'No disassembly available'})
            end
          end)
        end
      end,
      desc = 'Debug: Show disassembly view',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'netcoredbg',
        'codelldb', -- C/C++/Rust debugger
        'cpptools', -- C/C++ debugger (alternative)
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.3 },
            { id = 'watches', size = 0.3 },
            { id = 'breakpoints', size = 0.2 },
            { id = 'stacks', size = 0.2 },
          },
          size = 80,
          position = 'left',
        },
        {
          elements = {
            'repl',
            'console',
          },
          size = 0.25,
          position = 'bottom',
        },
      },
    }

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Update disassembly view on stepping
    dap.listeners.after.event_stopped['disasm_update'] = function()
      -- Find disassembly buffer
      local disasm_buf = nil
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):match('DAP Disassembly') then
          disasm_buf = buf
          break
        end
      end
      
      if disasm_buf and vim.api.nvim_buf_is_loaded(disasm_buf) then
        local session = dap.session()
        if session then
          -- Get current instruction pointer and disassembly
          session:evaluate('-exec disas', function(err, response)
            if response and response.result then
              local lines = vim.split(response.result, '\n')
              vim.api.nvim_buf_set_option(disasm_buf, 'modifiable', true)
              vim.api.nvim_buf_set_lines(disasm_buf, 0, -1, false, lines)
              vim.api.nvim_buf_set_option(disasm_buf, 'modifiable', false)
              
              -- Find and highlight current instruction (marked with =>)
              for i, line in ipairs(lines) do
                if line:match('=>') then
                  -- Find window displaying the disassembly buffer
                  for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_get_buf(win) == disasm_buf then
                      vim.api.nvim_win_set_cursor(win, {i, 0})
                      break
                    end
                  end
                  break
                end
              end
            end
          end)
        end
      end
    end

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- Configure C# debugging with netcoredbg
    dap.adapters.netcoredbg = {
      type = 'executable',
      command = vim.fn.stdpath 'data' .. '/mason/bin/netcoredbg',
      args = { '--interpreter=vscode' },
    }

    dap.configurations.cs = {
      {
        type = 'netcoredbg',
        name = 'Launch - netcoredbg',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/net9.0/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
        console = 'integratedTerminal',
      },
      {
        type = 'netcoredbg',
        name = 'Attach to process - netcoredbg',
        request = 'attach',
        processId = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
      },
    }

    -- Configure C/C++ debugging with cpptools (Microsoft's debugger)
    dap.adapters.cppdbg = {
      id = 'cppdbg',
      type = 'executable',
      command = vim.fn.stdpath 'data' .. '/mason/bin/OpenDebugAD7',
    }

    -- Keep codelldb as backup option
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
        args = { '--port', '${port}' },
      },
    }

    dap.configurations.c = {
      {
        name = 'Launch with cpptools',
        type = 'cppdbg',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
        setupCommands = {
          {
            text = '-enable-pretty-printing',
            description = 'enable pretty printing',
            ignoreFailures = false,
          },
        },
      },
      {
        name = 'Launch with codelldb (backup)',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    dap.configurations.cpp = dap.configurations.c

    -- Configure Rust debugging with codelldb
    dap.configurations.rust = {
      {
        name = 'Launch file',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
      {
        name = 'Launch current package',
        type = 'codelldb',
        request = 'launch',
        program = function()
          local handle = io.popen 'cargo metadata --no-deps --format-version 1 | jq -r ".packages[0].name"'
          local package_name = handle:read('*a'):gsub('\n', '')
          handle:close()
          return vim.fn.getcwd() .. '/target/debug/' .. package_name
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        preLaunchTask = 'cargo build',
      },
    }
  end,
}
