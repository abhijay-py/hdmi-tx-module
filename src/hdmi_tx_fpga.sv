//Zybo Z7-10
module hdmi_tx_fpga (
    input logic sysclk,
    output logic hdmi_tx_clk_p, hdmi_tx_clk_n, hdmi_tx_hpd, hdmi_tx_scl, hdmi_tx_sda, hdmi_tx_cec,
    output logic [2:0] hdmi_tx_p, hdmi_tx_n
);
    // Logic to allow fpga synthesis to be accurate for the board.

endmodule