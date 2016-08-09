tool

# Performs a positive integer division rounded to upper (4/2 = 2, 5/3 = 2)
static func up_div(a, b):
	if a % b != 0:
		return a / b + 1
	return a / b

# Creates a 2D array as an array of arrays
static func create_grid(w, h, v=null):
	var is_create_func = typeof(v) == TYPE_OBJECT and v extends FuncRef
	var grid = []
	grid.resize(h)
	for y in range(grid.size()):
		var row = []
		row.resize(w)
		if is_create_func:
			for x in range(row.size()):
				row[x] = v(x,y)
		else:
			for x in range(row.size()):
				row[x] = v
		grid[y] = row
	return grid

# Creates a 2D array that is a copy of another 2D array
static func clone_grid(other_grid):
	var grid = []
	grid.resize(other_grid.size())
	for y in range(0, grid.size()):
		var row = []
		var other_row = other_grid[y]
		row.resize(other_row.size())
		grid[y] = row
		for x in range(0, row.size()):
			row[x] = other_row[x]
	return grid

# Resizes a 2D array and allows to set or call functions for each deleted and created cells.
# This is especially useful if cells contain objects and you don't want to loose existing data.
static func resize_grid(grid, new_width, new_height, create_func=null, delete_func=null):
	# Check parameters
	assert(new_width >= 0 and new_height >= 0)
	assert(grid != null)
	if delete_func != null:
		assert(typeof(delete_func) == TYPE_OBJECT and delete_func extends FuncRef)
	var is_create_func = typeof(create_func) == TYPE_OBJECT and create_func extends FuncRef
	
	# Get old size (supposed to be rectangular!)
	var old_height = grid.size()
	var old_width = 0
	if grid.size() != 0:
		old_width = grid[0].size()
	
	# Delete old rows
	if new_height < old_height:
		if delete_func != null:
			for y in range(new_height, grid.size()):
				var row = grid[y]
				for x in range(0, row.size()):
					var elem = row[x]
					delete_func.call_func(elem)
		grid.resize(new_height)
	
	# Delete old columns
	if new_width < old_width:
		for y in range(0, grid.size()):
			var row = grid[y]
			if delete_func != null:
				for x in range(new_width, row.size()):
					var elem = row[x]
					delete_func.call_func(elem)
			row.resize(new_width)
	
	# Create new columns
	if new_width > old_width:
		for y in range(0, grid.size()):
			var row = grid[y]
			row.resize(new_width)
			if is_create_func:
				for x in range(old_width, new_width):
					row[x] = create_func.call_func(x,y)
			else:
				for x in range(old_width, new_width):
					row[x] = create_func
	
	# Create new rows
	if new_height > old_height:
		grid.resize(new_height)
		for y in range(old_height, new_height):
			var row = []
			row.resize(new_width)
			grid[y] = row
			if is_create_func:
				for x in range(0, new_width):
					row[x] = create_func.call_func(x,y)
			else:
				for x in range(0, new_width):
					row[x] = create_func
	
	# Debug test check
	assert(grid.size() == new_height)
	for y in range(0, grid.size()):
		assert(grid[y].size() == new_width)


static func grid_min_max(grid):
	if grid.size() == 0 or grid[0].size() == 0:
		return [0,0]
	var vmin = grid[0][0]
	var vmax = vmin
	for y in range(0, grid.size()):
		var row = grid[y]
		for x in range(0, row.size()):
			var v = row[x]
			if v > vmax:
				vmax = v
			elif v < vmin:
				vmin = v
	return [vmin, vmax]


static func grid_extract_area(src_grid, x0, y0, w, h):
	var dst = create_grid(w, h)
	for y in range(0, h):
		var dst_row = dst[y]
		var src_row = src_grid[y0+y]
		for x in range(0, w):
			dst_row[x] = src_row[x0+x]
	return dst


static func grid_paste(src_grid, dst_grid, x0, y0):
	for y in range(0, src_grid.size()):
		var src_row = src_grid[y]
		var dst_row = dst_grid[y0+y]
		for x in range(0, src_row.size()):
			dst_row[x0+x] = src_row[x]


static func grid_equals(a, b):
	if a.size() != b.size():
		return false
	for y in range(0, a.size()):
		var a_row = a[y]
		var b_row = b[y]
		if a_row.size() != b_row.size():
			return false
		for x in range(0, b_row.size()):
			if a_row[x] != b_row[x]:
				return false
	return true



