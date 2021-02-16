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
require 'json'
require 'layers_in_time/time_layers'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Observes SketchUp model events and reacts.
  class ModelObserver < Sketchup::ModelObserver

    # When a component is placed into the model:
    def onPlaceComponent(component)

      time_layers_to_import = component.definition.get_attribute('LayersInTime', 'timeLayers')
      
      # If this component contains time data and...
      if !time_layers_to_import.nil? &&
        # we see it for very first time:
        !SESSION[:imported_components_definitions_oids].include?(
          component.definition.object_id
        )

        # Memorize processing of this component.
        SESSION[:imported_components_definitions_oids].push(component.definition.object_id)

        import_time_layers = UI.messagebox(
          TRANSLATE[
            Sketchup.version.to_i >= 20 ?
            'Import time tags associated to this component?' :
            'Import time layers associated to this component?'
          ],
          MB_OKCANCEL
        )

        if import_time_layers == IDOK

          # Note: SketchUp already imports native layers for sub-components.
          layer_to_import = component.definition.get_attribute('LayersInTime', 'layer')

          if !layer_to_import.nil?
            component.layer = Sketchup.active_model.layers.add(layer_to_import)
          end

          TimeLayers.from_json(time_layers_to_import)

        end

      end

    end

    # When user is saving a component instance:
    def onBeforeComponentSaveAs(component)

      time_layers_to_export = TimeLayers.associated_to_component(component)

      if time_layers_to_export.length >= 1

        component.definition.set_attribute('LayersInTime', 'layer', component.layer.name)
        component.definition.set_attribute(
          'LayersInTime', 'timeLayers', JSON.generate(time_layers_to_export)
        )

      end

    end

    # When user has saved a component instance:
    def onAfterComponentSaveAs(component)

      time_layers_to_export = TimeLayers.associated_to_component(component)

      if time_layers_to_export.length >= 1

        component.definition.delete_attribute('LayersInTime', 'layer')
        component.definition.delete_attribute('LayersInTime', 'timeLayers')

      end

    end

  end

end
