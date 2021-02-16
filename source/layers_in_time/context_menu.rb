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

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Connects Layers/Tags In Time plugin context menu to SketchUp user interface.
  module ContextMenu

    # Adds context menu.
    def self.add

      # This code is based on DanRathbun's snippet.
      # See: https://forums.sketchup.com/t/changing-an-objects-layer/72771
      UI.add_context_menu_handler do |context_menu|

        model = Sketchup.active_model

        if !model.selection.empty?

          context_menu_submenu = context_menu.add_submenu(
            TRANSLATE[Sketchup.version.to_i >= 20 ? 'Tag as' : 'Assign to layer'],
            0 # position
          )
          context_menu.add_separator

          context_menu_submenu.add_item(
            TRANSLATE[Sketchup.version.to_i >= 20 ? 'New tag...' : 'New layer...']
          ) do

            new_native_layer_name = UI.inputbox(
              [
                TRANSLATE[
                  Sketchup.version.to_i >= 20 ? 'Enter a tag name' : 'Enter a layer name'
                ] + ' '
              ], # prompts
              [''], # defaults
              NAME # title
            )

            if new_native_layer_name.is_a?(Array) && !new_native_layer_name[0].empty?

              model.layers.add(new_native_layer_name[0])

              model.selection.each do |entity|

                entity.layer = new_native_layer_name[0]\
                  if entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)

              end

            end

          end

          context_menu_submenu.add_item(
            Sketchup.version.to_i >= 20 ? model.layers['Layer0'].display_name : 'Layer0'
          ) do

            model.selection.each do |entity|
              entity.layer = 'Layer0' if entity.is_a?(Sketchup::Drawingelement)
            end

          end

          native_layers_names = model.layers.map(&:name).sort

          native_layers_names.each do |native_layer_name|

            next if native_layer_name == 'Layer0'

            context_menu_submenu.add_item(native_layer_name) do

              model.selection.each do |entity|

                entity.layer = native_layer_name\
                  if entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)
                  
              end

            end

          end

        end

      end

    end

  end

end
