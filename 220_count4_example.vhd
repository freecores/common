--------------------------------------------------------------------------
-- Copyright (c) 1996 Altera Corporation, all right reserved
--
-- This VHDL file may be copied and/or distributed at no cost as long as
-- this copyright notice is retained.
--
------------------------------------------------------------------
-- Four-bit Loadable Up-Down Counter with synchronous set, load and clear
------------------------------------------------------------------
-- Version 1.0   Date 05/20/96
------------------------------------------------------------------
--
library IEEE;
use IEEE.std_logic_1164.all;
use work.lpm_components.all;

entity COUNT4 is
     port (DATA : in std_logic_vector(3 downto 0);
           CLOCK : in std_logic;
           CLK_EN : in std_logic;
           CNT_EN : in std_logic;
           UPDOWN : in std_logic;
           SLOAD : in std_logic;
           SSET : in std_logic;
           SCLR : in std_logic;
           ALOAD : in std_logic;
           ASET : in std_logic;
           ACLR : in std_logic;
           EQ : in std_logic;
           Q : out std_logic_vector(3 downto 0));
end COUNT4;

architecture LPM of COUNT4 is

begin

  U1: LPM_COUNTER 
      generic map (LPM_WIDTH => 4)
      port map (DATA => DATA, CLOCK => CLOCK, CLK_EN => CLK_EN, 
                CNT_EN => CNT_EN, UPDOWN => UPDOWN, SLOAD => SLOAD,
                SSET => SSET, SCLR => SCLR, ALOAD => ALOAD, ASET => ASET,
                ACLR => ACLR, Q => Q);
end;
                
