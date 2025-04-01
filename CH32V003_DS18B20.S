#riscv32-unknown-elf-as -g CH32V003_DS18B20.S -o CH32V003_DS18B20.o
#riscv32-unknown-elf-ld -T CH32V003.ld -Map=final.map CH32V003_DS18B20.O
#riscv32-unknown-elf-objcopy -O ihex a.out CH32V003_DS18B20.hex

# measures temprature from ds18b20 and displays the reading via uart on console
# PD0 is input from DS18B20 , PD5:PD6 is uart TX:RX
# 
# pin PC1  used for SDA ,I2C
# pin PC2  used for SCL ,I2C

.equ SRAM_start, 0x20000000
.equ SRAM_end, 0x20000800
.equ STACK, 0x20000800
.equ TIM2_BASE, 0x40000000
.equ W_WDG_BASE, 0x40002C00
.equ I_WDG_BASE, 0x40003000
.equ I2C_BASE, 0x40005400
.equ PWR_BASE, 0x40007000
.equ AFIO_BASE, 0x40010000
.equ EXTI_BASE, 0x40010400
.equ PORTA_BASE, 0x40010800
.equ PORTC_BASE, 0x40011000
.equ PORTD_BASE, 0x40011400
.equ ADC_BASE, 0x40012400
.equ TIM1_BASE, 0x40012C00
.equ SPI_BASE, 0x40013000
.equ USART_BASE, 0x40013800
.equ DMA_BASE, 0x40020000
.equ RCC_BASE, 0x40021000
.equ FLASH_INTERFACE_BASE, 0x40022000
.equ EXTENDED_MEM_BASE, 0x40023800
.equ CORE_PRIVATE_BASE, 0xE0000000
.equ FLASH_BASE, 0x08000000
.equ R32_PWR_CTLR, 0x40007000 	#Power control register
.equ R32_PWR_CSR, 0x40007004 	#Power control/status register
.equ R32_PWR_AWUCSR, 0x40007008 	#Auto-wakeup control/status register
.equ R32_PWR_AWUWR, 0x4000700C		#Auto-wakeup window comparison value register
.equ R32_PWR_AWUPSC, 0x40007010 	#Auto-wakeup crossover factor register
.equ R32_RCC_CTLR, 0x40021000 		#Clock control register 0x0000xx83
.equ R32_RCC_CFGR0, 0x40021004 		#Clock configuration register 0 0x00000000
.equ R32_RCC_INTR, 0x40021008 		#Clock interrupt register 0x00000000
.equ R32_RCC_APB2PRSTR, 0x4002100C 	#APB2 peripheral reset register 0x00000000
.equ R32_RCC_APB1PRSTR, 0x40021010 	# APB1 peripheral reset register 0x00000000
.equ R32_RCC_AHBPCENR, 0x40021014 	#AHB peripheral clock enable register 0x00000014
.equ R32_RCC_APB2PCENR, 0x40021018 	#APB2 peripheral clock enable register 0x00000000
.equ R32_RCC_APB1PCENR, 0x4002101C 	#APB1 peripheral clock enable register 0x00000000
.equ R32_RCC_RSTSCKR, 0x40021024   	#Control/status register

.equ R16_IWDG_CTLR, 0x40003000 		#Control register 0x0000
.equ R16_IWDG_PSCR, 0x40003004		#Prescaler register 0x0000
.equ R16_IWDG_RLDR, 0x40003008 		#Reload register 0x0FFF
.equ R16_IWDG_STATR, 0x4000300C 	#Status register

.equ R16_WWDG_CTLR, 0x40002C00 		#Control register 0x007F
.equ R16_WWDG_CFGR, 0x40002C04 		#Configuration Register 0x007F
.equ R16_WWDG_STATR, 0x40002C08 	#Status Register

.equ R32_EXTI_INTENR, 0x40010400 	#Interrupt enable register 0x00000000
.equ R32_EXTI_EVENR,  0x40010404 	#Event enable register 0x00000000
.equ R32_EXTI_RTENR, 0x40010408 	#Rising edge trigger enable register 0x00000000
.equ R32_EXTI_FTENR, 0x4001040C 	#Falling edge trigger enable register 0x00000000
.equ R32_EXTI_SWIEVR, 0x40010410 	#Soft interrupt event register 0x00000000
.equ R32_EXTI_INTFR, 0x40010414 	#Interrupt flag register

.equ R32_PFIC_ISR1, 0xE000E000 		#PFIC interrupt enable status register 1
.equ R32_PFIC_ISR2, 0xE000E004 		#PFIC interrupt enable status register 2 
.equ R32_PFIC_IPR1, 0xE000E020 		#PFIC interrupt pending status register 1 
.equ R32_PFIC_IPR2, 0xE000E024 		#PFIC interrupt pending status register 2 
.equ R32_PFIC_ITHRESDR, 0xE000E040 	#PFIC interrupt priority threshold configuration register
.equ R32_PFIC_CFGR, 0xE000E048 		#PFIC interrupt configuration register
.equ R32_PFIC_GISR, 0xE000E04C 		#PFIC interrupt global status register 
.equ R32_PFIC_VTFIDR, 0xE000E050 	#PFIC VTF interrupt ID configuration register
.equ R32_PFIC_VTFADDRR0, 0xE000E060 	#PFIC VTF interrupt 0 offset address register
.equ R32_PFIC_VTFADDRR1, 0xE000E064 	#PFIC VTF interrupt 1 offset address register
.equ R32_PFIC_IENR1, 0xE000E100		#PFIC interrupt enable setting register 1 
.equ R32_PFIC_IENR2, 0xE000E104 	#PFIC interrupt enable setting register 2 
.equ R32_PFIC_IRER1, 0xE000E180 	#PFIC interrupt enable clear register 1 
.equ R32_PFIC_IRER2, 0xE000E184 	#PFIC interrupt enable clear register 2 
.equ R32_PFIC_IPSR1, 0xE000E200 	#PFIC interrupt pending setting register 1 
.equ R32_PFIC_IPSR2, 0xE000E204 	#PFIC interrupt pending setting register 2 
.equ R32_PFIC_IPRR1, 0xE000E280 	#PFIC interrupt hang clear register 1 
.equ R32_PFIC_IPRR2, 0xE000E284 	#PFIC interrupt hang clear register 2 
.equ R32_PFIC_IACTR1, 0xE000E300 	#PFIC interrupt activation status register1
.equ R32_PFIC_IACTR2, 0xE000E304 	#PFIC interrupt activation status register2
.equ R32_PFIC_IPRIOR1, 0xE000E400 	#PFIC interrupt priority configuration register
.equ R32_PFIC_IPRIOR2, 0xE000E401 	#PFIC interrupt priority configuration register
.equ R32_PFIC_SCTLR, 0xE000ED10 	#PFIC system control register

.equ INTSYSCR, 0x804 			#Interrupt System Control Register
.equ MTVEC, 0x305 			#Exception Entry Base Address Register
.equ DBGMCU_CR, 0x7C0  			#Debug MCU Configuration Register (CSR)
 
.equ R32_STK_CTLR, 0xE000F000 		#System count control register 
.equ R32_STK_SR, 0xE000F004 		#System count status register 
.equ R32_STK_CNTR, 0xE000F008		# System counter low register 
.equ R32_STK_CMPR, 0xE000F010 		#Counting comparison low register


