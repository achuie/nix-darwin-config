local wezterm = require 'wezterm'
local io = require 'io'
local os = require 'os'
local wact = wezterm.action

wezterm.on('augment-command-palette', function(window, pane)
  return {
    {
      brief = 'Rename tab',
      icon = 'md_rename_box',
      action = wact.PromptInputLine {
        description = 'Enter new name for active tab',
        action = wezterm.action_callback(function(awindow, apane, line)
          if line then
            awindow:active_tab():set_title(line)
          end
        end),
      },
    },
    {
      brief = 'Rename workspace',
      icon = 'md_rename_box',
      action = wact.PromptInputLine {
        description = 'Enter new name for active workspace',
        action = wezterm.action_callback(function(bwindow, bpane, line)
          if line then
            wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
          end
        end),
      },
    },
    {
      brief = 'Toggle tmux compatibility mode',
      icon = 'fa_toggle_on',
      action = wact.EmitEvent 'toggle-tmux-compatibility',
    },
  }
end)

wezterm.on('toggle-tmux-compatibility', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local dirKeys = { 'h', 'j', 'k', 'l' }
  local dirNames = { 'Left', 'Down', 'Up', 'Right' }

  if not overrides.leader then
    overrides.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 2000 }
    overrides.keys = { { key = 'a', mods = 'LEADER|CTRL', action = wact.SendKey { key = 'a', mods = 'CTRL' } } }
    for i = 1, #dirKeys do
      -- table.insert(overrides.keys, { key = dirKeys[i], mods = 'ALT', action = wact.SendKey { key = dirKeys[i], mods = 'ALT' } })
      table.insert(overrides.keys, { key = dirKeys[i], mods = 'ALT', action = wact.ActivatePaneDirection(dirNames[i]) })
    end
  else
    overrides.leader = nil
    overrides.keys = nil
  end
  window:set_config_overrides(overrides)
end)

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local zoomed = ''
  if tab.active_pane.is_zoomed then
    zoomed = '[Z] '
  end

  local index = ''
  if #tabs > 1 then
    index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
  end

  local tmux_compat = ''
  if config.leader.mods ~= 'SHIFT|CTRL' then
    tmux_compat = '[W] '
  end

  return zoomed .. tmux_compat .. index .. tab.active_pane.title
end)

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace())
end)

wezterm.on('toggle-ligature', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.harfbuzz_features then
    overrides.harfbuzz_features = { 'aalt=0', 'calt=0', 'clig=0', 'liga=0' }
  else
    overrides.harfbuzz_features = nil
  end
  window:set_config_overrides(overrides)
end)

wezterm.on('edit-scrollback', function(window, pane)
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)

  local filename = os.tmpname()
  local f = io.open(filename, 'w+')
  if f == nil then
    wezterm.log_error('Failed to create temp file for scrollback editing')
    return
  end
  f:write(text)
  f:flush()
  f:close()

  window:perform_action(wact.SpawnCommandInNewWindow { args = { 'nvim', filename } }, pane)
  -- Wait "enough" time for nvim to read the file before removing it
  wezterm.sleep_ms(2000)
  os.remove(filename)
end)

