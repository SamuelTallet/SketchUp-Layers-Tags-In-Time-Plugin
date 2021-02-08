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
require 'fileutils'
require 'json'
require 'layers_in_time/layer'
require 'layers_in_time/layers_editor'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Native SketchUp layers overloaded with time data.
  module TimeLayers

    # Gets count of time layers.
    #
    # @return [Integer]
    def self.count

      time_layers_count = 0

      Sketchup.active_model.layers.each do |native_layer|
        time_layers_count = time_layers_count + 1 if Layer.new(native_layer).time_layer?
      end

      time_layers_count

    end

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

    # Are there time layers associated to component?
    #
    # @param [Sketchup::ComponentInstance] component
    # @raise [ArgumentError]
    #
    # @return [Boolean]
    def self.associated_to_component?(component)

      raise ArgumentError, 'Component must be a Sketchup::ComponentInstance.'\
        unless component.is_a?(Sketchup::ComponentInstance)

      native_layers = Sketchup.active_model.layers

      return true if Layer.new(native_layers[component.layer.name]).time_layer?

      # Traverse component tree.
      component.definition.entities.grep(Sketchup::ComponentInstance).each do |sub_component|
        return true if Layer.new(native_layers[sub_component.layer.name]).time_layer?
      end

      false

    end

    # Exports time layers to JSON.
    #
    # @param [Boolean] pretty Prettify generated JSON?
    # @raise [ArgumentError]
    #
    # @return [String] JSON.
    def self.to_json(pretty = false)

      raise ArgumentError, 'Pretty must be a Boolean.'\
        unless pretty == true || pretty == false

      time_layers = {}

      Sketchup.active_model.layers.each do |native_layer|

        layer = Layer.new(native_layer)

        next unless layer.time_layer?

        time_layers[layer.native.name] = {}

        time_layers[layer.native.name][:dates] = layer.dates if layer.dates_layer?
        time_layers[layer.native.name][:hours] = layer.hours if layer.hours_layer?

      end

      if pretty
        JSON.pretty_generate(time_layers)
      else
        JSON.generate(time_layers)
      end

    end

    # Exports time layers to a JSON file.
    def self.to_json_file

      return UI.messagebox(
        TRANSLATE[
          Sketchup.version.to_i >= 20 ?
          'No time tag found. Export aborted.' :
          'No time layer found. Export aborted.'
        ]
      ) if count == 0

      if !Sketchup.active_model.path.empty?
        json_basename = File.basename(Sketchup.active_model.path).sub('.skp', '.json')
      else
        json_basename = TRANSLATE['Untitled model'] + '.json'
      end

      json_path = UI.savepanel(
        TRANSLATE['Export to a JSON file'] + ' - ' + NAME, # title
        nil, # directory
        json_basename
      )

      # Exit if user cancelled export...
      return if json_path.nil?

      File.write(json_path, to_json(pretty = true))

      UI.messagebox(
        TRANSLATE[
          Sketchup.version.to_i >= 20 ?
          'Time tags successfully exported here:' :
          'Time layers successfully exported here:'
        ] + ' ' + json_path
      )

    end

    # Imports time layers from JSON.
    #
    # @param [String] json
    # @raise [ArgumentError]
    #
    # @return [Integer] Count of imported time layers.
    def self.from_json(json)

      raise ArgumentError, 'JSON must be a String.'\
        unless json.is_a?(String)

      native_layers = Sketchup.active_model.layers

      importing_time_layers = JSON.parse(json)

      importing_time_layers.each do |importing_time_layer_name, importing_layer_time_data|

        layer = Layer.new(
          # Note: If you give the name of a Layer that is already defined,
          # it will return the existing Layer rather than adding a new one.
          native_layers.add(importing_time_layer_name)
        )

        # TODO: Manage conflicts instead of ignore them?
        
        if importing_layer_time_data.key?('dates')

          layer.dates = importing_layer_time_data['dates']
          layer.hours = ''

        end

        if importing_layer_time_data.key?('hours')

          layer.dates = ''
          layer.hours = importing_layer_time_data['hours']
          
        end
        
      end

      LayersEditor.reload if !importing_time_layers.empty?

      importing_time_layers.length

    end

    # Imports time layers from a JSON file.
    def self.from_json_file

      json_path = UI.openpanel(
        TRANSLATE['Import from a JSON file'] + ' - ' + NAME, # title,
        nil, # directory
        TRANSLATE['JSON files'] + '|*.json||'
      )

      # Exit if user cancelled import...
      return if json_path.nil?

      imported_time_layers_count = from_json(File.read(json_path))

      if imported_time_layers_count > 1

        UI.messagebox(
          imported_time_layers_count.to_s + ' ' + TRANSLATE[
            Sketchup.version.to_i >= 20 ?
            'time tags successfully imported.' :
            'time layers successfully imported.'
          ]
        )

      else

        UI.messagebox(
          imported_time_layers_count.to_s + ' ' + TRANSLATE[
            Sketchup.version.to_i >= 20 ?
            'time tag successfully imported.' :
            'time layer successfully imported.'
          ]
        )

      end

    end

  end

end
