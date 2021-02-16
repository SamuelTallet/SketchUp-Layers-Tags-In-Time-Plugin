# Layers/Tags In Time extension for SketchUp.
# Copyright: © 2021 Samuel Tallet <samuel.tallet arobase gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3.0 of the License, or
# (at your option) any later version.
# 
# If you release a modified version of this program TO THE PUBLIC,
# the GPL requires you to MAKE THE MODIFIED SOURCE CODE AVAILABLE
# to the program's users, UNDER THE GPL.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# Get a copy of the GPL here: https://www.gnu.org/licenses/gpl.html

require 'sketchup'
require 'fileutils'
require 'layers_in_time/layers_editor'
require 'layers_in_time/time_layers'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Connects Layers/Tags In Time plugin toolbar to SketchUp user interface.
  module Toolbar

    # Absolute path to "Toolbar Icons" directory.
    ICONS_DIR = File.join(__dir__, 'Toolbar Icons')

    private_constant :ICONS_DIR

    # Gets toolbar icon extension depending on platform.
    #
    # @return [String]
    def self.icon_extension
      Sketchup.platform == :platform_osx ? '.pdf' : '.svg'
    end

    # Adds toolbar.
    def self.add

      toolbar = UI::Toolbar.new(NAME)

      command_1 = UI::Command.new('edit') { LayersEditor.safe_open }

      command_1.small_icon = File.join(ICONS_DIR, 'edit' + icon_extension)
      command_1.large_icon = File.join(ICONS_DIR, 'edit' + icon_extension)
      command_1.tooltip = TRANSLATE[
        Sketchup.version.to_i >= 20 ? 'Open Tags Editor' : 'Open Layers Editor'
      ]

      toolbar.add_item(command_1)

      command_2 = UI::Command.new('play-anim') { TimeLayers.animate }

      command_2.small_icon = File.join(ICONS_DIR, 'play-anim' + icon_extension)
      command_2.large_icon = File.join(ICONS_DIR, 'play-anim' + icon_extension)
      command_2.tooltip = TRANSLATE['Play animation']

      toolbar.add_item(command_2)

      command_3 = UI::Command.new('export-anim') do
        TimeLayers.animate(export_animation = true)
      end

      command_3.small_icon = File.join(ICONS_DIR, 'export-anim' + icon_extension)
      command_3.large_icon = File.join(ICONS_DIR, 'export-anim' + icon_extension)
      command_3.tooltip = TRANSLATE['Export to an animation...']
      
      toolbar.add_item(command_3)

      toolbar.show

    end

  end

end
