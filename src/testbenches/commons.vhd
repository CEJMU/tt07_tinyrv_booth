-- Package commons.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package commons is
  constant period     : time := 20 ns;
  -- To prevent rounding errors, just to be sure
  constant half_period: time := 10 ns;
  constant sclk_period: time := 30 ns;

  -- Outputting values to the console
  function slv_to_hexstring(x: std_logic_vector) return string;
  function slv_to_decstring(vec: std_logic_vector) return string;
  function slv_to_bit(x: std_logic_vector) return string;
end package;

package body commons is
  function slv_to_hexstring(x: std_logic_vector) return string is
    type hex_lut is array (0 to 15) of character;
    constant hextable  : hex_lut :=
      ('0', '1', '2', '3', '4', '5', '6', '7',
      '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
    constant str_len   : natural :=(x'length+3)/4;
    variable temp      : integer;
    variable inva      : boolean;
    variable ret_string: string(str_len downto 1);
    variable x2        : std_logic_vector(x'length-1 downto 0);
  begin
    x2   := to_X01Z(x);
    temp := 0;
    inva := false;
    for j in 0 to x'length-1 loop
      if x2(j)='1' then
        temp := temp + 2**(j mod 4);
      elsif x2(j)/='0' then
        inva := true;
      end if;
      if (j mod 4)=3 or j=x'length-1 then
        if inva
        then ret_string(j/4+1):= 'X';
        else ret_string(j/4+1):= hextable(temp);
        end if;
        temp := 0;
        inva := false;
      end if;
    end loop;
    return ret_string;
  end slv_to_hexstring;

  function slv_to_decstring(vec: std_logic_vector) return string is
    --variable res : string (1 to vec'length);
  begin
    return integer'image(to_integer(signed(vec)));
  end slv_to_decstring;

  function slv_to_bit(x: std_logic_vector) return string is
    variable res : string (x'length downto 1);
  begin
    for i in 1 to x'length loop
      res(i) := std_logic'image(x(i-1))(2);
    end loop;
    return res;
  end slv_to_bit;

end commons;