.equ R32_GPIOA_CFGLR, 0x40010800 	#PA port configuration register low 0x44444444
.equ R32_GPIOC_CFGLR, 0x40011000 	#PC port configuration register low 0x44444444
.equ R32_GPIOD_CFGLR, 0x40011400 	#PD port configuration register low 0x44444444
.equ R32_GPIOA_INDR, 0x40010808 	#PA port input data register 0x0000XXXX
.equ R32_GPIOC_INDR, 0x40011008 	#PC port input data register 0x0000XXXX
.equ R32_GPIOD_INDR, 0x40011408 	#PD port input data register 0x0000XXXX
.equ R32_GPIOA_OUTDR, 0x4001080C 	#PA port output data register 0x00000000
.equ R32_GPIOC_OUTDR, 0x4001100C 	#PC port output data register 0x00000000
.equ R32_GPIOD_OUTDR, 0x4001140C 	#PD port output data register 0x00000000
.equ R32_GPIOA_BSHR, 0x40010810 	#PA port set/reset register 0x00000000
.equ R32_GPIOC_BSHR, 0x40011010 	#PC port set/reset register 0x00000000
.equ R32_GPIOD_BSHR, 0x40011410 	#PD port set/reset register 0x00000000
.equ R32_GPIOA_BCR, 0x40010814 		#PA port reset register 0x00000000
.equ R32_GPIOC_BCR, 0x40011014 		#PC port reset register
.equ R32_GPIOD_BCR, 0x40011414 		#PD port reset register 0x00000000
.equ R32_GPIOA_LCKR, 0x40010818 	#PA port configuration lock register 0x00000000
.equ R32_GPIOC_LCKR, 0x40011018 	#PC port configuration lock register 0x00000000
.equ R32_GPIOD_LCKR, 0x40011418 	#PD port configuration lock register 
.equ R32_AFIO_PCFR1, 0x40010004		#AFIO Remap Register 1
.equ R32_AFIO_EXTICR, 0x40010008 	#External interrupt configuration register 1

.equ R32_DMA_INTFR, 0x40020000 		#DMA interrupt status register 0x00000000
.equ R32_DMA_INTFCR, 0x40020004 	#DMA interrupt flag clear register 0x00000000
.equ R32_DMA_CFGR1, 0x40020008 		#DMA channel 1 configuration register 0x00000000
.equ R32_DMA_CNTR1, 0x4002000C 		#DMA channel 1 number of data register
.equ R32_DMA_PADDR1, 0x40020010 	#DMA channel 1 peripheral address register 0x00000000
.equ R32_DMA_MADDR1, 0x40020014 	#DMA channel 1 memory address register 0x00000000
.equ R32_DMA_CFGR2, 0x4002001C 		#DMA channel 2 configuration register 0x00000000
.equ R32_DMA_CNTR2, 0x40020020 		#DMA channel 2 number of data register 0x00000000
.equ R32_DMA_PADDR2, 0x40020024 	#DMA channel 2 peripheral address register 0x00000000
.equ R32_DMA_MADDR2, 0x40020028 	#DMA channel 2 memory address register 0x00000000
.equ R32_DMA_CFGR3, 0x40020030 		#DMA channel 3 configuration register 0x00000000
.equ R32_DMA_CNTR3, 0x40020034 		#DMA channel 3 number of data register 0x00000000
.equ R32_DMA_PADDR3, 0x40020038 	#DMA channel 3 peripheral address register 0x00000000
.equ R32_DMA_MADDR3, 0x4002003C 	#DMA channel 3 memory address register 0x00000000
.equ R32_DMA_CFGR4, 0x40020044 		#DMA channel 4 configuration register 0x00000000
.equ R32_DMA_CNTR4, 0x40020048 		#DMA channel 4 number of data register 0x00000000
.equ R32_DMA_PADDR4, 0x4002004C 	#DMA channel 4 peripheral address register 0x00000000
.equ R32_DMA_MADDR4, 0x40020050 	#DMA channel 4 memory address register 0x00000000
.equ R32_DMA_CFGR5, 0x40020058		#DMA channel 5 configuration register 0x00000000
.equ R32_DMA_CNTR5, 0x4002005C 		#DMA channel 5 number of data register 0x00000000
.equ R32_DMA_PADDR5, 0x40020060 	#DMA channel 5 peripheral address register 0x00000000
.equ R32_DMA_MADDR5, 0x40020064 	#DMA channel 5 memory address register 0x00000000
.equ R32_DMA_CFGR6, 0x4002006C 		#DMA channel 6 configuration register 0x00000000
.equ R32_DMA_CNTR6, 0x40020070 		#DMA channel 6 number of data register 0x00000000
.equ R32_DMA_PADDR6, 0x40020074 	#DMA channel 6 peripheral address register 0x00000000
.equ R32_DMA_MADDR6, 0x40020078 	#DMA channel 6 memory address register 0x00000000
.equ R32_DMA_CFGR7, 0x40020080 		#DMA channel 7 configuration register 0x00000000
.equ R32_DMA_CNTR7, 0x40020084 		#DMA channel 7 number of data register 0x00000000
.equ R32_DMA_PADDR7, 0x40020088 	#DMA channel 7 peripheral address register 0x00000000
.equ R32_DMA_MADDR7, 0x4002008C 	#DMA channel 7 memory address register


.equ R32_ADC_STATR, 0x40012400 		#ADC status register 0x00000000
.equ R32_ADC_CTLR1, 0x40012404 		#ADC control register 1 0x00000000
.equ R32_ADC_CTLR2, 0x40012408 		#ADC control register 2 0x00000000
.equ R32_ADC_SAMPTR1, 0x4001240C 	#ADC sample time register 1 0x00000000
.equ R32_ADC_SAMPTR2, 0x40012410 	#ADC sample time register 2 0x00000000
.equ R32_ADC_IOFR1, 0x40012414 		#ADC injected channel data offset register 1 0x00000000
.equ R32_ADC_IOFR2, 0x40012418 		#ADC injected channel data offset register 2 0x00000000
.equ R32_ADC_IOFR3, 0x4001241C 		#ADC injected channel data offset register 3 0x00000000
.equ R32_ADC_IOFR4, 0x40012420 		#ADC injected channel data offset register 4 0x00000000
.equ R32_ADC_WDHTR, 0x40012424 		#ADC watchdog high threshold register 0x00000000
.equ R32_ADC_WDLTR, 0x40012428 		#ADC watchdog low threshold register 0x00000000
.equ R32_ADC_RSQR1, 0x4001242C 		#ADC regular sequence register 1 0x00000000
.equ R32_ADC_RSQR2, 0x40012430 		#ADC regular sequence register 2 0x00000000
.equ R32_ADC_RSQR3, 0x40012434 		#ADC regular sequence register 3 0x00000000
.equ R32_ADC_ISQR, 0x40012438 		#ADC injected sequence register 0x00000000
.equ R32_ADC_IDATAR1, 0x4001243C 	#ADC injected data register 1 0x00000000
.equ R32_ADC_IDATAR2, 0x40012440 	#ADC injected data register 2 0x00000000
.equ R32_ADC_IDATAR3, 0x40012444 	#ADC injected data register 3 0x00000000
.equ R32_ADC_IDATAR4, 0x40012448 	#ADC injected data register 4 0x00000000
.equ R32_ADC_RDATAR, 0x4001244C 	#ADC regular data register 0x00000000
.equ R32_ADC_DLYR, 0x40012450 		#ADC delayed data register


