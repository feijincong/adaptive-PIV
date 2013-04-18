
import ClientServer::*;
import FIFO::*;
import GetPut::*;
import DefaultValue::*;
import SceMi::*;
import Clocks::*;
import ResetXactor::*;

import PIVTypes::*;
import PIV::*;

typedef PIV DutInterface;
typedef Data ToHost;
typedef Addr FromHost;

(* synthesize *)
module [Module] mkDutWrapper (DutInterface);
    let m <- mkPIV();
    return m;
endmodule

module [SceMiModule] mkSceMiLayer();

    SceMiClockConfiguration conf = defaultValue;

    SceMiClockPortIfc clk_port <- mkSceMiClockPort(conf);
    DutInterface dut <- buildDutWithSoftReset(mkDutWrapper, clk_port);

    Empty dispget <- mkDispXactor(dut, clk_port);
    Empty windowreq <- mkWindowReqXactor(dut, clk_port);
    Empty imstore <- mkStoreXactor(dut, clk_port);
    Empty imclear <- mkClearXactor(dut, clk_port);
    Empty imdone <- mkDoneLoadingXactor(dut, clk_port);

    Empty shutdown <- mkShutdownXactor();
endmodule

module [SceMiModule] mkDispXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Get#(Displacements) resp = interface Get;
        method ActionValue#(Displacements) get = piv.get_displacements();
    endinterface;

    Empty get <- mkGetXactor(resp, clk_port);
endmodule

module [SceMiModule] mkWindowReqXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(WindowReq) req = interface Put;
        method Action put(WindowReq x) = piv.put_window_req(x);
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule

module [SceMiModule] mkStoreXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(ImagePacket) req = interface Put;
        method Action put(ImagePacket x) = piv.store_image(x);
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule

module [SceMiModule] mkClearXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(ClearT) req = interface Put;
        method Action put(ClearT x) = piv.clear_image();
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule

module [SceMiModule] mkDoneLoadingXactor#(PIV piv, SceMiClockPortIfc clk_port ) (Empty);

    Put#(ClearT) req = interface Put;
        method Action put(ClearT x) = piv.done_loading();
    endinterface;

    Empty put <- mkPutXactor(req, clk_port);
endmodule
