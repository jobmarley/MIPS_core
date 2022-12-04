import os
import random
import subprocess

instr_asm_filename = 'instruction_test_asm.asm'
instr_cmd_filename = 'instruction_test_commands.txt'
clang_path = r'C:\Program Files\LLVM\bin\clang++'
lld_path = r'C:\Program Files\LLVM\bin\ld.lld'

def random_register(count = 1):
	return [random.randint(0, 31) for x in range(0, count)]

def random_register_non_zero(count = 1):
	return [random.randint(1, 31) for x in range(0, count)]

def random_uint32():
	return random.randint(0, 0xFFFFFFFF)
def random_int16():
	return random.randint(0, 0xFFFF) - 0x8000

class instruction_builder:
	def __init__(self, asm_filepath, cmd_filepath):
		self.test_commands = []
		self.instructions = []
		self.asm_filepath = asm_filepath
		self.outpath = cmd_filepath

	def add_instruction(self, asm):
		self.test_commands.append('EXEC')
		self.instructions.append(asm)
		
	def add_check_reg(self, reg, value):
		self.add_command('CHECK_REG {:08X} {:08X}'.format(reg, value))

	def add_write_reg(self, reg, value):
		self.add_command('WRITE_REG {:08X} {:08X}'.format(reg, value))

	def add_command(self, cmd):
		self.test_commands.append(cmd)

	def write_asm_file(self):
		print('write asm file {}'.format(self.asm_filepath))
		with open(self.asm_filepath, 'w') as f:
			for x in self.instructions:
				f.write(x)
			f.flush()

	def read_instruction_binary(self, filepath):
		l = []
		with open(filepath, 'rb') as f:
			for i in range(0, len(self.instructions)):
				l.append(int.from_bytes(f.read(4), 'little'))
		return l;

	def write_command_file(self, binary_filepath):
		print('write cmd file {}'.format(self.asm_filepath))
		instr_bin = self.read_instruction_binary(binary_filepath)

		with open(self.outpath, 'w') as f:
			i = 0
			for c in self.test_commands:
				if c == 'EXEC':
					f.write('EXEC {:08X}'.format(instr_bin[i]) + '\n')
					i = i + 1
				else:
					f.write(c + '\n')
			f.flush()
			
	def generate_cmd_file(self):
		self.write_asm_file()

		obj_filepath = os.path.splitext(self.asm_filepath)[0] + '.o'
		bin_filepath = os.path.splitext(self.asm_filepath)[0] + '.bin'
		clang_compile(self.asm_filepath, obj_filepath)
		clang_link(obj_filepath, bin_filepath)
		self.write_command_file(bin_filepath)

		
def generate_register_values():
	return [random_uint32() for i in range(0, 128)]

def generate_commands():
	
	builder = instruction_builder(instr_asm_filename, instr_cmd_filename)
	
	# initialize registers with random values
	register_init_values = generate_register_values()
	for i in range(0, 32):
		builder.add_write_reg(i, register_init_values[i])

	# test 0 unwritable
	regs = random_register(2)
	builder.add_instruction('add $0, ${}, ${}\n'.format(*regs))
	builder.add_check_reg(0, 0)

	regs = random_register_non_zero() + random_register(2)
	builder.add_instruction('add ${}, ${}, ${}\n'.format(*regs))
	builder.add_check_reg(regs[0], (register_init_values[regs[1]] + register_init_values[regs[2]]) % 0x100000000)
	
	regs = random_register_non_zero() + random_register(1)
	v = random_int16()
	builder.add_instruction('addi ${}, ${}, {}\n'.format(*regs + [v]))
	builder.add_check_reg(regs[0], (register_init_values[regs[1]] + v) % 0x100000000)
	
	regs = random_register_non_zero() + random_register(2)
	builder.add_instruction('sub ${}, ${}, ${}\n'.format(*regs))
	builder.add_check_reg(regs[0], (register_init_values[regs[1]] - register_init_values[regs[2]]) % 0x100000000)
	
	regs = random_register_non_zero() + random_register(1)
	v = random_int16()
	builder.add_instruction('sub ${}, ${}, {}\n'.format(*regs + [v]))
	builder.add_check_reg(regs[0], (register_init_values[regs[1]] - v) % 0x100000000)


	builder.generate_cmd_file()
		
def clang_compile(filepath, outpath):
	print('compiling {}...'.format(filepath, outpath))
	err = subprocess.call([clang_path, '-c',  '--target=mipsel', filepath, '-o', outpath])
	if err != 0:
		print('clang compilation failed with code {}'.format(err))
		exit(err)

def clang_link(filepath, outpath):
	print('linking {}...'.format(filepath, outpath))
	map_filepath = os.path.splitext(outpath)[0] + '.map'
	err = subprocess.call([lld_path, filepath, '-o', outpath, '--image-base=0', '--oformat', 'binary', '--section-start', '.text=0', '--Map', map_filepath])
	if err != 0:
		print('clang link failed with code {}'.format(err))
		exit(err)

def main():
	generate_commands()
	print('done.')

if __name__ == "__main__":
	main()