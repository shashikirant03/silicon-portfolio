
# Entity: tb_can_calc_network 
- **File**: tb_can_calc_network.v

## Diagram
![Diagram](tb_can_calc_network.svg "Diagram")
## Signals

| Name        | Type        | Description |
| ----------- | ----------- | ----------- |
| clk         | reg         |             |
| rst         | reg         |             |
| can_bus     | wire        |             |
| tx_req_A    | reg         |             |
| tx_req_B    | reg         |             |
| tx_req_C    | reg         |             |
| tx_id_A     | reg [10:0]  |             |
| tx_id_B     | reg [10:0]  |             |
| tx_id_C     | reg [10:0]  |             |
| tx_data_A   | reg [63:0]  |             |
| tx_data_B   | reg [63:0]  |             |
| tx_data_C   | reg [63:0]  |             |
| rx_val_A    | wire        |             |
| rx_val_B    | wire        |             |
| rx_val_C    | wire        |             |
| rx_data_A   | wire [63:0] |             |
| rx_data_B   | wire [63:0] |             |
| rx_data_C   | wire [63:0] |             |
| rx_id_A     | wire [10:0] |             |
| rx_id_B     | wire [10:0] |             |
| rx_id_C     | wire [10:0] |             |
| tx_A        | wire        |             |
| tx_B        | wire        |             |
| tx_C        | wire        |             |
| rx_c_caught | reg         |             |
| rx_a_caught | reg         |             |
| stored_A    | reg [63:0]  |             |
| stored_B    | reg [63:0]  |             |

## Processes
- unnamed: (  )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always

## Instantiations

- ecu_A: can_top
- ecu_B: can_top
- ecu_C: can_top
