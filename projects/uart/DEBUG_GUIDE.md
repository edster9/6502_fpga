# � UART Button Messaging Project - Interactive FPGA Learning

## 🎯 What This Project Does

This UART project demonstrates **interactive FPGA communication** using button-controlled messaging. Unlike automatic blinking LEDs, this project responds to **your input** in real-time!

**Key Features:**
- 🔴 **Button 1**: Press to send "button1" message via UART + lights red LED
- 🟢 **Button 2**: Press to send "button2" message via UART + lights green LED  
- 📱 **Real-time feedback**: See messages instantly in your terminal
- 🎓 **Learning platform**: Perfect for understanding FPGA-PC communication

## 🔌 Hardware Setup

### What You'll Need:
- **Tang Nano 9K or 20K** FPGA board
- **USB cable** (connects to PC for power + UART communication)
- **Terminal software** (PuTTY, Tera Term, Arduino Serial Monitor, etc.)

### Physical Connections:
```
Tang Nano 20K:
- Button 1: Pin 88 (SW1 onboard button)
- Button 2: Pin 87 (SW2 onboard button) 
- Red LED: Pin 15 (built-in RGB LED)
- Green LED: Pin 19 (built-in RGB LED)
- UART TX: Pin 69 (built-in USB-Serial converter)

Tang Nano 9K:
- Button 1: Pin 3 (SW1 onboard button)
- Button 2: Pin 4 (SW2 onboard button)
- Red LED: Pin 18 (built-in RGB LED)
- Green LED: Pin 17 (built-in RGB LED)  
- UART TX: Pin 69 (built-in USB-Serial converter)
```

**✅ Advantage**: Uses built-in USB-Serial converter - no external wiring needed!

## 📱 Software Setup

### Step 1: Find Your COM Port
**Windows:**
1. Open Device Manager
2. Expand "Ports (COM & LPT)"
3. Look for "USB-Enhanced-SERIAL CH340" or similar
4. Note the COM port number (e.g., COM3)

**Linux/Mac:**
```bash
# List available serial ports
ls /dev/tty*
# Look for /dev/ttyUSB0, /dev/ttyACM0, or similar
```

### Step 2: Configure Terminal Software

