module video_encoder(
    input logic [7:0] pixel_data,
    input logic signed [4:0] previous_count, //Decide on count reg size
    output logic [9:0] encoded_data,
    output logic signed [4:0] next_count,
);
    logic [8:0] q_m;
    logic [3:0] d_one_count, q_m_one_count, q_m_zero_count;

    assign d_one_count = pixel_data[0] + pixel_data[1] + pixel_data[2] + pixel_data[3] + pixel_data[4] + pixel_data[5] + pixel_data[6] + pixel_data[7];
    assign q_m_one_count = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7];
    assign q_m_zero_count = 8 - q_m_one_count;

    always_comb begin
        q_m[0] = pixel_data[0];
        
        if (d_one_count > 4 || (d_one_count == 4 && pixel_data[0] == 0)) begin
            q_m[1] = q_m[0] ~^ pixel_data[1];
            q_m[2] = q_m[1] ~^ pixel_data[2];
            q_m[3] = q_m[2] ~^ pixel_data[3];
            q_m[4] = q_m[3] ~^ pixel_data[4];
            q_m[5] = q_m[4] ~^ pixel_data[5];
            q_m[6] = q_m[5] ~^ pixel_data[6];
            q_m[7] = q_m[6] ~^ pixel_data[7];
            q_m[8] = 0;
        end
        else begin
            q_m[1] = q_m[0] ^ pixel_data[1];
            q_m[2] = q_m[1] ^ pixel_data[2];
            q_m[3] = q_m[2] ^ pixel_data[3];
            q_m[4] = q_m[3] ^ pixel_data[4];
            q_m[5] = q_m[4] ^ pixel_data[5];
            q_m[6] = q_m[5] ^ pixel_data[6];
            q_m[7] = q_m[6] ^ pixel_data[7];
            q_m[8] = 1;
        end

        if (previous_count == 0 || q_m_one_count == q_m_zero_count) begin
            encoded_data[9] = ~q_m[8];
            encoded_data[8] = q_m[8];
            encoded_data[7:0] = q_m[8] ? q_m[7:0] : ~q_m[7:0];
            if (q_m[8] == 0) begin
                next_count = previous_count + {1'b0, q_m_zero_count} - {1'b0, q_m_one_count};
            end
            else begin
                next_count = previous_count + {1'b0, q_m_one_count} - {1'b0, q_m_zero_count};
            end
        end
        else if ((~prev_count_neg_flag && previous_count != 0 && q_m_one_count > q_m_zero_count) || (prev_count_neg_flag && q_m_zero_count > q_m_one_count)) begin
            encoded_data[9] = 1;
            encoded_data[8] = q_m[8];
            encoded_data[7:0] = ~q_m[7:0];
            next_count = previous_count + {3'b0, q_m[8], 1'b0} + {1'b0, q_m_zero_count} - {1'b0, q_m_one_count};        
        end
        else begin
            encoded_data[9] = 0;
            encoded_data[8] = q_m[8];
            encoded_data[7:0] = q_m[7:0];
            next_count = previous_count - {3'b0, ~q_m[8], 1'b0} + {1'b0, q_m_zero_count} - {1'b0, q_m_one_count};
        end
    end
endmodule