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
require 'layers_in_time/ffmpeg'
require 'layers_in_time/layers_editor'

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

    # Animates then exports time layers to a MP4 video.
    #
    # @param [Boolean] export_animation Default: false
    # @raise [ArgumentError]
    #
    # @raise [RuntimeError]
    def self.animate(export_animation = false)

      raise ArgumentError, 'Export animation must be a Boolean.'\
        unless export_animation == true || export_animation == false

      return UI.messagebox(
        TRANSLATE[
          Sketchup.version.to_i >= 20 ?
          'There are no time tags to animate.' :
          'There are no time layers to animate.'
        ]
      ) if count == 0

      raise RuntimeError, 'Animation frames per day must be between 1 and 86400.'\
        unless SESSION[:animation][:frames_per_day].between?(1, 86400)

      if export_animation

        animation_export_options = UI.inputbox(
          [
            TRANSLATE['Format'] + ' ',
            TRANSLATE['Resolution'] + ' ',
            TRANSLATE['Frames per day'] + ' ',
            TRANSLATE['Skip nights?'] + ' ',
            TRANSLATE['Frames per second'] + ' ',
            TRANSLATE['MP4 quality (CRF)'] + ' '
          ], # prompts
          [
            SESSION[:animation][:format],
            SESSION[:animation][:resolution],
            SESSION[:animation][:frames_per_day].to_s,
            SESSION[:animation][:skip_nights?] ? TRANSLATE['Yes'] : TRANSLATE['No'],
            SESSION[:animation][:frames_per_second].to_s,
            SESSION[:animation][:constant_rate_factor].to_s
          ], # defaults
          [
            'GIF|MP4',
            '854x480|1280x720|1920x1080|2560x1440|3840x2160|7680x4320',
            '2|6|12|24|48|72|96|120',
            TRANSLATE['Yes'] + '|' + TRANSLATE['No'],
            '1|12|16|24|25|30|50|60',
            (18..28).to_a.join('|')
          ], # list
          TRANSLATE['Export to an animation...'] + ' - ' + NAME # title
        )

        # Exit if user cancelled...
        return if animation_export_options == false

        SESSION[:animation][:format] = animation_export_options[0]
        SESSION[:animation][:resolution] = animation_export_options[1]
        SESSION[:animation][:frames_per_day] = animation_export_options[2].to_i
        SESSION[:animation][:skip_nights?] = animation_export_options[3] == TRANSLATE['Yes']
        SESSION[:animation][:frames_per_second] = animation_export_options[4].to_i
        SESSION[:animation][:constant_rate_factor] = animation_export_options[5].to_i

        animation_output_extension = SESSION[:animation][:format] == 'GIF' ? '.gif' : '.mp4'

        if !Sketchup.active_model.path.empty?
          animation_output_basename = File.basename(Sketchup.active_model.path).sub(
            '.skp', animation_output_extension
          )
        else
          animation_output_basename = TRANSLATE['Untitled model'] + animation_output_extension
        end

        animation_output_path = UI.savepanel(
          TRANSLATE['Export to an animation...'] + ' - ' + NAME, # title
          nil, # directory
          animation_output_basename
        )
  
        # Exit if user cancelled...
        return if animation_output_path.nil?

      else

        animation_export_options = UI.inputbox(
          [
            TRANSLATE['Frames per day'] + ' ',
            TRANSLATE['Skip nights?'] + ' '
          ], # prompts
          [
            SESSION[:animation][:frames_per_day].to_s,
            SESSION[:animation][:skip_nights?] ? TRANSLATE['Yes'] : TRANSLATE['No']
          ], # defaults
          [
            '2|6|12|24|48|72|96|120',
            TRANSLATE['Yes'] + '|' + TRANSLATE['No']
          ], # list
          TRANSLATE['Play animation'] + ' - ' + NAME # title
        )

        # Exit if user cancelled...
        return if animation_export_options == false

        SESSION[:animation][:frames_per_day] = animation_export_options[0].to_i
        SESSION[:animation][:skip_nights?] = animation_export_options[1] == TRANSLATE['Yes']

      end

      temp_animation_dates = []
      
      Sketchup.active_model.layers.each do |native_layer|

        layer = Layer.new(native_layer)

        temp_animation_dates.push(layer.parsed_dates[:start]) if layer.dates_layer?

      end

      temp_animation_dates.sort! # chronologically

      animation_dates = []

      temp_animation_dates.each do |temp_animation_date|

        temp_animation_month_and_day = temp_animation_date.split('/')

        animation_dates.push({
          month: temp_animation_month_and_day[0].to_i,
          day: temp_animation_month_and_day[1].to_i
        })

      end

      # If needed: inject one arbitrary date, so animation can be still played.
      animation_dates.push({ month: 1, day: 1 }) if animation_dates.length == 0

      animation_step_in_seconds = 86400 / SESSION[:animation][:frames_per_day]
      animation_seconds_cursor = 0
      animation_hours = []

      SESSION[:animation][:frames_per_day].times do

        animation_seconds_cursor = animation_seconds_cursor + animation_step_in_seconds
        animation_time = Time.at(animation_seconds_cursor).to_time.utc

        animation_hours.push({
          hour: animation_time.hour.to_i,
          minute: animation_time.min.to_i,
          second: animation_time.sec.to_i
        })

      end

      shadow_info = Sketchup.active_model.shadow_info
      time_backup = shadow_info['ShadowTime']
      view = Sketchup.active_model.active_view
      utc_offset = shadow_info['ShadowTime'].utc_offset.to_i

      if export_animation

        animation_frames_temp_dir = File.join(
          Sketchup.temp_dir, 'SketchUp Layers In Time Plugin Animation Frames'
        )
  
        FileUtils.remove_dir(animation_frames_temp_dir)\
          if Dir.exist?(animation_frames_temp_dir)
        
        FileUtils.mkdir_p(animation_frames_temp_dir)

        animation_current_frame = 0
        animation_resolution_width_and_height = SESSION[:animation][:resolution].split('x')
        animation_resolution_width = animation_resolution_width_and_height[0].to_i
        animation_resolution_height = animation_resolution_width_and_height[1].to_i

        Sketchup.status_text = TRANSLATE['Exporting animation frames... Please wait.'] 

      end

      animation_dates.each do |animation_date|

        animation_hours.each do |animation_hour|

          animation_frame_timestamp = Time.new(
            2021, # Any non-leap year does the job.
            animation_date[:month],
            animation_date[:day],
            animation_hour[:hour],
            animation_hour[:minute],
            animation_hour[:second]
          ).to_i + utc_offset

          shadow_info['ShadowTime'] = Time.at(animation_frame_timestamp)

          next if SESSION[:animation][:skip_nights?] &&\
            !shadow_info['ShadowTime'].to_i.between?(
              shadow_info['SunRise'].to_i, shadow_info['SunSet'].to_i
            )

          view.refresh || view.invalidate

          if export_animation

            animation_frame_filename = File.join(
              animation_frames_temp_dir,
              ('%09d' % animation_current_frame) + '.jpg'
            )

            view.write_image({
              filename: animation_frame_filename,
              width: animation_resolution_width,
              height: animation_resolution_height,
              antialias: true
            })

            animation_current_frame = animation_current_frame + 1

          end

        end

      end

      shadow_info['ShadowTime'] = time_backup

      if export_animation

        Sketchup.status_text = TRANSLATE['Creating animation with FFmpeg... Please wait.']
        
        animation_frames_input_path = File.join(animation_frames_temp_dir, '%09d.jpg')

        if SESSION[:animation][:format] == 'GIF'

          FFmpeg.create_animated_gif({
            images_input_path: animation_frames_input_path,
            resolution: SESSION[:animation][:resolution],
            framerate: SESSION[:animation][:frames_per_second],
            gif_output_path: animation_output_path
          })

        else

          FFmpeg.create_mp4_video({
            images_input_path: animation_frames_input_path,
            codec: 'libx264',
            resolution: SESSION[:animation][:resolution],
            framerate: SESSION[:animation][:frames_per_second],
            constant_rate_factor: SESSION[:animation][:constant_rate_factor],
            video_output_path: animation_output_path
          })

        end

        Sketchup.status_text = nil

        UI.messagebox(
          TRANSLATE['Animation successfully exported here:'] + ' ' + animation_output_path
        )

        FileUtils.remove_dir(animation_frames_temp_dir)

      end

    end

    # Finds time layers associated to a component.
    #
    # @param [Sketchup::ComponentInstance] component
    # @raise [ArgumentError]
    #
    # @return [Hash]
    def self.associated_to_component(component)

      raise ArgumentError, 'Component must be a Sketchup::ComponentInstance.'\
        unless component.is_a?(Sketchup::ComponentInstance)

      native_layers = Sketchup.active_model.layers

      time_layers = {}

      layer = Layer.new(native_layers[component.layer.name])

      if layer.time_layer?

        time_layers[component.layer.name] = {}

        time_layers[component.layer.name][:dates] = layer.dates if layer.dates_layer?
        time_layers[component.layer.name][:hours] = layer.hours if layer.hours_layer?

      end

      # Traverse component tree.
      component.definition.entities.grep(Sketchup::ComponentInstance).each do |sub_component|

        layer = Layer.new(native_layers[sub_component.layer.name])

        if layer.time_layer?

          time_layers[sub_component.layer.name] = {}
  
          time_layers[sub_component.layer.name][:dates] = layer.dates if layer.dates_layer?
          time_layers[sub_component.layer.name][:hours] = layer.hours if layer.hours_layer?
  
        end

      end

      time_layers

    end

    # Exports time layers to JSON.
    #
    # @return [String] JSON.
    def self.to_json

      time_layers = {}

      Sketchup.active_model.layers.each do |native_layer|

        layer = Layer.new(native_layer)

        next unless layer.time_layer?

        time_layers[layer.native.name] = {}

        time_layers[layer.native.name][:dates] = layer.dates if layer.dates_layer?
        time_layers[layer.native.name][:hours] = layer.hours if layer.hours_layer?

      end

      JSON.pretty_generate(time_layers)

    end

    # Exports time layers to a JSON file.
    def self.to_json_file

      return UI.messagebox(
        TRANSLATE[
          Sketchup.version.to_i >= 20 ?
          'No time tag found. JSON export aborted.' :
          'No time layer found. JSON export aborted.'
        ]
      ) if count == 0

      if !Sketchup.active_model.path.empty?
        json_basename = File.basename(Sketchup.active_model.path).sub('.skp', '.json')
      else
        json_basename = TRANSLATE['Untitled model'] + '.json'
      end

      json_path = UI.savepanel(
        TRANSLATE['Export to a JSON file...'] + ' - ' + NAME, # title
        nil, # directory
        json_basename
      )

      # Exit if user cancelled...
      return if json_path.nil?

      File.write(json_path, to_json)

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
        TRANSLATE['Import from a JSON file...'] + ' - ' + NAME, # title,
        nil, # directory
        TRANSLATE['JSON files'] + '|*.json||'
      )

      # Exit if user cancelled...
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
