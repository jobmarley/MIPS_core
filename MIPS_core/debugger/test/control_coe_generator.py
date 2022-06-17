import os

CONTROL_READ = 0;
CONTROL_WRITE = 1;

class control_record:
	def __init__(self, error_check = True, mode = CONTROL_READ, success_next = 0, fail_next = 0):
		self.error_check = error_check
		self.mode = mode
		self.success_next = success_next
		self.fail_next = fail_next

	def get_value(self):
		value = 0x20000 if self.error_check else 0
		value = value | (0 if self.mode == CONTROL_READ else 0x10000)
		value = value | ((self.success_next & 0xFF) << 8)
		value = value | (self.fail_next & 0xFF)
		return value

def write_coe(filepath, records):
	print('writing {} records to {}...'.format(len(records), filepath))
	with open(filepath, 'w') as f:
		f.write("memory_initialization_radix=16;\n")
		f.write("memory_initialization_vector=\n")
		f.write(',\n'.join('{:08x}'.format(r) for r in records) + ";")
		f.flush()

def get_local_filename(filename):
	return os.path.join(os.path.dirname(__file__), filename)

address_content = []
data_content = []
control_content = []
mask_content = []

def add_test(address, data, control, mask):
	address_content.append(address)
	data_content.append(data)
	control.success_next = len(control_content) + 1
	control.fail_next = len(control_content) + 1
	control_content.append(control)
	mask_content.append(mask)

def test_read(address, expected):
	add_test(address, expected, control_record(True, CONTROL_READ), 0xFFFFFFFF)
def test_write_readback(address, data, expected):
	add_test(address, data, control_record(True, CONTROL_WRITE), 0xFFFFFFFF)
	add_test(address, expected, control_record(True, CONTROL_READ), 0xFFFFFFFF)

######### TESTS LIST #########
test_read(0, 0)
test_read(4, 0)
test_write_readback(0, 0xFFFFFFFF, 1)
test_write_readback(4, 0x00000AAA, 0x000000AA)
test_read(0x20, 0)
test_write_readback(0x20, 0xAAAAAAAA, 0xAAAAAAAA)
test_read(0x3C, 0)
test_write_readback(0x3C, 0xCCCCCCCC, 0xCCCCCCCC)
test_read(0x40, 0)
test_write_readback(0x40, 0xFFFFFFFF, 0)
######### END OF TESTS #########


write_coe(get_local_filename("debugger_test_traffic_address.coe"), address_content)
write_coe(get_local_filename("debugger_test_traffic_data.coe"), data_content)
write_coe(get_local_filename("debugger_test_traffic_control.coe"), [c.get_value() for c in control_content])
write_coe(get_local_filename("debugger_test_traffic_mask.coe"), mask_content)
print('done.')