
# Entity: can_btl 
- **File**: can_btl.v

## Diagram
![Diagram](can_btl.svg "Diagram")
## Ports

| Port name    | Direction | Type | Description |
| ------------ | --------- | ---- | ----------- |
| clk          | input     | wire |             |
| rst          |           |      |             |
| rx_sync_edge |           |      |             |
| sample_point | output    |      |             |
| tx_point     |           |      |             |

## Signals

| Name  | Type      | Description |
| ----- | --------- | ----------- |
| count | reg [3:0] |             |

## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always
