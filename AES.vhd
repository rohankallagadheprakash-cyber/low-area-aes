library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Recommended for arithmetic operations

-- AES Top Module
entity AES is
    Port ( clk             : in  STD_LOGIC;
           reset           : in  STD_LOGIC;
           data_in         : in  STD_LOGIC_VECTOR(127 downto 0);
           key_in          : in  STD_LOGIC_VECTOR(127 downto 0);
           encrypted_data  : out STD_LOGIC_VECTOR(127 downto 0);
           start           : in  STD_LOGIC;
           done            : out STD_LOGIC);
end AES;

architecture Behavioral of AES is

    -- State machine states
    type FSM_STATE is (IDLE, LOAD_DATA, ROUND0_ADD_KEY, ROUND_NORMAL_PROCESS, FINAL_ROUND_PROCESS, DONE_STATE);
    signal current_state : FSM_STATE := IDLE;

    -- Internal registered signals
    signal current_aes_state : STD_LOGIC_VECTOR(127 downto 0); -- The main state register
    signal round_counter_reg : INTEGER range 0 to 10 := 0; -- Current round number (0 to 10)
    signal done_internal     : STD_LOGIC := '0';
    signal encrypted_data_reg : STD_LOGIC_VECTOR(127 downto 0); -- Internal register for final output

    -- Combinational outputs of the inlined AES transformations
    signal sbox_out_comb   : STD_LOGIC_VECTOR(127 downto 0);
    signal shift_out_comb  : STD_LOGIC_VECTOR(127 downto 0);
    signal mixcol_out_comb : STD_LOGIC_VECTOR(127 downto 0);
    -- add_round_key_out_comb is no longer needed as a separate signal, its logic is directly inlined

    -- Signal to hold the current round key from KeyExpansion
    signal current_round_key : STD_LOGIC_VECTOR(127 downto 0);

    -- This signal is the COMBINATIONAL input to the current_aes_state register
    signal next_aes_state_reg_input : STD_LOGIC_VECTOR(127 downto 0);

    -- Component declaration for KeyExpansion (only remaining external component)
    component KeyExpansion is
        Port ( clk          : in  STD_LOGIC;
               reset        : in  STD_LOGIC;
               initial_key  : in  STD_LOGIC_VECTOR(127 downto 0);
               start_key_gen: in  STD_LOGIC;
               round_num    : in  INTEGER range 0 to 10;
               round_key_out: out STD_LOGIC_VECTOR(127 downto 0);
               key_gen_done : out STD_LOGIC);
    end component;

    -- Helper functions for inlined logic (S-box, GF(2^8) multiply)
    -- These functions must be defined here.

    -- S-box function (placeholder - slight modification to ensure logic)
    function SBOX_LOOKUP_INLINED(byte_in : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
    begin
        -- THIS IS STILL A PLACEHOLDER. Replace with the actual AES S-BOX for real functionality.
        -- Adding a simple XOR to ensure some logic is inferred, not just a wire/NOT.
        return byte_in xor X"5A"; -- Example: XOR with a constant (different from 0xAA to vary logic)
    end function;

    -- GF(2^8) multiplication by 0x02 (xtime) - placeholder
    function MULTIPLY_BY_02_INLINED(a : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
    begin
        -- THIS IS STILL A PLACEHOLDER. Replace with actual GF(2^8) multiplication.
        -- A simple XOR to ensure some logic is inferred.
        return a xor X"A5"; -- Example: XOR with a constant
    end function;

    -- GF(2^8) multiplication by 0x03 - placeholder
    function MULTIPLY_BY_03_INLINED(a : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
    begin
        -- THIS IS STILL A PLACEHOLDER. Replace with actual GF(2^8) multiplication.
        -- A simple XOR to ensure some logic is inferred.
        return a xor X"55"; -- Example: XOR with a constant
    end function;

begin

    -- INLINED SubBytes Logic
    -- This is a concurrent assignment, always active.
    sbox_out_comb(7 downto 0)     <= SBOX_LOOKUP_INLINED(current_aes_state(7 downto 0));
    sbox_out_comb(15 downto 8)    <= SBOX_LOOKUP_INLINED(current_aes_state(15 downto 8));
    sbox_out_comb(23 downto 16)   <= SBOX_LOOKUP_INLINED(current_aes_state(23 downto 16));
    sbox_out_comb(31 downto 24)   <= SBOX_LOOKUP_INLINED(current_aes_state(31 downto 24));
    sbox_out_comb(39 downto 32)   <= SBOX_LOOKUP_INLINED(current_aes_state(39 downto 32));
    sbox_out_comb(47 downto 40)   <= SBOX_LOOKUP_INLINED(current_aes_state(47 downto 40));
    sbox_out_comb(55 downto 48)   <= SBOX_LOOKUP_INLINED(current_aes_state(55 downto 48));
    sbox_out_comb(63 downto 56)   <= SBOX_LOOKUP_INLINED(current_aes_state(63 downto 56));
    sbox_out_comb(71 downto 64)   <= SBOX_LOOKUP_INLINED(current_aes_state(71 downto 64));
    sbox_out_comb(79 downto 72)   <= SBOX_LOOKUP_INLINED(current_aes_state(79 downto 72));
    sbox_out_comb(87 downto 80)   <= SBOX_LOOKUP_INLINED(current_aes_state(87 downto 80));
    sbox_out_comb(95 downto 88)   <= SBOX_LOOKUP_INLINED(current_aes_state(95 downto 88));
    sbox_out_comb(103 downto 96)  <= SBOX_LOOKUP_INLINED(current_aes_state(103 downto 96));
    sbox_out_comb(111 downto 104) <= SBOX_LOOKUP_INLINED(current_aes_state(111 downto 104));
    sbox_out_comb(119 downto 112) <= SBOX_LOOKUP_INLINED(current_aes_state(119 downto 112));
    sbox_out_comb(127 downto 120) <= SBOX_LOOKUP_INLINED(current_aes_state(127 downto 120));


    -- INLINED ShiftRows Logic
    -- This is a concurrent assignment, always active.
    shift_out_comb(7 downto 0)   <= sbox_out_comb(7 downto 0);
    shift_out_comb(15 downto 8)  <= sbox_out_comb(15 downto 8);
    shift_out_comb(23 downto 16) <= sbox_out_comb(23 downto 16);
    shift_out_comb(31 downto 24) <= sbox_out_comb(31 downto 24);

    -- Row 1 (1-byte left shift)
    shift_out_comb(39 downto 32) <= sbox_out_comb(47 downto 40);
    shift_out_comb(47 downto 40) <= sbox_out_comb(55 downto 48);
    shift_out_comb(55 downto 48) <= sbox_out_comb(63 downto 56);
    shift_out_comb(63 downto 56) <= sbox_out_comb(39 downto 32);

    -- Row 2 (2-byte left shift)
    shift_out_comb(71 downto 64)  <= sbox_out_comb(87 downto 80);
    shift_out_comb(79 downto 72)  <= sbox_out_comb(95 downto 88);
    shift_out_comb(87 downto 80)  <= sbox_out_comb(71 downto 64);
    shift_out_comb(119 downto 112) <= sbox_out_comb(55 downto 48);

    -- Row 3 (3-byte left shift)
    shift_out_comb(103 downto 96)  <= sbox_out_comb(119 downto 112);
    shift_out_comb(111 downto 104) <= sbox_out_comb(127 downto 120);
    shift_out_comb(119 downto 112) <= sbox_out_comb(103 downto 96);
    shift_out_comb(127 downto 120) <= sbox_out_comb(111 downto 104);


    -- INLINED MixColumns Logic
    -- This is a placeholder. YOU MUST REPLACE THIS WITH THE ACTUAL MIXCOLUMNS LOGIC.
    -- For now, a simple passthrough to ensure logic is synthesized.
    mixcol_out_comb <= shift_out_comb xor X"55AA55AA55AA55AA55AA55AA55AA55AA";



    -- Instantiate KeyExpansion (only remaining external component)
    U_KeyExpansion : KeyExpansion
        Port map(clk           => clk,
                 reset         => reset,
                 initial_key   => key_in,
                 start_key_gen => start,
                 round_num     => round_counter_reg,
                 round_key_out => current_round_key,
                 key_gen_done  => open);

    -- Combinational logic to determine the 'next_aes_state_reg_input' for the 'current_aes_state' register.
    -- This is the crucial multiplexer that selects the data to be registered.
    -- It must cover all possible paths for 'current_aes_state' to be updated.
    process(current_state, round_counter_reg, data_in, current_aes_state, mixcol_out_comb, shift_out_comb, current_round_key)
    begin
        -- Default assignment: ensures all paths are covered.
        -- This is the value that will be loaded into current_aes_state_reg if no other condition is met.
        next_aes_state_reg_input <= current_aes_state; -- Hold current state by default

        case current_state is
            when IDLE =>
                next_aes_state_reg_input <= current_aes_state; -- Explicitly hold state in IDLE

            when LOAD_DATA =>
                next_aes_state_reg_input <= data_in; -- Load initial plaintext

            when ROUND0_ADD_KEY =>
                -- Initial AddRoundKey (Round 0) - INLINED
                next_aes_state_reg_input <= current_aes_state xor current_round_key;

            when ROUND_NORMAL_PROCESS =>
                -- Rounds 1 to 9 (with MixColumns) - INLINED AddRoundKey
                -- Data flows: current_aes_state -> Inlined_SubBytes -> Inlined_ShiftRows -> Inlined_MixColumns -> XOR with Round Key
                next_aes_state_reg_input <= mixcol_out_comb xor current_round_key;

            when FINAL_ROUND_PROCESS =>
                -- Final Round (Round 10, no MixColumns) - INLINED AddRoundKey
                -- Data flows: current_aes_state -> Inlined_SubBytes -> Inlined_ShiftRows -> XOR with Round Key
                next_aes_state_reg_input <= shift_out_comb xor current_round_key;

            when DONE_STATE =>
                next_aes_state_reg_input <= current_aes_state; -- Hold final encrypted data

            when others =>
                next_aes_state_reg_input <= (others => '0'); -- Safety default, should not be reached
        end case;
    end process;


    -- Main FSM and Registered Data Path Control Process
    -- This process ONLY updates registers (state, counter, done, output)
    process(clk, reset)
    begin
        if reset = '1' then
            current_state      <= IDLE;
            current_aes_state  <= (others => '0');
            round_counter_reg  <= 0;
            done_internal      <= '0';
            encrypted_data_reg <= (others => '0');
        elsif rising_edge(clk) then
            done_internal <= '0'; -- Clear done flag each cycle unless explicitly set

            case current_state is
                when IDLE =>
                    if start = '1' then
                        current_state     <= LOAD_DATA;
                        round_counter_reg <= 0; -- Ensure KeyExpansion gets Round 0 key
                    end if;

                when LOAD_DATA =>
                    current_aes_state <= next_aes_state_reg_input; -- Load data_in (from combinational mux)
                    current_state     <= ROUND0_ADD_KEY;

                when ROUND0_ADD_KEY =>
                    current_aes_state <= next_aes_state_reg_input; -- Load result of initial AddRoundKey
                    round_counter_reg <= 1; -- Prepare for Round 1
                    current_state     <= ROUND_NORMAL_PROCESS;

                when ROUND_NORMAL_PROCESS =>
                    current_aes_state <= next_aes_state_reg_input; -- Load result of current round (MixColumns included)
                    round_counter_reg <= round_counter_reg + 1;
                    if round_counter_reg = 9 then -- After Round 9, move to final round
                        current_state <= FINAL_ROUND_PROCESS;
                    end if;

                when FINAL_ROUND_PROCESS =>
                    current_aes_state <= next_aes_state_reg_input; -- Load result of final round (no MixColumns)
                    current_state     <= DONE_STATE;
                    encrypted_data_reg <= next_aes_state_reg_input; -- Capture final result into output register

                when DONE_STATE =>
                    done_internal      <= '1'; -- Assert done signal
                    encrypted_data_reg <= current_aes_state; -- Ensure output holds final value
                    if start = '0' then -- Wait for start to go low to reset
                        current_state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

    -- Assign the output ports from their internal registered signals
    done           <= done_internal;
    encrypted_data <= encrypted_data_reg;

end Behavioral;