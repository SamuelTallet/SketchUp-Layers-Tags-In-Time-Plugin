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
require 'date'

# Layers/Tags In Time plugin namespace.
module LayersInTime

  # Overloads a native SketchUp layer with optional time data.
  class Layer

    # Regular expression for validating layer dates.
    DATES_REGEX = /^((((0[1-9]|1[0-2])\/([01][1-9]|10|2[0-8]))|((0[13-9]|1[0-2])\/(29|30))|((0[13578]|1[02])\/31)) - (((0[1-9]|1[0-2])\/([01][1-9]|10|2[0-8]))|((0[13-9]|1[0-2])\/(29|30))|((0[13578]|1[02])\/31)))$/

    # Regular expression for validating layer hours.
    HOURS_REGEX = /^((([0-1][0-9]|2[0-3]):([0-5][0-9])) - (([0-1][0-9]|2[0-3]):([0-5][0-9])))$/

    # Makes a Layer object with a native Sketchup::Layer object.
    def initialize(native_layer)

      raise ArgumentError, 'Native layer must be a Sketchup::Layer.'\
        unless native_layer.is_a?(Sketchup::Layer)

      @native_layer = native_layer

    end

    # Gets native SketchUp layer.
    #
    # @return [Sketchup::Layer]
    def native
      @native_layer
    end

    # Finds layer dates.
    #
    # @return [String, nil] nil if layer dates were not found.
    def dates
      @native_layer.get_attribute('LayersInTime', 'dates')
    end

    # Defines layer dates.
    # 
    # @note To unset dates: provide an empty or invalid string.
    #
    # @param [String] dates
    # @raise [ArgumentError]
    def dates=(dates)

      raise ArgumentError, 'Dates must be a String.'\
        unless dates.is_a?(String)

      if dates.match(DATES_REGEX)
        @native_layer.set_attribute('LayersInTime', 'dates', dates)
      else
        @native_layer.delete_attribute('LayersInTime', 'dates')
      end

    end

    # Is this layer a dates layer?
    #
    # @return [Boolean]
    def dates_layer?
      !@native_layer.get_attribute('LayersInTime', 'dates').nil?
    end

    # Gets parsed layer dates.
    #
    # @raise [RuntimeError]
    # 
    # @return [Hash]
    def parsed_dates

      layer_dates = @native_layer.get_attribute('LayersInTime', 'dates')
      raise RuntimeError, 'Layer has no dates.' if layer_dates.nil?

      layer_dates_start_and_end = layer_dates.gsub(' ', '').split('-')
      layer_dates_start = layer_dates_start_and_end[0]
      layer_dates_end = layer_dates_start_and_end[1]

      layer_dates_start_month_and_day = layer_dates_start.split('/')
      layer_dates_start_month = layer_dates_start_month_and_day[0].to_i
      layer_dates_start_day = layer_dates_start_month_and_day[1].to_i

      # 2021 isn't a leap year. So it's a good choice to get day of year.
      layer_dates_start_day_of_year = Date.new(
        2021, layer_dates_start_month, layer_dates_start_day
      ).yday

      layer_dates_end_month_and_day = layer_dates_end.split('/')
      layer_dates_end_month = layer_dates_end_month_and_day[0].to_i
      layer_dates_end_day = layer_dates_end_month_and_day[1].to_i

      layer_dates_end_day_of_year = Date.new(
        2021, layer_dates_end_month, layer_dates_end_day
      ).yday

      parsed_layer_dates = {

        start: layer_dates_start,
        start_month: layer_dates_start_month,
        start_day: layer_dates_start_day,
        start_day_of_year: layer_dates_start_day_of_year,

        end: layer_dates_end,
        end_month: layer_dates_end_month,
        end_day: layer_dates_end_day,
        end_day_of_year: layer_dates_end_day_of_year

      }

    end

    # Does layer match a date?
    #
    # @raise [ArgumentError]
    # 
    # @return [Boolean]
    def match_date?(time)
      
      raise ArgumentError, 'Time must be a Time.'\
        unless time.is_a?(Time)

      return false unless dates_layer?

      parsed_layer_dates = parsed_dates

      time_day_of_year = time.yday

      # Because all years aren't leap years, time layers don't support leap years.
      # Hence, we need to convert day of leap year of time to day of non-leap year
      # of time. This means that February 28 and 29 will be considered as same day.
      if Date.leap?(time.year) && time_day_of_year >= 60
        time_day_of_year = time_day_of_year - 1
      end

      # Handle two-years overlap.
      if parsed_layer_dates[:start_day_of_year] > parsed_layer_dates[:end_day_of_year]

        if time_day_of_year.between?(parsed_layer_dates[:start_day_of_year], 365) ||\
          time_day_of_year.between?(1, parsed_layer_dates[:end_day_of_year])
          return true
        else
          return false
        end

      end

      time_day_of_year.between?(
        parsed_layer_dates[:start_day_of_year], parsed_layer_dates[:end_day_of_year]
      )

    end

    # Finds layer hours.
    #
    # @return [String, nil] nil if layer hours were not found.
    def hours
      @native_layer.get_attribute('LayersInTime', 'hours')
    end

    # Defines layer hours.
    # 
    # @note To unset hours: provide an empty or invalid string.
    #
    # @param [String] hours
    # @raise [ArgumentError]
    def hours=(hours)

      raise ArgumentError, 'Hours must be a String.'\
        unless hours.is_a?(String)

      if hours.match(HOURS_REGEX)
        @native_layer.set_attribute('LayersInTime', 'hours', hours)
      else
        @native_layer.delete_attribute('LayersInTime', 'hours')
      end

    end

    # Is this layer a hours layer?
    #
    # @return [Boolean]
    def hours_layer?
      !@native_layer.get_attribute('LayersInTime', 'hours').nil?
    end

    # Gets parsed layer hours.
    #
    # @raise [RuntimeError]
    # 
    # @return [Hash]
    def parsed_hours

      layer_hours = @native_layer.get_attribute('LayersInTime', 'hours')
      raise RuntimeError, 'Layer has no hours.' if layer_hours.nil?

      layer_hours_start_and_end = layer_hours.gsub(' ', '').split('-')
      layer_hours_start = layer_hours_start_and_end[0]
      layer_hours_end = layer_hours_start_and_end[1]

      layer_hours_start_hour_and_minute = layer_hours_start.split(':')
      layer_hours_start_hour = layer_hours_start_hour_and_minute[0].to_i
      layer_hours_start_minute = layer_hours_start_hour_and_minute[1].to_i

      layer_hours_start_second_of_day = (layer_hours_start_hour * 3600) +\
        (layer_hours_start_minute * 60)

      layer_hours_end_hour_and_minute = layer_hours_end.split(':')
      layer_hours_end_hour = layer_hours_end_hour_and_minute[0].to_i
      layer_hours_end_minute = layer_hours_end_hour_and_minute[1].to_i

      layer_hours_end_second_of_day = (layer_hours_end_hour * 3600) +\
        (layer_hours_end_minute * 60)

      parsed_layer_hours = {

        start: layer_hours_start,
        start_hour: layer_hours_start_hour,
        start_minute: layer_hours_start_minute,
        start_second_of_day: layer_hours_start_second_of_day,

        end: layer_hours_end,
        end_hour: layer_hours_end_hour,
        end_minute: layer_hours_end_minute,
        end_second_of_day: layer_hours_end_second_of_day

      }

    end

    # Does layer match a hour?
    #
    # @raise [ArgumentError]
    # 
    # @return [Boolean]
    def match_hour?(time)
      
      raise ArgumentError, 'Time must be a Time.'\
        unless time.is_a?(Time)

      return false unless hours_layer?

      parsed_layer_hours = parsed_hours

      time_second_of_day = (time.hour * 3600) + (time.min * 60)

      # Handle two-days overlap.
      if parsed_layer_hours[:start_second_of_day] > parsed_layer_hours[:end_second_of_day]

        if time_second_of_day.between?(parsed_layer_hours[:start_second_of_day], 86400) ||\
          time_second_of_day.between?(0, parsed_layer_hours[:end_second_of_day])
          return true
        else
          return false
        end

      end

      time_second_of_day.between?(
        parsed_layer_hours[:start_second_of_day], parsed_layer_hours[:end_second_of_day]
      )

    end

    # Is this layer a time layer?
    #
    # @return [Boolean]
    def time_layer?
      dates_layer? || hours_layer?
    end

  end

end
