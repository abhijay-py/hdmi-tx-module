//Encode 10-bit TMDS data for HDMI channels.
module tmds_encoder (
    input logic tmds_clk, n_rst
    input logic [7:0] data,
    input logic [1:0] ctrl_data, period_type, tmds_channel_num,
    input logic [3:0] auxiliary_data,
    input logic tmds_0_channel,
    output logic [9:0] tmds_data
);
    logic [9:0] pixel_encoded;
    logic [3:0] data_island_data, dp_channel_zero_data; 
    logic guard_band_transmitting, vde_n_rst, dpchze_n_rst;
    
    video_data_encoder vde #(5) (.clk(tmds_clk), .n_rst(vde_n_rst), .pixel_data(data), .encoded_data(pixel_encoded));
    dp_ch0_encoder dpcze (.clk(tmds_clk), .n_rst(dpchze_n_rst), .auxiliary_data(auxiliary_data), .ctrl_data(ctrl_data), .data_out(dp_channel_zero_data));
    
    always_comb begin : control_logic
        vde_n_rst = n_rst && (period_type == 2'b10); //Always reset counter unless currently in video period.
        dpchze_n_rst = n_rst && (period_type == 2'b01); 

        data_island_data = tmds_channel_num != 2'b0 ? auxiliary_data : dp_channel_zero_data;

        guard_band_transmitting = 1'b0; //Temporary assignment, correct later.
    end

    always_comb begin : data_output_logic
        tmds_data = 10'b0;
        
        case (period_type) 
            2'b00: begin //Control Period
                case (ctrl_data)
                    2'b00: tmds_data = 10'b1101010100;
                    2'b01: tmds_data = 10'b0010101011;
                    2'b10: tmds_data = 10'b0101010100;
                    2'b11: tmds_data = 10'b1010101011;
                endcase
            end
            2'b01: begin //Data Island Period
                if (guard_band_transmitting && tmds_channel_num != 2'b0) begin
                    case (tmds_channel_num):
                        2'b01: tmds_data = 10'b0100110011;
                        2'b10: tmds_data = 10'b0100110011;
                    endcase
                end
                else begin  
                    case (data_island_data)
                        4'b0000: tmds_data = 10'b1010011100;
                        4'b0001: tmds_data = 10'b1001100011;
                        4'b0010: tmds_data = 10'b1011100100;
                        4'b0011: tmds_data = 10'b1011100010;
                        4'b0100: tmds_data = 10'b0101110001;
                        4'b0101: tmds_data = 10'b0100011110;
                        4'b0110: tmds_data = 10'b0110001110;
                        4'b0111: tmds_data = 10'b0100111100;
                        4'b1000: tmds_data = 10'b1011001100;
                        4'b1001: tmds_data = 10'b0100111001;
                        4'b1010: tmds_data = 10'b0110011100;
                        4'b1011: tmds_data = 10'b1011000110;
                        4'b1100: tmds_data = 10'b1010001110;
                        4'b1101: tmds_data = 10'b1001110001;
                        4'b1110: tmds_data = 10'b0101100011;
                        4'b1111: tmds_data = 10'b1011000011;
                    endcase
                end
            end
            2'b10: begin //Video Period 
                if (guard_band_transmitting) begin  
                    case (tmds_channel_num):
                        2'b00: tmds_data = 10'b1011001100;
                        2'b01: tmds_data = 10'b0100110011;
                        2'b10: tmds_data = 10'b1011001100;
                    endcase
                end
                else begin
                    tmds_data = pixel_encoded;
                end
            end
        endcase
    end


endmodule