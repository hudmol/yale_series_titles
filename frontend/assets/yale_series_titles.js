"use strict";

// This overrides the standard ArchivesSpace implementation to use the
// `display_string` that our tree decorator has inserted.

var existingRenderer = Tree.getRenderer('resource');

existingRenderer.build_node_title = function (node) {
    return node.display_string;
}

Tree.setRenderer('resource', existingRenderer);
