class fifo #(parameter drvrs = 4, parameter pckg_sz = 16);
    bit push;
    bit pop;
    bit pndng_bus;
    bit pndng_monitor;
    bit [pckg_sz-1:0] data_out_monitor;
    bit [pckg_sz-1:0] data_out_bus;
    bit [pckg_sz-1:0] queue_in [$:drvrs];
    bit [pckg_sz-1:0] queue_out [$:drvrs];
    bit id;
    
    
    function new (input int identification);
        this.push           = 0;
        this.pop            = 0;
        this.pndng_bus      = 0;
        this.pndng_monitor  = 0;
        this.data_out       = 0;
        this.id             = identification;
    endfunction
    
    function void receive_from_driver (input bit [pckg_sz-1:0] data_driver);
        if (this.push)
            queue_in.push_front(data_driver);
    endfunction
    
    function void send_to_monitor ();
        if (this.pop)
            data_out_monitor = queue_out.pop_back();
        
        if (queue_out.size() != 0)
            pndng_monitor = 1;
        else
            pndng_monitor = 0;
    endfunction
    
    
    function void receive_from_bus (input bit [pckg_sz-1:0] data_bus);
        if (this.push)
            queue_out.push_front(data_bus);
    endfunction
    
    function void send_to_bus ();
        if (this.pop)
            data_out_bus = queue_in.pop_back();
        
        if (queue_in.size() != 0)
            pndng_bus = 1;
        else
            pndng_bus = 0;
    endfunction
    
    function print(input string tag);
        $display("[%g] %s push=%b, pop=%b, pending=%b, data_out=%h, queue=%p, id=%d, size=%d",
            $time,
            tag,
            this.push,
            this.pop,
            this.pndng,
            this.data_out,
            this.queue,
            this.id,
            this.queue.size());
    endfunction
        
endclass
