#AES Encryption/Decryption FPGA Implementation

This project implements AES encryption and decryption on FPGA with support for 128-bit, 192-bit, and 256-bit keys. The current wrapper module (`aes_top.v`) is configured for AES-128, but the underlying core modules support all three key sizes through parameterization.

##Features

- **AES-128/192/256 Support** - Core modules support all three key sizes through parameterization
- **AES-128 Configuration** - Current wrapper (`aes_top.v`) configured for 128-bit keys (10 rounds)
- **User Input Interface** - No hardcoded keys - user enters key and plaintext/ciphertext byte-by-byte
- **Control Signals** - SELECT, LOAD, CMD, START for complete user control
- **Status Indicators** - busy and done signals for operation status
- **128-bit Data Bus** - Clean output interface without LED display logic

## Project Structure

```
├── RTL/
│   ├── aes_top.v          # Top-level wrapper module
│   ├── tb_aes_top.v       # Testbench for the wrapper
│   ├── aes_enc.v          # Encryption core
│   ├── aes_dec.v          # Decryption core
│   ├── key_gen.v          # Key expansion module
│   ├── g.v                # Helper for key expansion
│   ├── sbox.v             # Substitution box (encryption)
│   ├── inv_sbox.v         # Inverse substitution box (decryption)
│   ├── subs_bytes.v       # SubBytes transformation
│   ├── inv_subs_bytes.v   # InvSubBytes transformation
│   ├── shift_row.v        # ShiftRows transformation
│   ├── inv_shift_row.v    # InvShiftRows transformation
│   ├── mix_128.v          # MixColumns top-level
│   ├── mix_32.v           # MixColumns for 32-bit words
│   ├── inv_mix_128.v      # InvMixColumns top-level
│   ├── inv_mix_32.v       # InvMixColumns for 32-bit words
│   ├── add_rk.v           # AddRoundKey transformation
│   ├── enc_round.v        # Single encryption round
│   ├── dec_round.v        # Single decryption round
│   └── [other helper files]
```

## Top-Level Module Interface (aes_top.v)

### Inputs
- `clk` - System clock
- `rst_n` - Active-low reset
- `data_in[7:0]` - 8-bit data input (connect to switches)
- `select` - Switch: 0=KEY mode, 1=TEXT mode
- `load` - Push button: store current byte
- `cmd` - Switch: 0=ENCRYPT, 1=DECRYPT
- `start` - Push button: start processing

### Outputs
- `done` - High when operation completes
- `busy` - High during processing
- `data_out[127:0]` - 128-bit encrypted/decrypted result

## How to Use

### 1. Enter Key (128 bits for current configuration)
1. Set `select = 0` (KEY mode)
2. Set 8 switches to desired byte value
3. Press `load` button to store the byte
4. Repeat for all 16 bytes (128 bits)

**Note:** The current wrapper is configured for AES-128 (16-byte key). To use AES-192 (24-byte key) or AES-256 (32-byte key), modify the wrapper to support larger key sizes and adjust the byte counter accordingly.

### 2. Enter Text (128 bits)
1. Set `select = 1` (TEXT mode)
2. Set 8 switches to desired byte value
3. Press `load` button to store the byte
4. Repeat for all 16 bytes (128 bits)

### 3. Execute Operation
1. Set `cmd = 0` for ENCRYPT or `cmd = 1` for DECRYPT
2. Press `start` button
3. Wait for `done` signal to go high
4. Read result from `data_out[127:0]`

## Simulation Instructions

### Vivado Simulation

1. **Create Vivado Project**
   - File → New Project
   - Add all `.v` files from RTL folder
   - Set `tb_aes_top.v` as simulation top module

2. **Run Behavioral Simulation**
   - Click "Run Simulation" → "Run Behavioral Simulation"
   - Run for at least 3-5 microseconds
   - Observe waveform:
     - `load` pulses 16 times for KEY, 16 times for TEXT
     - `start` button goes high
     - `busy` goes high during processing
     - `done` goes high when complete
     - `data_out` shows final encrypted/decrypted value

3. **Check Console Output**
   - Look for "Encrypted Output: <hex value>" in TCL console
   - Verify against known AES test vectors

### ModelSim Simulation

1. **Compile Files**
   ```bash
   vlog *.v
   ```

2. **Run Simulation**
   ```bash
   vsim tb_aes_top
   add wave -r /*
   run 5us
   ```

## Synthesis Instructions

### Vivado Synthesis (Detailed Steps with Image Generation)

