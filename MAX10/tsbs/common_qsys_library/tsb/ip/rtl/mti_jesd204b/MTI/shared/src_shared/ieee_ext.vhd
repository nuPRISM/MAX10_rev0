library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

package ieee_ext is

  constant RESET_ACTIVE : std_logic := '1';

  type int_array is array(integer range <>) of integer;

  type array2 is array(integer range <>) of std_logic_vector(1 downto 0);
  type array3 is array(integer range <>) of std_logic_vector(2 downto 0);
  type array4 is array(integer range <>) of std_logic_vector(3 downto 0);
  type array5 is array(integer range <>) of std_logic_vector(4 downto 0);
  type array6 is array(integer range <>) of std_logic_vector(5 downto 0);
  type array7 is array(integer range <>) of std_logic_vector(6 downto 0);
  type array8 is array(integer range <>) of std_logic_vector(7 downto 0);
  type array10 is array(integer range <>) of std_logic_vector(9 downto 0);
  type array11 is array(integer range <>) of std_logic_vector(10 downto 0);
  type array12 is array(integer range <>) of std_logic_vector(11 downto 0);
  type array13 is array(integer range <>) of std_logic_vector(12 downto 0);
  type array16 is array(integer range <>) of std_logic_vector(15 downto 0);
  type array20 is array(integer range <>) of std_logic_vector(19 downto 0);
  type array23 is array(integer range <>) of std_logic_vector(22 downto 0);
  type array24 is array(integer range <>) of std_logic_vector(23 downto 0);
  type array32 is array(integer range <>) of std_logic_vector(31 downto 0);
  type array33 is array(integer range <>) of std_logic_vector(32 downto 0);
  type array34 is array(integer range <>) of std_logic_vector(33 downto 0);
  type array40 is array(integer range <>) of std_logic_vector(39 downto 0);
  type array48 is array(integer range <>) of std_logic_vector(47 downto 0);
  type array80 is array(integer range <>) of std_logic_vector(79 downto 0);

  function "="(L: std_logic_vector; R: std_logic_vector) return std_logic;

  function "/="(L: std_logic_vector; R: std_logic_vector) return std_logic;

  function ">"(L: std_logic_vector; R: std_logic_vector) return std_logic;

  function "<"(L: std_logic_vector; R: std_logic_vector) return std_logic;

  function ">="(L: std_logic_vector; R: std_logic_vector) return std_logic;

  function "<="(L: std_logic_vector; R: std_logic_vector) return std_logic;

  function ">"(L: unsigned; R: unsigned) return std_logic;

  function "<"(L: unsigned; R: unsigned) return std_logic;

  function ">="(L: unsigned; R: unsigned) return std_logic;

  function "<="(L: unsigned; R: unsigned) return std_logic;

  function and_all(V: in std_logic_vector) return std_logic;

  function and_all(V: in std_logic_vector; X: std_logic) return std_logic_vector;

  function or_all(V: in std_logic_vector) return std_logic;

  function or_all(V: in std_logic_vector; X: std_logic) return std_logic_vector;

  function xor_all(V: in std_logic_vector) return std_logic;

  function xor_all(V: in std_logic_vector; X: std_logic) return std_logic_vector;
  
  function cond_expr(c: boolean; t, f: integer) return integer;

  function cond_expr(c: boolean; t, f: std_logic) return std_logic;

  function cond_expr(c: boolean; t, f: std_logic_vector) return std_logic_vector;

  function cond_expr(c: boolean; t, f: string) return string;

  function max_of(x, y: integer) return integer;

  function max_of(x, y, z: integer) return integer;

  function min_of(x, y: integer) return integer;

  function count_ones( x: std_logic_vector; w: integer ) return std_logic_vector;

  function unsigned_expand( x : std_logic_vector; w:integer) return std_logic_vector;

  function signed_expand( x : std_logic_vector; w:integer) return std_logic_vector;

  function unsigned_shift_left( x : std_logic_vector; w:integer) return std_logic_vector;

  function unsigned_shift_right( x : std_logic_vector; w:integer) return std_logic_vector;

  function log2(x : natural) return natural;

  function log2_ceil(x : natural) return natural;

end ieee_ext;


