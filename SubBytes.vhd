library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SubBytes is
    Port ( state_in  : in  STD_LOGIC_VECTOR(127 downto 0);
           state_out : out STD_LOGIC_VECTOR(127 downto 0));
end SubBytes;

architecture Behavioral of SubBytes is
begin
    -- TEMPORARY: Implement a simple combinational operation (bitwise NOT)
    -- This is NOT the AES S-box, but it forces Vivado to synthesize logic for SubBytes.
    -- If this resolves the multi-driven net error, then the problem was with the passthrough.
    state_out <= state_in;

end Behavioral;