.equ R16_TIM1_CTLR1, 0x40012C00 	#Control register 1 0x0000
.equ R16_TIM1_CTLR2, 0x40012C04 	#Control register 2 0x0000
.equ R16_TIM1_SMCFGR, 0x40012C08 	#Slave mode control register 0x0000
.equ R16_TIM1_DMAINTENR, 0x40012C0C 	#DMA/interrupt enable register 0x0000
.equ R16_TIM1_INTFR, 0x40012C10 	#Interrupt status register 0x0000
.equ R16_TIM1_SWEVGR, 0x40012C14 	#Event generation register 0x0000
.equ R16_TIM1_CHCTLR1, 0x40012C18 	#Compare/capture control register 1 0x0000
.equ R16_TIM1_CHCTLR2, 0x40012C1C 	#Compare/capture control register 2 0x0000
.equ R16_TIM1_CCER, 0x40012C20 		#Compare/capture enable register 0x0000
.equ R16_TIM1_CNT, 0x40012C24 		#Counters 0x0000
.equ R16_TIM1_PSC, 0x40012C28 		#Counting clock prescaler 0x0000
.equ R16_TIM1_ATRLR, 0x40012C2C 	#Auto-reload value register 0x0000
.equ R16_TIM1_RPTCR, 0x40012C30 	#Recurring count value register 0x0000
.equ R16_TIM1_CH1CVR, 0x40012C34 	#Compare/capture register 1 0x0000
.equ R16_TIM1_CH2CVR, 0x40012C38 	#Compare/capture register 2 0x0000
.equ R16_TIM1_CH3CVR, 0x40012C3C 	#Compare/capture register 3 0x0000
.equ R16_TIM1_CH4CVR, 0x40012C40 	#Compare/capture register 4 0x0000
.equ R16_TIM1_BDTR, 0x40012C44 		#Brake and deadband registers 0x0000
.equ R16_TIM1_DMACFGR, 0x40012C48 	#DMA control register 0x0000
.equ R16_TIM1_DMAADR, 0x40012C4C 	#DMA address register for continuous mode


.equ R16_TIM2_CTLR1, 0x40000000 	#TIM2 control register1 0x0000
.equ R16_TIM2_CTLR2, 0x40000004 	#TIM2 control register2 0x0000
.equ R16_TIM2_SMCFGR, 0x40000008 	#TIM2 Slave mode control register 0x0000
.equ R16_TIM2_DMAINTENR, 0x4000000C 	#TIM2 DMA/interrupt enable register
.equ R16_TIM2_INTFR, 0x40000010 	#TIM2 interrupt status register 0x0000
.equ R16_TIM2_SWEVGR, 0x40000014 	#TIM2 event generation register 0x0000
.equ R16_TIM2_CHCTLR1, 0x40000018 	#TIM2 compare/capture control register1 0x0000
.equ R16_TIM2_CHCTLR2, 0x4000001C 	#TIM2 compare/capture control register2 0x0000
.equ R16_TIM2_CCER, 0x40000020 		#TIM2 compare/capture enable register 0x0000
.equ R16_TIM2_CNT, 0x40000024 		#TIM2 counter 0x0000
.equ R16_TIM2_PSC, 0x40000028 		#TIM2 count clock prescaler 0x0000
.equ R16_TIM2_ATRLR, 0x4000002C 	#TIM2 auto-reload register 0x0000
.equ R16_TIM2_CH1CVR, 0x40000034 	#TIM2 compare/capture register1 0x0000
.equ R16_TIM2_CH2CVR, 0x40000038 	#TIM2 compare/capture register2 0x0000
.equ R16_TIM2_CH3CVR, 0x4000003C 	#TIM2 compare/capture register3 0x0000
.equ R16_TIM2_CH4CVR, 0x40000040 	#TIM2 compare/capture register4 0x0000
.equ R16_TIM2_DMACFGR, 0x40000048 	#TIM2 DMA control register 0x0000
.equ R16_TIM2_DMAADR, 0x4000004C 	#TIM2 DMA address register in continuous mode
  

.equ R32_USART_STATR, 0x40013800 	#UASRT status register 0x000000C0
.equ R32_USART_DATAR, 0x40013804 	#UASRT data register 0x000000XX
.equ R32_USART_BRR, 0x40013808 		#UASRT baud rate register 0x00000000
.equ R32_USART_CTLR1, 0x4001380C 	#UASRT control register 1 0x00000000
.equ R32_USART_CTLR2, 0x40013810 	#UASRT control register 2 0x00000000
.equ R32_USART_CTLR3, 0x40013814 	#UASRT control register 3 0x00000000
.equ R32_USART_GPR, 0x40013818 		#UASRT protection time and prescaler register


.equ R16_I2C_CTLR1, 0x40005400 		#I2C control register 1 0x0000
.equ R16_I2C_CTLR2, 0x40005404 		#I2C control register 2 0x0000
.equ R16_I2C_OADDR1, 0x40005408 	#I2C address register 1 0x0000
.equ R16_I2C_OADDR2, 0x4000540C 	#I2C address register 2 0x0000
.equ R16_I2C_DATAR,  0x40005410 	#I2C data register 0x0000
.equ R16_I2C_STAR1,  0x40005414 	#I2C status register 1 0x0000
.equ R16_I2C_STAR2,  0x40005418 	#I2C status register 2 0x0000
.equ R16_I2C_CKCFGR, 0x4000541C 	#I2C clock register

.equ R16_SPI_CTLR1, 0x40013000 		#SPI Control register1 0x0000
.equ R16_SPI_CTLR2, 0x40013004 		#SPI Control register2 0x0000
.equ R16_SPI_STATR, 0x40013008 		#SPI Status register 0x0002
.equ R16_SPI_DATAR, 0x4001300C 		#SPI Data register 0x0000
.equ R16_SPI_CRCR,  0x40013010 		#SPI Polynomial register 0x0007
.equ R16_SPI_RCRCR, 0x40013014 		#SPI Receive CRC register 0x0000
.equ R16_SPI_TCRCR, 0x40013018 		#SPI Transmit CRC register 0x0000
.equ R16_SPI_HSCR,  0x40013024 		#SPI High-speed control register

.equ R16_ESIG_FLACAP, 0x1FFFF7E0 	#Flash capacity register 0xXXXX
.equ R32_ESIG_UNIID1, 0x1FFFF7E8 	#UID register 1 0xXXXXXXXX
.equ R32_ESIG_UNIID2, 0x1FFFF7EC 	#UID register 2 0xXXXXXXXX
.equ R32_ESIG_UNIID3,  0x1FFFF7F0 	#UID register 3 

.equ R32_FLASH_ACTLR, 0x40022000 	#Control register
.equ R32_FLASH_KEYR,  0x40022004 	#FPEC key register X
.equ R32_FLASH_OBKEYR, 0x40022008 	#OBKEY register X
.equ R32_FLASH_STATR, 0x4002200C 	#Status register 0x00008000
.equ R32_FLASH_CTLR,  0x40022010 	#Configuration register 0x00008080
.equ R32_FLASH_ADDR, 0x40022014 	#Address register X
.equ R32_FLASH_OBR,  0x4002201C 	#Select word register 0x03FFFFFE
.equ R32_FLASH_WPR,  0x40022020 	#Write protection register 0xFFFFFFF
.equ R32_FLASH_MODEKEYR,  0x40022024 	#Extended key register X
.equ R32_FLASH_BOOT_MODEKEYR,  0x40022028 #Unlock BOOT key register

.equ R32_EXTEN_CTR, 0x40023800 		#Configure extended control registers

.equ PFIC_KEY1, 0xFA050000
.equ PFIC_KEY2, 0xBCAF0000
.equ PFIC_KEY3, 0xBEEF0000
.equ mstatus, 	0x300
.equ mtvec, 	0x305
.equ intsyscr, 	0x804
.equ mepc, 	0x341

.equ  SYSTICK_SR_CNTIF,(1<<0)
.equ  SYSTICK_CTLR_STE ,(1<<0)
.equ  SYSTICK_CTLR_STIE,(1<<1)
.equ  SYSTICK_CTLR_STCLK,(1<<2)
.equ  SYSTICK_CTLR_STRE,(1<<3)
.equ  SYSTICK_CTLR_SWIE,(1<<31)