package body ieee_ext is

  function "="(L: std_logic_vector; R: std_logic_vector) return std_logic is
  begin
    if L = R then
      return '1';
    else
      return '0';
    end if;
  end;

  function "/="(L: std_logic_vector; R: std_logic_vector) return std_logic is
  begin
    if L /= R then
      return '1';
    else
      return '0';
    end if;
  end;

  function ">="(L: std_logic_vector; R: std_logic_vector) return std_logic is
  begin
    if L >= R then
      return '1';
    else
      return '0';
    end if;
  end;

  function ">"(L: std_logic_vector; R: std_logic_vector) return std_logic is
  begin
    if L > R then
      return '1';
    else
      return '0';
    end if;
  end;

  function "<"(L: std_logic_vector; R: std_logic_vector) return std_logic is
  begin
    if L < R then
      return '1';
    else
      return '0';
    end if;
  end;

  function "<="(L: std_logic_vector; R: std_logic_vector) return std_logic is
  begin
    if L <= R then
      return '1';
    else
      return '0';
    end if;
  end;

  function ">="(L: unsigned; R: unsigned) return std_logic is
  begin
    if L >= R then
      return '1';
    else
      return '0';
    end if;
  end;

  function ">"(L: unsigned; R: unsigned) return std_logic is
  begin
    if L > R then
      return '1';
    else
      return '0';
    end if;
  end;

  function "<"(L: unsigned; R: unsigned) return std_logic is
  begin
    if L < R then
      return '1';
    else
      return '0';
    end if;
  end;

  function "<="(L: unsigned; R: unsigned) return std_logic is
  begin
    if L <= R then
      return '1';
    else
      return '0';
    end if;
  end;

  function and_all(V: in std_logic_vector) return std_logic is
    variable Q: std_logic;
  begin
    Q := '1';
    for i in V'range loop
      Q := Q and V(i);
    end loop;
    return Q;
  end;
  
  function and_all(V: in std_logic_vector; X: std_logic) return std_logic_vector is
    variable Q: std_logic_vector(V'range);
  begin
    for i in V'range loop
      Q(i) := V(i) and X;
    end loop;
    return Q;
  end;

  function or_all(V: in std_logic_vector) return std_logic is
    variable Q: std_logic;
  begin
    Q := '0';
    for i in V'range loop
      Q := Q or V(i);
    end loop;
    return Q;
  end;

  function or_all(V: in std_logic_vector; X: std_logic) return std_logic_vector is
    variable Q: std_logic_vector(V'range);
  begin
    for i in V'range loop
      Q(i) := V(i) or X;
    end loop;
    return Q;
  end;
    
  function xor_all(V: in std_logic_vector) return std_logic is
    variable Q: std_logic;
  begin
    Q := '0';
    for i in V'range loop
      Q := V(i) xor Q;
    end loop;
    return Q;
  end;

  function xor_all(V: in std_logic_vector; X: std_logic) return std_logic_vector is
    variable Q: std_logic_vector(V'range);
  begin
    for i in V'range loop
      Q(i) := V(i) xor X;
    end loop;
    return Q;
  end;

  function cond_expr(c: boolean; t, f: integer) return integer is
  begin
    if c then
      return t;
    else
      return f;
    end if;
  end function;

  function cond_expr(c: boolean; t, f: std_logic) return std_logic is
  begin
    if c then
      return t;
    else
      return f;
    end if;
  end function;

  function cond_expr(c: boolean; t, f: std_logic_vector) return std_logic_vector is
  begin
    if c then
      return t;
    else
      return f;
    end if;
  end function;

  function cond_expr(c: boolean; t, f: string) return string is
  begin
    if c then
      return t;
    else
      return f;
    end if;
  end function;

                    
  function max_of(x, y: integer) return integer is
  begin
    if (x > y) then
      return x;
    else
      return y;
    end if;
  end function;

  function max_of(x, y, z: integer) return integer is
  begin
    if (x >= y) and (y >= z) then
      return x;
    elsif (y >= z) and (z >= x ) then 
      return y;
    else
      return z;
    end if;
  end function;
  
  function min_of(x, y: integer) return integer is
  begin
    if (x < y) then
      return x;
    else
      return y;
    end if;
  end function;
 
  function count_ones( x : std_logic_vector;
                       w : integer) return std_logic_vector is
    variable q : std_logic_vector(w-1 downto 0);
  begin
    q := (others => '0');
    for i in x'range loop
      q := q + x(i);
    end loop;
    return q;
  end function;
  
  function unsigned_expand( x : std_logic_vector; w:integer) return std_logic_vector is
    variable xx : std_logic_vector(x'length-1 downto 0);
    variable q : std_logic_vector(w-1 downto 0);
  begin
    xx := x;
--    for i in xx'range loop
--      q(i) := xx(i);
--    end loop;
--    for i in w-1 downto xx'high+1 loop
--      q(i) := '0';
--    end loop;
    for i in w-1 downto 0 loop      
      if i <= xx'high then
        q(i) := xx(i);
      else
        q(i) := '0';
      end if;
    end loop;
    return q;
  end function;

  function signed_expand( x : std_logic_vector; w:integer) return std_logic_vector is
    variable xx : std_logic_vector(x'length-1 downto 0);
    variable q : std_logic_vector(w-1 downto 0);
  begin
    xx := x;
    for i in xx'range loop
      q(i) := xx(i);
    end loop;
    for i in w-1 downto xx'high+1 loop
      q(i) := xx(xx'high);
    end loop;
    return q;
  end function;

  function unsigned_shift_left( x : std_logic_vector; w:integer) return std_logic_vector is
    variable q : std_logic_vector(x'range);
  begin
    q := (others => '0');
    for i in x'high downto x'low+w loop
      q(i) := x(i-w);
    end loop;
    return q;
  end function;

  function unsigned_shift_right( x : std_logic_vector; w:integer) return std_logic_vector is
    variable q : std_logic_vector(x'range);
  begin
    q := (others => '0');
    for i in x'high-w downto x'low loop
      q(i) := x(i+w);
    end loop;
    return q;
  end function;

  function log2(x : natural) return natural is
  begin
    return integer(Log2(real(x)));
  end;

  function log2_ceil(x : natural) return natural is
  begin
    return integer(Ceil(Log2(real(x))));
  end;

end ieee_ext;
