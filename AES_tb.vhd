library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL; -- For printing to console

entity AES_tb is
-- No ports for a testbench
end AES_tb;

architecture Behavioral of AES_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component AES is
        Port ( clk             : in  STD_LOGIC;
               reset           : in  STD_LOGIC;
               data_in         : in  STD_LOGIC_VECTOR(127 downto 0);
               key_in          : in  STD_LOGIC_VECTOR(127 downto 0);
               encrypted_data  : out STD_LOGIC_VECTOR(127 downto 0);
               start           : in  STD_LOGIC;
               done            : out STD_LOGIC);
    end component;

    -- Constants for clock generation
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock

    -- Signals for UUT ports
    signal tb_clk            : STD_LOGIC := '0';
    signal tb_reset          : STD_LOGIC := '1'; -- Start in reset
    signal tb_data_in        : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal tb_key_in         : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal tb_encrypted_data : STD_LOGIC_VECTOR(127 downto 0);
    signal tb_start          : STD_LOGIC := '0';
    signal tb_done           : STD_LOGIC;

    -- Test Vectors (NIST AES-128 example)
    constant TEST_PLAINTEXT  : STD_LOGIC_VECTOR(127 downto 0) := X"00112233445566778899AABBCCDDEEFF";
    constant TEST_KEY        : STD_LOGIC_VECTOR(127 downto 0) := X"000102030405060708090A0B0C0D0E0F";
    constant EXPECTED_CIPHERTEXT : STD_LOGIC_VECTOR(127 downto 0) := X"69C4E0D86A7B0430D8CDB78070B4C55A";

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT : AES
        Port map (
            clk            => tb_clk,
            reset          => tb_reset,
            data_in        => tb_data_in,
            key_in         => tb_key_in,
            encrypted_data => tb_encrypted_data,
            start          => tb_start,
            done           => tb_done
        );

    -- Clock generation process
    clk_gen : process
    begin
        loop
            tb_clk <= '0';
            wait for CLK_PERIOD / 2;
            tb_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test sequence process
    test_sequence : process
        variable L : LINE; -- For TEXTIO output

        -- Helper function to convert STD_LOGIC_VECTOR to hex string for reporting
        -- This function is now correctly placed inside the process.
        function HEX_IMAGE (slv_in : STD_LOGIC_VECTOR) return STRING is
            variable hex_str : STRING(1 to slv_in'length / 4);
            variable char_val : CHARACTER;
        begin
            for i in 0 to (slv_in'length / 4) - 1 loop
                case slv_in(i*4+3 downto i*4) is
                    when "0000" => char_val := '0';
                    when "0001" => char_val := '1';
                    when "0010" => char_val := '2';
                    when "0011" => char_val := '3';
                    when "0100" => char_val := '4';
                    when "0101" => char_val := '5';
                    when "0110" => char_val := '6';
                    when "0111" => char_val := '7';
                    when "1000" => char_val := '8';
                    when "1001" => char_val := '9';
                    when "1010" => char_val := 'A';
                    when "1011" => char_val := 'B';
                    when "1100" => char_val := 'C';
                    when "1101" => char_val := 'D';
                    when "1110" => char_val := 'E';
                    when "1111" => char_val := 'F';
                    when others => char_val := 'X'; -- Error or uninitialized
                end case;
                hex_str(i+1) := char_val;
            end loop;
            return hex_str;
        end function;

    begin -- Start of test_sequence process body
        -- 1. Apply initial reset
        tb_reset <= '1';
        tb_start <= '0';
        tb_data_in <= (others => '0');
        tb_key_in <= (others => '0');
        wait for CLK_PERIOD * 2; -- Hold reset for a few clock cycles

        -- 2. Release reset
        tb_reset <= '0';
        wait for CLK_PERIOD; -- Wait one cycle after reset release

        -- 3. Apply test vector and start encryption
        report "--- Starting AES Encryption Test ---";
        tb_data_in <= TEST_PLAINTEXT;
        tb_key_in  <= TEST_KEY;
        tb_start   <= '1';
        wait for CLK_PERIOD; -- Wait one cycle for FSM to load data

        -- 4. Wait for encryption to complete (done signal)
        report "Waiting for 'done' signal...";
        wait until tb_done = '1';
        report "Encryption Done!";

        -- 5. Check the encrypted output
        wait for CLK_PERIOD; -- Wait one more cycle to ensure stable output

        if tb_encrypted_data = EXPECTED_CIPHERTEXT then
            report "Test PASSED: Encrypted data matches expected ciphertext." severity NOTE;
            write(L, STRING'("Encrypted Data: "));
            write(L, HEX_IMAGE(tb_encrypted_data));
            writeline(OUTPUT, L);
        else
            report "Test FAILED: Encrypted data does NOT match expected ciphertext." severity ERROR;
            write(L, STRING'("Expected: "));
            write(L, HEX_IMAGE(EXPECTED_CIPHERTEXT));
            writeline(OUTPUT, L);
            write(L, STRING'("Got:      "));
            write(L, HEX_IMAGE(tb_encrypted_data));
            writeline(OUTPUT, L);
        end if;

        -- 6. De-assert start to reset the AES module for potential next test
        tb_start <= '0';
        wait for CLK_PERIOD * 2; -- Allow FSM to return to IDLE

        report "--- Test Finished ---" severity NOTE;

        -- End simulation
        wait; -- Will wait indefinitely, stopping the simulation

    end process;

end Behavioral;