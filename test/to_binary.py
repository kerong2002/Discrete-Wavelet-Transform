input_file = open('in.txt', 'r')
output_file = open('out_2.txt', 'w')

for line in input_file:
    num = int(line.strip())
    binary_num = format(num, '08b')  # Convert number to 8-bit binary

    print(binary_num, file=output_file)

input_file.close()
output_file.close()
