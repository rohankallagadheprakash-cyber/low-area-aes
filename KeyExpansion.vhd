library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- For unsigned to integer conversion

entity KeyExpansion is
    Port ( clk          : in  STD_LOGIC;
           reset        : in  STD_LOGIC;
           initial_key  : in  STD_LOGIC_VECTOR(127 downto 0);
           start_key_gen: in  STD_LOGIC;
           round_num    : in  INTEGER range 0 to 10;
           round_key_out: out STD_LOGIC_VECTOR(127 downto 0);
           key_gen_done : out STD_LOGIC);
end KeyExpansion;

architecture Behavioral of KeyExpansion is

    -- Internal storage for all round keys (11 keys * 128 bits each)
    type KEY_ARRAY is array (0 to 10) of STD_LOGIC_VECTOR(127 downto 0);
    signal expanded_keys : KEY_ARRAY := (others => (others => '0'));
    signal key_expansion_state : INTEGER range 0 to 11 := 0; -- State for iterative key generation

    -- Placeholder S-box function (same as in SubBytes, for SubWord)
    function SBOX_LOOKUP_KE(byte_in : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
    begin
        return byte_in; -- TEMPORARY: REPLACE WITH ACTUAL AES S-BOX
    end function;

    -- Placeholder RotWord function
    function RotWord(word : STD_LOGIC_VECTOR(31 downto 0)) return STD_LOGIC_VECTOR is
    begin
        return word; -- TEMPORARY: REPLACE WITH ACTUAL ROTWORD
    end function;

    -- Placeholder SubWord function
    function SubWord(word : STD_LOGIC_VECTOR(31 downto 0)) return STD_LOGIC_VECTOR is
    begin
        return word; -- TEMPORARY: REPLACE WITH ACTUAL SUBWORD USING SBOX_LOOKUP_KE
    end function;

    -- Placeholder Rcon values (Round Constants)
    constant RCON_VALUES : STD_LOGIC_VECTOR(319 downto 0) := (
        X"01000000" & X"02000000" & X"04000000" & X"08000000" &
        X"10000000" & X"20000000" & X"40000000" & X"80000000" &
        X"1B000000" & X"36000000"
    ); -- Rcon[1] to Rcon[10], each 32 bits (only first byte non-zero)

begin

    process(clk, reset)
        -- Variables for word calculations
        variable w0, w1, w2, w3 : STD_LOGIC_VECTOR(31 downto 0);
        variable temp_g_func    : STD_LOGIC_VECTOR(31 downto 0);
        variable rcon_val_var   : STD_LOGIC_VECTOR(31 downto 0);
        variable new_round_key  : STD_LOGIC_VECTOR(127 downto 0);
    begin
        if reset = '1' then
            expanded_keys       <= (others => (others => '0'));
            key_expansion_state <= 0;
            key_gen_done        <= '0';
        elsif rising_edge(clk) then
            key_gen_done <= '0'; -- Clear done flag

            case key_expansion_state is
                when 0 => -- IDLE state, waiting for start
                    if start_key_gen = '1' then
                        expanded_keys(0) <= initial_key; -- Store the initial key
                        key_expansion_state <= 1; -- Move to generate Round 1 key
                    end if;

                when 1 to 10 => -- Generate keys for Round 1 to Round 10
                    -- This is where the actual key expansion logic goes.
                    -- For now, a placeholder that just copies the previous key (WRONG FOR AES!)
                    -- YOU MUST IMPLEMENT THE REAL AES KEY SCHEDULE HERE.

                    -- Example of how it would conceptually work (simplified, not full AES logic):
                    -- Extract the previous round key words
                    w0 := expanded_keys(key_expansion_state - 1)(31 downto 0);
                    w1 := expanded_keys(key_expansion_state - 1)(63 downto 32);
                    w2 := expanded_keys(key_expansion_state - 1)(95 downto 64);
                    w3 := expanded_keys(key_expansion_state - 1)(127 downto 96);

                    -- Apply g-function (RotWord, SubWord, XOR with Rcon) to w3
                    temp_g_func := SubWord(RotWord(w3));
                    if key_expansion_state <= 10 then -- Rcon only up to Rcon[10]
                        rcon_val_var := RCON_VALUES(key_expansion_state*32 - 1 downto (key_expansion_state-1)*32);
                    else
                        rcon_val_var := (others => '0'); -- Should not happen if range is correct
                    end if;
                    temp_g_func := temp_g_func xor rcon_val_var;

                    -- Generate the new round key words
                    new_round_key(31 downto 0)   := w0 xor temp_g_func;
                    new_round_key(63 downto 32)   := w1 xor new_round_key(31 downto 0); -- Note: Uses newly generated word
                    new_round_key(95 downto 64)   := w2 xor new_round_key(63 downto 32);
                    new_round_key(127 downto 96)  := w3 xor new_round_key(95 downto 64);

                    expanded_keys(key_expansion_state) <= new_round_key;

                    key_expansion_state <= key_expansion_state + 1;

                when 11 => -- All keys generated (key_expansion_state 0 to 10)
                    key_gen_done <= '1';
                    if start_key_gen = '0' then -- Wait for start to go low to reset
                        key_expansion_state <= 0;
                    end if;

                when others =>
                    key_expansion_state <= 0; -- Should not happen
            end case;
        end if;
    end process;

    -- Output the requested round key based on 'round_num'
    round_key_out <= expanded_keys(round_num);

end Behavioral;