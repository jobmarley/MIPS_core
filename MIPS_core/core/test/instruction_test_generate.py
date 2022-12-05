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

def random_int(bitsize):
	return random.randint(-(1 << (bitsize - 1)), (1 << (bitsize - 1)) - 1)
def random_uint(bitsize):
	return random.randint(0, (1 << bitsize) - 1)
def random_uint32():
	return random_uint(32)
def random_int16():
	return random_int(16)

# result is unsigned, s can be signed or unsigned
def sign_extend(s, src_size, dst_size):
	s = s % (1 << src_size)
	if s >> (src_size - 1) == 1:
		s = s | (((1 << dst_size) - 1) << src_size)
	return s

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
		with open(self.asm_filepath, 'w', encoding='ascii') as f:
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
					f.write('# {}'.format(self.instructions[i]))
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


# execute instr with 3 random registers, and check result which must be equal to f(r[1], r[2]) % 0x100000000
# then revert the register
def check_op_3reg(instr, builder, registers, f):
	r = random_register_non_zero() + random_register(2)
	builder.add_instruction('{} ${}, ${}, ${}\n'.format(instr, *r))
	e = f(registers[r[1]], registers[r[2]]) % 0x100000000
	builder.add_check_reg(r[0], e)
	builder.add_write_reg(r[0], registers[r[0]])
	
# same as above but with random i16, f(r[1], i16)
def check_op_2reg_i16(instr, builder, registers, f):
	r = random_register_non_zero() + random_register(1)
	v = random_int16()
	builder.add_instruction('{} ${}, ${}, {}\n'.format(instr, *r, v))
	e = f(registers[r[1]], v) % 0x100000000
	builder.add_check_reg(r[0], e)
	builder.add_write_reg(r[0], registers[r[0]])
	
# same as above but with given immediate, f(r[1], imm)
def check_op_2reg_imm(instr, builder, registers, imm, f):
	r = random_register_non_zero() + random_register(1)
	builder.add_instruction('{} ${}, ${}, {}\n'.format(instr, *r, imm))
	e = f(registers[r[1]], imm) % 0x100000000
	builder.add_check_reg(r[0], e)
	builder.add_write_reg(r[0], registers[r[0]])


def generate_commands():
	
	builder = instruction_builder(instr_asm_filename, instr_cmd_filename)
	
	# initialize registers with random values
	registers = generate_register_values()
	registers[0] = 0
	for i in range(1, 32):
		builder.add_write_reg(i, registers[i])

	# register 0 should be unwritable
	regs = random_register(2)
	builder.add_instruction('add $0, ${}, ${}\n'.format(*regs))
	builder.add_check_reg(0, 0)

	check_op_3reg('add', builder, registers, lambda x, y: x + y)
	check_op_3reg('sub', builder, registers, lambda x, y: x - y)
	check_op_3reg('and', builder, registers, lambda x, y: x & y)
	check_op_3reg('or', builder, registers, lambda x, y: x | y)
	check_op_3reg('xor', builder, registers, lambda x, y: x ^ y)
	check_op_3reg('nor', builder, registers, lambda x, y: (x | y) ^ 0xFFFFFFFF)
	check_op_3reg('sll', builder, registers, lambda x, y: (x << (y & 0x1F)) & 0xFFFFFFFF)
	check_op_3reg('srl', builder, registers, lambda x, y: (x >> (y & 0x1F)) & 0xFFFFFFFF)
	check_op_3reg('sra', builder, registers, lambda x, y: ((x >> (y & 0x1F)) | ((0xFFFFFFFF if x >= 0x80000000 else 0) << (32 - (y & 0x1F)))) & 0xFFFFFFFF)
	check_op_2reg_i16('addi', builder, registers, lambda x, y: x + y)
	check_op_2reg_i16('sub', builder, registers, lambda x, y: x - y)
	check_op_2reg_imm('andi', builder, registers, random_uint(16), lambda x, y: x & sign_extend(y, 16, 32))
	check_op_2reg_imm('ori', builder, registers, random_uint(16), lambda x, y: x | sign_extend(y, 16, 32))
	check_op_2reg_imm('xori', builder, registers, random_uint(16), lambda x, y: x ^ sign_extend(y, 16, 32))
	check_op_2reg_imm('sll', builder, registers, random_uint(5), lambda x, y: (x << (y & 0x1F)) & 0xFFFFFFFF)
	check_op_2reg_imm('srl', builder, registers, random_uint(5), lambda x, y: (x >> (y & 0x1F)) & 0xFFFFFFFF)
	check_op_2reg_imm('sra', builder, registers, random_uint(5), lambda x, y: ((x >> (y & 0x1F)) | ((0xFFFFFFFF if x >= 0x80000000 else 0) << (32 - (y & 0x1F)))) & 0xFFFFFFFF)
	
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