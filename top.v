module top (
    input   clock_under_test,
    input   reference_clock,
    input   capture_enable,
    
    input   spi_sclk,
    inout   spi_miso,
    input   spi_mosi,
    input   spi_nss,
    
    input   reset_n
);
reg     [7:0]   capture_gate [0:1];

wire    [23:0]  capture_counter_q;
capture_counter capture_counter_inst (
    .clock  (clock_under_test),
    .aclr   (!reset_n),
    .cnt_en (capture_enable),
    .q      (capture_counter_q)
);

wire    capture_trigger;
capture_comparator  capture_comparator_inst ( // 3 clocks pipelined
    .clock  (clock_under_test),
    .aclr   (!reset_n),
    .dataa  (capture_counter_q),
    .datab  ({capture_gate[1],capture_gate[0]}),
    .ageb   (capture_trigger)
);

wire    capture_broaden_trigger;
JKFF    capture_jkff ( // 1 clocks latched
    .j      (capture_trigger), 
    .k      (!capture_enable), 
    .clk    (clock_under_test), 
    .clrn   (reset_n), 
    .prn    (1'b1), 
    .q      (capture_broaden_trigger)
);

wire   [15:0]       reference_counter_q;
reference_counter   reference_counter_inst (
    .clock  (reference_clock),
    .aclr   (!reset_n),
    .cnt_en (capture_enable),
    .q      (reference_counter_q)
);

reg    [15:0]    caputured_reference_counter;   
always @(posedge reference_clock or negedge reset_n) begin
    if (!reset_n) begin
        caputured_reference_counter <= 16'b0;
    end else if (capture_broaden_trigger) begin
        caputured_reference_counter <= reference_counter_q;
    end
end

reg    spi_valid;
reg    spi_dsel;
wire   spi_ready;
always @(posedge reference_clock or negedge reset_n) begin
    if (!reset_n) begin
        spi_valid <= 1'b0;
        spi_dsel  <= 1'b0;
    end else if (capture_broaden_trigger && spi_ready) begin
        spi_valid <= 1'b1;   
        spi_dsel  <= spi_dsel + 1'b1;
    end else begin
        spi_dsel  <= 1'b0;
    end
end
reg    spi_gate_dsel;
wire            spi_gate_valid;
wire    [7:0]   spi_gate_data;
always @(posedge reference_clock or negedge reset_n) begin
    if (!reset_n) begin
        capture_gate[0] <= 8'b0;
        capture_gate[1] <= 8'b0;
        spi_gate_dsel   <= 1'b0;
    end else if (spi_gate_valid) begin
        capture_gate[spi_gate_dsel] <= spi_gate_data;
        spi_gate_dsel               <= spi_gate_dsel + 1'b1;
    end else begin
        spi_gate_dsel   <= 1'b0;
    end
end

spi_qsys u0 (
    .sysclk        (reference_clock),
    .nreset        (reset_n),
    .mosi          (spi_mosi),
    .nss           (spi_nss),
    .miso          (spi_miso),
    .sclk          (spi_sclk),
    .stsourceready (1'b1),
    .stsourcevalid (spi_gate_valid),
    .stsourcedata  (spi_gate_data),
    .stsinkvalid   (capture_broaden_trigger),
    .stsinkdata    (spi_dsel ? caputured_reference_counter[15:8] : caputured_reference_counter[7:0]),
    .stsinkready   (spi_ready)
);
endmodule