#### Option A: PuTTY (Windows - Recommended)
1. Download from [putty.org](https://putty.org)
2. **Connection Type**: Serial
3. **Serial Line**: COM3 (your COM port)
4. **Speed**: 115200
5. **Data bits**: 8, **Stop bits**: 1, **Parity**: None
6. Click "Open"

#### Option B: Tera Term (Windows Alternative)
1. Download Tera Term
2. File → New Connection → Serial
3. **Port**: COM3, **Baud rate**: 115200
4. Setup → Serial Port: 8-N-1

#### Option C: Arduino IDE Serial Monitor
1. Open Arduino IDE
2. Tools → Serial Monitor  
3. **Baud rate**: 115200
4. **Port**: Select your COM port

#### Option D: Linux/Mac Terminal
```bash
# Using screen
screen /dev/ttyUSB0 115200

# Using minicom  
minicom -D /dev/ttyUSB0 -b 115200

# Using picocom
picocom -b 115200 /dev/ttyUSB0
```

## 🚀 Running the Project

### 1. Build and Program
```bash
# Build for Tang Nano 20K (default)
make uart

# Or for Tang Nano 9K
make uart BOARD=9k

# Program to FPGA
make prog-uart
```

### 2. Open Your Terminal
1. Launch your terminal software (PuTTY recommended)
2. Connect to the correct COM port at 115200 baud
3. You should see a blank terminal - this is normal!

### 3. Test the Buttons!
- **Press Button 1 (SW1)**: 
  - ✅ Red LED lights up while pressed
  - ✅ Terminal shows: `button1`
- **Press Button 2 (SW2)**:
  - ✅ Green LED lights up while pressed  
  - ✅ Terminal shows: `button2`

**Expected Terminal Output:**
```
button1
button2
button1
button1
button2
button1
```

## 🧠 Understanding the Code Architecture

### Main Module: `uart.v`
```verilog
module uart (
    input wire clk,          // 27MHz system clock
    input wire btn1,         // Button 1 (active low)
    input wire btn2,         // Button 2 (active low)
    output wire led_r,       // Red LED
    output wire led_g,       // Green LED  
    output wire led_b,       // Blue LED (unused)
    output wire uart_tx      // UART transmit
);
```

### 1. Button Debouncing & Edge Detection
```verilog
reg [2:0] btn1_sync, btn2_sync;  // 3-stage synchronizer
reg btn1_pressed, btn2_pressed;  // Edge detection

// Synchronize and detect rising edge
always @(posedge clk) begin
    btn1_sync <= {btn1_sync[1:0], ~btn1};  // Shift register
    btn1_pressed <= (btn1_sync[2:1] == 2'b01);  // Rising edge
end
```

**Why Debouncing?**
- Mechanical buttons "bounce" causing multiple triggers
- 3-stage synchronizer filters out noise
- Edge detection ensures single message per press

### 2. LED Control
```verilog
// LED follows button state (inverted for active-low LEDs)
assign led_r = ~btn1_sync[2];  // Red on when btn1 pressed
assign led_g = ~btn2_sync[2];  // Green on when btn2 pressed
```

### 3. UART Debug Module
```verilog
uart_debug debug_uart_inst (
    .clk(clk),
    .btn1_trigger(btn1_pressed),  // Triggers on button edge
    .btn2_trigger(btn2_pressed),
    .uart_tx(uart_tx)
);
```

### 4. UART State Machine
The `uart_debug` module implements a **5-state finite state machine**:

```
IDLE → START → DATA → STOP → NEXT → (back to IDLE or START)
```

**State Details:**
- **IDLE**: Wait for button press trigger
- **START**: Send UART start bit (0)
- **DATA**: Send 8 data bits (LSB first)
- **STOP**: Send stop bit (1)
- **NEXT**: Advance to next character or finish

**Baud Rate Timing:**
```verilog
parameter BAUD_DIVISOR = 234;  // 27MHz ÷ 115200 ≈ 234 clocks/bit
```

## 🎮 What the Buttons Do

### Button 1 (SW1) - Red LED
- **Physical**: Tang Nano built-in button (active low)
- **Electrical**: Connected with pull-up resistor
- **Function**: Triggers "button1\r\n" UART message
- **LED**: Lights red LED while pressed
- **Debouncing**: 3-stage synchronizer prevents multiple triggers

### Button 2 (SW2) - Green LED  
- **Physical**: Tang Nano built-in button (active low)
- **Electrical**: Connected with pull-up resistor
- **Function**: Triggers "button2\r\n" UART message
- **LED**: Lights green LED while pressed
- **Debouncing**: 3-stage synchronizer prevents multiple triggers

### UART Communication Details
- **Baud Rate**: 115200 (fast, reliable)
- **Format**: 8N1 (8 data bits, no parity, 1 stop bit)
- **Message Format**: ASCII text + carriage return + line feed
- **Transmission**: Each button press sends complete message
- **Timing**: Immediate response to button press

## 🔍 Module Interconnection

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Buttons   │───▶│    uart.v    │───▶│  uart_debug │
│  (Physical) │    │   (Control)  │    │ (UART TX)   │
└─────────────┘    └──────────────┘    └─────────────┘
                           │                     │
                           ▼                     ▼
                   ┌─────────────┐    ┌─────────────┐
                   │    LEDs     │    │  Terminal   │
                   │ (Visual FB) │    │   (PC)      │
                   └─────────────┘    └─────────────┘
```

## 🛠️ Customization Ideas

### 1. Change Messages
Edit the message arrays in `uart_debug` module:
```verilog
// Current: "button1\r\n" and "button2\r\n"
// Try: "Hello!\r\n" and "World!\r\n"
button1_msg[0] = "H"; button1_msg[1] = "e"; // etc.
```

### 2. Add More Information
Include timestamps or counter values:
```verilog
// Add a counter to track button presses
reg [15:0] press_counter;
// Include counter in message: "btn1_005\r\n"
```

### 3. Different Baud Rates
```verilog
// Slower: 9600 baud
parameter BAUD_DIVISOR = 2812;  // 27MHz ÷ 9600

// Faster: 230400 baud  
parameter BAUD_DIVISOR = 117;   // 27MHz ÷ 230400
```

### 4. Add Button 3/4
Extend to more buttons using GPIO pins:
```verilog
input wire btn3, btn4;
output wire extra_led1, extra_led2;
```

## 🐛 Troubleshooting Guide

### ❌ No Messages in Terminal
**Check:**
1. **Correct COM port**: Device Manager → Ports
2. **Baud rate**: Must be exactly 115200
3. **Terminal settings**: 8N1 format
4. **FPGA programmed**: LEDs should light when buttons pressed
5. **USB connection**: Try different USB cable/port

### ❌ Messages Appear Multiple Times
**Cause**: Button bounce not properly filtered
**Solution**: The debouncing should handle this - check clock frequency

### ❌ LEDs Don't Light
**Check:**
1. **FPGA programming**: Re-run `make prog-uart`
2. **Button connection**: Built-in buttons should work
3. **Power**: USB cable provides power
4. **Constraints**: Pin assignments match your board

### ❌ Garbled Characters
**Check:**
1. **Baud rate mismatch**: Terminal and FPGA must match
2. **Clock frequency**: Should be 27MHz
3. **UART timing**: BAUD_DIVISOR calculation

### ❌ Random Characters
**Cause**: Usually floating pins or electrical noise
**Solution**: Check constraint files and pin assignments

## � Learning Outcomes

After completing this project, you'll understand:

✅ **FPGA-PC Communication**: Real-time data exchange  
✅ **Button Interfacing**: Debouncing and edge detection  
✅ **UART Protocol**: Serial communication fundamentals  
✅ **State Machines**: Sequential control logic  
✅ **Module Hierarchy**: Breaking complex designs into parts  
✅ **Pin Constraints**: Mapping signals to physical pins  
✅ **Synchronous Design**: Clock-based digital systems  
✅ **Hardware Debugging**: Real-time system monitoring  

## 🚀 Next Steps

### Beginner Projects:
1. **Add LED patterns**: Make LEDs blink in sequences
2. **Count button presses**: Display press count in messages
3. **Add delays**: Introduce timing between button and LED

### Intermediate Projects:
1. **Bi-directional UART**: Receive commands from PC
2. **Protocol design**: JSON or CSV message formats
3. **Buffer messages**: Use FIFOs for message queuing

### Advanced Projects:
1. **6502 Computer**: `make 6502-computer` - Full CPU with UART
2. **Video output**: `make video` - VGA signal generation
3. **Sound synthesis**: `make sound` - Audio generation

## 📚 Technical Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Clock Frequency** | 27MHz | Tang Nano crystal oscillator |
| **UART Baud Rate** | 115200 | Standard high-speed rate |
| **UART Format** | 8N1 | 8 data, no parity, 1 stop |
| **Button Voltage** | 3.3V | LVCMOS33 with pull-up |
| **LED Drive** | 8mA | DRIVE=8 in constraints |
| **Debounce Stages** | 3 | Sufficient for most applications |
| **Message Length** | 9 chars | "button1\r\n" or "button2\r\n" |

## 🏆 Why This Project Matters

This project teaches **fundamental embedded systems concepts**:

1. **Real-time response**: FPGA reacts immediately to inputs
2. **Human-machine interface**: Buttons + LEDs + terminal feedback  
3. **Protocol implementation**: UART is used everywhere in industry
4. **State machine design**: Core skill for digital system design
5. **Modular architecture**: Professional FPGA development practices

**Real-world applications**: IoT devices, embedded controllers, debugging interfaces, test equipment, industrial automation.

---

**🎉 Congratulations!** You've built an interactive FPGA communication system. This is your foundation for understanding how FPGAs interface with the real world!

*Ready to level up? Try the 6502 Computer project next!* 🚀
