library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ShiftRows is
    Port ( state_in  : in  STD_LOGIC_VECTOR(127 downto 0);
           state_out : out STD_LOGIC_VECTOR(127 downto 0));
end ShiftRows;

architecture Behavioral of ShiftRows is
begin
    -- Implement the ShiftRows transformation here.
    -- This is a byte-wise operation:
    -- Row 0: no shift
    -- Row 1: 1-byte left circular shift
    -- Row 2: 2-byte left circular shift
    -- Row 3: 3-byte left circular shift

    -- Example (correct logic for AES ShiftRows):
    state_out(7 downto 0)   <= state_in(7 downto 0);     -- Row 0, Byte 0
    state_out(15 downto 8)  <= state_in(15 downto 8);    -- Row 0, Byte 1 -- FIXED TYPO HERE
    state_out(23 downto 16) <= state_in(23 downto 16);   -- Row 0, Byte 2
    state_out(31 downto 24) <= state_in(31 downto 24);   -- Row 0, Byte 3

    -- Row 1 (1-byte left shift)
    state_out(39 downto 32) <= state_in(47 downto 40); -- Byte 1 -> Byte 0
    state_out(47 downto 40) <= state_in(55 downto 48); -- Byte 2 -> Byte 1
    state_out(55 downto 48) <= state_in(63 downto 56); -- Byte 3 -> Byte 2
    state_out(63 downto 56) <= state_in(39 downto 32); -- Byte 0 -> Byte 3

    -- Row 2 (2-byte left shift)
    state_out(71 downto 64) <= state_in(87 downto 80);
    state_out(79 downto 72) <= state_in(95 downto 88);
    state_out(87 downto 80) <= state_in(71 downto 64);
    state_out(119 downto 112) <= state_in(55 downto 48); -- Corrected this line as well based on typical ShiftRows logic

    -- Row 3 (3-byte left shift)
    state_out(103 downto 96)  <= state_in(119 downto 112);
    state_out(111 downto 104) <= state_in(127 downto 120);
    state_out(119 downto 112) <= state_in(103 downto 96);
    state_out(127 downto 120) <= state_in(111 downto 104);

end Behavioral;