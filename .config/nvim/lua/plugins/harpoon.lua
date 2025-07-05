return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  keys = {
    {
      '<leader>a',
      function()
        require('harpoon'):list():add()
      end,
      desc = 'Add file to harpoon',
    },
    {
      '<leader>e',
      function()
        local harpoon = require 'harpoon'
        local conf = require('telescope.config').values
        local function toggle_telescope(harpoon_files)
          local file_paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
          end
          require('telescope.pickers')
            .new({}, {
              prompt_title = 'Harpoon',
              finder = require('telescope.finders').new_table {
                results = file_paths,
              },
              previewer = conf.file_previewer {},
              sorter = conf.generic_sorter {},
            })
            :find()
        end
        toggle_telescope(harpoon:list())
      end,
      desc = 'Open harpoon telescope menu',
    },
    {
      '<leader>1',
      function()
        require('harpoon'):list():select(1)
      end,
      desc = 'Harpoon file 1',
    },
    {
      '<leader>2',
      function()
        require('harpoon'):list():select(2)
      end,
      desc = 'Harpoon file 2',
    },
    {
      '<leader>3',
      function()
        require('harpoon'):list():select(3)
      end,
      desc = 'Harpoon file 3',
    },
    {
      '<leader>4',
      function()
        require('harpoon'):list():select(4)
      end,
      desc = 'Harpoon file 4',
    },
    {
      '<C-S-P>',
      function()
        require('harpoon'):list():prev()
      end,
      desc = 'Previous harpoon file',
    },
    {
      '<C-S-N>',
      function()
        require('harpoon'):list():next()
      end,
      desc = 'Next harpoon file',
    },
  },
  config = function()
    require('harpoon'):setup()
    -- NOTE: telescope extension will be loaded when telescope loads
    require('telescope').load_extension 'harpoon'
  end,
}
