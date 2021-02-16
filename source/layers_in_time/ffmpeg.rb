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
require 'fileutils'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Wraps FFmpeg executable.
  module FFmpeg

    # Gets absolute path to FFmpeg executable.
    #
    # @raise [RuntimeError]
    #
    # @return [String]
    def self.executable

      if Sketchup.platform == :platform_osx
        File.join(__dir__, 'FFmpeg', 'Mac', 'ffmpeg')
      elsif Sketchup.platform == :platform_win
        File.join(__dir__, 'FFmpeg', 'Win', 'ffmpeg.exe')
      else
        raise RuntimeError, 'Unsupported platform: ' + Sketchup.platform.to_s
      end

    end

    # Ensures FFmpeg is executable.
    #
    # Note: Only useful on macOS.
    def self.ensure_executable
      FileUtils.chmod('+x', executable) if Sketchup.platform == :platform_osx
    end

    # Creates a MP4 video from still images thanks to FFmpeg.
    #
    # @param [Hash] parameters
    # @raise [ArgumentError]
    def self.create_mp4_video(parameters)

      raise ArgumentError, 'Parameters must be a Hash.'\
        unless parameters.is_a?(Hash)

      command = '"' + executable + '" -y -r ' + parameters[:framerate].to_s + ' -f image2' +
        ' -s ' + parameters[:resolution] + ' -i "' + parameters[:images_input_path] + '"' +
        ' -c:v ' + parameters[:codec] + ' -crf ' + parameters[:constant_rate_factor].to_s +
        ' -pix_fmt yuv420p -movflags +faststart "' + parameters[:video_output_path] + '"'
      
      ensure_executable

      command_status = system(command)

      UI.messagebox(TRANSLATE['Command failed:'] + ' ' + command) if command_status != true

    end

    # Creates an animated GIF from still images thanks to FFmpeg.
    #
    # @param [Hash] parameters
    # @raise [ArgumentError]
    def self.create_animated_gif(parameters)

      raise ArgumentError, 'Parameters must be a Hash.'\
        unless parameters.is_a?(Hash)

      command = '"' + executable + '" -y -r ' + parameters[:framerate].to_s + ' -f image2' +
        ' -s ' + parameters[:resolution] + ' -i "' + parameters[:images_input_path] + '"' +
        ' -filter_complex "[0:v] split [a][b];[a] palettegen [p];[b][p] paletteuse"' +
        ' "' + parameters[:gif_output_path] + '"'
      
      ensure_executable

      command_status = system(command)

      UI.messagebox(TRANSLATE['Command failed:'] + ' ' + command) if command_status != true

    end

  end

end
