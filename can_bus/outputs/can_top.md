
# Entity: can_top 
- **File**: can_top.v

## Diagram
![Diagram](can_top.svg "Diagram")
## Ports

| Port name  | Direction | Type        | Description |
| ---------- | --------- | ----------- | ----------- |
| clk        | input     | wire        |             |
| rst        |           |             |             |
| rx_in      |           |             |             |
| tx_out     | output    | wire        |             |
| tx_request | input     | wire        |             |
| tx_id      | input     | wire [10:0] |             |
| tx_dlc     | input     | wire [3:0]  |             |
| tx_data    | input     | wire [63:0] |             |
| rx_valid   | output    | wire        |             |
| rx_id      | output    | wire [10:0] |             |
| rx_dlc     | output    | wire [3:0]  |             |
| rx_data    | output    | wire [63:0] |             |

## Signals

| Name                                                 | Type        | Description |
| ---------------------------------------------------- | ----------- | ----------- |
| sample_point                                         | wire        |             |
| tx_point                                             | wire        |             |
| tx_data_to_bsp                                       | wire        |             |
| rx_data_out                                          | wire        |             |
| tx_stall                                             | wire        |             |
| rx_stall                                             | wire        |             |
| enable_tx_stuffing                                   | wire        |             |
| enable_rx_stuffing                                   | wire        |             |
| crc_out                                              | wire [14:0] |             |
| crc_enable                                           | wire        |             |
| crc_reset                                            | wire        |             |
| rx_idle                                              | wire        |             |
| tx_idle                                              | wire        |             |
| q1                                                   | reg         |             |
| q2                                                   | reg         |             |
| rx_sync_edge = (~q1 & q2) && rx_idle && tx_idle      | wire        |             |
| crc_data_in = tx_idle ? rx_data_out : tx_data_to_bsp | wire        |             |
| gated_crc_en = crc_enable && sample_point            | wire        |             |

## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always

## Instantiations

- uut_btl: can_btl
- uut_bsp: can_bsp
- uut_crc: can_crc
- uut_fsm: can_fsm
