import os
from pickle import TRUE
import random
import subprocess
import math

instr_asm_filename = 'instruction_test_asm.asm'
instr_cmd_filename = 'instruction_test_commands.txt'
instr_ram_filename = 'instruction_ram.coe'
clang_path = r'C:\Program Files\LLVM\bin\clang++'
lld_path = r'C:\Program Files\LLVM\bin\ld.lld'

WAIT_CYCLE_COUNT = 40

def random_register(count = 1):
	return random.sample([x for x in range(0, 32)], count)

def random_register_non_zero(count = 1):
	return random.sample([x for x in range(1, 32)], count)

def random_int(bitsize):
	return random.randint(-(1 << (bitsize - 1)), (1 << (bitsize - 1)) - 1)
def random_uint(bitsize):
	return random.randint(0, (1 << bitsize) - 1)

def random_int_positive(bitsize):
	return random.randint(1, (1 << (bitsize - 1)) - 1)
def random_int_negative(bitsize):
	return random.randint(-(1 << (bitsize - 1)), -1)

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
    s = s & ((1 << dst_size) - 1);
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
	def __init__(self, asm_filepath, cmd_filepath, registers, hilo, ram):
		self.test_commands = []
		self.instructions = []
		self.asm_filepath = asm_filepath
		self.outpath = cmd_filepath
		self.registers_initial = registers.copy()
		self.registers = registers
		self.hilo_initial = hilo
		self.hilo = hilo
		self.ram = ram
		self.instruction_bin_ofs = 0
		
	def wait(self, cycle_count):
		self.add_command('WAIT {:08X}'.format(cycle_count))
	def begin(self):
		self.add_command('BEGIN')
	def end(self):
		self.add_command('END')

	def reset_registers(self):
		for i in range(0, len(self.registers)):
			if self.registers[i] != self.registers_initial[i]:
				self.write_reg(i, self.registers_initial[i])
				self.registers[i] = self.registers_initial[i]
		if self.hilo != self.hilo_initial:
			self.write_hilo(self.hilo_initial)
			self.hilo = self.hilo_initial
		
	def force_reset_registers(self, regs):
		for r in regs:
			self.write_reg(r, self.registers_initial[r])
			
	def force_reset_hilo(self):
		self.write_hilo(self.hilo_initial)
		
	def set_register(self, i, v):
		self.registers[i] = to_unsigned(v, 32)
	def set_hilo(self, v):
		self.hilo = to_unsigned(v, 64)

	def get_register(self, i):
		return self.registers[i]
	def get_register_signed(self, i):
		return unsigned_to_signed(self.registers[i], 32)
	def get_hilo(self):
		return self.hilo
	def get_ram(self, address, size):
		return (self.ram[address // 4] >> ((address % 4) * 8)) & ((1 << size) - 1)

	# generate (base, offset) such as (base + offset) is a valid address with given alignment
	def random_ram_address(self, alignment):
		base = random.randint(0, len(self.ram)*4-1);
		offset = random.randint(-base, len(self.ram)*4-1 - base)
		offset = offset - ((base + offset) % alignment)
		offset = clamp(offset, -0x8000, 0x7FFF)
		return (base, offset)

	def execute(self, asm):
		self.test_commands.append('EXEC')
		self.instructions.append((self.instruction_bin_ofs , asm))
		self.instruction_bin_ofs = self.instruction_bin_ofs + 4
		
	def check_reg(self, reg, value):
		value = to_unsigned(value, 32)
		self.add_command('CHECK_REG {:08X} {:08X}'.format(reg, value))

	def check_branch(self, address, skip, execute_delay_slot):
		address = to_unsigned(address, 32)
		self.add_command('CHECK_BRANCH {:08X} {:08X} {:08X}'.format(address, skip, execute_delay_slot))
		
	def skip_bin_instruction(self):
		self.instruction_bin_ofs = self.instruction_bin_ofs + 4

	def skip_asm_line(self):
		self.add_command('SKIP_ASM_LINE');

	def check_hilo(self, value):
		value = to_unsigned(value, 64)
		self.add_command('CHECK_HILO {:08X} {:08X}'.format((value >> 32) & 0xFFFFFFFF, value & 0xFFFFFFFF))
		
	def check_ram(self, address, value):
		value = to_unsigned(value, 32)
		self.add_command('CHECK_RAM {:08X} {:08X}'.format(address & 0xFFFFFFFF, value & 0xFFFFFFFF))
		
	def write_pc(self, value):
		value = to_unsigned(value, 32)
		self.add_command('WRITE_PC {:08X}'.format(value))

	def write_reg(self, reg, value):
		value = to_unsigned(value, 32)
		self.registers[reg] = value
		self.add_command('WRITE_REG {:08X} {:08X}'.format(reg, value))
		
	def write_hilo(self, value):
		value = to_unsigned(value, 64)
		self.add_command('WRITE_HILO {:08X} {:08X}'.format((value >> 32) & 0xFFFFFFFF, value & 0xFFFFFFFF))


	def add_command(self, cmd):
		self.test_commands.append(cmd)

	def write_asm_file(self):
		print('write asm file {}'.format(self.asm_filepath))
		with open(self.asm_filepath, 'w', encoding='ascii') as f:
			for ofs, instr in self.instructions:
				f.write(instr + '\n')
			f.flush()

	def read_instruction_binary(self, filepath):
		l = []
		with open(filepath, 'rb') as f:
			for ofs, instr in self.instructions:
				f.seek(ofs)
				l.append(int.from_bytes(f.read(4), 'little'))
		return l;

	def write_command_file(self, binary_filepath):
		print('write cmd file {}'.format(self.asm_filepath))
		instr_bin = self.read_instruction_binary(binary_filepath)

		with open(self.outpath, 'w') as f:
			i = 0
			for c in self.test_commands:
				if c == 'EXEC':
					f.write('# {}'.format(self.instructions[i][1]) + '\n')
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
    if a != 0 and b < 0:
        b = b + 1
        a = a - y
    return a, b

def count_leading_one(x, size):
	for i in range(0, size):
		if (x >> size-1-i) & 1 == 0:
			return i
	return size

def count_leading_zero(x, size):
	for i in range(0, size):
		if (x >> size-1-i) & 1 == 1:
			return i
	return size

uint32_value_set = [0xFFFFFFFF, 0x80000000, 0x7FFFFFFF, 0xF9841754, 0x948, 1, 0]
int32_value_set = [-0x80000000, -0x58942391, -0x8574, -1, 0x7FFFFFFF, 0x19385095, 0x948, 1, 0]
uint16_value_set = [0xFFFF, 0x8000, 0x7FFF, 0xF984, 0x948, 0x43, 1, 0]
int16_value_set = [-0x8000, -0x5894, -0x85, -1, 0x7FFF, 0x1938, 0x94, 1, 0]
_0_31_value_set = [0, 1, 5, 15, 16, 30, 31]

def combine_value_sets(s1, s2):
	l = []
	for x in s1:
		for y in s2:
			l.append((x, y))
	return l

# execute syntax.format(regs..., imm_values...)
# test [rdest] = f(reg_values..., imm_values..., [rdest])
def test_regs_imm(builder : instruction_builder, reg_values, imm_values, syntax, f):
	r0 = random_register_non_zero()
	regs = write_random_registers(builder, *reg_values)
	builder.begin()
	e = f(*reg_values, *imm_values, builder.get_register(*r0))
	builder.check_reg(*r0, e)
	builder.execute(syntax.format(*r0, *regs, *imm_values))
	builder.set_register(*r0, e)
	builder.end()

# execute syntax.format(regs..., imm_values...)
# check if branch is correctly executed, f should return (address, jump, execute_delay_slot)
# if jump == False, we dont branch
def test_regs_imm_branch(builder : instruction_builder, current_address, reg_values, imm_values, syntax, f):
	regs = write_random_registers(builder, *reg_values)
	builder.write_pc(current_address)
	builder.begin()
	addr, jump, execute_delay_slot = f(*reg_values, *imm_values, current_address)
	builder.check_branch(addr, not jump, execute_delay_slot)
	builder.execute(syntax.format(*regs, *imm_values))
	builder.end()

# check if branch is correctly executed, f should return (address, jump, execute_delay_slot)
def test_regs_imm_branch_link(builder : instruction_builder, current_address, reg_values, imm_values, syntax, f):
	regs = write_random_registers(builder, *reg_values)
	builder.write_pc(current_address)
	builder.begin()
	
	addr, jump, execute_delay_slot = f(*reg_values, *imm_values, current_address)
	builder.check_branch(addr, not jump, execute_delay_slot)
	if jump:
		builder.check_reg(31, current_address + 8)
		builder.set_register(31, current_address + 8)

	builder.execute(syntax.format(*regs, *imm_values))
	builder.end()

# check if branch is correctly executed, f should return (address, jump, execute_delay_slot)
def test_regs_imm_branch_link_r(builder : instruction_builder, current_address, reg_values, imm_values, syntax, f):
	regs = write_random_registers(builder, 0, *reg_values)
	builder.write_pc(current_address)
	builder.begin()
	addr, jump, execute_delay_slot = f(*reg_values, *imm_values, current_address)
	builder.check_branch(addr, not jump, execute_delay_slot)
	builder.check_reg(regs[0], current_address + 8)
	builder.execute(syntax.format(*regs, *imm_values))
	builder.set_register(regs[0], current_address + 8)
	builder.end()

# execute syntax.format(regs..., imm_values...)
# test [hilo] = f(reg_values..., imm_values..., [hilo])
def test_regs_imm_check_hilo(builder : instruction_builder, reg_values, imm_values, syntax, f):
	regs = write_random_registers(builder, *reg_values)
	builder.begin()
	
	result = f(*reg_values, *imm_values, builder.get_hilo())
	if type(result) != int:
		result = ((result[0] & 0xFFFFFFFF) << 32) | (result[1] & 0xFFFFFFFF);
	builder.check_hilo(result)

	builder.execute(syntax.format(*regs, *imm_values))
	builder.set_hilo(result)
	builder.end()

def test_mfc0(builder : instruction_builder):
	# just test with register cop0 4: TLB pointer
	test_regs_imm(builder, [], [], 'mfc0 ${}, $4', lambda z: builder.get_register(32 + 4))
	
def test_mtc0(builder : instruction_builder):
	# just test with register cop0 4: TLB pointer
	r = random_register_non_zero()
	builder.begin()
	builder.execute('mtc0 ${}, $4'.format(*r))
	builder.wait(WAIT_CYCLE_COUNT)
	builder.check_reg(32 + 4, builder.get_register(r[0]))
	builder.write_reg(32 + 4, builder.get_register(32 + 4))
	builder.end()

def write_random_registers(builder:instruction_builder, *values):
	regs = random_register_non_zero(len(values))
	for r, v in zip(regs, values):
		builder.write_reg(r, v)
	return regs
		
def test_add(builder : instruction_builder):
	# s32 + s32
	s = combine_value_sets(int32_value_set, int32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'add ${}, ${}, ${}', lambda x, y, z: x + y)
	# u32 + u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'add ${}, ${}, ${}', lambda x, y, z: x + y)

	# addi
	# s32 + is16
	s = combine_value_sets(int32_value_set, int16_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'add ${}, ${}, {}', lambda x, y, z: x + y)

	# u32 + is16
	s = combine_value_sets(uint32_value_set, int16_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'add ${}, ${}, {}', lambda x, y, z: x + sign_extend(y, 16, 32))
	
def test_sub(builder : instruction_builder):
	# s32 - s32
	s = combine_value_sets(int32_value_set, int32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'sub ${}, ${}, ${}', lambda x, y, z: x - y)
		
def test_subu(builder : instruction_builder):
	# u32 - u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'subu ${}, ${}, ${}', lambda x, y, z: x - y)
		
def test_mul(builder : instruction_builder):
	# s32 * s32
	s = combine_value_sets(int32_value_set, int32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'mul ${}, ${}, ${}', lambda x, y, z: x * y)
		
def test_mult(builder : instruction_builder):
	# s32 * s32
	s = combine_value_sets(int32_value_set, int32_value_set)
	for x, y in s:
		test_regs_imm_check_hilo(builder, [x, y], [], 'mult ${}, ${}', lambda x, y, z: x * y)
		
def test_multu(builder : instruction_builder):
	# u32 * u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm_check_hilo(builder, [x, y], [], 'multu ${}, ${}', lambda x, y, z: x * y)

def test_div(builder : instruction_builder):
	# s32 / s32
	s = combine_value_sets(int32_value_set, [x for x in int32_value_set if x != 0])
	
	for x, y in s:
		test_regs_imm_check_hilo(builder, [x, y], [], 'div $0, ${}, ${}', lambda x, y, z: correct_signed_div(x, y))
		
def test_divu(builder : instruction_builder):
	# u32 / u32
	s = combine_value_sets(uint32_value_set, [x for x in uint32_value_set if x != 0])
	for x, y in s:
		test_regs_imm_check_hilo(builder, [x, y], [], 'divu $0, ${}, ${}', lambda x, y, z: (x % y, x // y))


def test_and(builder : instruction_builder):
	# u32 & u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'and ${}, ${}, ${}', lambda x, y, z: x & y)

	# u32 & iu16
	s = combine_value_sets(uint32_value_set, uint16_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'andi ${}, ${}, {}', lambda x, y, z: x & y)

def test_or(builder : instruction_builder):
	# u32 | u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'or ${}, ${}, ${}', lambda x, y, z: x | y)

	# u32 | iu16
	s = combine_value_sets(uint32_value_set, uint16_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'ori ${}, ${}, {}', lambda x, y, z: x | y)
		
def test_xor(builder : instruction_builder):
	# u32 ^ u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'xor ${}, ${}, ${}', lambda x, y, z: x ^ y)

	# u32 ^ iu16
	s = combine_value_sets(uint32_value_set, uint16_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'xori ${}, ${}, {}', lambda x, y, z: x ^ y)

def test_nor(builder : instruction_builder):
	f = lambda x, y, z: (x | y) ^ 0xFFFFFFFF
	f2 = lambda x, y, z: (x | sign_extend(y, 16, 32)) ^ 0xFFFFFFFF

	# u32 nor u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'nor ${}, ${}, ${}', f)

def test_sll(builder : instruction_builder):
	f = lambda x, y, z: (x << (y & 0x1F)) & 0xFFFFFFFF
	
	# u32 sll u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'sll ${}, ${}, ${}', f)

	# u32 sll 0-32
	s = combine_value_sets(uint32_value_set, _0_31_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'sll ${}, ${}, ${}', f)

	# u32 sll 0-32
	s = combine_value_sets(uint32_value_set, _0_31_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'sll ${}, ${}, {}', f)
		
def test_srl(builder : instruction_builder):
	f = lambda x, y, z: (x >> (y & 0x1F)) & 0xFFFFFFFF
	
	# u32 srl u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'srl ${}, ${}, ${}', f)

	# u32 srl 0-32
	s = combine_value_sets(uint32_value_set, _0_31_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'srl ${}, ${}, ${}', f)

	# u32 srl 0-32
	s = combine_value_sets(uint32_value_set, _0_31_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'srl ${}, ${}, {}', f)

def test_sra(builder : instruction_builder):
	f = lambda x, y, z: ((x >> (y & 0x1F)) | ((0xFFFFFFFF if x >= 0x80000000 else 0) << (32 - (y & 0x1F)))) & 0xFFFFFFFF
	
	# u32 sra u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'sra ${}, ${}, ${}', f)

	# u32 sra 0-32
	s = combine_value_sets(uint32_value_set, _0_31_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'sra ${}, ${}, ${}', f)

	# u32 sra 0-32
	s = combine_value_sets(uint32_value_set, _0_31_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'sra ${}, ${}, {}', f)

def test_slt(builder : instruction_builder):
	f = lambda x, y, z: 1 if x < y else 0

	# s32 < s32
	s = combine_value_sets(int32_value_set, int32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'slt ${}, ${}, ${}', f)
		
	# s32 < is16
	s = combine_value_sets(int32_value_set, int16_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'slti ${}, ${}, {}', f)
		
def test_sltu(builder : instruction_builder):
	f = lambda x, y, z: 1 if x < y else 0
	f2 = lambda x, y, z: 1 if x < sign_extend(y, 16, 32) else 0

	# u32 < u32
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'sltu ${}, ${}, ${}', f)

	# u32 < iu16
	s = combine_value_sets(uint32_value_set, int16_value_set)
	for x, y in s:
		test_regs_imm(builder, [x], [y], 'sltiu ${}, ${}, {}', f2)
		
def test_movn(builder : instruction_builder):
	f = lambda x, y, z: x if y != 0 else z

	# u32 != 0
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'movn ${}, ${}, ${}', f)
		
def test_movz(builder : instruction_builder):
	f = lambda x, y, z: x if y == 0 else z

	# u32 == 0
	s = combine_value_sets(uint32_value_set, uint32_value_set)
	for x, y in s:
		test_regs_imm(builder, [x, y], [], 'movz ${}, ${}, ${}', f)

def test_lui(builder : instruction_builder):
	f = lambda y, z: y << 16
	
	s = uint16_value_set
	for x in s:
		test_regs_imm(builder, [], [x], 'lui ${}, {}', f)

def test_clo(builder : instruction_builder):
	f = lambda y, z: count_leading_one(y, 32)
	
	s = uint16_value_set
	for x in s:
		test_regs_imm(builder, [x], [], 'clo ${}, ${}', f)
	s = uint32_value_set
	for x in s:
		test_regs_imm(builder, [x], [], 'clo ${}, ${}', f)

def test_clo(builder : instruction_builder):
	f = lambda y, z: count_leading_zero(y, 32)
	
	s = uint16_value_set
	for x in s:
		test_regs_imm(builder, [x], [], 'clz ${}, ${}', f)
	s = uint32_value_set
	for x in s:
		test_regs_imm(builder, [x], [], 'clz ${}, ${}', f)

def test_lb(builder : instruction_builder):
	f = lambda x, y, z: sign_extend(builder.get_ram(x + y, 8), 8, 32)
	
	base, ofs = builder.random_ram_address(4)
	test_regs_imm(builder, [base], [ofs+0], 'lb ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+1], 'lb ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+2], 'lb ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+3], 'lb ${0}, {2}(${1})', f)

def test_lbu(builder : instruction_builder):
	f = lambda x, y, z: builder.get_ram(x + y, 8)
	
	base, ofs = builder.random_ram_address(4)
	test_regs_imm(builder, [base], [ofs+0], 'lbu ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+1], 'lbu ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+2], 'lbu ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+3], 'lbu ${0}, {2}(${1})', f)

def test_lh(builder : instruction_builder):
	f = lambda x, y, z: sign_extend(builder.get_ram(x + y, 16), 16, 32)
	
	base, ofs = builder.random_ram_address(4)
	test_regs_imm(builder, [base], [ofs+0], 'lh ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+2], 'lh ${0}, {2}(${1})', f)

def test_lhu(builder : instruction_builder):
	f = lambda x, y, z: builder.get_ram(x + y, 16)
	
	base, ofs = builder.random_ram_address(4)
	test_regs_imm(builder, [base], [ofs+0], 'lhu ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+2], 'lhu ${0}, {2}(${1})', f)

def test_lw(builder : instruction_builder):
	f = lambda x, y, z: builder.get_ram(x + y, 32)
	
	base, ofs = builder.random_ram_address(4)
	test_regs_imm(builder, [base], [ofs+0], 'lw ${0}, {2}(${1})', f)
	
def test_lwl(builder : instruction_builder):
	f = lambda x, y, z: (z & (0xFFFFFFFF >> ((x + y) % 4 + 1) * 8)) | (builder.get_ram((x + y) // 4 * 4, 32) << (3 - (x + y) % 4) * 8)
	
	base, ofs = builder.random_ram_address(4)
	test_regs_imm(builder, [base], [ofs+0], 'lwl ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+1], 'lwl ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+2], 'lwl ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+3], 'lwl ${0}, {2}(${1})', f)

def test_lwr(builder : instruction_builder):
	f = lambda x, y, z: (z & (0xFFFFFFFF << (4 - (x + y) % 4) * 8)) | (builder.get_ram((x + y) // 4 * 4, 32) >> ((x + y) % 4) * 8)
	
	base, ofs = builder.random_ram_address(4)
	test_regs_imm(builder, [base], [ofs+0], 'lwr ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+1], 'lwr ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+2], 'lwr ${0}, {2}(${1})', f)
	test_regs_imm(builder, [base], [ofs+3], 'lwr ${0}, {2}(${1})', f)

# execute syntax.format(regs..., imm_values...)
# test [ram] = f(reg_values..., imm_values..., [ram])
def test_regs_imm_check_ram(builder : instruction_builder, reg_values, imm_values, address, syntax, f):
	regs = write_random_registers(builder, *reg_values)
	builder.begin()
	builder.execute(syntax.format(*regs, *imm_values))
	e = f(*reg_values, *imm_values, address, builder.get_ram(address // 4 * 4, 32))
	e = e & 0xFFFFFFFF
	builder.wait(WAIT_CYCLE_COUNT)
	builder.check_ram(address // 4 * 4, e)
	builder.ram[address // 4] = e
	builder.end()

def test_sb(builder : instruction_builder):
	f = lambda value, base, ofs, addr, oldvalue: (oldvalue & invert(0xFF << addr % 4 * 8, 32)) | ((value & 0xFF) << addr % 4 * 8)

	base, ofs = builder.random_ram_address(4)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+0], base + ofs + 0, 'sb ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+1], base + ofs + 1, 'sb ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+2], base + ofs + 2, 'sb ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+3], base + ofs + 3, 'sb ${0}, {2}(${1})', f)
	
def test_sh(builder : instruction_builder):
	f = lambda value, base, ofs, addr, oldvalue: (oldvalue & invert(0xFFFF << addr % 4 * 8, 32)) | ((value & 0xFFFF) << addr % 4 * 8)

	base, ofs = builder.random_ram_address(4)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+0], base + ofs, 'sh ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+2], base + ofs + 2, 'sh ${0}, {2}(${1})', f)

def test_sw(builder : instruction_builder):
	f = lambda value, base, ofs, addr, oldvalue: value

	base, ofs = builder.random_ram_address(4)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+0], base + ofs, 'sw ${0}, {2}(${1})', f)

def test_swl(builder : instruction_builder):
	f = lambda value, base, ofs, addr, oldvalue: (oldvalue & (0xFFFFFFFF << (addr % 4 + 1) * 8)) | (value >> (3 - addr % 4) * 8)

	base, ofs = builder.random_ram_address(4)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+0], base + ofs + 0, 'swl ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+1], base + ofs + 1, 'swl ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+2], base + ofs + 2, 'swl ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+3], base + ofs + 3, 'swl ${0}, {2}(${1})', f)

def test_swr(builder : instruction_builder):
	f = lambda value, base, ofs, addr, oldvalue: (oldvalue & (0xFFFFFFFF >> (4 - addr % 4) * 8)) | (value << (addr % 4) * 8)

	base, ofs = builder.random_ram_address(4)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+0], base + ofs + 0, 'swr ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+1], base + ofs + 1, 'swr ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+2], base + ofs + 2, 'swr ${0}, {2}(${1})', f)
	test_regs_imm_check_ram(builder, [random_uint(32), base], [ofs+3], base + ofs + 3, 'swr ${0}, {2}(${1})', f)

def test_j(builder : instruction_builder):
	f = lambda ofs, current_addr: ((current_addr & 0xF0000000) | ofs, True, True)
	
	# the address in asm is absolute
	# we wont reach 1 << 26 addressing, so higher bits would be 0
	# but if we did, that means jumping to below (eg. from FF000000 to 00000000) that would fail, or generate pseudo instructions I think
	# in the test, we would get the higher bits of current_address
	ofs = random_uint(26) << 2
	current_address = random_uint(30) << 2
	test_regs_imm_branch(builder, current_address, [], [ofs], 'j {}', f)
	builder.skip_bin_instruction()

def test_jal(builder : instruction_builder):
	f = lambda ofs, current_addr: ((current_addr & 0xF0000000) | ofs, True, True)

	ofs = random_uint(26) << 2
	current_address = random_uint(30) << 2
	test_regs_imm_branch_link(builder, current_address, [], [ofs], 'jal {}', f)
	builder.skip_bin_instruction()
	
def test_jr(builder : instruction_builder):
	f = lambda r, current_addr: (r, True, True)
	
	ofs = random_uint(30) << 2
	current_address = random_uint(30) << 2
	test_regs_imm_branch(builder, current_address, [ofs], [], 'jr ${}', f)
	builder.skip_bin_instruction()
	
def test_jalr(builder : instruction_builder):
	f = lambda r, current_addr: (r, True, True)
	
	ofs = random_uint(30) << 2
	current_address = random_uint(30) << 2
	test_regs_imm_branch_link_r(builder, current_address, [ofs], [], 'jalr ${}, ${}', f)
	builder.skip_bin_instruction()

def test_beq(builder : instruction_builder):
	f = lambda r1, r2, ofs, current_addr: (current_addr + ofs, r1 == r2, True)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x, y in combine_value_sets(int16_value_set, int16_value_set):
		test_regs_imm_branch(builder, current_address, [x, y], [ofs], 'beq ${}, ${}, .+{}', f)
		builder.skip_bin_instruction()
		
def test_beql(builder : instruction_builder):
	# delay slot only if branch is taken
	f = lambda r1, r2, ofs, current_addr: (current_addr + ofs, r1 == r2, r1 == r2)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x, y in combine_value_sets(int16_value_set, int16_value_set):
		test_regs_imm_branch(builder, current_address, [x, y], [ofs], 'beql ${}, ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_bne(builder : instruction_builder):
	f = lambda r1, r2, ofs, current_addr: (current_addr + ofs, r1 != r2, True)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x, y in combine_value_sets(int16_value_set, int16_value_set):
		test_regs_imm_branch(builder, current_address, [x, y], [ofs], 'bne ${}, ${}, .+{}', f)
		builder.skip_bin_instruction()
		
def test_bnel(builder : instruction_builder):
	# delay slot only if branch is taken
	f = lambda r1, r2, ofs, current_addr: (current_addr + ofs, r1 != r2, r1 != r2)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x, y in combine_value_sets(int16_value_set, int16_value_set):
		test_regs_imm_branch(builder, current_address, [x, y], [ofs], 'bnel ${}, ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_bgez(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 >= 0, True)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch(builder, current_address, [x], [ofs], 'bgez ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_bgezl(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 >= 0, r1 >= 0)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch(builder, current_address, [x], [ofs], 'bgezl ${}, .+{}', f)
		builder.skip_bin_instruction()
		
def test_bgezal(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 >= 0, True)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch_link(builder, current_address, [x], [ofs], 'bgezal ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_bgezall(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 >= 0, r1 >= 0)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch_link(builder, current_address, [x], [ofs], 'bgezall ${}, .+{}', f)
		builder.skip_bin_instruction()
		
def test_bgtz(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 > 0, True)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch(builder, current_address, [x], [ofs], 'bgtz ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_bgtzl(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 > 0, r1 > 0)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch(builder, current_address, [x], [ofs], 'bgtzl ${}, .+{}', f)
		builder.skip_bin_instruction()
		
def test_blez(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 <= 0, True)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch(builder, current_address, [x], [ofs], 'blez ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_blezl(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 <= 0, r1 <= 0)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch(builder, current_address, [x], [ofs], 'blezl ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_bltz(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 < 0, True)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch(builder, current_address, [x], [ofs], 'bltz ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_bltzl(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 < 0, r1 < 0)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch(builder, current_address, [x], [ofs], 'bltzl ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_bltzal(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 < 0, True)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch_link(builder, current_address, [x], [ofs], 'bltzal ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_bltzall(builder : instruction_builder):
	f = lambda r1, ofs, current_addr: (current_addr + ofs, r1 < 0, r1 < 0)

	ofs = random_int(16) << 2
	current_address = random.randint(max(-ofs, 0), min(0x800000000 - 4 - ofs, 0x800000000 - 4))
	current_address = current_address // 4 * 4
	for x in int16_value_set:
		test_regs_imm_branch_link(builder, current_address, [x], [ofs], 'bltzall ${}, .+{}', f)
		builder.skip_bin_instruction()

def test_dependency(builder : instruction_builder):
	# test div, mfhi
	regs = random_register_non_zero(3)
	v0 = random_uint(32)
	v1 = random_uint(8)
	builder.write_reg(regs[0], v0)
	builder.write_reg(regs[1], v1)
	builder.begin()
	
	result = correct_signed_div(v0, v1)
	if type(result) != int:
		result = ((result[0] & 0xFFFFFFFF) << 32) | (result[1] & 0xFFFFFFFF);
	builder.check_hilo(result)
	hi = result >> 32
	builder.check_reg(regs[2], hi)

	builder.execute('div $0, ${}, ${}'.format(*regs[:2]))
	builder.execute('mfhi ${}'.format(regs[2]))
	builder.wait(30)
	builder.set_hilo(result)
	builder.set_register(regs[2], hi)
	builder.end()

	# test mul, add
	regs = random_register_non_zero(5)
	v0 = random_uint(32)
	v1 = random_uint(32)
	v2 = random_uint(32)
	builder.write_reg(regs[0], v0)
	builder.write_reg(regs[1], v1)
	builder.write_reg(regs[2], v2)
	builder.begin()
	
	mul_res = (v0 * v1) & 0xFFFFFFFF
	builder.check_reg(regs[3], mul_res)
	add_res = (mul_res + v2) & 0xFFFFFFFF
	builder.check_reg(regs[4], add_res)

	builder.execute('mul ${}, ${}, ${}'.format(regs[3], regs[0], regs[1]))
	builder.execute('add ${}, ${}, ${}'.format(regs[4], regs[3], regs[2]))
	builder.set_register(regs[3], mul_res)
	builder.set_register(regs[4], add_res)
	builder.end()

	# test mfhi, mtlo
	regs = random_register_non_zero(1)
	v1 = random_uint(32)
	v2 = random_uint(32)
	builder.write_hilo((v1 << 32) | v2)
	builder.begin()
	
	builder.check_reg(regs[0], v1)
	builder.check_hilo((v1 << 32) | v1)

	builder.execute('mfhi ${}'.format(regs[0]))
	builder.execute('mtlo ${}'.format(regs[0]))
	builder.set_register(regs[0], v1)
	builder.set_hilo((v1 << 32) | v1)
	builder.end()

def generate_commands():
	
	registers = generate_register_values()
	registers[0] = 0
	register_hilo = random_int(64)
	ram = generate_memory_values(1024)
	ram_initial = ram.copy()

	builder = instruction_builder(instr_asm_filename, instr_cmd_filename, registers, register_hilo, ram)
	
	# initialize registers with random values
	for i in range(1, 64):
		builder.write_reg(i, registers[i])
	builder.write_hilo(register_hilo)
		

	# register 0 should be unwritable
	#regs = random_register(2)
	#builder.execute('add $0, ${}, ${}'.format(*regs))
	#builder.check_reg(0, 0)
	
	test_add(builder)
	test_sub(builder)
	test_subu(builder)
	test_and(builder)
	test_or(builder)
	test_xor(builder)
	test_nor(builder)
	test_sll(builder)
	test_srl(builder)
	test_sra(builder)
	test_slt(builder)
	test_sltu(builder)
	test_mul(builder)
	test_mult(builder)
	test_multu(builder)
	test_div(builder)
	test_divu(builder)
	
	test_movn(builder)
	test_movz(builder)

	#test_mfc0(builder)
	#test_mtc0(builder)
	
	test_lui(builder)
	
	test_lb(builder)
	test_lbu(builder)
	test_lh(builder)
	test_lhu(builder)
	test_lw(builder)
	test_lwl(builder)
	test_lwr(builder)
	
	test_sb(builder)
	test_sh(builder)
	test_sw(builder)
	test_swl(builder)
	test_swr(builder)
	
	test_j(builder)
	test_jal(builder)
	test_jalr(builder)
	test_jr(builder)
	test_beq(builder)
	test_beql(builder)
	test_bne(builder)
	test_bnel(builder)
	test_bgez(builder)
	test_bgezl(builder)
	test_bgezal(builder)
	test_bgezall(builder)
	test_bgtz(builder)
	test_bgtzl(builder)
	test_blez(builder)
	test_blezl(builder)
	test_bltz(builder)
	test_bltzl(builder)
	test_bltzal(builder)
	test_bltzall(builder)

	test_dependency(builder)

	builder.generate_cmd_file()
	write_memory_file(instr_ram_filename, ram_initial)
		
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