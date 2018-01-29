# Things to do

## Handle Class
Purpose of the handle class is to select the adapter and the address map. 2 use cases  

1. Always select the adapter inside the agent using get_name(). Upto user to keep the name unique.  

```
   virtual function int is_correct_adapter();
       return -1; // If this is ignored
       return 0 ; // If not selected
       return 1`; // If selected
   endfunction
```

2. Iterate over all the adapters in the node. Say search for background adapter which happens
   to be the last one in the list. if not found then go back and select the sidedoor else just
   select the front door.  

## Adapter
## convert data in adapter to uvm_hdl_data_t HDL_MAX_WIDTH

## Locking
