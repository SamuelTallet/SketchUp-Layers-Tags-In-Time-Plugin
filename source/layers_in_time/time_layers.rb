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
require 'time'
require 'layers_in_time/layer'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Native SketchUp layers overloaded with time data.
  module TimeLayers

    # Display or hide time layers depending on a time.
    def self.display_or_hide(time)

      raise ArgumentError, 'Time must be a Time.'\
        unless time.is_a?(Time)

      Sketchup.active_model.layers.each do |native_layer|

        layer = Layer.new(native_layer)

        # In this module, we care only about time layers.
        next unless layer.time_layer?

        layer.native.visible = layer.match_date?(time) || layer.match_hour?(time)

      end

    end

  end

end
