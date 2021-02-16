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
require 'layers_in_time/app_observer'
require 'layers_in_time/model_observer'
require 'layers_in_time/layers_observer'
require 'layers_in_time/time_observer'
require 'layers_in_time/menu'
require 'layers_in_time/toolbar'
require 'layers_in_time/context_menu'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  Sketchup.add_observer(AppObserver.new)
  Sketchup.active_model.add_observer(ModelObserver.new)
  Sketchup.active_model.layers.add_observer(LayersObserver.new)
  Sketchup.active_model.shadow_info.add_observer(TimeObserver.new)

  Menu.add
  Toolbar.add
  ContextMenu.add

  # Load complete.

end
