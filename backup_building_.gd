@tool
extends EditorScript

func _run():
	var scene_root = get_editor_interface().get_edited_scene_root()
	
	if not scene_root:
		printerr("No scene is currently open.")
		return

	var mat_update_count = [0]
	var overlay_add_count = [0]
	_process_node(scene_root, mat_update_count, overlay_add_count)
	
	print("Updated %d materials to toon with roughness 0" % mat_update_count[0])
	print("Added %d overlay materials with black, grow = 0.02, cull = FRONT" % overlay_add_count[0])

func _process_node(node: Node, mat_count: Array, overlay_count: Array):
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh and mesh.get_surface_count() > 0:
			for i in mesh.get_surface_count():
				var mat = mesh.surface_get_material(i)
				if mat is StandardMaterial3D:
					var new_mat = mat.duplicate()
					new_mat.diffuse_mode = StandardMaterial3D.DIFFUSE_TOON
					new_mat.roughness = 0.0
					mesh.surface_set_material(i, new_mat)
					mat_count[0] += 1

		## Add overlay if none exists
		#if node.material_overlay == null:
			#var overlay = StandardMaterial3D.new()
			#overlay.albedo_color = Color.BLACK
			#overlay.grow = true
			#overlay.grow_amount = 0.02
			#overlay.cull_mode = BaseMaterial3D.CULL_FRONT
			#node.material_overlay = overlay
			#overlay_count[0] += 1
	
	for child in node.get_children():
		_process_node(child, mat_count, overlay_count)
