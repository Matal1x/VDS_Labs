// -------------------------------------------------
// Copyright(c) LUBIS EDA GmbH, All rights reserved
// Contact: contact@lubis-eda.com
// -------------------------------------------------

`default_nettype none

module logic_unit_seq #(
    parameter    WIDTH = 16
)(
    input  logic             clk,
    input  logic             rst,
    input  logic [WIDTH-1:0] req_vec,
    input  logic             valid,
    output logic             out,
    output logic             done
);

    //////////////////////
    // Internal Signals //
    //////////////////////
    logic [WIDTH-1:0] req_vec_reg;
    logic [WIDTH-1:0] counter;
    logic             or_result_reg;
    logic             out_reg;
    logic             valid_reg;
    logic             done_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out_reg       <= 1'b0;
	// only this  is set to 1
            done_reg      <= 1'b1;
	//------------------------
            valid_reg     <= 1'b0;
            req_vec_reg   <= WIDTH'(0);
            counter       <= WIDTH'(0);
            or_result_reg <= (WIDTH-1)'(0);
        end else begin
            if (valid && done_reg) begin
                valid_reg     <= valid;
                req_vec_reg   <= req_vec;
                or_result_reg <= (WIDTH-1)'(0);

                //done_reg      <= 1'b1;
		done_reg      <= 1'b0; // this should be set to 0 or else it will mess up in case the valid signal is asserted for more than one clock signal
            end

            if(valid_reg) begin
                if (counter < (WIDTH-1)) begin
                    or_result_reg <= or_result_reg || req_vec_reg[counter];
                    counter <= counter + WIDTH'(1);
                end else if (counter == (WIDTH-1)) begin
                    out_reg <= req_vec_reg[(WIDTH-1)] && or_result_reg;
                    done_reg <= 1'b1;
		// counter needs to be reset or else it won't be ready for the next computation
		    counter <= 0;
                end
                if (counter == (WIDTH-1)) begin
                    valid_reg <= 1'b0;
                end else begin
                    out_reg  <= 1'b0;
                    done_reg <= 1'b0;
                end
            end else begin
                out_reg <= 1'b0;
            end
        end
    end

    assign out = out_reg;
    assign done = done_reg;

endmodule
