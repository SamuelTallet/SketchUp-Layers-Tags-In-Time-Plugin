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
require 'extensions'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  if Sketchup.version.to_i >= 17

    VERSION = '1.0.0'

    # Load translation if it's available for current locale.
    TRANSLATE = LanguageHandler.new('layers_in_time.translation')
    # See: "layers_in_time/Resources/#{Sketchup.get_locale}/layers_in_time.translation"
  
    # Remember extension name. See: `LayersInTime::Menu`.
    NAME = TRANSLATE[
      Sketchup.version.to_i >= 20 ?
      'Tags In Time' :
      'Layers In Time'
    ]
  
    # Initialize session storage.
    SESSION = {
      layers_editor_html_dialog_open?: false,
      layers_editor_html_dialog: nil
    }
  
    # Register extension.
  
    extension = SketchupExtension.new(NAME, 'layers_in_time/load.rb')
  
    extension.version     = VERSION
    extension.creator     = 'Samuel Tallet'
    extension.copyright   = "© 2021 #{extension.creator}"
  
    if Sketchup.version.to_i >= 20
      extension_features = [
        TRANSLATE['Display or hide SketchUp tags depending on time (dates or hours).'],
        TRANSLATE['Define as much time tags you want: they combine.'],
        TRANSLATE['Create and assign simultaneously a tag to an entity via context menu.']
      ]
    else
      extension_features = [
        TRANSLATE['Display or hide SketchUp layers depending on time (dates or hours).'],
        TRANSLATE['Define as much time layers you want: they combine.'],
        TRANSLATE['Create and assign simultaneously a layer to an entity via context menu.']
      ]
    end

    extension_features.push(
      TRANSLATE['Now, your favorite 3D modeling software understands seasons concept.']
    )
  
    extension.description = extension_features.join(' ')
  
    Sketchup.register_extension(
      extension,
      true # load_at_start
    )
    
  else
    UI.messagebox('Layers/Tags In Time plugin requires at least SketchUp 2017.')
  end

end
