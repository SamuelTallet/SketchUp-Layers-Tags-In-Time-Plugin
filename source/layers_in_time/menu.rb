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
require 'layers_in_time/layers_editor'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Connects Layers/Tags In Time plugin menu to SketchUp user interface.
  module Menu

    # Adds menu.
    def self.add

      plugins_menu = UI.menu('Plugins')

      layers_in_time_menu = plugins_menu.add_submenu(NAME)

      layers_in_time_menu.add_item(
        TRANSLATE[Sketchup.version.to_i >= 20 ? 'Open Tags Editor' : 'Open Layers Editor']
      ) { LayersEditor.safe_open }

      layers_in_time_menu.add_item(
        TRANSLATE['Export to a JSON file']
      ) { TimeLayers.to_json_file }

      layers_in_time_menu.add_item(
        TRANSLATE['Import from a JSON file']
      ) { TimeLayers.from_json_file }

    end

  end

end