.equ data_command1 , 0x09		#0b00001001# data control nibble ,led on P3, EN 0 on P2, R/W 0 (write) in P1 , RS 1 (0 instruction, 1 data) = 1001  =0x09
.equ data_command2 , 0x0d               #0b00001101# data control nibble , 1101  = 0x0D   - EN goes hi=1
.equ data_command3 , 0xF9               #0b00001011# data control nibble , 1011  = 0x0B   - EN goes low=0
.equ inst_command1 , 0x08	        #0b00001000# instruction control nibble ,  led on en-lo,Rw-0,rs =0   = 1000   = 0x08
.equ inst_command2 , 0x0C               #0b00001100# instruction control nibble ,  led on,EN hi , rs/RW 0    = 1100   = 0x0C
.equ inst_command3 , 0xF8               #0b00001011# instruction control nibble  , led on, EN lo ,rs/rw 0    = 1000   = 0x08
.equ LCDWAD , 0x4E 

.equ search_rom , 0xf0
.equ read_rom , 0x33
.equ match_rom , 0x55
.equ skip_rom , 0xcc
.equ alarm_search , 0xec
.equ convert , 0x44
.equ write_scratchpad , 0x4e
.equ read_sscratchpad , 0xbe
.equ copy_scratchpad , 0x48
.equ recall_E2 , 0xb8
.equ read_powersupply , 0xb4

######################################### SRAM  VARIABLES
fclk 		= 24000000   		# 24Mhz RCO internal , AHB =8Mhz by default
state 		= 0x2000000C 		# located in SRAM
result11 	= 0x20000010 		# 0x20000010 to 0x20000018 is used for storing result in decimal format
result22 	= 0x20000014
fraction 	= 0x20000018
fraction2  	= 0x2000001C
result_lo 	= 0x20000020
result_hi 	= 0x20000024
modulo 		= 0x20000028
scratch 	= 0x2000002C
result1 	= 0x20000030
result2 	= 0x20000034
dividend 	= 0x20000038 
divisor 	= 0x2000003C
scratchpad 	= 0x20000040
buffer		= 0x20000044
presence        = 0x20000048
mem 		= 0x2000004C


.macro push val
  addi sp, sp, -4
  sw \val, 0(sp)
.endm

.macro pop val
  lw \val, 0(sp)
  addi sp, sp, 4
.endm

.macro pos x, y
  li x6,\y
  li x7,\x
  call posi
.endm

.macro string address
  addi sp,sp,-4
  sw a2,0(sp)
  la a2,\address
  call string_reader
  lw a2,0(sp)
  addi sp,sp,4
.endm

.macro micros val
  addi sp,sp,-4
  sw t1,0(sp)
  li t1,\val
  call delayus
  lw t1,0(sp)
  addi sp,sp,4
.endm

.macro R_COMMAND val
  addi sp,sp,-4
  sw t1,0(sp)
  li t1,\val
  call ROM_COMMANDS
  lw t1,0(sp)
  addi sp,sp,4
.endm

.macro F_COMMAND val
  addi sp,sp,-4
  sw t1,0(sp)
  li t1,\val
  call f_command
  lw t1,0(sp)
  addi sp,sp,4
.endm


.align 4
.text
.global start
start:
sp_init:
    	la sp, STACK			# initialize stack pointer
		
#Enable GPIO clocks & AFIO in APB2 clock register
        
    	la x10,R32_RCC_APB2PCENR 	# load address of APB2PCENR register to x10 ,for enabling GPIO A,D,C peripherals
	lw x11,0(x10) 			# load contents from peripheral register R32_RCC_APB2PCENR pointed by x10
	li x7,((1<<2)|(1<<4)|(1<<5)|(1<<0)|(1<<11)|(1<<14)) # 1<<IOPA_EN,1<<IOPC_EN,1<<IOPD_EN,1<<USART_EN,1<<TIM1_EN,1<<AFIOEN, enable port A,C,D and AFIO functions
	or x11,x11,x7 			# or values 
	sw x11,0(x10) 			# store modified enable values in R32_RCC_APB2PCENR

#Enable I2C clock in  APB1 register
    
    	la x10,R32_RCC_APB1PCENR 	# load address of APB1PCENR register to x10 ,for enabling I2C peripheral
	lw x11,0(x10) 			# load contents from peripheral register R32_RCC_APB1PCENR pointed by x10
	li x7,(1<<21) 			# 1<<I2C1_EN, = 1<<21 for I2C functions
	or x11,x11,x7 			# or values 
	sw x11,0(x10) 
###########
#configure GPIO PortC as multiplex open drain output for I2C
	la x10,R32_GPIOC_CFGLR 		# load pointer x10 with address of R32_GPIOC_CFGLR , I2C SDA & SCL is on portC PC1,PC2
	lw x11,0(x10) 			# load contents from register pointed by x10
	li x7,~((0xf<<4)|(0xf<<8)) 	# clear pc1,pc2,pc3. we need to setup PC1 & PC2 for I2C and pc3 for DFplayer switching
	and x11,x11,x7 			# clear  mode and cnf bits for selected pin C1,C2
	li x7,((13<<4)|(13<<8)) 	# PC1 = multiplex open drain output 10mhz ,PC2= multiplex open drain output 10mhz, 0b1101, PC3 pushpull out
	or x11,x11,x7 			# OR value to register
	sw x11,0(x10) 			# store in R32_GPIOD_CFGLR
######################
#configure GPIO D 5,6 for UART
	la x10,R32_GPIOD_CFGLR		# load pointer x10 with address of R32_GPIOD_CFGLR , GPIO configuration register
	lw x11,0(x10)			# load contents from register pointed by x10
	li x7,~((0xf<<20)|(0xf<<24))	# clear pd5,pd6,pd0. we need to setup PD5 & PD6 for usart tx and rx and pd4 for ETR
	and x11,x11,x7			# clear pd5,pd6 mode and cnf bits for selected pin D4,D5,D6
	li x7,((0x8<<24)|(0xB<<20))	# pd6 = input with PU/PD,pd5= multiplex pushpull output 50mhz,pd4 as floating input
	or x11,x11,x7			# OR value to register
	sw x11,0(x10)			# store in R32_GPIOD_CFGLR

######################

#configure GPIO PortD as pullup input for UART on PD6
	la x10,R32_GPIOD_OUTDR		# output register D, enable 1 in ODR for pUllup with input in pullup/down MODE
	lw x11,0(x10)			# we need 6 as pullup 
	li x7,(1<<6)			# write 1 in GPIOD_OUTDR to enable pull up resistor while GPIOD  RX pin 6 also pull up
	or x11,x11,x7
	sw x11,0(x10)

############
#configure USART baud
	la x10,R32_USART_BRR		# USART BAUD setting
	lw x11,0(x10)			# copy R32_USART_BRR to x11
	li x7,((52<<4)|(1<<0))		# 52.1 in BRR =9600
	or x11,x11,x7			# or registers
	sw x11,0(x10)			# store in R32_USART_BRR

#setup UART control and enable	
	la x10,R32_USART_CTLR1		# load x10 with R32_USART_CTLR1 address
	lw x11,0(x10)			# load to x11 contents
	li x7,(1<<13)|(1<<3)|(1<<2)	# enable USART UE, TX,RX bits		# UE 
	or x11,x11,x7
	sw x11,0(x10)			# store back new values



