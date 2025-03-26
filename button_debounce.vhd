library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity button_debounce is
    port ( 
    clk : in STD_LOGIC;
    btn_in : in STD_LOGIC;
    btn_out : out STD_LOGIC
    );
end button_debounce;

architecture Behavioral of button_debounce is
    
    signal ff : STD_LOGIC_VECTOR(2 downto 0);
begin

    flip_flop : process(clk) is
    begin
        if rising_edge(clk) then
            ff(0) <= btn_in;
            ff(1) <= ff(0);
            ff(2) <= ff(1);
        end if;
    end process flip_flop;

    btn_out <= ff(2);

end Behavioral;