local config = {
  scrollback_lines = 10000,
  audible_bell = "Disabled",
  use_ime = false,
  alternate_buffer_wheel_scroll_speed = 1,
  adjust_window_size_when_changing_font_size = false,

  quick_select_patterns = {
    -- Git-status file paths
    '(?<=\\s{8}|\\s{8}modified:\\s{3})/*[0-9A-Za-z.+_/-]+',
    -- Git branch names in ()
    '\\(([0-9A-Za-z.+_/-]+)\\)',
  },

  font = wezterm.font_with_fallback {
    -- 'Fira Code Custom',
    'Iosevka Whiteletter Extended',
    'Rec Mono Custom',
    'Font Awesome 6 Free',
  },
  font_size = 12,
  font_rules = {
    {
      intensity = 'Bold',
      font = wezterm.font('Iosevka Whiteletter XBd Ex'),
    },
    {
      italic = true,
      intensity = 'Bold',
      font = wezterm.font('Iosevka Whiteletter XBd Ex', { italic = true }),
    },
  },

  window_background_opacity = 0.9,
  macos_window_background_blur = 20,
  window_decorations = "TITLE | RESIZE | MACOS_FORCE_ENABLE_SHADOW",

  color_scheme = 'tokyo-night-storm',
  -- color_scheme = 'root-beer-float',
  color_schemes = {
    ['tokyo-night-storm'] = {
      foreground = '#d3d7eb',
      background = '#24283b',
      cursor_fg = '#24283b',
      cursor_bg = '#ffe8d5',
      cursor_border = '#ffe8d5',
      selection_bg = '#2d4370',
      ansi = {
        '#32344a',
        '#ea4e6b',
        '#9ece6a',
        '#ff9e64',
        '#7aa2f7',
        '#ad8ee6',
        '#75c1ee',
        '#b6b9cc',
      },
      brights = {
        '#444b6a',
        '#ff4266',
        '#ace173',
        '#e0af68',
        '#9abaff',
        '#bb9af7',
        '#7dcfff',
        '#cbcff5',
      },
    },
    ['root-beer-float'] = {
      foreground = "#f5e8e5",
      background = "#331b17",
      cursor_bg = "#e3bcb5",
      cursor_border = "#fbf5f4",
      cursor_fg = "#331b17",
      selection_bg = "#f5e8e5",
      selection_fg = "#331b17",
      ansi = {
        "#522f29",
        "#f9aac1",
        "#b7d348",
        "#f7b37c",
        "#8eccf8",
        "#cdb6f9",
        "#4fdec7",
        "#e3bcb5"
      },
      brights = {
        "#915a50",
        "#fbcbd9",
        "#cde967",
        "#fbd1af",
        "#bae0fb",
        "#e0d2fb",
        "#76f4dd",
        "#fbf5f4"
      },
    }
  },

  -- Default: saturation = 0.9, brightness = 0.8
  inactive_pane_hsb = { saturation = 0.9, brightness = 0.6 },

  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,

  unix_domains = { { name = 'unix' } },

  -- Override default table to confirm for everything besides shells I use
  skip_close_confirmation_for_processes_named = { 'zsh', 'bash' },

  leader = { key = 'A', mods = 'CTRL|SHIFT', timeout_milliseconds = 2000 },
  keys = {
    { key = 'e',     mods = 'CTRL|SHIFT',        action = wact.EmitEvent 'toggle-ligature' },
    { key = 'y',     mods = 'CTRL|SHIFT',        action = wact.EmitEvent 'edit-scrollback' },

    -- Send literal leader when pressed twice
    { key = 'A',     mods = 'LEADER|CTRL|SHIFT', action = wact.SendKey { key = 'A', mods = 'CTRL|SHIFT' } },
    -- Spawn new terminal with the same working directory
    { key = 'Enter', mods = 'SHIFT|CTRL',  action = wact.SpawnWindow, },

    -- Split panes
    { key = 'v',     mods = 'LEADER',      action = wact.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'b',     mods = 'LEADER',      action = wact.SplitHorizontal { domain = 'CurrentPaneDomain' } },

    { key = 'z',     mods = 'LEADER',      action = wact.TogglePaneZoomState },
    { key = 'o',     mods = 'LEADER|CTRL', action = wact.RotatePanes('Clockwise') },
    { key = 'x',     mods = 'LEADER',      action = wact.CloseCurrentPane { confirm = true } },

    -- Tab actions
    { key = 'c',     mods = 'LEADER',      action = wact.SpawnTab('CurrentPaneDomain') },
    { key = 'h',     mods = 'LEADER|CTRL', action = wact.ActivateTabRelative(-1) },
    { key = 'l',     mods = 'LEADER|CTRL', action = wact.ActivateTabRelative(1) },

    {
      key = '[',
      mods = 'LEADER',
      action = wact.Multiple { wact.ActivateCopyMode, wact.CopyMode('ClearSelectionMode') }
    },
    { key = ']',     mods = 'LEADER',      action = wact.PasteFrom('PrimarySelection') },

    -- Workspaces
    { key = 's',     mods = 'LEADER',  action = wact.ShowLauncherArgs { flags = 'WORKSPACES' } },
  },

  key_tables = {
    copy_mode = {
      { key = 'q',      mods = 'NONE',       action = wact.CopyMode('Close') },
      { key = 'Escape', mods = 'NONE',       action = wact.CopyMode('ClearSelectionMode') },

      -- Movement
      { key = 'w', mods = 'NONE',       action = wact.CopyMode('MoveForwardWord') },
      { key = 'b', mods = 'NONE',       action = wact.CopyMode('MoveBackwardWord') },
      { key = 'e', mods = 'NONE',       action = wact.CopyMode('MoveForwardWordEnd') },
      { key = '0', mods = 'NONE',       action = wact.CopyMode('MoveToStartOfLine') },
      { key = '^', mods = 'SHIFT',      action = wact.CopyMode('MoveToStartOfLineContent') },
      { key = '$', mods = 'SHIFT',      action = wact.CopyMode('MoveToEndOfLineContent') },
      { key = 'g', mods = 'NONE',       action = wact.CopyMode('MoveToScrollbackTop') },
      { key = 'g', mods = 'SHIFT',      action = wact.CopyMode('MoveToScrollbackBottom') },
      { key = 'h', mods = 'SHIFT',      action = wact.CopyMode('MoveToViewportTop') },
      { key = 'l', mods = 'SHIFT',      action = wact.CopyMode('MoveToViewportBottom') },

      -- Page movement
      { key = 'b', mods = 'CTRL',       action = wact.CopyMode('PageUp') },
      { key = 'f', mods = 'CTRL',       action = wact.CopyMode('PageDown') },

      -- Selection
      { key = 'v', mods = 'NONE',       action = wact.CopyMode { SetSelectionMode = 'Cell' } },
      { key = 'v', mods = 'SHIFT',      action = wact.CopyMode { SetSelectionMode = 'Line' } },
      { key = 'v', mods = 'CTRL',       action = wact.CopyMode { SetSelectionMode = 'Block' } },
      { key = 'o', mods = 'NONE',       action = wact.CopyMode('MoveToSelectionOtherEnd') },

      -- Copy selection
      { key = 'y', mods = 'NONE',       action = wact.CopyTo('Clipboard') },
      { key = 'y', mods = 'SHIFT',      action = wact.CopyTo('PrimarySelection') },

      -- Search
      { key = '/', mods = 'NONE',       action = wact.Search { CaseInSensitiveString = '' } },
      { key = '?', mods = 'SHIFT',      action = wact.Search('CurrentSelectionOrEmptyString') },
      { key = 'f', mods = 'CTRL|SHIFT', action = wact.Search { Regex = '' } },

      -- Naviagte search matches
      {
        key = 'n',
        mods = 'NONE',
        action = wact.Multiple { wact.CopyMode('NextMatch'), wact.CopyMode('ClearSelectionMode') }
      },
      {
        key = 'n',
        mods = 'SHIFT',
        action = wact.Multiple { wact.CopyMode('PriorMatch'), wact.CopyMode('ClearSelectionMode') }
      },
      { key = 'l', mods = 'CTRL', action = wact.CopyMode('ClearPattern') },
    },
    search_mode = {
      { key = 'Escape', mods = 'NONE', action = wact.ActivateCopyMode },
      {
        key = 'Enter',
        mods = 'NONE',
        action = wact.Multiple {
          wact.CopyMode('AcceptPattern'),
          wact.ActivateCopyMode, wact.CopyMode('ClearSelectionMode')
        }
      },
      { key = 'r', mods = 'CTRL', action = wact.CopyMode('CycleMatchType') },
    },
  },

  mouse_bindings = {
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wact.CompleteSelectionOrOpenLinkAtMouseCursor("PrimarySelection"),
    },
  },
}

