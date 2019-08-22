class ArchivesSpaceService

  alias :large_tree_for_resource_pre_yale_series :large_tree_for_resource

  def large_tree_for_resource(largetree_opts = {})
    result = large_tree_for_resource_pre_yale_series
    result.add_decorator(YaleSeriesTreeDecorator.new)
    result
  end

  class YaleSeriesTreeDecorator
    def root(response, root_record)
      response
    end

    def node(response, node_record)
      response
    end

    # Add the custom display string to the data sent back on this waypoint.  On
    # the client-side, we'll show this for the tree item.
    def waypoint(response, record_ids)
      display_strings_by_uri = {}

      ArchivalObject.sequel_to_jsonmodel(ArchivalObject.filter(:id => record_ids).all).each do |json|
        display_strings_by_uri[json.uri] = MixedContentParser.parse(json.display_string, '/')
      end

      response.each do |node|
        node['display_string'] = display_strings_by_uri.fetch(node.fetch('uri'))
      end

      response
    end

  end

end
