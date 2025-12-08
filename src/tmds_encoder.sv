
module tmds_encoder (
    input logic tmds_clk, n_rst
    input logic [7:0] data,
    input logic [1:0] ctrl, period_type, tmds_channel_num,
    input logic [3:0] auxiliary_data,
    input logic tmds_0_channel,
    output logic [9:0] tmds_data
);
    logic [9:0] pixel_encoded;
    logic guard_band_transmitting, pe_n_rst;
    
    video_data_encoder vde #(5) (.clk(tmds_clk), .n_rst(pe_n_rst), .pixel_data(data), .encoded_data(pixel_encoded));
    
    
    always_comb begin : data_output_logic
        tmds_data = 10'b0;
        pe_n_rst = n_rst && (period_type == 2'b10); //Always reset counter unless currently in video period.

        case (period_type) 
            2'b00: begin //Control Period
                case (ctrl)
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
                    //Data Island encoding
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