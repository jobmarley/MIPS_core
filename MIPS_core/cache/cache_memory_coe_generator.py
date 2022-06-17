import os

def write_coe(filepath, records):
	print('writing {} records to {}...'.format(len(records), filepath))
	with open(filepath, 'w') as f:
		f.write("memory_initialization_radix=16;\n")
		f.write("memory_initialization_vector=\n")
		f.write(',\n'.join(r for r in records) + ";")
		f.flush()

def get_local_filename(filename):
	return os.path.join(os.path.dirname(__file__), filename)

data_content = []

def format_data(data):
	result = []
	for i in range(0, len(data), 16):
		l = ""
		for j in range(0, 16):
			l = '{:08x}'.format(data[i + j]) + l
		result.append(l)
	return result

######### TESTS LIST #########
for i in range(0, 256):
	data_content.append(i)
######### END OF TESTS #########


write_coe(get_local_filename("cache_memory_data.coe"), format_data(data_content))
print('done.')