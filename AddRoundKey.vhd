library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AddRoundKey is
    Port ( state_in  : in  STD_LOGIC_VECTOR(127 downto 0);
           round_key : in  STD_LOGIC_VECTOR(127 downto 0);
           state_out : out STD_LOGIC_VECTOR(127 downto 0));
end AddRoundKey;

architecture Behavioral of AddRoundKey is
begin
    -- Implement the AddRoundKey transformation: simple XOR
    state_out <= state_in xor round_key;

end Behavioral;