############
#I2C0 configuration 
	la x10,R32_RCC_APB1PRSTR 	# set pointer to clock control  peripheral reset register 
	lw x11,0(x10) 			# load contents to x11
	li x7,(1<<21) 			# shift 1 to 21st bit position
	or x11,x11,x7 			# OR with x11
	sw x11,0(x10) 			# set bit 21 of R32_RCC_APB1PRSTR to reset I2C peripheral
	not x7,x7 			# invert values in x7
	and x11,x11,x7 			# and x11 to write a 0 in 21st bit
	sw x11,0(x10) 			# store 0 in 21st bit to restart i2c engine

	la x10,R16_I2C_CTLR2 		# set clock in control 2 register
    	lh x11,0(x10) 			# copy contents of R16_I2C_CTLR2 to x11
	li x7,0xffffffc0 		# clear frequency bits 0-5 with bit mask 0xffffffc0
	and x11,x11,x7 			# AND will clear bit 0-5
    	li x7,(8<<0) 			# 8Mhz I2C clock .default 24Mhz HSI/3 =8Mhz APB clock
    	or x11,x11,x7 			# store APB clock frequency in bit 0-5
	sh x11,0(x10) 			# store back in R16_I2C_CTLR2
    	la x10,R16_I2C_CKCFGR 		# set pointer to I2C clockregister
    	lh x11,0(x10) 			# copy values to x11 from above register
	li x7,0xfffff000 		# clear CCR bits 0-11 with bitmask 0xfffff000
	and x11,x11,x7 			# ANDing clears bit 0-11 in x11 register
	li x7,(40<<0) 			# CCR = t(rscl)+t(wsclh)/tpclk1 = 1000+4000/125 =40 , or (8000000/2*100000)=40 , PCLK/2*100Khz =CCR
    	or x11,x11,x7 			# store calculated CCR (data sheet)in x11 by OR
	sh x11,0(x10) 			# store back in peripheral register
	la x10,R16_I2C_CTLR1 		# set pointer to I2C control register 1
	lh x11,0(x10) 			# copy contents
	li x7,(1<<0) 			# 1<<PE = 1<<0 enable bit is bit0,1<<10 is ack enable bit
	or x11,x11,x7 			# OR enable bit to x11
	sh x11,0(x10) 			# store half word in control register 1
	la x10,R16_I2C_CTLR1 		# set pointer to I2C control register 1
	lh x11,0(x10) 			# copy contents
	li x7,(1<<10) 			# 1<<10 is ack enable bit
	or x11,x11,x7 			# OR ACK enable bit to x11
	sh x11,0(x10) 			# store half word in control register 1
#################################

measure:
	call dallas_init		# initialize DS18B20
	R_COMMAND skip_rom		# send ROM command for skipping ROM read
	F_COMMAND convert		# send command to start a conversion	
check1:
	call bit_read			# read ready bit from sensor
	la x10,buffer			# 1 or 0 written in buffer
	lw x7,0(x10)			# copy buffer to x7
	bnez x7,check1			# if x7 is 1 sensor busy ,wait in loop
	call dallas_init		# initialize DS18B20
	R_COMMAND skip_rom		# send ROM command for skipping ROM read
	F_COMMAND read_sscratchpad	# send command to read conversion result from scratch_pad
	call scratchpad_read 		# 9 bytes starting from mem to mem+8  MSB>>>LSB stored from scratchpad
	call multiply 			# multiply lsb and lsb1 with 0.0625 to convert readings to degree Centigrade ,result in result_lo , result_hi
	call D_ASCII			# ascii values in mem to mem+9
	call dallas_init
#	call debug
	call print			# print result to UART ,1st 3 digits are 0 and ignored , temprature in range of 0-99 is printed
	call delay1S			# 1 second delay
	   j measure			# jump to measure label and repeat






############################

f_command:
	addi sp,sp,-16
	sw ra,0(sp)
	sw x5,4(sp)
	sw x3,8(sp)
	sw x4,12(sp)
	li x5,8
	mv x3,x6
loop51:
	li x6,0x00000001
	and x4,x3,x6
	bnez x4,high2
	call write0
	srli x3,x3,1
	addi x5,x5,-1
	bnez x5,loop51
	lw x4,12(sp)
	lw x3,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret
high2:
	call write1
	srli x3,x3,1
	addi x5,x5,-1
	bnez x5,loop51
	lw x4,12(sp)
	lw x3,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret



###########################
ROM_COMMANDS:
	addi sp,sp,-16
	sw ra,0(sp)
	sw x5,4(sp)
	sw x3,8(sp)
	sw x4,12(sp)
	li x5,8
	call dallas_init
	la a0,presence
	lw x4,0(a0)
	bnez x4,exit0
	mv x3,x6
loop41:
	li x6,0x00000001
	and x4,x3,x6
	bnez x4,high1
	call write0
	srli x3,x3,1
	addi x5,x5,-1
	bnez x5,loop41
	lw x4,12(sp)
	lw x3,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret	
high1:
	call write1
	srli x3,x3,1
	addi x5,x5,-1
	bnez x5,loop41
exit0:	lw x4,12(sp)
	lw x3,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret


#############################
data_out:
	addi sp,sp,-16
	sw ra,0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x7,12(sp)
	la x10,R32_GPIOD_CFGLR
	lw x11,0(x10)
	li x7,~(0xf<<0)    	# set pd0
	and x11,x11,x7		# clear MODE and CNF bits
	li x7,(0x3<<0)		# pushpull output, line is pulled low
	or x11,x11,x7
	sw x11,0(x10)
	lw x7,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret
###############################
data_in:
	addi sp,sp,-16
	sw ra,0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x7,12(sp)
	la x10,R32_GPIOD_CFGLR
	lw x11,0(x10)
	li x7,~(0xf<<0)    	# clear pd0
	and x11,x11,x7
	li x7,(0x4<<0)          # pd0 is floating input, pulled high
	or x11,x11,x7
	sw x11,0(x10)
	lw x7,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret
############################
dallas_ready:
	addi sp,sp,-16
	sw ra,0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x7,12(sp)
	la x10,R32_GPIOD_INDR
	lw x11,0(x10)
	li x7,0x00000001    	# clear pd0
	and x11,x11,x7
	la x10,presence
	sw x11,0(x10)
	lw x7,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret
#############################
dallas_init:
	addi sp,sp,-4
	sw ra,0(sp)
	call data_out		# data line is pulled low
	micros 1000		# 500us delay (min 480us low resets DS18B20)
	call data_in		# data line becomes input to receive presence pulse
	micros 200		# min 60us for DS to respond, 100us
	call dallas_ready	# checks for presence pulse(0), time 60-280us
	micros 600		# wait out the remaining 200us
	lw ra,0(sp)
	addi sp,sp,4
	ret
###############################	
write1:
	addi sp,sp,-4
	sw ra,0(sp)
	call data_out		# pull line low (6.5us without delay)
	call data_in		# samples line in 15-60us of low detection
	micros 200
	lw ra,0(sp)
	addi sp,sp,4
	ret
##############################
write0:
	addi sp,sp,-4
	sw ra,0(sp)
	call data_out
	micros 150		# line pulled low for entire 60us
	call data_in
	#micros 20
	lw ra,0(sp)
	addi sp,sp,4
	ret	
##############################
bit_read:
	addi sp,sp,-16
	sw ra,0(sp)
	sw x10,4(sp)
	sw x11,8(sp)
	sw x7,12(sp)
	la x10,buffer
	sw zero,0(x10)
read_bit:
	call data_out
	call data_in
	micros 40
	la x10,R32_GPIOD_INDR
	lw x11,0(x10)
	li x7,0x00000001    	# clear pd0
	and x11,x11,x7
	la x10,buffer
	sw x11,0(x10)
	micros 10
	lw x7,12(sp)
	lw x11,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret
####################################
byte_read:
	addi sp,sp,-24
	sw ra,0(sp)
	sw x5,4(sp)
	sw x8,8(sp)
	sw x10,12(sp)
	sw x11,16(sp)
	sw x7,20(sp)
	li x5,8
	li x8,0
loopread:
    	call data_out  		# 6.5us
	call data_in
	micros 20		# 20us, data outputs begining 15us and ends 60us of data low detection
	la x10,R32_GPIOD_INDR
	lw x11,0(x10)
	li x7,0x00000001    	# clear pd0
	and x11,x11,x7
	bnez x11,one
	srli x8,x8,1		# 0 shifted in on msb side. DS transmits lsb first
	micros 40
	addi x5,x5,-1
	bnez x5,loopread
	srli x8,x8,24		# the byte in MSB of x8 is right aligned
	la x10,buffer
	sw x8,0(x10)		# read byte in buffer
	lw x7,20(sp)
	lw x11,16(sp)
	lw x10,12(sp)
	lw x8,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)
	addi sp,sp,24
	ret

