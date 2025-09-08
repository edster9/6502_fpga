# 🔍 Hello World with UART Debug - Learning Guide

## 🎯 What You'll Learn

This enhanced hello-world project teaches you:
1. **Basic FPGA Design** - LED blinking with counters
2. **UART Communication** - Real-time debug output to your computer
3. **Hardware Debugging** - See what's happening inside your FPGA
4. **Module Integration** - How to connect multiple Verilog modules

## 🔌 Hardware Setup

### You'll Need:
- **Tang Nano 9K/20K** FPGA board
- **USB-to-Serial Adapter** (FTDI, CH340, CP2102, etc.)
- **Jumper wires**
- **Terminal software** (PuTTY, Arduino Serial Monitor, screen, minicom)

### Wiring Connections:
```
Tang Nano 9K Pin 17 (UART TX) → USB-Serial RX
USB-Serial GND → Tang Nano GND
```

**⚠️ Important**: Only connect TX→RX and GND. Don't connect the 3.3V/5V lines unless you know your adapter's voltage levels!

## 📱 Software Setup

### Option 1: PuTTY (Windows)
1. Download PuTTY from putty.org
2. Set Connection Type: `Serial`
3. Set Serial Line: `COM3` (check Device Manager for your port)
4. Set Speed: `115200`
5. Click "Open"

### Option 2: Arduino IDE Serial Monitor
1. Open Arduino IDE
2. Go to Tools → Serial Monitor
3. Set baud rate to `115200`
4. Select your COM port

### Option 3: Terminal (Linux/Mac)
```bash
# Find your device (usually /dev/ttyUSB0 or /dev/ttyACM0)
ls /dev/tty*

# Connect with screen
screen /dev/ttyUSB0 115200

# Or with minicom
minicom -D /dev/ttyUSB0 -b 115200
```

## 🚀 Running the Project

### 1. Build and Program
```bash
# Build the project
make hello-world

# Program to Tang Nano
make prog-hello-world
```

### 2. Watch the Debug Output
You should see messages like this every ~5 seconds:
```
Hello! Counter: 0x0001A4
Hello! Counter: 0x0067B2
Hello! Counter: 0x00CE89
Hello! Counter: 0x013560
```

### 3. Observe Both Outputs
- **LEDs**: Red, Green, Blue blinking at different rates
- **UART**: Counter values updating in your terminal

## 🧠 Understanding the Code

### Counter Logic
```verilog
reg [23:0] counter;        // Main LED counter
reg [26:0] debug_counter;  // Debug message timing

always @(posedge clk) begin
    counter <= counter + 1;         // Increments every clock cycle
    debug_counter <= debug_counter + 1;  // Controls debug timing
end
```

### Debug Trigger
```verilog
wire debug_trigger = (debug_counter == 27'd0);  // True every ~5 seconds
```

### UART Debug Module
The `uart_debug_simple` module:
1. Waits for `debug_trigger` edge
2. Converts counter value to hex ASCII
3. Sends "Hello! Counter: 0xXXXX\r\n" at 115200 baud
4. Uses a state machine to send each character

## 🔍 What to Experiment With

### 1. Change Debug Frequency
```verilog
// Faster debug messages (every ~1 second)
reg [24:0] debug_counter;  // Smaller counter = faster messages

// Slower debug messages (every ~20 seconds)  
reg [28:0] debug_counter;  // Larger counter = slower messages
```

### 2. Add More Debug Information
Modify the debug message to include LED states:
```verilog
// In uart_debug_simple module, change the message array
debug_message[0]  = "L";  debug_message[1]  = "E";  debug_message[2]  = "D";
debug_message[3]  = ":";  debug_message[4]  = " ";  
// Add logic to include led_r, led_g, led_b values
```

### 3. Debug Different Counter Bits
```verilog
// Send different parts of the counter
.counter_value(counter[31:8])    // Upper bits
.counter_value(counter[15:0])    // Lower 16 bits
```

## 🏆 Learning Outcomes

After completing this project, you'll understand:

✅ **FPGA Basics**: Clock domains, registers, combinational logic  
✅ **UART Protocol**: Serial communication fundamentals  
✅ **Debug Strategies**: Real-time hardware monitoring  
✅ **State Machines**: Sequential logic design  
✅ **Module Hierarchy**: Building complex designs from simple parts  
✅ **Pin Constraints**: Connecting internal signals to physical pins  

## 🐛 Troubleshooting

### No UART Output?
1. **Check wiring**: TX→RX, GND→GND
2. **Verify COM port**: Device Manager (Windows) or `dmesg` (Linux)
3. **Correct baud rate**: Must be 115200
4. **Terminal settings**: 8N1 (8 data bits, no parity, 1 stop bit)

### LEDs Not Blinking?
1. **Check programming**: Make sure bitstream loaded
2. **Verify clock**: Pin 52 should have 27MHz crystal
3. **Power supply**: Ensure board is powered properly

### Wrong Debug Values?
1. **Endianness**: Counter might show different than expected
2. **Timing**: Debug messages sent every ~5 seconds
3. **Hex conversion**: Values are in hexadecimal

## 🎓 Next Steps

Once you master this project:

1. **Try the 6502 Computer**: `make 6502-computer`
2. **Add more debug features**: Memory dumping, CPU registers
3. **Learn about FIFOs**: Buffer debug messages
4. **Implement bi-directional UART**: Send commands to FPGA
5. **Add protocol layers**: JSON, CSV, or custom formats

## 📚 Key Concepts Learned

| Concept | Application | Real-World Use |
|---------|-------------|----------------|
| **UART** | Debug output | Embedded system communication |
| **State Machines** | Character transmission | Protocol controllers |
| **Clock Domains** | Counter timing | Digital signal processing |
| **Module Hierarchy** | Code organization | Large system design |
| **Pin Constraints** | I/O mapping | PCB design integration |

Happy learning! 🎉

*This is your gateway to understanding how real FPGA debugging works in industry!*