-- Bindings for vim directions
local dirKeys = { 'h', 'j', 'k', 'l' }
local dirNames = { 'Left', 'Down', 'Up', 'Right' }
local dirArrows = { 'LeftArrow', 'DownArrow', 'UpArrow', 'RightArrow' }
for i = 1, #dirKeys do
  -- Move focus
  table.insert(config.keys, { key = dirKeys[i], mods = 'LEADER', action = wact.ActivatePaneDirection(dirNames[i]) })
  -- table.insert(config.keys, { key = dirKeys[i], mods = 'ALT', action = wact.ActivatePaneDirection(dirNames[i]) })
  -- Resize pane
  table.insert(config.keys,
    { key = dirArrows[i], mods = 'LEADER|CTRL', action = wact.AdjustPaneSize { dirNames[i], 5 } })

  -- Copy mode directions
  table.insert(config.key_tables.copy_mode,
    { key = dirKeys[i], mods = 'NONE', action = wact.CopyMode('Move' .. dirNames[i]) })
  table.insert(config.key_tables.copy_mode,
    { key = dirArrows[i], mods = 'NONE', action = wact.CopyMode('Move' .. dirNames[i]) })
end

-- Bindings to activate tabs 1--9
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = wact.ActivateTab(i - 1),
  })
end

return config
