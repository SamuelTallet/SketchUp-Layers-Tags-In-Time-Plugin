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
require 'layers_in_time/model_observer'
require 'layers_in_time/layers_observer'
require 'layers_in_time/time_observer'
require 'layers_in_time/layers_editor'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Observes SketchUp events and reacts.
  class AppObserver < Sketchup::AppObserver

    # When user creates a new, empty model:
    def onNewModel(model)

      model.add_observer(ModelObserver.new)
      model.layers.add_observer(LayersObserver.new)
      model.shadow_info.add_observer(TimeObserver.new)

      LayersEditor.reload

      SESSION[:imported_components_definitions_oids] = []

    end

    # When user opens an existing model:
    def onOpenModel(model)

      model.add_observer(ModelObserver.new)
      model.layers.add_observer(LayersObserver.new)
      model.shadow_info.add_observer(TimeObserver.new)

      LayersEditor.reload

      SESSION[:imported_components_definitions_oids] = []

    end

  end

end
