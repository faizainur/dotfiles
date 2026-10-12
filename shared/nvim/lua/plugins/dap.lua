-- Debugging: nvim-dap stack ported from the repo's debugger.lua
-- NOTE: the pwa-node adapter expects ~/.config/vscode-js-debug/js-debug/src/dapDebugServer.js
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "suketa/nvim-dap-ruby",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dapgo = require("dap-go")
      -- local daprb = require("dap-ruby")

      -- Setup dependencies
      dapui.setup()
      dapgo.setup()
      -- daprb.setup()

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { vim.fn.expand("~/.config/vscode-js-debug/js-debug/src/dapDebugServer.js"), "${port}" },
        },
      }

      dap.configurations.javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
      }

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "Error", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "WarningMsg", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "❌", texthl = "ErrorMsg", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "📘", texthl = "Comment", linehl = "", numhl = "" })

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debugger : Start/Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debugger : Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debugger : Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debugger : Step Out" })
      vim.keymap.set("n", "<Leader>bt", dap.toggle_breakpoint, { desc = "Debugger : Toggle Breakpoint" })
      vim.keymap.set("n", "<Leader>B", dap.set_breakpoint, { desc = "Debugger : Set Breakpoint" })
      vim.keymap.set("n", "<Leader>dr", dap.repl.open, { desc = "Debugger : Open REPL" })
      vim.keymap.set("n", "<Leader>dl", dap.run_last, { desc = "Debugger : Run Last" })
      vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
        require("dap.ui.widgets").hover()
      end)
      vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
        require("dap.ui.widgets").preview()
      end)
      vim.keymap.set("n", "<Leader>df", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.frames)
      end)
      vim.keymap.set("n", "<Leader>ds", function()
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(widgets.scopes)
      end)

      vim.keymap.set("n", "<Leader>de", dapui.eval, { desc = "Debugger : Evaluate Expression" })

      -- Go Specific
      vim.keymap.set("n", "<Leader>dgt", dapgo.debug_test, { desc = "Debugger : Debug Test" })
    end,
  },
}