1. **Setup Project**
   - Create new Vivado project
   - Add all RTL files to design sources
   - Set `aes_top.v` as top module (NOT the testbench)

2. **Run Synthesis**
   - Click "Run Synthesis" in the Flow Navigator
   - Wait for synthesis to complete
   - Check resource utilization:
     - LUTs: Look-up tables used
     - FFs: Flip-flops used
     - BRAM: Block RAM (if any)
     - DSP: DSP slices (if any)

3. **Generate Synthesis Images/Reports**

   **A. Resource Utilization Image**
   - After synthesis completes, click "Open Synthesized Design"
   - Go to "Reports" → "Report Utilization"
   - In the Utilization Report window, click the camera icon or "File" → "Save As"
   - Save as PNG: Shows LUT, FF, BRAM, DSP usage in graphical format

   **B. Schematic Image**
   - With synthesized design open, press "Ctrl+S" or click the schematic icon
   - This opens the RTL schematic view
   - Navigate through the hierarchy (aes_top → aes_enc/aes_dec → key_gen, etc.)
   - Click "File" → "Export" → "Export Image" or use camera tool
   - Save as PNG: Shows the hardware structure and connections

   **C. Timing Report Image**
   - Go to "Reports" → "Report Timing Summary"
   - Review the timing analysis (setup, hold, recovery)
   - Click "File" → "Save As" to save the timing summary as image
   - This shows max frequency and timing slack

   **D. Power Report Image (Optional)**
   - Go to "Reports" → "Report Power"
   - Review power consumption analysis
   - Export as image for documentation

4. **View Synthesis Report**
   - Post-synthesis timing report
   - Resource utilization summary
   - Power analysis (optional)

5. **Implementation**
   - Click "Run Implementation"
   - This will place and route the design
   - Check timing constraints are met

6. **Generate Bitstream**
   - Click "Generate Bitstream"
   - This creates the `.bit` file for FPGA programming

### Quartus Synthesis (Intel/Altera)

1. **Create Project**
   - File → New Project Wizard
   - Add all RTL files
   - Set `aes_top.v` as top entity
   - Select target FPGA device

2. **Compile Design**
   - Processing → Start Compilation
   - This runs Analysis & Synthesis, Fitter, and Assembler

3. **View Reports**
   - Compilation Report → Resource Section
   - Check ALM usage, registers, memory bits
   - Timing Analyzer reports

4. **Generate Programming File**
   - File → Convert Programming Files
   - Create `.sof` or `.pof` for FPGA programming

## FPGA Pin Mapping (Constraints)

Create an XDC file (Vivado) or QSF file (Quartus) to map physical pins:

### Vivado XDC Example
```tcl
# Clock
set_property LOC <clock_pin> [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Reset
set_property LOC <reset_pin> [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# Data Input (8 switches)
set_property LOC <switch0_pin> [get_ports {data_in[0]}]
set_property LOC <switch1_pin> [get_ports {data_in[1]}]
# ... continue for all 8 bits

# Control Signals
set_property LOC <select_pin> [get_ports select]
set_property LOC <cmd_pin> [get_ports cmd]
set_property LOC <load_pin> [get_ports load]
set_property LOC <start_pin> [get_ports start]

# Status LEDs (optional)
set_property LOC <busy_led_pin> [get_ports busy]
set_property LOC <done_led_pin> [get_ports done]
```

## Testing on FPGA

1. **Program FPGA**
   - Vivado: Hardware Manager → Program Device
   - Quartus: Tools → Programmer

2. **Manual Test**
   - Enter known test vector key (e.g., 00 01 02 ... 0F)
   - Enter known plaintext (e.g., 00 11 22 ... FF)
   - Select encryption mode
   - Start operation
   - Verify output against expected ciphertext

3. **Verification**
   - Use NIST AES test vectors for validation
   - Test both encryption and decryption
   - Verify round-trip (encrypt then decrypt returns original)

## Expected Results

For key `00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F` and plaintext `00 11 22 33 44 55 66 77 88 99 AA BB CC DD EE FF`, the encrypted output should match standard AES-128 test vectors.

## Troubleshooting

- **Multiple driver errors**: Fixed in current version - cores use separate outputs with MUX
- **Timing violations**: Check clock frequency constraints in XDC file
- **Simulation not starting**: Ensure `tb_aes_top.v` is set as simulation top
- **Synthesis fails**: Check all required files are added to project

## License

This project is provided for educational purposes.
