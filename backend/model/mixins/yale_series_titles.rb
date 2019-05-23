romanize_lib = ASUtils.find_local_directories('public/models/romanize_series_identifier.rb',
                                              'aspace_yale_pui').first

if File.exist?(romanize_lib)
  load romanize_lib
else
  raise "yale_series_title needs the aspace_yale_pui to be loaded first.  File could not be found: #{romanize_lib}"
end

module YaleSeriesTitles

  SERIES_LEVELS = ['series', 'otherlevel']

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def sequel_to_jsonmodel(objs, opts = {})
      jsons = super

      objs.zip(jsons).each do |obj, json|
        original_display_string = json.display_string

        # We'll only generate a new display string if this is a top-level AO of
        # the appropriate level.
        json.display_string = YaleSeriesTitles.build_yale_series_display(json)

        # If that didn't yield a result, keep the original display string.
        if json.display_string.empty?
          json.display_string = original_display_string
        end
      end

      jsons
    end
  end

  def self.build_yale_series_display(json)
    return '' unless SERIES_LEVELS.include?(json['level']) && json['parent'].nil?

    display_string = ''

    # If we have a component ID, we'll prefix the title with the series
    # level and the fun begins...
    if !json.component_id.to_s.empty?
      if json['level'] == 'series'
        series_label = ''

        # A series should start with "Series" followed by its component
        # ID.  If that component ID is numeric, use roman numerals.
        #
        if json.component_id =~ /\A(Series )?([0-9]+)\z/
          series_label = Romanizer.romanize(Integer($2))
        else
          series_label = json.component_id
        end

        # Our component ID may have contained the word "Series", but if it
        # didn't, add it in.
        unless series_label.start_with?('Series ')
          series_label = "Series #{series_label}"
        end

        display_string = series_label
      else
        # If we're an "other" level, that's our label and we don't use
        # roman numerals.
        display_string += json.other_level.capitalize
        display_string += (' ' + json.component_id)
      end
    end

    title_dates = ASUtils.wrap(json['dates']).select {|date|
      date['label'] == 'creation' && ['inclusive', 'single'].include?(date['date_type'])
    }

    if title_dates.empty? && json.title.to_s.empty?
      # If there are no dates and no title, we're done.
      return display_string
    end

    # Separate our series label if there is one.
    unless display_string.to_s.empty?
      display_string += ': '
    end

    # If there's a title, add it now.
    if !json.title.to_s.empty?
      display_string += json.title
      display_string.strip!

      # If we have some dates, separate them from the title.
      unless title_dates.empty?
        # If the string ends on a double quote, we want our added comma to
        # be inside the quotes.  Otherwise, at the end of the string.
        if display_string.end_with?('"')
          display_string = display_string.gsub(/"$/, ',"')
        else
          display_string += ','
        end

        display_string += ' '
      end
    end

    # Add our dates (if any)
    display_string += title_dates.map {|date| YaleSeriesTitles.format_date(date)}.join(', ')
  end

  def self.format_date(date)
    if date['expression']
      date['expression']
    else
      [date['begin'], date['end']].compact.join(' - ')
    end
  end


  class Romanizer
    extend RomanizeSeriesIdentifier
  end

end
