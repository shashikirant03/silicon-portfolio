
# Entity: can_crc 
- **File**: can_crc.v

## Diagram
![Diagram](can_crc.svg "Diagram")
## Ports

| Port name | Direction | Type   | Description |
| --------- | --------- | ------ | ----------- |
| clk       | input     | wire   |             |
| rst       | input     | wire   |             |
| data_in   | input     | wire   |             |
| enable    | input     | wire   |             |
| crc_reg   | output    | [14:0] |             |

## Processes
- unnamed: ( @(posedge clk or posedge rst) )
  - **Type:** always