one:
	li x7,0x80000000	# set msb of x7
	srli x8,x8,1		# 0 shifted in on msb side. DS transmits lsb first
	or x8,x8,x7		# msb is set to 1 by logical OR ing X8 and x7
	micros 40
	addi x5,x5,-1
	bnez x5,loopread
	srli x8,x8,24		# the byte in MSB of x8 is right aligned
	la x10,buffer
	sw x8,0(x10)		# read byte in buffer
	lw x7,20(sp)
	lw x11,16(sp)
	lw x10,12(sp)
	lw x8,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)
	addi sp,sp,24
	ret
#############################
word_read:
	addi sp,sp,-24
	sw ra,0(sp)
	sw x5,4(sp)
	sw x8,8(sp)
	sw x10,12(sp)
	sw x11,16(sp)
	sw x7,20(sp)
	li x5,32
	li x8,0
loopreadw:
    	call data_out  		# 6.5us
	call data_in
	micros 40		# 20us, data outputs begining 15us and ends 60us of data low detection
	la x10,R32_GPIOD_INDR
	lw x11,0(x10)
	li x7,0x00000001    	# clear pd0
	and x11,x11,x7
	bnez x11,one1
	srli x8,x8,1		# 0 shifted in on msb side. DS transmits lsb first
	micros 40
	addi x5,x5,-1
	bnez x5,loopreadw
	srli x8,x8,24		# the byte in MSB of x8 is right aligned
	la x10,buffer
	sw x8,0(x10)		# read byte in buffer
	lw x7,20(sp)
	lw x11,16(sp)
	lw x10,12(sp)
	lw x8,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)
	addi sp,sp,24
	ret

one1:
	li x7,0x80000000	# set msb of x7
	srli x8,x8,1		# 0 shifted in on msb side. DS transmits lsb first
	or x8,x8,x7		# msb is set to 1 by logical OR ing X8 and x7
	micros 40
	addi x5,x5,-1
	bnez x5,loopreadw
	srli x8,x8,24		# the byte in MSB of x8 is right aligned
	la x10,buffer
	sw x8,0(x10)		# read byte in buffer
	lw x7,20(sp)
	lw x11,16(sp)
	lw x10,12(sp)
	lw x8,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)
	addi sp,sp,24
	ret
#############################
scratchpad_read:
	addi sp,sp,-24
	sw ra,0(sp)
	sw x5,4(sp)
	sw x8,8(sp)
	sw x10,12(sp)
	sw x11,16(sp)
	sw x7,20(sp)
	li x5,9
	li x8,0
	la x10,mem
	addi x10,x10,8
scratch_loop:
	call byte_read
	la x11,buffer
	lb x7,0(x11)
	sb x7,0(x10)		# store in mem+8 then decrement each iteration till 0 byte is stored in mem. 9 bytes
	addi x10,x10,-1
	addi x5,x5,-1
	bnez x5,scratch_loop
	lw x7,20(sp)
	lw x11,16(sp)
	lw x10,12(sp)
	lw x8,8(sp)
	lw x5,4(sp)
	lw ra,0(sp)
	addi sp,sp,24
	ret

##############################


##########################
CRC_check:
	# CRC = X8 + X5 + X4 + 1  = 100110001
	# width = 8 , 00110001 =0x31
	# after process is finished if r8 is 0x00 received message is good ,else error
	# we divide the message including the CRC by polynomial ,if 0 good any other value message corrupt
	
	li x5,56
	la x10,buffer
	addi x10,x10,4
	lw x4,0(x10)
	la x10,buffer
	lw x3,0(x10)		#x3 MSword , x4	LSword
CRCLOOP:
	andi x6,x4,1		# isolate lsb
	bnez x6,XORIT
	andi x7,x3,1		# isolate lsb of MSword
	bnez x7,shift2
	srli x4,x4,1		# mimic rotate right through carry (0)
	srli x3,x3,1		# 0>>x3msb  0>>x4msb   lsb>>out of x4
	j exitshift	
shift2:
	li x7,0x8000000		# mimic rotate right throuh carry (1)
	srli x4,x4,1		# X4>>
	or x4,x4,x7		# 1>>x4msb from x3lsb
	srli x3,x3,1		# 0>>x3msb  1>>xmsb  lsb >>out x4
exitshift:
	addi x5,x5,-1
	bnez x5,CRCLOOP
	ret

XORIT:
	andi x7,x3,1		# check lsb of x3 high word
	bnez x7,shift1		# if x3 lsb is 1 branch to shift1
	srli x4,x4,1		# mimic rotate right through carry (0)
	srli x3,x3,1		# x3:x4 >> right 1
	li x7,(0x131<<23)	#0b100110001 , polynomial X8 + X5 + X4 + 1 
	xor x3,x3,x7
	j exitxor
shift1:
	li x7,0x8000000		# mimic rotate right throuh carry (1)
	srli x4,x4,1
	or x4,x4,x7		# effect similar to 1 shifted into msb
	srli x3,x3,1		# x3 shifted right 1 , x3:x4>>1
	li x7,(0x131<<23)	#0b100110001 , polynomial X8 + X5 + X4 + 1 
	xor x3,x3,x7
exitxor:
	addi x5,x5,-1
	bnez x5,CRCLOOP	
	ret

####################################






################################################################################
# delay routines
#==========================================
delay10S: 
	addi sp,sp,-8 			# push RA
	sw ra,0(sp) 			# push RA
	sw t1,4(sp)
	li t1,20100101 			# load an arbitarary value 20000000 to t1 register 
loop10S:
	addi t1,t1,-1 			# subtract 1 from t1
	bne t1,zero,loop10S 		# if t1 not equal to 0 branch to label loop
	lw t1,4(sp)
	lw ra,0(sp) 			# POP RA
	addi sp,sp,8 			# pop RA
	ret 

delay1S: 
	addi sp,sp,-8 			# push RA
	sw ra,0(sp) 			# push RA
	sw t1,4(sp)
	li t1,2010010 			# load an arbitarary value 20000000 to t1 register 
loop1s:
	addi t1,t1,-1 			# subtract 1 from t1
	bne t1,zero,loop1s 		# if t1 not equal to 0 branch to label loop
	lw t1,4(sp)
	lw ra,0(sp) 			# POP RA
	addi sp,sp,8 			# pop RA
	ret 

delay1ms:
	addi sp,sp,-8 			# push RA
	sw ra,0(sp) 			# push RA
	sw t1,4(sp) 
	li t1,2010 			# load an arbitarary value 20000000 to t1 register 
loop1ms:
	addi t1,t1,-1 			# subtract 1 from t1
	bne t1,zero,loop1ms 		# if t1 not equal to 0 branch to label loop
	lw t1,4(sp)
	lw ra,0(sp) 			# POP RA
	addi sp,sp,8 			# pop RA 
	ret 

delay10ms:
	addi sp,sp,-8 			# push RA
	sw ra,0(sp) 			# push RA
	sw t1,4(sp) 
	li t1,20100 			# load an arbitarary value 20000000 to t1 register 
loop10ms:
	addi t1,t1,-1 			# subtract 1 from t1
	bne t1,zero,loop10ms 		# if t1 not equal to 0 branch to label loop
	lw t1,4(sp)
	lw ra,0(sp) 			# POP RA
	addi sp,sp,8 			# pop RA
	ret

delay50ms:
	addi sp,sp,-8 			# push RA
	sw ra,0(sp) 			# push RA
	sw t1,4(sp) 
	li t1,100500 			# load an arbitrary value 20000000 to t1 register 
