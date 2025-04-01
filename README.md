# CH32V003-drives-DS18B20-temperature-sensor


#riscv32-unknown-elf-as -g CH32V003_DS18B20.S -o CH32V003_DS18B20.o
#riscv32-unknown-elf-ld -T CH32V003.ld -Map=final.map CH32V003_DS18B20.O
#riscv32-unknown-elf-objcopy -O ihex a.out CH32V003_DS18B20.hex

# measures temprature from ds18b20 and displays the reading via uart on console
# PD0 is input from DS18B20 , PD5:PD6 is uart TX:RX
# I2C for LCD , OLED
# pin PC1  used for SDA ,I2C 
# pin PC2  used for SCL ,I2C
