$(function() {
    "use strict";

    // This overrides the standard ArchivesSpace implementation to use the
    // `display_string` that our tree decorator has inserted.
    var existingRenderer = window.renderers.resource;

    existingRenderer.build_node_title = function (node) {
        return node.display_string;
    }
});