loop50ms:
	addi t1,t1,-1 			# subtract 1 from t1
	bne t1,zero,loop50ms 		# if t1 not equal to 0 branch to label loop
	lw t1,4(sp)
	lw ra,0(sp) 			# POP RA
	addi sp,sp,8 			# pop RA
	ret 

delay10us:
	addi sp,sp,-8 			# push RA
	sw ra,0(sp) 			# push RA
	sw t1,4(sp) 
	li t1,105			# load an arbitrary value 20000000 to t1 register 
loop10us:
	addi t1,t1,-1 			# subtract 1 from t1
	bne t1,zero,loop10us 		# if t1 not equal to 0 branch to label loop
	lw t1,4(sp)
	lw ra,0(sp) 			# POP RA
	addi sp,sp,8 			# pop RA
	ret 

delayus:
	addi sp,sp,-4 			# push RA
	sw ra,0(sp) 			# push RA
loopus:
	addi t1,t1,-1 			# subtract 1 from t1
	bne t1,zero,loopus 		# if t1 not equal to 0 branch to label loop
	lw ra,0(sp) 			# POP RA
	addi sp,sp,4 			# pop RA
	ret 

#####################################################################
#######################################################################
multiply:
	addi sp,sp,-52
	sw ra,0(sp)
	sw a0,4(sp)
	sw a1,8(sp)
	sw a2,12(sp)
	sw a3,16(sp)
	sw a4,20(sp)
	sw a5,24(sp)
	sw x5,28(sp)
	sw x3,32(sp)
	sw x6,36(sp)
	sw x4,40(sp)
	sw x8,44(sp)
	sw x7,48(sp)


	la a0,mem
	addi a0,a0,8
	lbu a1,0(a0)
	addi sp,sp,-4
	sb a1,0(sp)
	addi a0,a0,-1
	lbu a1,0(a0)
	sb a1,1(sp)
	lhu a1,0(sp)
	addi sp,sp,4		

# 	li a1,0xffffffff 	# multiplicant
 	li a2,6250		# multiplier
 	li a3,0x00000000 	# result_lo
 	li a4,0x00000000 	# result_hi
 	li a5,0			# working register 
 

	li x5,32		# number of bits to be tested/counter
loop:
 	mv x3,a2		# copy multiplier to test lsb 1 or 0
	andi x3,x3,1		# extract lsb in x3
	bnez x3,addnshift1	# if x3 is 1 branch to add and shift
	call shift		# if x3 is 0 call routine to shift result hi and lo + carry register right
	addi x5,x5,-1		# decrease counter
	bnez x5,loop		# if counter is not 0 go to label loop
	slli x6,x6,1		# if counter is 0, shift carry register left 1 time ( i dont know why but corrects answer)
	j exit			# exit multiplication procedure
addnshift1:
	call addnshift		# call addnshift routine to add multiplicand to result_hi and shift both result_hi & result_lo
	addi x5,x5,-1		# decrease counter
	bnez x5,loop		# if counter is more than 0 branch to label loop
	slli x6,x6,1		# if counter is 0, shift carry register left 1 time ( i dont know why but corrects answer)
	j exit			# exit multiplication procedure



shift:
	addi sp,sp,-4
	sw ra,0(sp)
	srli a2,a2,1		# multiplier right shift, 1 lsb lost
	srli a3,a3,1		# 2n low register(a3) right shift and 0 in msb (a4:a3)
	mv x4,a4		# a copy of high 2n register(a4) to x4 (a4:a3)
	andi x4,x4,1		# copy lsb of a4 high 2n register
	beqz x4,lsb0		# if lsb extracted is 0 , branch to lsb0 label
	li x4,0x80000000	# if lsb of a4 was 1
	or a3,a3,x4		# lsb of a4 now in msb of a3. (a4:a3 >> 1)
lsb0:
	srli a4,a4,1		# 2n high register right shift ,same as 0 shifted between a4 to a3 >>
	srli x6,x6,1		# shift right carry register together with a4:a3
	lw ra,0(sp)
	addi sp,sp,4
	ret			# return to main program


addnshift:
	addi sp,sp,-4
	sw ra,0(sp)
	add a4,a4,a1		# add multiplicand to high 2n register
 	sltu x8,a4,a1		# set x8 to 1 if result of addition (a4 + a1) answer_hi and multiplicand
	bnez x8,setcarry	# if x8 is not 0 , branch to setcarry label
return:
	srli a2,a2,1		# multiplier right shift
	srli a3,a3,1		# 2n low register right shift and 0 in msb
	mv x4,a4		# a copy of lw 2n
	andi x4,x4,1		# copy lsb of a4 high 2n register
	beqz x4,addlsb0		# if lsb extracted is 0 , branch to addlsb0 label 
	li x4,0x80000000	# if lsb of a4 was 1
	or a3,a3,x4		# lsb of a4 now in msb of a3. (a4:a3 >> 1)
addlsb0:
	srli a4,a4,1		# 2n high register right shift
	srli x6,x6,1		# shift right carry register together with a4:a3
	lw ra,0(sp)
	addi sp,sp,4	
	ret			# return to main program


setcarry:
	li x7,0x80000000	# set msb of x7 with 0x80000000
	or x6,x6,x7		# set msb of x7 by oring t6 with x7
	j return		# jump to shifing routine

exit:
	beqz x6,nocarry		# if t6 is not set , 0 , no overflow occured, branch to nocarry
	mv a4,x6		# if carry set , copy t6 to answer hi register
nocarry:
	la a0,result_hi		# 
	sw a4,0(a0)		# save to data section
	la a0,result_lo
	sw a3,0(a0)		# save to data section
end:
	lw x7,48(sp)
	lw x8,44(sp)
	lw x4,40(sp)
	lw x6,36(sp)
	lw x3,32(sp)
	lw x5,28(sp)
	lw a5,24(sp)
	lw a4,20(sp)
	lw a3,16(sp)
	lw a2,12(sp)
	lw a1,8(sp)
	lw a0,4(sp)
	lw ra,0(sp)
	addi sp,sp,52
 	ret

########################################################################

#########################################################################
# D_ASCII subroutine for converting binary in result_lo to DECIMAL (ASCII)
#########################################################################

D_ASCII:			
	addi sp,sp,-32		# adjust stack pointer
	sw ra,28(sp)		# PUSH
	sw x15,24(sp)		# PUSH
	sw x11,20(sp)		# PUSH
	sw x8,16(sp)		# PUSH
	sw x7,12(sp)		# PUSH
	sw x5,8(sp)		# PUSH
	sw x4,4(sp)		# PUSH
	sw t1,0(sp)		# PUSH
	li x4,0			# clear register
	li x5,0			# clear register
	li x7,0			# clear register
	li x8,0			# clear register
	li x15,0		# clear register
	
	la x10,result_lo	# result_lo
	lw x4,0(x10)		# copy result1 to x4
#	li x4,0xffffffff	# 32bit word to be converted into ascii chars
	li x7,1000000000	# divisor
Y1:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X1		# if result negative(not divisible) branch to X1
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y1			# jump to label Y1 till not divisible
X1:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	la x10,mem		# set pointer x10 to SRAM register mem to store the byte
	sb x15,0(x10)		# store byte in mem+0
	li x15,0		# clear result
	li x7,100000000		# load x7 with new divisor
Y2:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X2		# if result negative(not divisible) branch to X2
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y2			# jump to label Y2 till not divisible
X2:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+1 to store the byte
	sb x15,0(x10)		# store byte in mem+1
	li x15,0		# clear result
	li x7,10000000		# load x7 with new divisor
Y3:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X3		# if result negative(not divisible) branch to X3
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y3			# jump to label Y3 till not divisible
X3:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+2 to store the byte
	sb x15,0(x10)		# store byte in mem+2
	li x15,0		# clear result
	li x7,1000000		# load x7 with new divisor
