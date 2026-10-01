`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Design Name: jtag_top
// Module Name: tb_jtag_fault.v
// Description: EXTEST - day tot, stuck-at-0, stuck-at-1 va phuc hoi.
// Chon tb_jtag_fault lam Simulation Top, Run All.
// Xem: tck, instruction, y, a, tdo, fault_detected.
// Loi tren duong noi mo phong Y0 -> A0, khong phai loi ben trong core.
// fault_detected chi duoc cap nhat khi doc bit A0 qua TDO.
////////////////////////////////////////////////////////////////////////////////
module tb_jtag_fault;
    // Inputs
    reg tck, tms, tdi, trst_n;
    reg [3:0] b;
    reg sel;
    wire [3:0] a;

    // Outputs
    wire [3:0] y;
    wire tdo;
    wire [2:0] instruction;

    // Mot bien ket qua: 1 = bit nhan qua TDO khac bit phat Y0.
    reg fault_detected;

    // Chi noi Y0 -> A0 khi EXTEST, tranh vong phan hoi o functional mode.
    assign a = (instruction == 3'b000) ? {3'b000, y[0]} : 4'b0000;

    jtag_top uut (
        .tck(tck), .tms(tms), .tdi(tdi), .trst_n(trst_n),
        .a(a), .b(b), .sel(sel), .y(y), .tdo(tdo),
        .instruction(instruction),
        .extest_mode(), .intest_mode(),
        .capture_ir(), .shift_ir(), .update_ir(),
        .capture_dr(), .shift_dr(), .update_dr(),
        .test_logic_reset()
    );

    initial begin
        tck=0;
        forever #10 tck=~tck;
    end

    initial begin
        tms=1; tdi=0; trst_n=0;
        b=0; sel=0; fault_detected=0;
        #25; trst_n=1;
        #100; // Reset bang TMS trong 5 chu ky.
        tms=0; tdi=0; #20; // Reset -> Idle
        
        // PRELOAD = 010: nap Y0=1 vao BSR.
        tms=1; tdi=0; #20; // Select-DR
        tms=1; tdi=0; #20; // Select-IR
        tms=0; tdi=0; #20; // Capture-IR
        tms=0; tdi=0; #20; // Shift-IR
        tms=0; tdi=0; #20; // IR bit 0
        tms=0; tdi=1; #20; // IR bit 1
        tms=1; tdi=0; #20; // IR bit 2
        tms=1; tdi=0; #20; // Update-IR
        tms=0; tdi=0; #20; // Idle
        
        // Nap 13'h0200: Y=1, SEL=0, B=0, A=0.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #20; // DR bit 0, LSB truoc
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=0; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=0; #20; // DR bit 4, LSB truoc
        tms=0; tdi=0; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=1; #20; // DR bit 9, LSB truoc
        tms=0; tdi=0; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=0; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        
        // EXTEST = 000: Y=1; duong day tot thi A0=1.
        tms=1; tdi=0; #20; // Select-DR
        tms=1; tdi=0; #20; // Select-IR
        tms=0; tdi=0; #20; // Capture-IR
        tms=0; tdi=0; #20; // Shift-IR
        tms=0; tdi=0; #20; // IR bit 0
        tms=0; tdi=0; #20; // IR bit 1
        tms=1; tdi=0; #20; // IR bit 2
        tms=1; tdi=0; #20; // Update-IR
        tms=0; tdi=0; #20; // Idle
        
        // 1. DAY TOT, PHAT 1.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #2;
        // TDO dau tien la A0; Y0 chua doi ke tu Capture.
        fault_detected = (tdo !== y[0]);
        $display("1. DAY TOT, PHAT 1. fault_detected=%b (expected 0)", fault_detected);
        #18;
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=0; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=0; #20; // DR bit 4, LSB truoc
        tms=0; tdi=0; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=1; #20; // DR bit 9, LSB truoc
        tms=0; tdi=0; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=0; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        
        // Bom loi tren dau nhan duong day; khong ep TDO hay fault_detected.
        force a[0]=1'b0;
        
        // 2. STUCK-AT-0: Y0=1, A0=0.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #2;
        // TDO dau tien la A0; Y0 chua doi ke tu Capture.
        fault_detected = (tdo !== y[0]);
        $display("2. STUCK-AT-0: Y0=1, A0=0. fault_detected=%b (expected 1)", fault_detected);
        #18;
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=0; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=0; #20; // DR bit 4, LSB truoc
        tms=0; tdi=0; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=1; #20; // DR bit 9, LSB truoc
        tms=0; tdi=0; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=0; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        release a[0]; // Bo loi: net A0 theo lai Y0.
        
        // 3. PHUC HOI SAU STUCK-AT-0.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #2;
        // TDO dau tien la A0; Y0 chua doi ke tu Capture.
        fault_detected = (tdo !== y[0]);
        $display("3. PHUC HOI SAU STUCK-AT-0. fault_detected=%b (expected 0)", fault_detected);
        #18;
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=0; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=0; #20; // DR bit 4, LSB truoc
        tms=0; tdi=0; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=1; #20; // DR bit 9, LSB truoc
        tms=0; tdi=0; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=0; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        
        // Chuan bi phat 0: Update BSR de Y=0.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #20; // DR bit 0, LSB truoc
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=0; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=0; #20; // DR bit 4, LSB truoc
        tms=0; tdi=0; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=0; #20; // DR bit 9, LSB truoc
        tms=0; tdi=0; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=0; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        
        // 4. DAY TOT, PHAT 0.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #2;
        // TDO dau tien la A0; Y0 chua doi ke tu Capture.
        fault_detected = (tdo !== y[0]);
        $display("4. DAY TOT, PHAT 0. fault_detected=%b (expected 0)", fault_detected);
        #18;
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=0; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=0; #20; // DR bit 4, LSB truoc
        tms=0; tdi=0; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=0; #20; // DR bit 9, LSB truoc
        tms=0; tdi=0; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=0; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        force a[0]=1'b1;
        
        // 5. STUCK-AT-1: Y0=0, A0=1.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #2;
        // TDO dau tien la A0; Y0 chua doi ke tu Capture.
        fault_detected = (tdo !== y[0]);
        $display("5. STUCK-AT-1: Y0=0, A0=1. fault_detected=%b (expected 1)", fault_detected);
        #18;
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=0; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=0; #20; // DR bit 4, LSB truoc
        tms=0; tdi=0; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=0; #20; // DR bit 9, LSB truoc
        tms=0; tdi=0; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=0; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        release a[0]; // Bo loi: net A0 theo lai Y0.
        
        // 6. PHUC HOI SAU STUCK-AT-1.
        tms=1; tdi=0; #20; // Select-DR
        tms=0; tdi=0; #20; // Capture-DR
        tms=0; tdi=0; #20; // Shift-DR
        tms=0; tdi=0; #2;
        // TDO dau tien la A0; Y0 chua doi ke tu Capture.
        fault_detected = (tdo !== y[0]);
        $display("6. PHUC HOI SAU STUCK-AT-1. fault_detected=%b (expected 0)", fault_detected);
        #18;
        tms=0; tdi=0; #20; // DR bit 1, LSB truoc
        tms=0; tdi=0; #20; // DR bit 2, LSB truoc
        tms=0; tdi=0; #20; // DR bit 3, LSB truoc
        tms=0; tdi=0; #20; // DR bit 4, LSB truoc
        tms=0; tdi=0; #20; // DR bit 5, LSB truoc
        tms=0; tdi=0; #20; // DR bit 6, LSB truoc
        tms=0; tdi=0; #20; // DR bit 7, LSB truoc
        tms=0; tdi=0; #20; // DR bit 8, LSB truoc
        tms=0; tdi=0; #20; // DR bit 9, LSB truoc
        tms=0; tdi=0; #20; // DR bit 10, LSB truoc
        tms=0; tdi=0; #20; // DR bit 11, LSB truoc
        tms=1; tdi=0; #20; // DR bit 12, LSB truoc
        tms=1; tdi=0; #20; // Update-DR
        tms=0; tdi=0; #20; // Idle
        #40;
        $finish;
    end
endmodule

// Thoi diem cap nhat ket qua mong doi (ns):
// 967: 1. DAY TOT, PHAT 1. -> fault_detected=0
// 1367: 2. STUCK-AT-0: Y0=1, A0=0. -> fault_detected=1
// 1767: 3. PHUC HOI SAU STUCK-AT-0. -> fault_detected=0
// 2567: 4. DAY TOT, PHAT 0. -> fault_detected=0
// 2967: 5. STUCK-AT-1: Y0=0, A0=1. -> fault_detected=1
// 3367: 6. PHUC HOI SAU STUCK-AT-1. -> fault_detected=0
// Ket thuc: 3705 ns. Cac moc nay tinh theo stimulus, chua phai log ISim.
