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
require 'objspace'
require 'layers_in_time/html_dialogs'
require 'layers_in_time/layer'
require 'layers_in_time/time_layers'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Layers/Tags In Time Layers Editor.
  class LayersEditor

    # Is it safe to open Layers Editor right now?
    #
    # @return [Boolean]
    def self.safe_to_open?

      if SESSION[:layers_editor_html_dialog_open?]

        UI.messagebox(
          TRANSLATE[
            Sketchup.version.to_i >= 20 ?
            'Tags Editor is already open.' :
            'Layers Editor is already open.'
          ]
        )
        return false

      end

      true

    end

    # Shows Layers Editor if all good conditions are met.
    #
    # @return [nil]
    def self.safe_show

      self.new.show if safe_to_open?

      nil

    end

    # Reloads Layers Editor.
    #
    # @return [Boolean]
    def self.reload

      if SESSION[:layers_editor_html_dialog_open?]

        raise 'Layers Editor HTML Dialog instance is missing.'\
          if SESSION[:layers_editor_html_dialog].nil?

        SESSION[:layers_editor_html_dialog].set_html(HTMLDialogs.merge(

          # Note: Paths below are relative to `HTMLDialogs::DIR`.
          document: 'layers-editor.rhtml',
          scripts: [
            'libraries/imask.js',
            'layers-editor.js'
          ],
          styles: [
            'layers-editor.css'
          ]
  
        ))

        return true

      end

      false

    end

    # Builds Layers Editor.
    def initialize

      @html_dialog = create_html_dialog

      SESSION[:layers_editor_html_dialog] = @html_dialog

      fill_html_dialog

      configure_html_dialog

    end

    # Shows Layers Editor.
    #
    # @return [void]
    def show

      @html_dialog.show

      # Layers Editor is open.
      SESSION[:layers_editor_html_dialog_open?] = true

    end

    # Creates SketchUp HTML dialog that powers Layers/Tags In Time Layers Editor.
    #
    # @return [UI::HtmlDialog] HTML dialog.
    private def create_html_dialog

      UI::HtmlDialog.new(
        dialog_title:    NAME,
        preferences_key: 'LayersInTime',
        scrollable:      true,
        width:           510,
        height:          490,
        min_width:       510,
        min_height:      490
      )

    end

    # Fills HTML dialog.
    #
    # @return [nil]
    private def fill_html_dialog

      @html_dialog.set_html(HTMLDialogs.merge(

        # Note: Paths below are relative to `HTMLDialogs::DIR`.
        document: 'layers-editor.rhtml',
        scripts: [
          'libraries/imask.js',
          'layers-editor.js'
        ],
        styles: [
          'layers-editor.css'
        ]

      ))

      nil

    end

    # Configures HTML dialog.
    #
    # @return [nil]
    private def configure_html_dialog

      @html_dialog.add_action_callback('updateLayers') do |_ctx, layers_time_data|
        
        layers_time_data.each do |native_layer_object_id, layer_time_data|

          layer = Layer.new(ObjectSpace._id2ref(native_layer_object_id.to_i))

          layer.dates = layer_time_data['dates']
          layer.hours = layer_time_data['hours']

        end

      end

      @html_dialog.set_on_closed { SESSION[:layers_editor_html_dialog_open?] = false }

      @html_dialog.center

      nil

    end

  end

end
