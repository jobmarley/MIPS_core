import os
import random
import subprocess
import math

instr_asm_filename = 'instruction_test_asm.asm'
instr_cmd_filename = 'instruction_test_commands.txt'
instr_ram_filename = 'instruction_ram.coe'
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

def random_int_nonzero(bitsize):
	r = 0
	while r == 0:
		r = random_int(bitsize)
	return r
def random_uint_nonzero(bitsize):
	r = 0
	while r == 0:
		r = random_uint(bitsize)
	return r

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

# works on signed and unsigned
def unsigned_to_signed(u, size):
    if u < 0:
        return u
    if u & (1 << size - 1):
        return u - (1 << size)
    else:
        return u

def invert(u, size):
    u = to_unsigned(u, size)
    return ((1 << size) - 1) ^ u

# works on signed and unsigned
def to_unsigned(s, size):
  return s % (1 << size)

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

	def add_check_hilo(self, value):
		self.add_command('CHECK_HILO {:08X} {:08X}'.format((value >> 32) & 0xFFFFFFFF, value & 0xFFFFFFFF))
		
	def add_check_ram(self, address, value):
		self.add_command('CHECK_RAM {:08X} {:08X}'.format(address & 0xFFFFFFFF, value & 0xFFFFFFFF))

	def add_write_reg(self, reg, value):
		self.add_command('WRITE_REG {:08X} {:08X}'.format(reg, value))
		
	def add_write_hilo(self, value):
		self.add_command('WRITE_HILO {:08X} {:08X}'.format((value >> 32) & 0xFFFFFFFF, value & 0xFFFFFFFF))


	def add_command(self, cmd):
		self.test_commands.append(cmd)

	def write_asm_file(self):
		print('write asm file {}'.format(self.asm_filepath))
		with open(self.asm_filepath, 'w', encoding='ascii') as f:
			for x in self.instructions:
				f.write(x + '\n')
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
					f.write('# {}'.format(self.instructions[i]) + '\n')
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

def generate_memory_values(count):
	return [random_uint32() for i in range(0, count)]

# execute instr with 3 random registers, and check result which must be equal to f([r1], [r2], [rdest])
# then revert the register
def check_op_3reg(instr, builder, registers, f):
	r = random_register_non_zero() + random_register(2)
	builder.add_instruction('{} ${}, ${}, ${}'.format(instr, *r))
	e = f(registers[r[1]], registers[r[2]], registers[r[0]])
	e = to_unsigned(e, 32)
	e = e & 0xFFFFFFFF
	builder.add_check_reg(r[0], e)
	builder.add_write_reg(r[0], registers[r[0]])
	
# same as above but with random i16, f([r1], i16, [rdest])
def check_op_2reg_i16(instr, builder, registers, f):
	r = random_register_non_zero() + random_register(1)
	v = random_int16()
	builder.add_instruction('{} ${}, ${}, {}'.format(instr, *r, v))
	e = f(registers[r[1]], v, registers[r[0]])
	e = to_unsigned(e, 32)
	e = e & 0xFFFFFFFF
	builder.add_check_reg(r[0], e)
	builder.add_write_reg(r[0], registers[r[0]])
	
# same as above but with given immediate, f([r1], imm, [rdest])
def check_op_2reg_imm(instr, builder, registers, imm, f):
	r = random_register_non_zero() + random_register(1)
	builder.add_instruction('{} ${}, ${}, {}'.format(instr, *r, imm))
	e = f(registers[r[1]], imm, registers[r[0]])
	e = to_unsigned(e, 32)
	e = e & 0xFFFFFFFF
	builder.add_check_reg(r[0], e)
	builder.add_write_reg(r[0], registers[r[0]])
	
# same as check_op_3reg but target is hilo, [hilo] = f([r1], [r2], [hilo])
def check_op_2reg_hilo(instr, builder, registers, reghilo, f, syntax = '{} ${}, ${}'):
	r = random_register(2)
	builder.add_instruction(syntax.format(instr, *r))
	e = f(registers[r[0]], registers[r[1]], reghilo)
	e = to_unsigned(e, 64)
	e = e & 0xFFFFFFFFFFFFFFFF
	builder.add_check_hilo(e)
	builder.add_write_hilo(reghilo)