Y4:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X4		# if result negative(not divisible) branch to X4
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y4			# jump to label Y4 till not divisible
X4:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+3		
	sb x15,0(x10)		# store byte in mem+3
	li x15,0		# clear result
	li x7,100000		# load x7 with new divisor
Y5:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X5		# if result negative(not divisible) branch to X5
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y5			# jump to label Y5 till not divisible
X5:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+4 to store the byte
	sb x15,0(x10)		# store byte in mem+4
	li x15,0		# clear result
	li x7,10000		# load x7 with new divisor
Y6:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X6		# if result negative(not divisible) branch to X6
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y6			# jump to label Y6 till not divisible
X6:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+5 to store the byte
	sb x15,0(x10)		# store byte in mem+5
	li x15,0		# clear result
	li x7,1000		# load x7 with new divisor
Y7:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X7		# if result negative(not divisible) branch to X7
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y7			# jump to label Y7 till not divisible
X7:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+6 to store the byte
	sb x15,0(x10)		# store byte in mem+6
	li x15,0		# clear result
	li x7,100		# load x7 with new divisor
Y8:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X8		# if result negative(not divisible) branch to X8
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y8			# jump to label Y8 till not divisible
X8:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+7 to store the byte
	sb x15,0(x10)		# store byte in mem+7
	li x15,0		# clear result
	li x7,10		# load x7 with new divisor
Y9:
	sub x8,x4,x7		# subtract divisor from word to be converted
	sltu x5,x4,x7		# if result negative set x5 to indicate cannot be divided
	bnez x5,X9		# if result negative(not divisible) branch to X9
	mv x4,x8		# else move remainder to x4 for further division/subtraction
	addi x15,x15,1		# increase result by 1
	j Y9			# jump to label Y9 till not divisible
X9:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+8 to store the byte
	sb x15,0(x10)		# store byte in mem+8
	li x15,0		# clear result
	mv x15,x4
X10:
	addi x15,x15,0x30	# add ascii 0 to result to convert to ASCII char
	addi x10,x10,1		# set pointer x10 to SRAM register mem+9 to store the byte	
	sb x15,0(x10)		# store byte in mem+9

	lw t1,0(sp)		# POP
	lw x4,4(sp)		# POP
	lw x5,8(sp)		# POP
	lw x7,12(sp)		# POP
	lw x8,16(sp)		# POP
	lw x11,20(sp)		# POP
	lw x15,24(sp)		# POP
	lw ra,28(sp)		# POP
	addi sp,sp,32		# adjust stack pointer
	ret			# return to caller
##############################################################################################
#####################################################################
#load byte in x8 for UART and call USART_TX to transmit a byte
#####################################################################	
	
USART_TX:
	addi sp,sp,-16			# add space in stack
	sw ra,0(sp)			# push ra
	sw x7,4(sp)			# push x7
	sw x10,8(sp)			# push x10
	sw x11,12(sp)			# push x11

	li x10,R32_USART_STATR		# load address of usart status register
	lw x11,0(x10)			# load contents of status register in x11
	andi x11,x11,(1<<7)		# mask out 7th bit, transmit buffer empty flag
	beqz x11,USART_TX		# if 0 transmit buffer full, wait until bit is set
	#li x8,0x30
	mv x7,x8			# move byte in x8 to x7
	li x10,R32_USART_DATAR		# x10 has the address of data register
	sb x7,0(x10)			#store byte in x7 to data register
TC_check:
	li x10,R32_USART_STATR		# get contents of status register again
	lw x11,0(x10)
	andi x11,x11,(1<<6)		# check transmit complete bit
	beqz x11,TC_check		# wait if bit is 0 , when transmit complete = 1
		
	lw x11,12(sp)			# pop x11
	lw x10,8(sp)			# pop x10
	lw x7,4(sp)			# pop x7
	lw ra,0(sp)			# pop ra
	addi sp,sp,16			# set SP back 16 bytes
	ret				# return to caller

########################################
##########################################################################################################
# converts 1 byte into ASCII represented hexadecimal value , load byte in t2
##########################################################################################################
bin_to_ascii:
	addi sp,sp,-4
	sw ra,0(sp)
	mv a3,t2
	andi a3,a3,0xf0
	srli a3,a3,4
	slti a4,a3,10			# set a4 to 1 if a3 is less than 10 ,10and higher a4=0
	beqz a4 ,letter1
	ori a3,a3,0x30
	#mv a0,a3
	mv x8,a3
	call USART_TX
	j low_nibble
letter1:
	addi a3,a3,0x37
	#mv a0,a3
	mv x8,a3
	call USART_TX
low_nibble:
	mv a3,t2
	andi a3,a3,0x0f
	slti a4,a3,10			# set a4 to 1 if a3 is less than 10 ,10and higher a4=0
	beqz a4 ,letter2
	ori a3,a3,0x30
	#mv a0,a3
	mv x8,a3
	call USART_TX
	j exit_bin_to_ascii
letter2:
	addi a3,a3,0x37
	#mv a0,a3
	mv x8,a3
	call USART_TX
exit_bin_to_ascii:
	lw ra,0(sp)
	addi sp,sp,4
	ret
####################################################
#########################################################################################################################################
######### below block is for DEBUGGING, prints  registers contents in hexadecimal & decimal via UART to terminal
#########################################################################################################################################
debug:
	addi sp,sp,-20
	sw ra,0(sp)
	sw x10,4(sp)
	sw t1,8(sp)
	sw t2,12(sp)
	sw x8,16(sp)

	la x10,buffer			# SRAM address where systick count is stored in ISR
	li t1,4				# print count 4 , 4 bytes to be transfered
readloop22:
	lb t2,3(x10)			# read from top most byte 
	call bin_to_ascii		# call routine that converts binary to ASCII format of hexadecimal , convets 1 byte
	addi x10,x10,-1			# decrease memorey address  counter
	addi t1,t1,-1			# decrease byte counter ( total 4 bytes to be converted and transmitted via uart)
	bnez t1,readloop22		# if counter greater than 0 loop
	li x8,0x0d			# carriage return
	call USART_TX			# transmit
	li x8,0x0a			# line feed
	call USART_TX			# transmit

	la x10,result_lo		# SRAM address where systick count is stored in ISR
	li t1,4				# print count 4 , 4 bytes to be transfered
readloop23:
	lb t2,3(x10)			# read from top most byte 
	call bin_to_ascii
	addi x10,x10,-1
	addi t1,t1,-1
	bnez t1,readloop23
	li x8,0x0d
	call USART_TX
	li x8,0x0a
	call USART_TX
	lw x8,16(sp)
	lw t2,12(sp)
	lw t1,8(sp)
	lw x10,4(sp)
	lw ra,0(sp) 
	addi sp,sp,20
	ret
	
###########################################

print:
	addi sp,sp,-16
	sw ra,0(sp)
	sw x10,4(sp)
	sw t1,8(sp)
	sw x8,12(sp)
	la x10,mem			# SRAM address where systick count is stored in ISR
	addi x10,x10,3			# 1st 3 digits usually 0,avoid
	li t1,7				# print count 4 , 4 bytes to be transfered
printloop:
	lb x8,0(x10)			# read from top most byte 
	call USART_TX
	addi x10,x10,1			# decrease memorey address  counter
	addi t1,t1,-1			# decrease byte counter ( total 4 bytes to be converted and transmitted via uart)
	li x7,5
	beq t1,x7,put_decimal
donedecimal:
	bnez t1,printloop		# if counter greater than 0 loop
	li x8,0x0d			# carriage return
	call USART_TX			# transmit
	li x8,0x0a			# line feed
	call USART_TX			# transmit
	lw x8,12(sp)
	lw t1,8(sp)
	lw x10,4(sp)
	lw ra,0(sp)
	addi sp,sp,16
	ret
put_decimal:
	li x8,'.'
	call USART_TX
	j donedecimal


