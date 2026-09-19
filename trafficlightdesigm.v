// Simple Traffic Light Controller - Moore FSM
// States: NS Green -> NS Yellow -> EW Green -> EW Yellow -> (repeat)
// A pedestrian button press inserts a WALK state after EW Yellow.

module traffic_light_fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire       ped_req,
    output reg  [1:0] ns_light,   // 00=RED, 01=YELLOW, 10=GREEN
    output reg  [1:0] ew_light,
    output reg        ped_walk
);

    // States
    parameter NS_GREEN  = 3'd0;
    parameter NS_YELLOW = 3'd1;
    parameter EW_GREEN  = 3'd2;
    parameter EW_YELLOW = 3'd3;
    parameter PED_WALK  = 3'd4;

    // Fixed durations (clock cycles)
    parameter GREEN_TIME  = 8;
    parameter YELLOW_TIME = 3;
    parameter WALK_TIME   = 6;

    reg [2:0] state;
    reg [3:0] count;
    reg       ped_flag;   // latched pedestrian request

    // Latch pedestrian request until it's serviced
    always @(posedge clk) begin
        if (rst)
            ped_flag <= 0;
        else if (ped_req)
            ped_flag <= 1;
        else if (state == EW_YELLOW && count == 0)
            ped_flag <= 0;   // clears the moment we decide to service it
    end

    // State + counter
    always @(posedge clk) begin
        if (rst) begin
            state <= NS_GREEN;
            count <= GREEN_TIME - 1;
        end else if (count == 0) begin
            case (state)
                NS_GREEN:  begin state <= NS_YELLOW; count <= YELLOW_TIME - 1; end
                NS_YELLOW: begin state <= EW_GREEN;  count <= GREEN_TIME  - 1; end
                EW_GREEN:  begin state <= EW_YELLOW; count <= YELLOW_TIME - 1; end
                EW_YELLOW: begin
                    if (ped_flag) begin
                        state <= PED_WALK;
                        count <= WALK_TIME - 1;
                    end else begin
                        state <= NS_GREEN;
                        count <= GREEN_TIME - 1;
                    end
                end
                PED_WALK:  begin state <= NS_GREEN; count <= GREEN_TIME - 1; end
                default:   begin state <= NS_GREEN; count <= GREEN_TIME - 1; end
            endcase
        end else begin
            count <= count - 1;
        end
    end

    // Moore outputs: depend only on state
    always @(*) begin
        case (state)
            NS_GREEN:  begin ns_light = 2'b10; ew_light = 2'b00; ped_walk = 0; end
            NS_YELLOW: begin ns_light = 2'b01; ew_light = 2'b00; ped_walk = 0; end
            EW_GREEN:  begin ns_light = 2'b00; ew_light = 2'b10; ped_walk = 0; end
            EW_YELLOW: begin ns_light = 2'b00; ew_light = 2'b01; ped_walk = 0; end
            PED_WALK:  begin ns_light = 2'b00; ew_light = 2'b00; ped_walk = 1; end
            default:   begin ns_light = 2'b00; ew_light = 2'b00; ped_walk = 0; end
        endcase
    end

endmodule
