//------------------------------------------------------------------------------
// Class: jelly_bean_types
//------------------------------------------------------------------------------

class jelly_bean_types;
   typedef enum bit[2:0] { NO_FLAVOR, APPLE, BLUEBERRY, BUBBLE_GUM, CHOCOLATE }
                flavor_e;
   typedef enum bit[1:0] { NO_COLOR, RED, GREEN, BLUE } color_e;
   typedef enum bit[1:0] { NO_TASTE, YUMMY, YUCKY } taste_e;
   typedef enum bit[1:0] { NO_OP = 0, READ = 1, WRITE = 2 } command_e;
endclass: jelly_bean_types