# same but result is a tuple (hi, lo)
def check_op_2reg_hilo2(instr, builder, registers, reghilo, f, syntax = '{} ${}, ${}'):
	r = random_register(2)
	builder.add_instruction(syntax.format(instr, *r))
	e = f(registers[r[0]], registers[r[1]], reghilo)
	e = to_unsigned(e[0], 32) & to_unsigned(e[1], 32)
	e = e & 0xFFFFFFFFFFFFFFFF
	builder.add_check_hilo(e)
	builder.add_write_hilo(reghilo)

# the registers values are given, this is to avoid corner cases with div by zero etc..
def check_op_2reg_nonrand_hilo2(instr, builder, registers, r1, r2, reghilo, f, syntax = '{} ${}, ${}'):
	r = random_register_non_zero(2)
	builder.add_write_reg(r[0], to_unsigned(r1, 32))
	builder.add_write_reg(r[1], to_unsigned(r2, 32))
	builder.add_instruction(syntax.format(instr, *r))
	e = f(r1, r2, reghilo)
	e = (to_unsigned(e[0], 32) << 32) | to_unsigned(e[1], 32)
	e = e & 0xFFFFFFFFFFFFFFFF
	builder.add_check_hilo(e)
	builder.add_write_hilo(reghilo)
	builder.add_write_reg(r[0], registers[r[0]])
	builder.add_write_reg(r[1], registers[r[1]])

# [rdest] = f(v, [rdest])
def check_op_1reg_imm(instr, builder, registers, v, f, syntax = '{} ${}, {}'):
	r = random_register_non_zero()
	builder.add_instruction(syntax.format(instr, *r, v))
	e = f(v, registers[r[0]])
	e = to_unsigned(e, 32)
	e = e & 0xFFFFFFFF
	builder.add_check_reg(r[0], e)
	builder.add_write_reg(r[0], registers[r[0]])
	
# [rdest] = f([r1], v, [rdest])
# write r with a random value before hand
# r and v are generated such as aligned([r1] + v) is a valid address
def check_op_ram(instr, alignment, builder, ram, registers, f):
	r = random_register_non_zero()
	base = random.randint(0, len(ram)*4-1);
	offset = random.randint(-base, len(ram)*4-1 - base)
	offset = offset - ((base + offset) % alignment)
	offset = clamp(offset, -0x8000, 0x7FFF)
	builder.add_write_reg(*r, base)
	check_op_1reg_imm(instr, builder, registers, offset, lambda y, z: f(base, y, z), '{{}} ${{}}, {{}}(${})'.format(*r))
	builder.add_write_reg(*r, registers[r[0]])


