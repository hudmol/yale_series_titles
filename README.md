Installation
============

Check out this repository into your ArchivesSpace `plugins` directory
as `yale_series_title`.  Then add it to your ArchivesSpace `config.rb`
in the usual way:

     AppConfig[:plugins] = [... , 'yale_series_titles']


**Important note:** In the `yale` branch there is a small modification
to the ArchivesSpace core code to let us hook into.  Make sure you
have this commit in your ArchivesSpace build:

> 48c46a440 Add the ability for third-party plugins to override tree renderers if desired


Design notes
============

This plugin applies new rules for generating series titles where they
appear.  It works by overriding the `display_string` attribute on
the Archival Objects that qualify as series and then modifies the
staff and public interfaces to use that display string.

Here is a rundown of the major pieces:

  * On the backend, we hook into `large_tree_for_resource` which is
    defined in the Resources controller.  We add a new decorator that
    adds the `display_string` property to the JSON representation of
    tree waypoints.

  * In the ArchivalObject model, we add a new mixin that generates
    `display_string` on a call to `sequel_to_json`.  The display
    string stored in the database is effectively ignored as a result
    of this, but that shouldn't matter.

  * We modify the tree renderers in the staff and public interfaces to
    make use of the new `display_string` property on the waypoints.
    As noted above, this required a small enhancement to the
    ArchivesSpace core code.


Optional configuration
======================

You can optionally control the separators used in display strings by
setting the following configuration options.  The values shown are the
defaults:

     AppConfig[:series_separator] = ':'
     AppConfig[:title_date_separator] = ','
     AppConfig[:date_range_separator] = ' - '
