
module stream_upsize #(
  parameter T_DATA_WIDTH = 8,
  parameter T_DATA_RATIO = 2
) (
  input  logic                    clk                        , // Clock
  input  logic                    rst_n                      , // Asynchronous reset active low
  /*------------------------------------------------------------------------------
  --  slave interface
  ------------------------------------------------------------------------------*/
  input  logic [T_DATA_WIDTH-1:0] s_data_i                   ,
  input  logic                    s_last_i                   ,
  input  logic                    s_valid_i                  ,
  output logic                    s_ready_o                  ,
  /*------------------------------------------------------------------------------
  --  master interface
  ------------------------------------------------------------------------------*/
  output logic [T_DATA_WIDTH-1:0] m_data_o [T_DATA_RATIO-1:0],
  output logic [T_DATA_RATIO-1:0] m_keep_o                   ,
  output logic                    m_last_o                   ,
  output logic                    m_valid_o                  ,
  input  logic                    m_ready_i
);

/***********************Input Fifo*******************************/
typedef struct packed
{
  logic [  T_DATA_WIDTH:0] data_out    ;
  logic                    valid_out   ;
  logic                    ready_out   ;
  logic                    last_out    ;
  logic [T_DATA_WIDTH-1:0] payload_data;
} axis;
axis fifo;

ff_fifo_wrapped_in_valid_ready #(
  .width(T_DATA_WIDTH + 1),
  .depth(1024            )
) uut_ff_fifo_wrapped_in_valid_ready (
  .clk       (clk                ),
  .rst       (~rst_n             ),
  .up_valid  (s_valid_i          ),
  .up_ready  (s_ready_o          ),
  .up_data   ({s_data_i,s_last_i}),
  .down_valid(fifo.valid_out     ),
  .down_ready(fifo.ready_out     ),
  .down_data (fifo.data_out      )
);
assign fifo.last_out     = fifo.data_out[0];
assign fifo.payload_data = fifo.data_out[T_DATA_WIDTH:1];
/******************************************************************/

logic [T_DATA_RATIO-1:0] pointer    ;
logic                    write      ;
logic                    read       ;
logic                    full_bank  ;
logic                    end_pointer;
logic [T_DATA_RATIO-1:0] keep_r     ;

assign write          = fifo.valid_out & !full_bank;
assign read           = full_bank & m_ready_i;
assign end_pointer    = (pointer == T_DATA_RATIO-1);
assign fifo.ready_out = !full_bank;
assign m_valid_o      = full_bank;

/**********************Pointer logic*******************************/
  always_ff @(posedge clk or negedge rst_n) begin : proc_pointer
    if( ~rst_n ) begin
      pointer <= 1'b0;
    end else if ( write ) begin
      if ( end_pointer | fifo.last_out ) pointer <= '0;
      else                   pointer <= pointer + 1'b1;
    end
  end

/**********************Tkeep logic*********************************/
  always_ff @(posedge clk or negedge rst_n) begin : proc_keep_r
    if( ~rst_n ) begin
      keep_r <= { {T_DATA_RATIO-1{1'b0}}, 1'b1 };
    end else if ( write ) begin
      if ( end_pointer | fifo.last_out ) keep_r <= { {T_DATA_RATIO-1{1'b0}}, 1'b1   };
      else                               keep_r <= {keep_r[T_DATA_RATIO-1-1:0], 1'b1};
    end
  end

/**********************Flag full size*****************************/
  always_ff @(posedge clk or negedge rst_n) begin : proc_full_bank
    if( ~rst_n ) begin
      full_bank <= 1'b0;
    end else begin
      if (write & (end_pointer | fifo.last_out) & !read) full_bank <= 1'b1;
      else if (read)                                     full_bank <= 1'b0;
    end
  end

/***************************Out data*****************************/
  always_ff @(posedge clk or negedge rst_n) begin : proc_m_data_o
    if( ~rst_n ) begin
      for (int i=0; i<=T_DATA_RATIO-1; i++) begin
        m_data_o[i] <= '0;
      end
    end else if (write) begin
      m_data_o[pointer] <= fifo.payload_data;
    end
  end

/**********************Out registers******************************/
always_ff @( posedge clk ) if (end_pointer | (fifo.last_out & fifo.ready_out)) m_keep_o <= keep_r;
always_ff @( posedge clk ) if (!read) m_last_o <= fifo.last_out;


endmodule