# check that
# [ram] = f(value, address, oldvalue)
def check_op_ram_store(instr, alignment, builder, ram, registers, f):
	r = random_register_non_zero() + random_register()
	base = random.randint(0, len(ram)*4-1);
	#print('base: ' + str(base))
	offset = random.randint(-base, len(ram)*4-1 - base)
	##print('offset: ' + str(offset))
	offset = offset - ((base + offset) % alignment)
	###print('offset: ' + str(offset))
	offset = clamp(offset, -0x8000, 0x7FFF)
	#print('offset: ' + str(offset))
	builder.add_write_reg(r[0], base)
	
	oldvalue = ram[(base + offset) // 4]
	#print('oldvalue: {:08X}'.format(oldvalue))
	value = f(registers[r[1]], base + offset, oldvalue)
	value = to_unsigned(value, 32)
	value = value & 0xFFFFFFFF
	builder.add_instruction('{} ${}, {}(${})'.format(instr, r[1], offset, r[0]))
	builder.add_check_ram((base + offset) // 4 * 4, value)
	builder.add_write_reg(r[0], registers[r[0]])

def write_memory_file(filepath, content):
	print('write ram file {}'.format(filepath))
	with open(filepath, 'w') as f:
		f.write('memory_initialization_radix=16;\n')
		f.write('memory_initialization_vector=\n')
		f.write(',\n'.join(['{:08X}'.format(x) for x in content]) + ';')
		f.flush()

def clamp(x, a, b):
	return max(min(x, b), a)

def get_ram(ram, address, size):
	return (ram[address // 4] >> ((address % 4) * 8)) & ((1 << size) - 1)


# from xilinx ip doc div_gen:
# Dividend = Quotient x Divisor + IntRmd (Equation 3-1)
# For signed mode with integer remainder, the sign of the quotient and remainder correspond exactly to Equation 3-1.
# Thus, 6/-4 = -1 REMD 2
# whereas -6/4 = -1 REMD -2

# python return a remainder always positive
def correct_signed_div(x, y):
    x = unsigned_to_signed(x, 32)
    y = unsigned_to_signed(y, 32)
    a, b = (x % y, x // y)
    if b < 0:
        b = b + 1
        a = a - y
    return a, b

def generate_commands():
	
	builder = instruction_builder(instr_asm_filename, instr_cmd_filename)
	
	# initialize registers with random values
	registers = generate_register_values()
	registers[0] = 0
	register_hilo = random_int(64)
	for i in range(1, 32):
		builder.add_write_reg(i, registers[i])
	builder.add_write_hilo(register_hilo)
		
	ram = generate_memory_values(1024)

	# register 0 should be unwritable
	regs = random_register(2)
	builder.add_instruction('add $0, ${}, ${}'.format(*regs))
	builder.add_check_reg(0, 0)

	# lambda parameters are (op1, op2, dest_register_previous_value)
	check_op_3reg('add', builder, registers, lambda x, y, z: x + y)
	check_op_3reg('sub', builder, registers, lambda x, y, z: unsigned_to_signed(x, 32) - unsigned_to_signed(y, 32))
	check_op_3reg('subu', builder, registers, lambda x, y, z: x - y)
	check_op_3reg('and', builder, registers, lambda x, y, z: x & y)
	check_op_3reg('or', builder, registers, lambda x, y, z: x | y)
	check_op_3reg('xor', builder, registers, lambda x, y, z: x ^ y)
	check_op_3reg('nor', builder, registers, lambda x, y, z: (x | y) ^ 0xFFFFFFFF)
	check_op_3reg('sll', builder, registers, lambda x, y, z: (x << (y & 0x1F)) & 0xFFFFFFFF)
	check_op_3reg('srl', builder, registers, lambda x, y, z: (x >> (y & 0x1F)) & 0xFFFFFFFF)
	check_op_3reg('sra', builder, registers, lambda x, y, z: ((x >> (y & 0x1F)) | ((0xFFFFFFFF if x >= 0x80000000 else 0) << (32 - (y & 0x1F)))) & 0xFFFFFFFF)
	check_op_3reg('slt', builder, registers, lambda x, y, z: 1 if unsigned_to_signed(x, 32) < unsigned_to_signed(y, 32) else 0)
	check_op_3reg('sltu', builder, registers, lambda x, y, z: 1 if x < y else 0)
	check_op_3reg('mul', builder, registers, lambda x, y, z: unsigned_to_signed(x, 32) * unsigned_to_signed(y, 32))
	check_op_2reg_hilo('mult', builder, registers, register_hilo, lambda x, y, z: unsigned_to_signed(x, 32) * unsigned_to_signed(y, 32))
	check_op_2reg_hilo('multu', builder, registers, register_hilo, lambda x, y, z: x * y)
	# llvm requires $0 as dest for normal div
	# Otherwise it matches a pseudo instruction "$rs = div $rs, $rt" where result is a GPR
	check_op_2reg_nonrand_hilo2('div', builder, registers, random_int(32), random_int_nonzero(32), register_hilo, lambda x, y, z: correct_signed_div(x, y), '{} $0, ${}, ${}')
	check_op_2reg_nonrand_hilo2('divu', builder, registers, random_uint(32), random_uint_nonzero(32), register_hilo, lambda x, y, z: (x % y, x // y), '{} $0, ${}, ${}')
	# test with smaller divisor value (otherwise we always get result 0 or 1)
	check_op_2reg_nonrand_hilo2('div', builder, registers, random_int(32), random_int_nonzero(16), register_hilo, lambda x, y, z: correct_signed_div(x, y), '{} $0, ${}, ${}')
	check_op_2reg_nonrand_hilo2('divu', builder, registers, random_uint(32), random_uint_nonzero(16), register_hilo, lambda x, y, z: (x % y, x // y), '{} $0, ${}, ${}')
	
	check_op_2reg_i16('addi', builder, registers, lambda x, y, z: x + y)
	check_op_2reg_i16('sub', builder, registers, lambda x, y, z: x - y)
	check_op_2reg_i16('subu', builder, registers, lambda x, y, z: x - sign_extend(y, 16, 32))
	check_op_2reg_imm('andi', builder, registers, random_uint(16), lambda x, y, z: x & sign_extend(y, 16, 32))
	check_op_2reg_imm('ori', builder, registers, random_uint(16), lambda x, y, z: x | sign_extend(y, 16, 32))
	check_op_2reg_imm('xori', builder, registers, random_uint(16), lambda x, y, z: x ^ sign_extend(y, 16, 32))
	check_op_2reg_imm('sll', builder, registers, random_uint(5), lambda x, y, z: (x << (y & 0x1F)) & 0xFFFFFFFF)
	check_op_2reg_imm('srl', builder, registers, random_uint(5), lambda x, y, z: (x >> (y & 0x1F)) & 0xFFFFFFFF)
	check_op_2reg_imm('sra', builder, registers, random_uint(5), lambda x, y, z: ((x >> (y & 0x1F)) | ((0xFFFFFFFF if x >= 0x80000000 else 0) << (32 - (y & 0x1F)))) & 0xFFFFFFFF)
	check_op_2reg_imm('slti', builder, registers, random_int(16), lambda x, y, z: 1 if unsigned_to_signed(x, 32) < y else 0)
	# this is weird, operand is a signed 16bits, signed extended to 32 and compared to the other operand
	check_op_2reg_imm('sltiu', builder, registers, random_int(16), lambda x, y, z: 1 if x < sign_extend(y, 16, 32) else 0)
	check_op_1reg_imm('lui', builder, registers, random_uint(16), lambda y, z: (z & 0xFFFF) | (y << 16))
	
	check_op_ram('lb', 1, builder, ram, registers, lambda x, y, z: sign_extend(get_ram(ram, x + y, 8), 8, 32))
	check_op_ram('lbu', 1, builder, ram, registers, lambda x, y, z: get_ram(ram, x + y, 8))
	check_op_ram('lh', 2, builder, ram, registers, lambda x, y, z: sign_extend(get_ram(ram, x + y, 16), 16, 32))
	check_op_ram('lhu', 2, builder, ram, registers, lambda x, y, z: get_ram(ram, x + y, 16))
	check_op_ram('lw', 4, builder, ram, registers, lambda x, y, z: get_ram(ram, x + y, 32))
	check_op_ram('lwl', 1, builder, ram, registers, lambda x, y, z: (z & (0xFFFFFFFF >> ((x + y) % 4 + 1) * 8)) | (get_ram(ram, (x + y) // 4 * 4, 32) << (3 - (x + y) % 4) * 8))
	check_op_ram('lwr', 1, builder, ram, registers, lambda x, y, z: (z & (0xFFFFFFFF << (4 - (x + y) % 4) * 8)) | (get_ram(ram, (x + y) // 4 * 4, 32) >> ((x + y) % 4) * 8))
	
	check_op_ram_store('sb', 1, builder, ram, registers, lambda value, addr, oldvalue: (oldvalue & invert(0xFF << addr % 4 * 8, 32)) | ((value & 0xFF) << addr % 4 * 8))
	check_op_ram_store('sh', 2, builder, ram, registers, lambda value, addr, oldvalue: (oldvalue & invert(0xFFFF << addr % 4 * 8, 32)) | ((value & 0xFFFF) << addr % 4 * 8))
	check_op_ram_store('sw', 4, builder, ram, registers, lambda value, addr, oldvalue: value)
	check_op_ram_store('swl', 1, builder, ram, registers, lambda value, addr, oldvalue: (oldvalue & (0xFFFFFFFF << (addr % 4 + 1) * 8)) | (value >> (3 - addr % 4) * 8))
	check_op_ram_store('swr', 1, builder, ram, registers, lambda value, addr, oldvalue: (oldvalue & (0xFFFFFFFF >> (4 - addr % 4) * 8)) | (value << (addr % 4) * 8))
	
	builder.generate_cmd_file()
	write_memory_file(instr_ram_filename, ram)
		
def clang_compile(filepath, outpath):
	print('compiling {}...'.format(filepath, outpath))
	err = subprocess.call([clang_path, '-c', '--target=mipsel', '-mips32', filepath, '-o', outpath])
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