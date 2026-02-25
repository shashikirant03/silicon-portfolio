
# Entity: can_bsp 
- **File**: can_bsp.v

## Diagram
![Diagram](can_bsp.svg "Diagram")
## Ports

| Port name          | Direction | Type | Description |
| ------------------ | --------- | ---- | ----------- |
| clk                | input     | wire |             |
| rst                |           |      |             |
| sample_point       |           |      |             |
| tx_point           |           |      |             |
| rx_in              |           |      |             |
| tx_data_in         |           |      |             |
| enable_tx_stuffing | input     | wire |             |
| enable_rx_stuffing |           |      |             |
| tx_out             | output    |      |             |
| rx_data_out        |           |      |             |
| tx_stall           | output    | wire |             |
| rx_stall           |           |      |             |

## Signals

| Name     | Type      | Description |
| -------- | --------- | ----------- |
| tx_ones  | reg [2:0] |             |
| tx_zeros | reg [2:0] |             |
| rx_ones  | reg [2:0] |             |
| rx_zeros | reg [2:0] |             |

## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always
